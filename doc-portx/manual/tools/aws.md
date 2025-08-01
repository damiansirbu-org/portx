# AWS CLI - v2.7.13
**Amazon Web Services Command Line Interface**

[🏠 Back to Wiki Home](../index.md) | [☁️ Cloud & Infrastructure](../categories/cloud-infrastructure.md)

---

## 🚀 Overview

The AWS CLI is a unified tool to manage your AWS services from the command line. With just one tool to download and configure, you can control multiple AWS services and automate them through scripts.

- **Version**: 2.7.13
- **Category**: Cloud & Infrastructure
- **Location**: `bin-tools/aws/aws.exe`
- **Documentation**: https://docs.aws.amazon.com/cli/

---

## ⚡ Quick Start

### Installation Check
```bash
aws --version
# aws-cli/2.7.13 Python/3.11.4 Windows/10 exe/AMD64 prompt/off
```

### Basic Configuration
```bash
# Configure credentials (legacy method)
aws configure

# Modern SSO configuration (recommended)
aws configure sso
```

### Test Connection
```bash
# List S3 buckets
aws s3 ls

# Get current identity
aws sts get-caller-identity
```

---

## 🔧 Essential Commands

### S3 Operations
```bash
# List buckets
aws s3 ls

# Sync local directory to S3
aws s3 sync ./local-folder s3://my-bucket/folder --delete

# Copy single file
aws s3 cp file.txt s3://my-bucket/

# Download file
aws s3 cp s3://my-bucket/file.txt ./
```

### EC2 Management
```bash
# List instances
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PublicIpAddress]' --output table

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Create key pair
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem
```

### IAM Operations
```bash
# List users
aws iam list-users --query 'Users[].[UserName,CreateDate]' --output table

# Create user
aws iam create-user --user-name newuser

# Attach policy
aws iam attach-user-policy --user-name newuser --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

---

## 🔐 Authentication Methods

### 1. AWS SSO (Recommended)
```bash
# Configure SSO
aws configure sso --profile production

# Login to SSO
aws sso login --profile production

# Use profile
aws s3 ls --profile production
```

### 2. IAM User Credentials
```bash
# Configure with access keys
aws configure --profile myprofile
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name: us-west-2
# Default output format: json
```

### 3. IAM Roles (EC2/Lambda)
```bash
# Automatically uses instance profile when running on EC2
aws sts get-caller-identity
```

---

## 📊 Advanced Features

### JMESPath Queries
```bash
# Filter EC2 instances by state
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType]'

# Get latest AMI
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-*" --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name]'
```

### Output Formats
```bash
# Table format (human-readable)
aws ec2 describe-instances --output table

# JSON format (default)
aws ec2 describe-instances --output json

# Text format (scriptable)
aws ec2 describe-instances --output text

# YAML format
aws ec2 describe-instances --output yaml
```

### Pagination
```bash
# List all objects in large S3 bucket
aws s3api list-objects-v2 --bucket large-bucket --max-items 1000

# Continue with pagination token
aws s3api list-objects-v2 --bucket large-bucket --starting-token <token>
```

---

## 🛠️ Configuration Management

### Profiles
```bash
# List configured profiles
aws configure list-profiles

# Use specific profile
aws s3 ls --profile production

# Set default profile
export AWS_PROFILE=production
```

### Configuration Files
```bash
# View configuration
aws configure list

# Configuration file locations:
# ~/.aws/config         # Configuration settings
# ~/.aws/credentials    # Access credentials
```

### Environment Variables
```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
export AWS_PROFILE=production
```

---

## 🚀 Automation Examples

### Backup Script
```bash
#!/bin/bash
# Backup local files to S3
DATE=$(date +%Y-%m-%d)
aws s3 sync /important/data s3://backup-bucket/$DATE/ \
    --delete \
    --storage-class GLACIER \
    --exclude "*.tmp" \
    --include "*.log"
```

### Infrastructure Query
```bash
#!/bin/bash
# Get infrastructure overview
echo "=== AWS Infrastructure Overview ==="
echo "EC2 Instances:"
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType]' --output table

echo "S3 Buckets:"
aws s3 ls

echo "RDS Instances:"
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table
```

### Cost Management
```bash
# Get cost and usage
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE
```

---

## 💡 Pro Tips

1. **Use SSO**: Modern authentication with `aws configure sso`
2. **JMESPath**: Master query syntax for filtering output
3. **Profiles**: Organize multiple AWS accounts/environments
4. **Pagination**: Handle large result sets with `--max-items`
5. **Dry Run**: Use `--dry-run` flag to test commands safely
6. **Output**: Choose appropriate format (table, json, text) for your use case
7. **Completion**: Enable bash completion for faster typing

---

## 🔗 Related Tools

- **[kubectl](kubectl.md)** - Kubernetes management (EKS integration)
- **[terraform](terraform.md)** - Infrastructure as Code with AWS provider
- **[docker-compose](docker-compose.md)** - Container orchestration (ECS integration)

---

## 📚 Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/)
- [JMESPath Tutorial](https://jmespath.org/tutorial.html)
- [AWS CLI Examples](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-examples.html)

---

*Use `portx tool aws` to view this page | `portx search aws` to find related tools*

**[⬆️ Back to Top](#aws-cli---v2713)** | **[🏠 Wiki Home](../index.md)**