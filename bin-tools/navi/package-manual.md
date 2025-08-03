# Navi Package Manual

## Package Information
- **Package Name**: navi
- **Category**: Productivity Tools
- **Type**: Interactive Cheatsheet
- **License**: Apache 2.0

## Description
Interactive cheatsheet tool for command-line with fuzzy searching and customizable commands.

Command-line snippet manager with fuzzy finder interface, allowing quick access to frequently used commands with variable substitution.
Essential for improving command-line productivity and reducing memorization burden.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| navi.exe | Interactive command cheatsheet | Browse and execute commands with fuzzy search |

## Common Usage Examples

### Basic Usage
```bash
# Launch interactive cheatsheet
navi

# Search for specific commands
navi --query "git"

# Show best match and execute
navi --best-match --query "docker logs"

# Preview mode (don't execute)
navi --preview

# Print command without executing
navi --print
```

### Command Execution
```bash
# Execute command directly
navi --best-match --query "find files"

# Execute with fzf selection
navi --fzf-overrides '--height 50%'

# Save output to variable
cmd=$(navi --print --best-match --query "git branch")
```

## Cheat Sheet Management

### Built-in Cheatsheets
```bash
# Download community cheatsheets
navi repo add denisidoro/cheats

# List available repositories
navi repo list

# Browse available cheatsheets
navi info cheats-path

# Update cheatsheets
navi repo update
```

### Custom Cheatsheets
```bash
# Create custom cheatsheet
navi info cheats-path  # Get cheatsheets directory
# Create .cheat files in that directory

# Add personal repository
navi repo add /path/to/personal/cheats

# Edit cheatsheets
navi edit

# Validate cheatsheet syntax
navi check /path/to/cheatsheet.cheat
```

## Cheatsheet Format

### Basic Syntax
```bash
% git, version control

# Show git status
git status

# Add all files to staging
git add .

# Commit with message
git commit -m "<message>"

# Push to remote
git push origin <branch>

# Create new branch
git checkout -b <branch_name>

$ branch: git branch -r | grep -v HEAD | sed 's/origin\///' | sed 's/^ *//'
```

### Variable Substitution
```bash
% docker, containers

# List running containers
docker ps

# Stop container
docker stop <container_id>

# View container logs
docker logs <container_id> <options>

# Execute command in container
docker exec -it <container_id> <command>

# Remove container
docker rm <container_id>

$ container_id: docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" | tail -n +2 | awk '{print $1}'
$ command: echo -e "bash\nsh\n/bin/bash\n/bin/sh"
$ options: echo -e "-f\n--tail 100\n--since 1h"
```

### Advanced Features
```bash
% kubernetes, k8s

# Get pods in namespace
kubectl get pods -n <namespace>

# Describe pod
kubectl describe pod <pod_name> -n <namespace>

# Get pod logs
kubectl logs <pod_name> -n <namespace> <log_options>

# Port forward to pod
kubectl port-forward <pod_name> <local_port>:<pod_port> -n <namespace>

# Execute command in pod
kubectl exec -it <pod_name> -n <namespace> -- <command>

$ namespace: kubectl get namespaces -o name | sed 's/namespace\///'
$ pod_name: kubectl get pods -n <namespace> -o name | sed 's/pod\///'
$ log_options: echo -e "-f\n--tail=100\n--since=1h\n--previous"
$ local_port: echo -e "8080\n3000\n5432\n6379"
$ pod_port: echo -e "80\n8080\n3000\n5432"
$ command: echo -e "bash\nsh\n/bin/bash\nenv\nps aux"
```

### Multi-line Commands
```bash
% system, administration

# Find large files
find <directory> -type f -size +<size> -exec ls -lh {} \; | \
  awk '{ print $9 ": " $5 }' | \
  sort -k2 -hr

# System resource usage
ps aux | sort -nrk 3,3 | head -n <count>

# Network connections
netstat -tuln | grep <port>

# Disk usage summary
du -sh <directory>/* | sort -hr | head -n <count>

$ directory: find /home /var /opt -maxdepth 1 -type d 2>/dev/null
$ size: echo -e "100M\n500M\n1G\n2G\n5G"
$ count: echo -e "5\n10\n15\n20"
$ port: echo -e "80\n443\n22\n3000\n8080"
```

## Configuration

### Configuration File (~/.config/navi/config.yaml)
```yaml
# Finder settings
finder:
  command: fzf
  overrides: --height 50% --reverse --border

# Style settings
style:
  tag:
    color: cyan
    width_percentage: 26
    min_width: 20
  comment:
    color: blue
  snippet:
    color: white

# Search settings
search:
  tags: true
  comments: true

# Shell settings
shell:
  command: bash

# Cheatsheet settings
cheats:
  paths:
    - ~/.local/share/navi/cheats
    - /usr/share/navi/cheats
```

### Environment Variables
```bash
# Navi configuration
export NAVI_CONFIG="$HOME/.config/navi/config.yaml"
export NAVI_PATH="$HOME/.local/share/navi/cheats"

# FZF customization for navi
export NAVI_FZF_OVERRIDES="--height 60% --reverse --border --preview-window 'right:60%'"

# Default query
export NAVI_TAG_RULES="git,docker,kubernetes"
```

## Integration Examples

### Shell Integration
```bash
# Bash integration (~/.bashrc)
eval "$(navi widget bash)"

# Zsh integration (~/.zshrc)
eval "$(navi widget zsh)"

# Fish integration (~/.config/fish/config.fish)
navi widget fish | source

# Key binding (Ctrl+G)
bind -x '"\C-g": navi'
```

### Custom Functions
```bash
# Git helper function
git_helper() {
    navi --best-match --query "git $1"
}

# Docker helper
docker_helper() {
    navi --fzf-overrides '--height 70%' --query "docker $1"
}

# Kubernetes helper
k8s_helper() {
    navi --query "kubernetes $1"
}
```

### IDE Integration
```bash
# VS Code task (tasks.json)
{
    "label": "Navi Command Helper",
    "type": "shell",
    "command": "navi",
    "group": "build",
    "presentation": {
        "echo": true,
        "reveal": "always",
        "panel": "new"
    }
}
```

## Custom Cheatsheet Examples

### Personal Development Workflow
```bash
% development, workflow

# Start development server
npm run dev

# Run tests
npm test <test_pattern>

# Build for production
npm run build

# Lint code
npm run lint <file_pattern>

# Format code
npm run format

# Commit changes
git add . && git commit -m "<commit_message>" && git push

$ test_pattern: find . -name "*.test.js" -o -name "*.spec.js" | head -10
$ file_pattern: echo -e "src/\n*.js\n*.ts\n*.jsx\n*.tsx"
$ commit_message: echo -e "feat: \nbug: \nfix: \nrefactor: \ndocs: \ntest: "
```

### System Administration
```bash
% sysadmin, server

# Check service status
systemctl status <service_name>

# Restart service
sudo systemctl restart <service_name>

# View service logs
journalctl -u <service_name> <log_options>

# Monitor system resources
htop

# Check disk space
df -h <mount_point>

# Network diagnostics
ping -c <count> <host>

$ service_name: systemctl list-units --type=service --state=running | awk '{print $1}' | head -20
$ log_options: echo -e "-f\n--since today\n--since \"1 hour ago\"\n-n 100"
$ mount_point: df -h | tail -n +2 | awk '{print $6}'
$ count: echo -e "4\n10\n100"
$ host: echo -e "8.8.8.8\ngoogle.com\ngithub.com\nlocalhost"
```

### Database Operations
```bash
% database, sql

# Connect to PostgreSQL
psql -h <host> -U <username> -d <database>

# MySQL connection
mysql -h <host> -u <username> -p <database>

# Show tables
\dt

# Describe table structure
\d <table_name>

# Export database
pg_dump -h <host> -U <username> <database> > backup.sql

# Import database
psql -h <host> -U <username> -d <database> < backup.sql

$ host: echo -e "localhost\n127.0.0.1\ndb.example.com"
$ username: echo -e "postgres\nroot\nadmin\nuser"
$ database: echo -e "postgres\nmyapp\ntest\nproduction"
$ table_name: echo -e "users\norders\nproducts\nsessions"
```

## Advanced Usage

### Scripting with Navi
```bash
#!/bin/bash
# Automated deployment script using navi

echo "Starting deployment process..."

# Get deployment command from navi
deploy_cmd=$(navi --print --best-match --query "deploy production")

# Execute with confirmation
echo "About to execute: $deploy_cmd"
read -p "Continue? (y/N): " confirm
if [[ $confirm == [yY] ]]; then
    eval "$deploy_cmd"
fi
```

### Team Cheatsheet Repository
```bash
# Team shared cheatsheets repository
% team, procedures

# Code review process
gh pr create --title "<title>" --body "<description>"

# Release procedure
git tag -a v<version> -m "Release <version>"
git push origin v<version>

# Emergency rollback
kubectl rollout undo deployment/<deployment_name> -n <namespace>

# Infrastructure scaling
terraform plan -var="instance_count=<count>"
terraform apply -var="instance_count=<count>"

$ title: echo -e "feat: \nfix: \nrefactor: \ndocs: "
$ description: echo -e "Implements new feature\nFixes critical bug\nImproves performance"
$ version: git tag | sort -V | tail -5
$ deployment_name: kubectl get deployments -o name | sed 's/deployment\///'
$ namespace: kubectl get namespaces -o name | sed 's/namespace\///'
$ count: echo -e "1\n2\n3\n5\n10"
```

## Use Cases

### Developer Productivity
- Quick access to frequently used commands
- Complex command templates with variables
- Team knowledge sharing
- Onboarding documentation

### System Administration
- Server management procedures
- Troubleshooting workflows
- Security protocols
- Backup and recovery procedures

### DevOps Operations
- Deployment procedures
- Infrastructure management
- Monitoring and alerting
- CI/CD pipeline operations

### Learning and Training
- Command discovery and learning
- Best practices documentation
- Interactive tutorials
- Reference documentation

## Installation
Interactive command cheatsheet tool for improving command-line productivity.
Essential for managing complex commands and sharing team knowledge.

## Dependencies
- fzf (fuzzy finder) for interactive selection
- Shell environment (bash, zsh, fish)
- Git (optional, for repository management)
- Terminal with color support for optimal experience

## Performance Features
- Fast fuzzy search
- Efficient command execution
- Minimal memory footprint
- Quick startup time
- Responsive interface

---
*Part of PORTX Portable Development Environment*