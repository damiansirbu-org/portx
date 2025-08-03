using System;
using System.Text.RegularExpressions;

namespace PORTX.PackageManager.Domain
{
    /// <summary>
    /// Domain logic for version constraint handling.
    /// Implements semantic versioning with simplified constraint syntax.
    /// Follows ARCHITECT principle: Simple over clever.
    /// </summary>
    public class VersionConstraint
    {
        private readonly string _constraint;
        private readonly ConstraintType _type;
        private readonly Version _version;

        public VersionConstraint(string constraint)
        {
            if (string.IsNullOrWhiteSpace(constraint))
                throw new ArgumentException("Version constraint cannot be empty", nameof(constraint));

            _constraint = constraint.Trim();
            ParseConstraint(_constraint, out _type, out _version);
        }

        /// <summary>
        /// Business rule: Check if a version satisfies this constraint
        /// </summary>
        public bool IsSatisfiedBy(Version version)
        {
            if (version == null)
                return false;

            return _type switch
            {
                ConstraintType.Exact => version.Equals(_version),
                ConstraintType.GreaterThan => version > _version,
                ConstraintType.GreaterThanOrEqual => version >= _version,
                ConstraintType.LessThan => version < _version,
                ConstraintType.LessThanOrEqual => version <= _version,
                ConstraintType.Compatible => IsCompatible(version, _version),
                ConstraintType.Any => true,
                _ => false
            };
        }

        /// <summary>
        /// Business rule: Compatible version matching (caret range ^1.2.3)
        /// Allows patch and minor updates but not major updates
        /// </summary>
        private static bool IsCompatible(Version version, Version constraintVersion)
        {
            // Same major version required
            if (version.Major != constraintVersion.Major)
                return false;

            // Must be greater than or equal to constraint version
            return version >= constraintVersion;
        }

        private static void ParseConstraint(string constraint, out ConstraintType type, out Version version)
        {
            // Simple constraint parsing - no complex version range syntax
            // Follows ARCHITECT principle: Optimize for maintainability

            if (constraint == "*" || constraint == "latest")
            {
                type = ConstraintType.Any;
                version = new Version(0, 0, 0);
                return;
            }

            if (constraint.StartsWith("^"))
            {
                type = ConstraintType.Compatible;
                version = ParseVersion(constraint.Substring(1));
                return;
            }

            if (constraint.StartsWith(">="))
            {
                type = ConstraintType.GreaterThanOrEqual;
                version = ParseVersion(constraint.Substring(2));
                return;
            }

            if (constraint.StartsWith("<="))
            {
                type = ConstraintType.LessThanOrEqual;
                version = ParseVersion(constraint.Substring(2));
                return;
            }

            if (constraint.StartsWith(">"))
            {
                type = ConstraintType.GreaterThan;
                version = ParseVersion(constraint.Substring(1));
                return;
            }

            if (constraint.StartsWith("<"))
            {
                type = ConstraintType.LessThan;
                version = ParseVersion(constraint.Substring(1));
                return;
            }

            // Default to exact match
            type = ConstraintType.Exact;
            version = ParseVersion(constraint);
        }

        private static Version ParseVersion(string versionString)
        {
            versionString = versionString.Trim();

            // Remove 'v' prefix if present
            if (versionString.StartsWith("v", StringComparison.OrdinalIgnoreCase))
                versionString = versionString.Substring(1);

            // Try standard .NET Version parsing first
            if (Version.TryParse(versionString, out var version))
                return version;

            // Handle semantic versions with pre-release tags (1.2.3-alpha)
            var match = Regex.Match(versionString, @"^(\d+)\.(\d+)\.(\d+)(?:-[\w\.-]+)?(?:\+[\w\.-]+)?$");
            if (match.Success)
            {
                var major = int.Parse(match.Groups[1].Value);
                var minor = int.Parse(match.Groups[2].Value);
                var patch = int.Parse(match.Groups[3].Value);
                return new Version(major, minor, patch);
            }

            // Handle two-part versions (1.2)
            match = Regex.Match(versionString, @"^(\d+)\.(\d+)$");
            if (match.Success)
            {
                var major = int.Parse(match.Groups[1].Value);
                var minor = int.Parse(match.Groups[2].Value);
                return new Version(major, minor, 0);
            }

            throw new ArgumentException($"Invalid version format: {versionString}");
        }

        public override string ToString()
        {
            return _constraint;
        }

        public override bool Equals(object obj)
        {
            return obj is VersionConstraint other && _constraint == other._constraint;
        }

        public override int GetHashCode()
        {
            return _constraint.GetHashCode();
        }
    }

    internal enum ConstraintType
    {
        Exact,
        GreaterThan,
        GreaterThanOrEqual,
        LessThan,
        LessThanOrEqual,
        Compatible,
        Any
    }
}