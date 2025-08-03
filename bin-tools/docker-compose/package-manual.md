# Docker Compose Package Manual

## Package Information
- **Package Name**: docker-compose
- **Category**: Containers
- **Type**: Container Orchestration
- **License**: Apache 2.0

## Description
Docker Compose tool for defining and running multi-container Docker applications.

Enables declarative container orchestration using YAML configuration files to define services, networks, and volumes.
Essential for local development, testing, and deployment of containerized applications.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| docker-compose.exe | Multi-container Docker application orchestration | Define and manage container stacks |

## Common Usage Examples

### Basic Operations
```bash
# Start services defined in docker-compose.yml
docker-compose up

# Start services in background
docker-compose up -d

# Stop and remove containers
docker-compose down

# Stop services without removing containers
docker-compose stop
```

### Service Management
```bash
# Build or rebuild services
docker-compose build

# Build and start services
docker-compose up --build

# Scale a service
docker-compose up --scale web=3

# View running services
docker-compose ps
```

### Logs and Monitoring
```bash
# View logs from all services
docker-compose logs

# Follow logs from specific service
docker-compose logs -f web

# View logs from multiple services
docker-compose logs web db
```

### Configuration Management
```bash
# Validate compose file
docker-compose config

# View resolved configuration
docker-compose config --services

# Use custom compose file
docker-compose -f custom-compose.yml up
```

### Service Interaction
```bash
# Execute command in running service
docker-compose exec web bash

# Run one-off command in new container
docker-compose run web python manage.py migrate

# Run command without dependencies
docker-compose run --no-deps web python manage.py test
```

### Network and Volume Management
```bash
# List networks
docker-compose config --networks

# List volumes
docker-compose config --volumes

# Remove volumes when stopping
docker-compose down -v
```

## Sample docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app
    environment:
      - DEBUG=1
    depends_on:
      - db
      - redis

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6
    ports:
      - "6379:6379"

volumes:
  postgres_data:

networks:
  default:
    driver: bridge
```

## Advanced Features

### Environment Files
```bash
# Use environment file
docker-compose --env-file production.env up

# Override with multiple files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### Profiles
```yaml
services:
  web:
    profiles: ["frontend"]
  api:
    profiles: ["backend"]
  debug:
    profiles: ["debug"]
```

```bash
# Start specific profiles
docker-compose --profile frontend up
```

### Health Checks
```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
```

## Installation
Docker Compose for multi-container application orchestration.
Enables declarative container management for development and deployment workflows.

## Dependencies
- Docker Engine installed and running
- docker-compose.yml configuration file
- Access to container images (local or registry)

## Configuration
Create docker-compose.yml in your project directory with service definitions.
Use environment variables and override files for different environments.

---
*Part of PORTX Portable Development Environment*