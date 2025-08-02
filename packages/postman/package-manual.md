# Postman Package Manual

## Package Information
- **Package Name**: postman
- **Category**: Development Tools
- **Type**: API Testing CLI
- **License**: Apache 2.0

## Description
Command-line collection runner for Postman API testing and automation.

Newman is the command-line companion for Postman that allows running and testing Postman collections directly from the command line.
Essential for API testing automation, CI/CD integration, and automated testing workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| newman.exe | Postman collection runner | Execute Postman collections from command line |

## Common Usage Examples

### Basic Collection Execution
```bash
# Run Postman collection
newman run collection.json

# Run collection with environment
newman run collection.json -e environment.json

# Run with specific iteration count
newman run collection.json -n 5

# Run with delay between requests
newman run collection.json --delay-request 1000
```

### Collection Sources
```bash
# Run from URL
newman run https://api.getpostman.com/collections/12345-abcd-efgh

# Run from Postman Cloud
newman run "https://www.getpostman.com/collections/12345"

# Run local collection file
newman run ./api-tests/collection.json

# Run with specific folder
newman run collection.json --folder "User Management"
```

### Environment and Variables
```bash
# Run with environment file
newman run collection.json -e prod-environment.json

# Run with global variables
newman run collection.json -g globals.json

# Set environment variables
newman run collection.json --env-var "baseUrl=https://api.example.com"

# Set global variables
newman run collection.json --global-var "apiKey=secret123"
```

## Advanced Execution Options

### Request Configuration
```bash
# Set request timeout
newman run collection.json --timeout-request 30000

# Set script timeout
newman run collection.json --timeout-script 10000

# Disable SSL verification
newman run collection.json --insecure

# Follow redirects
newman run collection.json --max-redirects 5
```

### Data-Driven Testing
```bash
# Run with data file
newman run collection.json -d data.csv

# Run with JSON data
newman run collection.json -d test-data.json

# Specify iteration data
newman run collection.json -d data.csv -n 10
```

### Output and Reporting
```bash
# Verbose output
newman run collection.json --verbose

# Disable color output
newman run collection.json --no-color

# Silent mode
newman run collection.json --silent

# Custom reporter
newman run collection.json -r cli,json,html
```

## Reporting Options

### Built-in Reporters
```bash
# JSON report
newman run collection.json -r json --reporter-json-export results.json

# HTML report
newman run collection.json -r html --reporter-html-export report.html

# JUnit XML report
newman run collection.json -r junit --reporter-junit-export results.xml

# CLI table format
newman run collection.json -r cli
```

### Custom Reports
```bash
# Multiple reporters
newman run collection.json -r cli,json,html \
  --reporter-json-export results.json \
  --reporter-html-export report.html

# CSV export
newman run collection.json -r csv --reporter-csv-export results.csv

# TeamCity integration
newman run collection.json -r teamcity
```

### Report Templates
```bash
# Custom HTML template
newman run collection.json -r html \
  --reporter-html-template custom-template.hbs \
  --reporter-html-export custom-report.html
```

## CI/CD Integration

### Jenkins Pipeline
```groovy
pipeline {
    stages {
        stage('API Tests') {
            steps {
                sh 'newman run collection.json -e prod.json -r junit --reporter-junit-export results.xml'
                publishTestResults testResultsPattern: 'results.xml'
            }
        }
    }
}
```

### GitHub Actions
```yaml
name: API Tests
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Install Newman
      run: npm install -g newman
    - name: Run API Tests
      run: |
        newman run tests/api-collection.json \
          -e tests/prod-environment.json \
          -r junit --reporter-junit-export results.xml
    - name: Publish Results
      uses: dorny/test-reporter@v1
      with:
        name: API Test Results
        path: results.xml
        reporter: java-junit
```

### GitLab CI
```yaml
api_tests:
  stage: test
  script:
    - newman run collection.json -e environment.json -r junit --reporter-junit-export results.xml
  artifacts:
    reports:
      junit: results.xml
```

### Azure DevOps
```yaml
- task: Npm@1
  displayName: 'Install Newman'
  inputs:
    command: 'custom'
    customCommand: 'install -g newman'

- script: |
    newman run $(System.DefaultWorkingDirectory)/tests/collection.json \
      -e $(System.DefaultWorkingDirectory)/tests/environment.json \
      -r junit --reporter-junit-export results.xml
  displayName: 'Run API Tests'

- task: PublishTestResults@2
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: 'results.xml'
```

## Test Automation Workflows

### Smoke Tests
```bash
# Quick smoke test
newman run smoke-tests.json -e production.json --bail

# Health check automation
newman run health-checks.json -r json --reporter-json-export health.json

# Critical path testing
newman run critical-path.json --folder "Authentication" --folder "Core API"
```

### Load Testing Integration
```bash
# Stress testing with iterations
newman run load-test.json -n 100 --delay-request 100

# Concurrent execution simulation
for i in {1..10}; do
  newman run api-tests.json -e env.json &
done
wait
```

### Data Validation
```bash
# Schema validation tests
newman run schema-validation.json -d test-data.json

# Regression testing
newman run regression-suite.json -e staging.json -r html --reporter-html-export regression-report.html
```

## Environment Management

### Environment Files
```json
{
  "id": "prod-environment",
  "name": "Production Environment",
  "values": [
    {
      "key": "baseUrl",
      "value": "https://api.example.com",
      "enabled": true
    },
    {
      "key": "apiKey",
      "value": "{{$randomUUID}}",
      "enabled": true
    }
  ]
}
```

### Dynamic Environments
```bash
# Environment from command line
newman run collection.json \
  --env-var "baseUrl=https://staging.api.com" \
  --env-var "apiKey=$API_KEY" \
  --env-var "environment=staging"

# Global variables
newman run collection.json \
  --global-var "timestamp=$(date +%s)" \
  --global-var "testId=$BUILD_NUMBER"
```

### Multi-Environment Testing
```bash
# Test across environments
for env in dev staging prod; do
  echo "Testing $env environment..."
  newman run collection.json -e ${env}-environment.json \
    -r html --reporter-html-export ${env}-report.html
done
```

## Monitoring and Observability

### Performance Monitoring
```bash
# Response time monitoring
newman run performance-tests.json \
  -r json --reporter-json-export perf-results.json

# Extract performance metrics
jq '.run.stats' perf-results.json
```

### Error Tracking
```bash
# Detailed error reporting
newman run collection.json -r json \
  --reporter-json-export detailed-results.json

# Failed request analysis
jq '.run.failures[] | {name: .error.name, message: .error.message}' detailed-results.json
```

### Health Monitoring
```bash
# Continuous health checks
while true; do
  newman run health-check.json -e prod.json --silent
  if [ $? -ne 0 ]; then
    echo "Health check failed at $(date)"
    # Send alert
  fi
  sleep 300  # Check every 5 minutes
done
```

## Advanced Configuration

### Collection Structure
```json
{
  "info": {
    "name": "API Test Suite",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{authToken}}",
        "type": "string"
      }
    ]
  },
  "event": [
    {
      "listen": "prerequest",
      "script": {
        "exec": [
          "pm.environment.set('timestamp', Date.now());"
        ]
      }
    }
  ]
}
```

### Custom Scripting
```javascript
// Pre-request script
pm.environment.set("requestId", pm.variables.replaceIn("{{$guid}}"));
pm.environment.set("timestamp", new Date().toISOString());

// Test script
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response time is less than 500ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});

pm.test("Response has required fields", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('id');
    pm.expect(jsonData).to.have.property('status');
});
```

## Error Handling and Debugging

### Debug Options
```bash
# Verbose debugging
newman run collection.json --verbose

# Debug SSL issues
newman run collection.json --insecure --verbose

# Request/response logging
newman run collection.json -r cli --reporter-cli-no-summary
```

### Failure Analysis
```bash
# Stop on first failure
newman run collection.json --bail

# Continue on failures but report
newman run collection.json --suppress-exit-code

# Custom failure handling
newman run collection.json || echo "Tests failed, continuing..."
```

## Use Cases

### API Development
- Automated API testing
- Regression testing
- Integration testing
- Contract testing

### Quality Assurance
- Test automation
- Continuous testing
- Performance validation
- Data validation

### DevOps and CI/CD
- Build pipeline integration
- Deployment validation
- Health monitoring
- Environment testing

### Monitoring and Alerting
- Service health checks
- SLA monitoring
- Performance tracking
- Uptime validation

## Installation
Command-line collection runner for Postman API testing automation.
Essential tool for API testing, monitoring, and CI/CD integration.

## Dependencies
- Node.js runtime (if installed via npm)
- Valid Postman collection files
- Network access to API endpoints
- Environment configuration files (optional)

## Performance Features
- Parallel request execution
- Efficient collection parsing
- Memory-optimized reporting
- Fast test execution
- Scalable automation support

---
*Part of PORTX Portable Development Environment*