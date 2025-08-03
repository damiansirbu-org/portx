using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace PORTX.PackageManager.Domain
{
    /// <summary>
    /// Domain logic for dependency resolution.
    /// Implements minimal version selection for PORTX packages.
    /// Follows ARCHITECT principle: Simple dependency resolution over complex algorithms.
    /// </summary>
    public class DependencyResolver
    {
        private readonly IPackageRepository _packageRepository;

        public DependencyResolver(IPackageRepository packageRepository)
        {
            _packageRepository = packageRepository ?? throw new ArgumentNullException(nameof(packageRepository));
        }

        /// <summary>
        /// Business logic: Resolve all dependencies for a package
        /// Uses minimal version selection - simple and predictable
        /// </summary>
        public async Task<IEnumerable<Package>> ResolveAsync(
            Package rootPackage,
            IEnumerable<Package> alreadyInstalled,
            CancellationToken cancellationToken = default)
        {
            if (rootPackage == null)
                throw new ArgumentNullException(nameof(rootPackage));

            var installedPackages = (alreadyInstalled ?? Enumerable.Empty<Package>()).ToList();
            var resolvedPackages = new List<Package>();
            var processingQueue = new Queue<Package>();
            var visited = new HashSet<string>(); // Track by package name to avoid cycles

            processingQueue.Enqueue(rootPackage);

            while (processingQueue.Count > 0)
            {
                var currentPackage = processingQueue.Dequeue();

                // Skip if already processed
                if (visited.Contains(currentPackage.Name))
                    continue;

                visited.Add(currentPackage.Name);

                // Process each dependency
                foreach (var dependency in currentPackage.Dependencies)
                {
                    // Skip optional dependencies that aren't installed
                    if (dependency.IsOptional && !IsPackageInstalled(dependency.Name, installedPackages))
                        continue;

                    // Check if dependency is already satisfied by installed packages
                    var installedDep = FindInstalledPackage(dependency.Name, installedPackages);
                    if (installedDep != null && dependency.IsSatisfiedBy(installedDep))
                    {
                        // Already satisfied, no need to install
                        continue;
                    }

                    // Check if dependency is already in resolution list
                    var resolvedDep = resolvedPackages.FirstOrDefault(p => p.Name == dependency.Name);
                    if (resolvedDep != null)
                    {
                        // Business rule: Use minimal version selection
                        // If current resolved version satisfies new constraint, keep it
                        if (dependency.IsSatisfiedBy(resolvedDep))
                            continue;

                        // If new constraint requires higher version, upgrade
                        var newPackage = await FindMinimalVersionAsync(dependency, cancellationToken);
                        if (newPackage == null)
                            throw new DependencyResolutionException(currentPackage.Name, dependency);

                        // Replace with newer version
                        resolvedPackages.Remove(resolvedDep);
                        resolvedPackages.Add(newPackage);
                        
                        // Re-process dependencies of the new version
                        processingQueue.Enqueue(newPackage);
                        continue;
                    }

                    // Find minimal version that satisfies constraint
                    var dependencyPackage = await FindMinimalVersionAsync(dependency, cancellationToken);
                    if (dependencyPackage == null)
                        throw new DependencyResolutionException(currentPackage.Name, dependency);

                    resolvedPackages.Add(dependencyPackage);
                    processingQueue.Enqueue(dependencyPackage);
                }
            }

            // Business rule: Validate no conflicts in final resolution
            ValidateNoConflicts(resolvedPackages, installedPackages);

            return resolvedPackages;
        }

        /// <summary>
        /// Business logic: Find the minimal version that satisfies a dependency constraint
        /// Implements minimal version selection principle
        /// </summary>
        private async Task<Package> FindMinimalVersionAsync(
            PackageDependency dependency,
            CancellationToken cancellationToken)
        {
            var availableVersions = await _packageRepository.GetAvailableVersionsAsync(
                dependency.Name, 
                cancellationToken);

            // Business rule: Find minimal version that satisfies constraint
            var satisfyingVersions = availableVersions
                .Where(v => dependency.VersionConstraint.IsSatisfiedBy(v))
                .OrderBy(v => v); // Minimal version first

            var minimalVersion = satisfyingVersions.FirstOrDefault();
            if (minimalVersion == null)
                return null;

            return await _packageRepository.GetPackageAsync(
                new PackageId(dependency.Name, minimalVersion),
                cancellationToken);
        }

        /// <summary>
        /// Business logic: Check if package is already installed
        /// </summary>
        private static bool IsPackageInstalled(string packageName, IEnumerable<Package> installedPackages)
        {
            return installedPackages.Any(p => p.Name == packageName);
        }

        /// <summary>
        /// Business logic: Find installed package by name
        /// </summary>
        private static Package FindInstalledPackage(string packageName, IEnumerable<Package> installedPackages)
        {
            return installedPackages.FirstOrDefault(p => p.Name == packageName);
        }

        /// <summary>
        /// Business rule: Validate that resolved packages don't conflict
        /// </summary>
        private static void ValidateNoConflicts(
            IEnumerable<Package> resolvedPackages, 
            IEnumerable<Package> installedPackages)
        {
            var allPackages = resolvedPackages.Concat(installedPackages).ToList();
            var packageGroups = allPackages.GroupBy(p => p.Name);

            foreach (var group in packageGroups)
            {
                var versions = group.Select(p => p.Version).Distinct().ToList();
                if (versions.Count > 1)
                {
                    throw new DependencyConflictException(
                        group.Key, 
                        versions, 
                        "Multiple versions of the same package cannot be installed");
                }
            }
        }

        /// <summary>
        /// Business logic: Create dependency graph for visualization/debugging
        /// </summary>
        public async Task<DependencyGraph> BuildDependencyGraphAsync(
            Package rootPackage,
            CancellationToken cancellationToken = default)
        {
            var nodes = new List<DependencyNode>();
            var edges = new List<DependencyEdge>();
            var visited = new HashSet<string>();
            var queue = new Queue<Package>();

            queue.Enqueue(rootPackage);

            while (queue.Count > 0)
            {
                var current = queue.Dequeue();

                if (visited.Contains(current.Name))
                    continue;

                visited.Add(current.Name);
                nodes.Add(new DependencyNode(current.Name, current.Version));

                foreach (var dependency in current.Dependencies)
                {
                    edges.Add(new DependencyEdge(
                        current.Name, 
                        dependency.Name, 
                        dependency.VersionConstraint.ToString(),
                        dependency.IsOptional));

                    // Find the dependency package to continue graph building
                    var depPackage = await FindMinimalVersionAsync(dependency, cancellationToken);
                    if (depPackage != null && !visited.Contains(depPackage.Name))
                    {
                        queue.Enqueue(depPackage);
                    }
                }
            }

            return new DependencyGraph(nodes, edges);
        }
    }

    #region Value Objects

    /// <summary>
    /// Value object representing dependency graph for analysis
    /// </summary>
    public class DependencyGraph
    {
        public IReadOnlyList<DependencyNode> Nodes { get; }
        public IReadOnlyList<DependencyEdge> Edges { get; }

        public DependencyGraph(IEnumerable<DependencyNode> nodes, IEnumerable<DependencyEdge> edges)
        {
            Nodes = (nodes?.ToList() ?? new List<DependencyNode>()).AsReadOnly();
            Edges = (edges?.ToList() ?? new List<DependencyEdge>()).AsReadOnly();
        }

        /// <summary>
        /// Business logic: Check for circular dependencies
        /// </summary>
        public bool HasCircularDependency()
        {
            var graph = Edges.GroupBy(e => e.From)
                            .ToDictionary(g => g.Key, g => g.Select(e => e.To).ToList());

            var visited = new HashSet<string>();
            var recursionStack = new HashSet<string>();

            foreach (var node in Nodes.Select(n => n.PackageName))
            {
                if (HasCircularDependencyDFS(node, graph, visited, recursionStack))
                    return true;
            }

            return false;
        }

        private static bool HasCircularDependencyDFS(
            string node,
            Dictionary<string, List<string>> graph,
            HashSet<string> visited,
            HashSet<string> recursionStack)
        {
            visited.Add(node);
            recursionStack.Add(node);

            if (graph.ContainsKey(node))
            {
                foreach (var neighbor in graph[node])
                {
                    if (!visited.Contains(neighbor))
                    {
                        if (HasCircularDependencyDFS(neighbor, graph, visited, recursionStack))
                            return true;
                    }
                    else if (recursionStack.Contains(neighbor))
                    {
                        return true; // Circular dependency found
                    }
                }
            }

            recursionStack.Remove(node);
            return false;
        }
    }

    /// <summary>
    /// Value object representing a node in dependency graph
    /// </summary>
    public class DependencyNode
    {
        public string PackageName { get; }
        public Version Version { get; }

        public DependencyNode(string packageName, Version version)
        {
            PackageName = packageName ?? throw new ArgumentNullException(nameof(packageName));
            Version = version ?? throw new ArgumentNullException(nameof(version));
        }
    }

    /// <summary>
    /// Value object representing an edge in dependency graph
    /// </summary>
    public class DependencyEdge
    {
        public string From { get; }
        public string To { get; }
        public string VersionConstraint { get; }
        public bool IsOptional { get; }

        public DependencyEdge(string from, string to, string versionConstraint, bool isOptional = false)
        {
            From = from ?? throw new ArgumentNullException(nameof(from));
            To = to ?? throw new ArgumentNullException(nameof(to));
            VersionConstraint = versionConstraint ?? throw new ArgumentNullException(nameof(versionConstraint));
            IsOptional = isOptional;
        }
    }

    #endregion

    #region Domain Exceptions

    /// <summary>
    /// Exception thrown when dependency resolution fails
    /// </summary>
    public class DependencyResolutionException : Exception
    {
        public string PackageName { get; }
        public PackageDependency Dependency { get; }

        public DependencyResolutionException(string packageName, PackageDependency dependency)
            : base($"Cannot resolve dependency '{dependency.Name}' with constraint '{dependency.VersionConstraint}' " +
                   $"required by package '{packageName}'")
        {
            PackageName = packageName;
            Dependency = dependency;
        }
    }

    /// <summary>
    /// Exception thrown when dependency conflicts are detected
    /// </summary>
    public class DependencyConflictException : Exception
    {
        public string PackageName { get; }
        public IEnumerable<Version> ConflictingVersions { get; }

        public DependencyConflictException(string packageName, IEnumerable<Version> conflictingVersions, string message = null)
            : base(message ?? $"Dependency conflict for package '{packageName}': " +
                   $"versions {string.Join(", ", conflictingVersions)} are in conflict")
        {
            PackageName = packageName;
            ConflictingVersions = conflictingVersions;
        }
    }

    #endregion
}