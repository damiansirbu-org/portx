using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace PORTX.PackageManager.Domain
{
    /// <summary>
    /// Domain repository interface - defines business operations without infrastructure concerns.
    /// Follows ARCHITECT principle: Domain boundaries must not leak infrastructure details.
    /// </summary>
    public interface IPackageRepository
    {
        /// <summary>
        /// Retrieve a specific package by its unique identifier
        /// </summary>
        Task<Package> GetPackageAsync(PackageId packageId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Find package by name and optional version constraint
        /// </summary>
        Task<Package> FindPackageAsync(string name, VersionConstraint versionConstraint = null, CancellationToken cancellationToken = default);

        /// <summary>
        /// Search packages by query string
        /// </summary>
        Task<IEnumerable<Package>> SearchAsync(string query, int maxResults = 50, CancellationToken cancellationToken = default);

        /// <summary>
        /// Get all packages in a specific category
        /// </summary>
        Task<IEnumerable<Package>> GetPackagesByCategoryAsync(string category, CancellationToken cancellationToken = default);

        /// <summary>
        /// Get all available packages (for listing operations)
        /// </summary>
        Task<IEnumerable<Package>> GetAllPackagesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Check if a package exists
        /// </summary>
        Task<bool> ExistsAsync(PackageId packageId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Get available versions for a package name
        /// </summary>
        Task<IEnumerable<Version>> GetAvailableVersionsAsync(string packageName, CancellationToken cancellationToken = default);

        /// <summary>
        /// Get package statistics (download counts, etc.)
        /// </summary>
        Task<PackageStatistics> GetStatisticsAsync(PackageId packageId, CancellationToken cancellationToken = default);
    }

    /// <summary>
    /// Repository for managing installed packages on local system
    /// </summary>
    public interface IInstalledPackageRepository
    {
        /// <summary>
        /// Get all locally installed packages
        /// </summary>
        Task<IEnumerable<InstalledPackage>> GetInstalledPackagesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Check if a package is installed
        /// </summary>
        Task<bool> IsInstalledAsync(PackageId packageId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Get specific installed package information
        /// </summary>
        Task<InstalledPackage> GetInstalledPackageAsync(PackageId packageId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Record package installation
        /// </summary>
        Task SaveInstalledPackageAsync(InstalledPackage installedPackage, CancellationToken cancellationToken = default);

        /// <summary>
        /// Remove package installation record
        /// </summary>
        Task RemoveInstalledPackageAsync(PackageId packageId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Update installation record (for updates)
        /// </summary>
        Task UpdateInstalledPackageAsync(InstalledPackage installedPackage, CancellationToken cancellationToken = default);
    }

    /// <summary>
    /// Value object representing installed package information
    /// </summary>
    public class InstalledPackage
    {
        public Package Package { get; }
        public string InstallationPath { get; }
        public DateTime InstalledAt { get; }
        public DateTime? LastUpdated { get; }
        public InstallationStatus Status { get; }
        public IReadOnlyList<string> InstalledFiles { get; }

        public InstalledPackage(
            Package package,
            string installationPath,
            DateTime installedAt,
            InstallationStatus status = InstallationStatus.Installed,
            IEnumerable<string> installedFiles = null,
            DateTime? lastUpdated = null)
        {
            Package = package ?? throw new ArgumentNullException(nameof(package));
            InstallationPath = installationPath ?? throw new ArgumentNullException(nameof(installationPath));
            InstalledAt = installedAt;
            LastUpdated = lastUpdated;
            Status = status;
            InstalledFiles = (installedFiles?.ToList() ?? new List<string>()).AsReadOnly();
        }

        /// <summary>
        /// Business rule: Check if installation is healthy
        /// </summary>
        public bool IsHealthy()
        {
            return Status == InstallationStatus.Installed && 
                   Directory.Exists(InstallationPath) &&
                   Package.Executables.All(exe => File.Exists(Path.Combine(InstallationPath, exe)));
        }

        /// <summary>
        /// Business rule: Calculate disk space used by installation
        /// </summary>
        public long CalculateDiskUsage()
        {
            if (!Directory.Exists(InstallationPath))
                return 0;

            var directoryInfo = new DirectoryInfo(InstallationPath);
            return directoryInfo.EnumerateFiles("*", SearchOption.AllDirectories)
                                .Sum(file => file.Length);
        }
    }

    /// <summary>
    /// Value object for package usage statistics
    /// </summary>
    public class PackageStatistics
    {
        public long DownloadCount { get; }
        public DateTime LastDownloaded { get; }
        public double AverageRating { get; }
        public int RatingCount { get; }

        public PackageStatistics(
            long downloadCount = 0,
            DateTime lastDownloaded = default,
            double averageRating = 0.0,
            int ratingCount = 0)
        {
            DownloadCount = Math.Max(0, downloadCount);
            LastDownloaded = lastDownloaded == default ? DateTime.MinValue : lastDownloaded;
            AverageRating = Math.Max(0.0, Math.Min(5.0, averageRating));
            RatingCount = Math.Max(0, ratingCount);
        }
    }

    /// <summary>
    /// Installation status enumeration
    /// </summary>
    public enum InstallationStatus
    {
        Installed,
        Corrupted,
        Outdated,
        PendingUpdate
    }
}