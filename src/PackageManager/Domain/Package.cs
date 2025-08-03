using System;
using System.Collections.Generic;
using System.Linq;

namespace PORTX.PackageManager.Domain
{
    /// <summary>
    /// Core domain entity representing a PORTX package.
    /// Contains business rules and validation logic.
    /// </summary>
    public class Package
    {
        public PackageId Id { get; }
        public string Name { get; }
        public Version Version { get; }
        public string Description { get; }
        public string Category { get; }
        public Uri SourceUrl { get; }
        public string Checksum { get; }
        public HashAlgorithm ChecksumAlgorithm { get; }
        public IReadOnlyList<string> Executables { get; }
        public IReadOnlyList<PackageDependency> Dependencies { get; }
        public PackageMetadata Metadata { get; }
        public DateTime CreatedAt { get; }
        
        public Package(
            string name,
            Version version,
            string description,
            string category,
            Uri sourceUrl,
            string checksum,
            HashAlgorithm checksumAlgorithm,
            IEnumerable<string> executables,
            IEnumerable<PackageDependency> dependencies = null,
            PackageMetadata metadata = null)
        {
            if (string.IsNullOrWhiteSpace(name))
                throw new ArgumentException("Package name cannot be empty", nameof(name));
            
            if (string.IsNullOrWhiteSpace(description))
                throw new ArgumentException("Package description cannot be empty", nameof(description));
            
            if (sourceUrl == null)
                throw new ArgumentNullException(nameof(sourceUrl));
            
            if (string.IsNullOrWhiteSpace(checksum))
                throw new ArgumentException("Package checksum is required", nameof(checksum));

            // Business rule: Package names must follow PORTX naming convention
            if (!IsValidPackageName(name))
                throw new ArgumentException($"Invalid package name: {name}. Must contain only lowercase letters, numbers, and hyphens.", nameof(name));

            // Business rule: Executables list cannot be empty for PORTX packages
            var executablesList = executables?.ToList() ?? new List<string>();
            if (!executablesList.Any())
                throw new ArgumentException("Package must contain at least one executable", nameof(executables));

            Id = new PackageId(name, version);
            Name = name;
            Version = version ?? throw new ArgumentNullException(nameof(version));
            Description = description;
            Category = category ?? "tools";
            SourceUrl = sourceUrl;
            Checksum = checksum;
            ChecksumAlgorithm = checksumAlgorithm;
            Executables = executablesList.AsReadOnly();
            Dependencies = (dependencies?.ToList() ?? new List<PackageDependency>()).AsReadOnly();
            Metadata = metadata ?? new PackageMetadata();
            CreatedAt = DateTime.UtcNow;
        }

        /// <summary>
        /// Business rule: Validates PORTX package naming convention
        /// </summary>
        public static bool IsValidPackageName(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return false;

            // PORTX naming convention: lowercase, numbers, hyphens only
            return name.All(c => char.IsLower(c) || char.IsDigit(c) || c == '-') &&
                   name.Length >= 2 &&
                   name.Length <= 50 &&
                   !name.StartsWith("-") &&
                   !name.EndsWith("-");
        }

        /// <summary>
        /// Business rule: Check if package is compatible with current PORTX installation
        /// </summary>
        public bool IsCompatibleWith(PortxEnvironment environment)
        {
            // Business logic for compatibility checking
            return environment.Platform == "windows" && 
                   environment.Architecture == "x64";
        }

        /// <summary>
        /// Business rule: Calculate package installation size estimate
        /// </summary>
        public long EstimateInstallationSize()
        {
            // Simple heuristic based on package metadata
            // More sophisticated calculation could be added based on package analysis
            return Metadata.DownloadSize * 2; // Assume 2x expansion after extraction
        }

        public override bool Equals(object obj)
        {
            return obj is Package other && Id.Equals(other.Id);
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }

        public override string ToString()
        {
            return $"{Name} v{Version}";
        }
    }

    /// <summary>
    /// Value object representing unique package identification
    /// </summary>
    public class PackageId : IEquatable<PackageId>
    {
        public string Name { get; }
        public Version Version { get; }

        public PackageId(string name, Version version)
        {
            Name = name ?? throw new ArgumentNullException(nameof(name));
            Version = version ?? throw new ArgumentNullException(nameof(version));
        }

        public bool Equals(PackageId other)
        {
            if (other == null) return false;
            return Name == other.Name && Version.Equals(other.Version);
        }

        public override bool Equals(object obj)
        {
            return Equals(obj as PackageId);
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Name, Version);
        }

        public override string ToString()
        {
            return $"{Name}@{Version}";
        }
    }

    /// <summary>
    /// Value object representing package dependency
    /// </summary>
    public class PackageDependency
    {
        public string Name { get; }
        public VersionConstraint VersionConstraint { get; }
        public bool IsOptional { get; }

        public PackageDependency(string name, VersionConstraint versionConstraint, bool isOptional = false)
        {
            Name = name ?? throw new ArgumentNullException(nameof(name));
            VersionConstraint = versionConstraint ?? throw new ArgumentNullException(nameof(versionConstraint));
            IsOptional = isOptional;
        }

        public bool IsSatisfiedBy(Package package)
        {
            return package.Name == Name && VersionConstraint.IsSatisfiedBy(package.Version);
        }
    }

    /// <summary>
    /// Value object for package metadata
    /// </summary>
    public class PackageMetadata
    {
        public string Author { get; }
        public string License { get; }
        public Uri HomepageUrl { get; }
        public Uri RepositoryUrl { get; }
        public long DownloadSize { get; }
        public IReadOnlyDictionary<string, string> Tags { get; }

        public PackageMetadata(
            string author = null,
            string license = null,
            Uri homepageUrl = null,
            Uri repositoryUrl = null,
            long downloadSize = 0,
            IDictionary<string, string> tags = null)
        {
            Author = author;
            License = license;
            HomepageUrl = homepageUrl;
            RepositoryUrl = repositoryUrl;
            DownloadSize = Math.Max(0, downloadSize);
            Tags = (tags ?? new Dictionary<string, string>()).ToDictionary(
                kvp => kvp.Key, 
                kvp => kvp.Value
            ).AsReadOnly();
        }
    }

    /// <summary>
    /// Supported hash algorithms for package integrity verification
    /// </summary>
    public enum HashAlgorithm
    {
        SHA256,
        SHA512
    }

    /// <summary>
    /// Environment information for compatibility checking
    /// </summary>
    public class PortxEnvironment
    {
        public string Platform { get; }
        public string Architecture { get; }
        public Version PortxVersion { get; }

        public PortxEnvironment(string platform, string architecture, Version portxVersion)
        {
            Platform = platform ?? throw new ArgumentNullException(nameof(platform));
            Architecture = architecture ?? throw new ArgumentNullException(nameof(architecture));
            PortxVersion = portxVersion ?? throw new ArgumentNullException(nameof(portxVersion));
        }
    }
}