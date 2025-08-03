# AWS CLI Package Manual

## Package Information
- **Package Name**: aws
- **Category**: Cloud
- **Type**: Amazon Web Services CLI
- **License**: Apache 2.0

## Description
Amazon Web Services Command Line Interface - unified tool for managing AWS services. 

Provides direct access to AWS APIs for scripting, automation, and interactive cloud resource management.
Supports all AWS services with comprehensive command-line access for cloud operations, DevOps workflows, and infrastructure management.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| aws.exe | AWS CLI main command | Manage all AWS services |
| aws_completer.exe | AWS CLI command completion | Tab completion for commands |

## Supported AWS Services
- **Compute**: EC2, Lambda, ECS, EKS, Batch
- **Storage**: S3, EBS, EFS, Glacier
- **Database**: RDS, DynamoDB, ElastiCache, Redshift
- **Networking**: VPC, CloudFront, Route 53, ELB
- **Security**: IAM, Secrets Manager, KMS, Certificate Manager
- **Monitoring**: CloudWatch, CloudTrail, X-Ray
- **DevOps**: CodePipeline, CodeBuild, CodeDeploy, CloudFormation
- **And 200+ other AWS services**

## Common Usage Examples

### Configuration
```bash
# Configure AWS credentials
aws configure

# List available profiles
aws configure list-profiles

# Use specific profile
aws --profile myprofile s3 ls
```

### S3 Operations
```bash
# List S3 buckets
aws s3 ls

# Upload file to S3
aws s3 cp file.txt s3://mybucket/

# Sync directory to S3
aws s3 sync ./local-folder s3://mybucket/remote-folder
```

### EC2 Operations
```bash
# List EC2 instances
aws ec2 describe-instances

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Create security group
aws ec2 create-security-group --group-name MySecurityGroup --description "My security group"
```

### Lambda Operations
```bash
# List Lambda functions
aws lambda list-functions

# Invoke function
aws lambda invoke --function-name myfunction output.txt

# Update function code
aws lambda update-function-code --function-name myfunction --zip-file fileb://function.zip
```

## Installation
Complete AWS CLI v2 with Python runtime and all AWS service modules. Ready for enterprise cloud operations and automation.

## Dependencies
- Python runtime (bundled)
- AWS credentials (configure with `aws configure`)

## Configuration
Run `aws configure` to set up:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region
- Output format (json, text, table)

---
*Part of PORTX Portable Development Environment*