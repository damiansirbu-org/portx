# Liquibase Package Manual

## Package Information
- **Package Name**: liquibase
- **Category**: Database Tools
- **Type**: Database Schema Migration Tool
- **License**: Apache 2.0 / Commercial

## Description
Enterprise database migration and version control tool for managing database schema changes.

Liquibase enables database-agnostic schema migration with support for SQL, XML, YAML, and JSON changelog formats.
Provides rollback capabilities, database comparison, and automated deployment across all major database platforms.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| liquibase.bat | Liquibase command-line interface | Database migration and version control |
| liquibase | Unix shell script for Liquibase | Cross-platform database management |

## Supported Database Platforms

### Commercial Databases
- **Oracle Database** (11g, 12c, 19c, 21c)
- **Microsoft SQL Server** (2012-2022)
- **IBM DB2** (LUW, z/OS)
- **SAP HANA**
- **Snowflake Data Cloud**
- **Amazon Redshift**

### Open Source Databases
- **PostgreSQL** (9.6+)
- **MySQL** / **MariaDB** (5.7+)
- **SQLite** (3.x)
- **H2 Database** (embedded testing)
- **HSQLDB** (in-memory testing)

## Common Usage Examples

### Project Initialization
```bash
# Initialize new Liquibase project
liquibase init project

# Generate example changelog
liquibase init copy-defaults

# Create database connection properties
liquibase init properties

# Start H2 database for testing
examples/start-h2.bat
```

### Schema Migration
```bash
# Update database to latest version
liquibase update

# Update with specific tag
liquibase update --tag=v1.2.0

# Update specific number of changes
liquibase update-count 5

# Test update without applying changes
liquibase update-sql
```

### Changelog Management
```bash
# Generate changelog from existing database
liquibase generate-changelog

# Create new changeset
liquibase generate-changeset

# Validate changelog syntax
liquibase validate

# Check changelog status
liquibase status
```

### Database Comparison
```bash
# Compare two databases
liquibase diff

# Generate diff changelog
liquibase diff-changelog

# Synchronize database schemas
liquibase sync
```

## Advanced Operations

### Rollback Operations
```bash
# Rollback to specific tag
liquibase rollback v1.1.0

# Rollback specific number of changes
liquibase rollback-count 3

# Rollback to specific date
liquibase rollback-to-date 2024-01-15

# Generate rollback SQL
liquibase rollback-sql v1.1.0
```

### Database Documentation
```bash
# Generate database documentation
liquibase db-doc output/

# Create data modeling report
liquibase snapshot

# Export database structure
liquibase snapshot --format=json > schema.json
```

### Quality Assurance
```bash
# Check for database drift
liquibase diff-changelog --reference-url=jdbc:h2:~/test

# Validate database state
liquibase status --verbose

# Check for pending changes
liquibase list-locks

# Release database locks
liquibase release-locks
```

## Configuration Management

### Database Connection Properties
```properties
# liquibase.properties
changeLogFile=changelog.xml
url=jdbc:postgresql://localhost:5432/mydb
username=dbuser
password=secretpassword
driver=org.postgresql.Driver
classpath=postgresql.jar

# Advanced settings
contexts=development,test
labels=feature-branch
defaultSchemaName=public
liquibaseSchemaName=liquibase_metadata
```

### Changelog Formats

#### XML Changelog Example
```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <changeSet id="1" author="developer">
        <createTable tableName="users">
            <column name="id" type="int" autoIncrement="true">
                <constraints primaryKey="true" nullable="false"/>
            </column>
            <column name="username" type="varchar(50)">
                <constraints unique="true" nullable="false"/>
            </column>
            <column name="email" type="varchar(100)"/>
            <column name="created_date" type="timestamp" defaultValueComputed="CURRENT_TIMESTAMP"/>
        </createTable>
    </changeSet>

    <changeSet id="2" author="developer">
        <addColumn tableName="users">
            <column name="last_login" type="timestamp"/>
        </addColumn>
    </changeSet>

</databaseChangeLog>
```

#### YAML Changelog Example
```yaml
databaseChangeLog:
  - changeSet:
      id: 1
      author: developer
      changes:
        - createTable:
            tableName: products
            columns:
              - column:
                  name: id
                  type: int
                  autoIncrement: true
                  constraints:
                    primaryKey: true
                    nullable: false
              - column:
                  name: name
                  type: varchar(255)
                  constraints:
                    nullable: false
              - column:
                  name: price
                  type: decimal(10,2)
                  constraints:
                    nullable: false

  - changeSet:
      id: 2
      author: developer
      context: test
      changes:
        - insert:
            tableName: products
            columns:
              - column:
                  name: name
                  value: Sample Product
              - column:
                  name: price
                  value: 29.99
```

#### SQL Changelog Example
```sql
--liquibase formatted sql

--changeset developer:1
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL
);

--changeset developer:2
ALTER TABLE orders 
ADD COLUMN status VARCHAR(20) DEFAULT 'pending';

--changeset developer:3 context:production
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
```

## Enterprise Deployment Workflows

### CI/CD Integration
```bash
#!/bin/bash
# Liquibase CI/CD Pipeline Script

# Set environment variables
export LIQUIBASE_COMMAND_URL=$DATABASE_URL
export LIQUIBASE_COMMAND_USERNAME=$DB_USERNAME
export LIQUIBASE_COMMAND_PASSWORD=$DB_PASSWORD

# Validate changelog
liquibase validate

# Check database status
liquibase status --verbose

# Update database in staging
if [ "$ENVIRONMENT" = "staging" ]; then
    liquibase update --contexts=staging
fi

# Update database in production
if [ "$ENVIRONMENT" = "production" ]; then
    liquibase update --contexts=production --label-filter="release"
fi

# Generate deployment report
liquibase db-doc reports/db-docs/
```

### Multi-Environment Management
```bash
# Development environment
liquibase --defaults-file=liquibase-dev.properties update

# Testing environment
liquibase --defaults-file=liquibase-test.properties update

# Production environment
liquibase --defaults-file=liquibase-prod.properties update

# Compare environments
liquibase --defaults-file=liquibase-dev.properties diff \
  --reference-defaults-file=liquibase-prod.properties
```

### Database Backup and Recovery
```bash
# Create pre-migration backup
liquibase --defaults-file=production.properties tag pre-migration-backup

# Perform migration with automatic rollback on failure
liquibase update || liquibase rollback pre-migration-backup

# Create post-migration snapshot
liquibase snapshot --format=json > post-migration-$(date +%Y%m%d).json

# Verify migration success
liquibase status --verbose
```

## Security and Compliance

### Secure Configuration
```bash
# Use environment variables for sensitive data
export LIQUIBASE_COMMAND_PASSWORD=$(cat /secure/db-password.txt)
export LIQUIBASE_COMMAND_URL="jdbc:postgresql://secure-db:5432/app"

# Run with minimal privileges
liquibase --log-level=INFO update

# Audit trail generation
liquibase history > migration-audit-$(date +%Y%m%d).log
```

### Change Approval Process
```bash
# Generate preview of changes
liquibase update-sql > pending-changes.sql

# Review and approve changes
git add pending-changes.sql
git commit -m "Database changes for release v2.1.0"

# Apply approved changes
liquibase update --tag=v2.1.0
```

## Troubleshooting and Maintenance

### Common Operations
```bash
# Clear checksum validation errors
liquibase clear-checksums

# Mark changeset as executed (without running)
liquibase change-log-sync

# Force unlock database
liquibase release-locks

# Repair changelog metadata
liquibase change-log-sync-sql
```

### Performance Monitoring
```bash
# Enable detailed logging
liquibase --log-level=DEBUG update

# Monitor large migrations
liquibase update --verbose

# Benchmark migration performance
time liquibase update
```

### Database Health Checks
```bash
# Verify database connectivity
liquibase status

# Check for schema drift
liquibase diff > schema-drift-report.txt

# Validate integrity
liquibase validate --verbose

# List applied changes
liquibase history
```

## Integration Examples

### Maven Integration
```xml
<plugin>
    <groupId>org.liquibase</groupId>
    <artifactId>liquibase-maven-plugin</artifactId>
    <version>4.20.0</version>
    <configuration>
        <changeLogFile>src/main/resources/db/changelog/db.changelog-master.xml</changeLogFile>
        <driver>org.postgresql.Driver</driver>
        <url>jdbc:postgresql://localhost:5432/mydb</url>
        <username>dbuser</username>
        <password>secretpassword</password>
    </configuration>
</plugin>
```

### Docker Integration
```dockerfile
FROM liquibase/liquibase:latest

COPY changelog/ /liquibase/changelog/
COPY liquibase.properties /liquibase/
COPY drivers/ /liquibase/lib/

ENTRYPOINT ["liquibase", "update"]
```

### Kubernetes Deployment
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: database-migration
spec:
  template:
    spec:
      containers:
      - name: liquibase
        image: liquibase/liquibase:latest
        command: ["liquibase", "update"]
        env:
        - name: LIQUIBASE_COMMAND_URL
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: url
        - name: LIQUIBASE_COMMAND_USERNAME
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: username
        - name: LIQUIBASE_COMMAND_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: password
        volumeMounts:
        - name: changelog
          mountPath: /liquibase/changelog
      volumes:
      - name: changelog
        configMap:
          name: liquibase-changelog
      restartPolicy: OnFailure
```

## Use Cases

### Enterprise Database Management
- Schema versioning and migration across environments
- Automated deployment pipelines with rollback capabilities
- Database change approval and audit workflows
- Multi-tenant database management

### DevOps and CI/CD
- Automated database updates in deployment pipelines
- Environment synchronization and comparison
- Database testing and validation automation
- Infrastructure as code for database schemas

### Compliance and Governance
- Change tracking and audit trail generation
- Approval workflows for database modifications
- Regulatory compliance reporting
- Database documentation and metadata management

### Development Workflow Integration
- Local development database setup and seeding
- Feature branch database isolation
- Database refactoring and optimization
- Legacy system modernization and migration

## Installation
Enterprise database migration tool with support for all major database platforms.
Includes comprehensive changelog formats, rollback capabilities, and enterprise deployment features.

## Dependencies
- Java Runtime Environment (JRE 8+)
- Database-specific JDBC drivers (included for major databases)
- Network connectivity to target databases
- Appropriate database privileges for schema modification

## Configuration Files
- **liquibase.properties** - Database connection and migration settings
- **changelog files** - Schema change definitions (XML, YAML, SQL, JSON)
- **liquibase.flowfile.yaml** - Advanced workflow configuration
- **Database drivers** - JDBC drivers for target database platforms

---
*Part of PORTX Portable Development Environment*