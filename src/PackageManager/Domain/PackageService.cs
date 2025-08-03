using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace PORTX.PackageManager.Domain
{
    /// <summary>
    /// Core business logic for package management operations.
    /// Contains NO infrastructure dependencies - pure domain logic.
    /// Follows ARCHITECT principle: Business logic separate from infrastructure.
    /// </summary>
    public class PackageService
    {
        private readonly IPackageRepository _packageRepository;
        private readonly IInstalledPackageRepository _installedPackageRepository;
        private readonly DependencyResolver _dependencyResolver;

        public PackageService(
            IPackageRepository packageRepository,
            IInstalledPackageRepository installedPackageRepository,
            DependencyResolver dependencyResolver)
        {
            _packageRepository = packageRepository ?? throw new ArgumentNullException(nameof(packageRepository));
            _installedPackageRepository = installedPackageRepository ?? throw new ArgumentNullException(nameof(installedPackageRepository));
            _dependencyResolver = dependencyResolver ?? throw new ArgumentNullException(nameof(dependencyResolver));
        }

        /// <summary>
        /// Business logic: Resolve package and dependencies for installation
        /// </summary>
        public async Task<InstallationPlan> PlanInstallationAsync(
            string packageName, 
            VersionConstraint versionConstraint = null,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(packageName))
                throw new ArgumentException("Package name cannot be empty", nameof(packageName));

            // Business rule: Find the package that matches constraints
            var package = await _packageRepository.FindPackageAsync(packageName, versionConstraint, cancellationToken);
            if (package == null)
                throw new PackageNotFoundException(packageName, versionConstraint?.ToString());

            // Business rule: Check if already installed
            var isInstalled = await _installedPackageRepository.IsInstalledAsync(package.Id, cancellationToken);
            if (isInstalled)
            {
                var installedPackage = await _installedPackageRepository.GetInstalledPackageAsync(package.Id, cancellationToken);
                if (installedPackage.Package.Version >= package.Version)
                    throw new PackageAlreadyInstalledException(package.Id);
            }

            // Business rule: Resolve dependencies
            var allInstalledPackages = await _installedPackageRepository.GetInstalledPackagesAsync(cancellationToken);
            var dependencyPlan = await _dependencyResolver.ResolveAsync(
                package, 
                allInstalledPackages.Select(ip => ip.Package),
                cancellationToken);

            return new InstallationPlan(package, dependencyPlan);
        }

        /// <summary>
        /// Business logic: Plan package removal with dependency checking
        /// </summary>
        public async Task<RemovalPlan> PlanRemovalAsync(
            PackageId packageId,
            bool force = false,
            CancellationToken cancellationToken = default)
        {
            // Business rule: Package must be installed to remove
            var installedPackage = await _installedPackageRepository.GetInstalledPackageAsync(packageId, cancellationToken);
            if (installedPackage == null)
                throw new PackageNotInstalledException(packageId);

            // Business rule: Check for dependent packages
            var allInstalled = await _installedPackageRepository.GetInstalledPackagesAsync(cancellationToken);
            var dependentPackages = FindDependentPackages(installedPackage.Package, allInstalled);

            if (dependentPackages.Any() && !force)
            {
                throw new PackageHasDependentsException(packageId, dependentPackages.Select(p => p.Package.Id));
            }

            return new RemovalPlan(installedPackage, dependentPackages, force);
        }

        /// <summary>
        /// Business logic: Find packages that need updates
        /// </summary>
        public async Task<IEnumerable<UpdateCandidate>> FindUpdatesAsync(CancellationToken cancellationToken = default)
        {
            var installedPackages = await _installedPackageRepository.GetInstalledPackagesAsync(cancellationToken);
            var updateCandidates = new List<UpdateCandidate>();

            foreach (var installedPackage in installedPackages)
            {
                // Business rule: Check for newer versions
                var availableVersions = await _packageRepository.GetAvailableVersionsAsync(
                    installedPackage.Package.Name, 
                    cancellationToken);

                var newerVersions = availableVersions
                    .Where(v => v > installedPackage.Package.Version)
                    .OrderByDescending(v => v);

                if (newerVersions.Any())
                {
                    var latestVersion = newerVersions.First();
                    var latestPackage = await _packageRepository.GetPackageAsync(
                        new PackageId(installedPackage.Package.Name, latestVersion),
                        cancellationToken);

                    if (latestPackage != null)
                    {
                        updateCandidates.Add(new UpdateCandidate(installedPackage, latestPackage));
                    }
                }
            }

            return updateCandidates;
        }

        /// <summary>
        /// Business logic: Search packages with intelligent ranking
        /// </summary>
        public async Task<IEnumerable<PackageSearchResult>> SearchPackagesAsync(
            string query,
            string category = null,
            int maxResults = 50,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(query))
                throw new ArgumentException("Search query cannot be empty", nameof(query));

            // Get packages by search query
            var packages = await _packageRepository.SearchAsync(query, maxResults * 2, cancellationToken);

            // Filter by category if specified
            if (!string.IsNullOrWhiteSpace(category))
            {
                packages = packages.Where(p => 
                    string.Equals(p.Category, category, StringComparison.OrdinalIgnoreCase));
            }

            // Business rule: Rank search results by relevance
            var results = packages.Select(package => new PackageSearchResult(
                package,
                CalculateRelevanceScore(package, query)
            )).OrderByDescending(r => r.RelevanceScore)
              .Take(maxResults);

            return results;
        }

        /// <summary>
        /// Business logic: Validate package health and integrity
        /// </summary>
        public async Task<PackageHealthReport> CheckPackageHealthAsync(
            PackageId packageId,
            CancellationToken cancellationToken = default)
        {
            var installedPackage = await _installedPackageRepository.GetInstalledPackageAsync(packageId, cancellationToken);
            if (installedPackage == null)
                return new PackageHealthReport(packageId, PackageHealthStatus.NotInstalled);

            // Business rule: Check installation integrity
            var issues = new List<string>();

            if (!installedPackage.IsHealthy())
            {
                issues.Add("Package files are missing or corrupted");
            }

            // Business rule: Check for available updates
            var availableVersions = await _packageRepository.GetAvailableVersionsAsync(
                packageId.Name, 
                cancellationToken);
            var hasUpdates = availableVersions.Any(v => v > packageId.Version);

            var status = issues.Any() ? PackageHealthStatus.Corrupted :
                        hasUpdates ? PackageHealthStatus.UpdateAvailable :
                        PackageHealthStatus.Healthy;

            return new PackageHealthReport(packageId, status, issues, hasUpdates);
        }

        /// <summary>
        /// Business logic: Calculate search relevance score
        /// </summary>
        private static double CalculateRelevanceScore(Package package, string query)
        {
            query = query.ToLowerInvariant();
            var name = package.Name.ToLowerInvariant();
            var description = package.Description.ToLowerInvariant();

            double score = 0;

            // Exact name match gets highest score
            if (name == query) score += 100;
            else if (name.StartsWith(query)) score += 80;
            else if (name.Contains(query)) score += 60;

            // Description match
            if (description.Contains(query)) score += 30;

            // Category relevance
            if (package.Category.ToLowerInvariant().Contains(query)) score += 20;

            // Bonus for popular packages (could be based on download stats)
            // score += Math.Log10(package.Statistics?.DownloadCount ?? 1);

            return score;
        }

        /// <summary>
        /// Business logic: Find packages that depend on the given package
        /// </summary>
        private static List<InstalledPackage> FindDependentPackages(
            Package package, 
            IEnumerable<InstalledPackage> installedPackages)
        {
            return installedPackages
                .Where(installed => installed.Package.Dependencies
                    .Any(dep => dep.Name == package.Name))
                .ToList();
        }
    }

    #region Value Objects and Exceptions

    /// <summary>
    /// Value object representing an installation plan
    /// </summary>
    public class InstallationPlan
    {
        public Package TargetPackage { get; }
        public IReadOnlyList<Package> Dependencies { get; }
        public long TotalDownloadSize { get; }
        public long EstimatedInstallSize { get; }

        public InstallationPlan(Package targetPackage, IEnumerable<Package> dependencies)
        {
            TargetPackage = targetPackage ?? throw new ArgumentNullException(nameof(targetPackage));
            Dependencies = (dependencies?.ToList() ?? new List<Package>()).AsReadOnly();
            
            var allPackages = new List<Package> { targetPackage };
            allPackages.AddRange(Dependencies);
            
            TotalDownloadSize = allPackages.Sum(p => p.Metadata.DownloadSize);
            EstimatedInstallSize = allPackages.Sum(p => p.EstimateInstallationSize());
        }
    }

    /// <summary>
    /// Value object representing a removal plan
    /// </summary>
    public class RemovalPlan
    {
        public InstalledPackage TargetPackage { get; }
        public IReadOnlyList<InstalledPackage> DependentPackages { get; }
        public bool Force { get; }

        public RemovalPlan(
            InstalledPackage targetPackage, 
            IEnumerable<InstalledPackage> dependentPackages, 
            bool force)
        {
            TargetPackage = targetPackage ?? throw new ArgumentNullException(nameof(targetPackage));
            DependentPackages = (dependentPackages?.ToList() ?? new List<InstalledPackage>()).AsReadOnly();
            Force = force;
        }
    }

    /// <summary>
    /// Value object representing an update candidate
    /// </summary>
    public class UpdateCandidate
    {
        public InstalledPackage CurrentPackage { get; }
        public Package AvailableUpdate { get; }

        public UpdateCandidate(InstalledPackage currentPackage, Package availableUpdate)
        {
            CurrentPackage = currentPackage ?? throw new ArgumentNullException(nameof(currentPackage));
            AvailableUpdate = availableUpdate ?? throw new ArgumentNullException(nameof(availableUpdate));
        }
    }

    /// <summary>
    /// Value object for search results with relevance scoring
    /// </summary>
    public class PackageSearchResult
    {
        public Package Package { get; }
        public double RelevanceScore { get; }

        public PackageSearchResult(Package package, double relevanceScore)
        {
            Package = package ?? throw new ArgumentNullException(nameof(package));
            RelevanceScore = relevanceScore;
        }
    }

    /// <summary>
    /// Value object for package health reports
    /// </summary>
    public class PackageHealthReport
    {
        public PackageId PackageId { get; }
        public PackageHealthStatus Status { get; }
        public IReadOnlyList<string> Issues { get; }
        public bool HasUpdatesAvailable { get; }

        public PackageHealthReport(
            PackageId packageId, 
            PackageHealthStatus status, 
            IEnumerable<string> issues = null,
            bool hasUpdatesAvailable = false)
        {
            PackageId = packageId ?? throw new ArgumentNullException(nameof(packageId));
            Status = status;
            Issues = (issues?.ToList() ?? new List<string>()).AsReadOnly();
            HasUpdatesAvailable = hasUpdatesAvailable;
        }
    }

    public enum PackageHealthStatus
    {
        Healthy,
        UpdateAvailable,
        Corrupted,
        NotInstalled
    }

    #endregion

    #region Domain Exceptions

    public class PackageNotFoundException : Exception
    {
        public string PackageName { get; }
        public string VersionConstraint { get; }

        public PackageNotFoundException(string packageName, string versionConstraint = null)
            : base($"Package '{packageName}' not found" + 
                   (versionConstraint != null ? $" with constraint '{versionConstraint}'" : ""))
        {
            PackageName = packageName;
            VersionConstraint = versionConstraint;
        }
    }

    public class PackageAlreadyInstalledException : Exception
    {
        public PackageId PackageId { get; }

        public PackageAlreadyInstalledException(PackageId packageId)
            : base($"Package '{packageId}' is already installed")
        {
            PackageId = packageId;
        }
    }

    public class PackageNotInstalledException : Exception
    {
        public PackageId PackageId { get; }

        public PackageNotInstalledException(PackageId packageId)
            : base($"Package '{packageId}' is not installed")
        {
            PackageId = packageId;
        }
    }

    public class PackageHasDependentsException : Exception
    {
        public PackageId PackageId { get; }
        public IEnumerable<PackageId> DependentPackages { get; }

        public PackageHasDependentsException(PackageId packageId, IEnumerable<PackageId> dependentPackages)
            : base($"Package '{packageId}' cannot be removed because other packages depend on it: " +
                   string.Join(", ", dependentPackages.Select(p => p.ToString())))
        {
            PackageId = packageId;
            DependentPackages = dependentPackages;
        }
    }

    #endregion
}