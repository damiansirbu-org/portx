# USQL Package Manual

## Package Information
- **Package Name**: usql
- **Category**: Database Tools
- **Type**: Universal SQL Client
- **License**: MIT

## Description
Universal command-line interface for SQL databases with unified syntax and extensive driver support.

USQL provides a consistent interface for connecting to and querying over 30 different SQL and NoSQL databases.
Features advanced SQL capabilities, syntax highlighting, and comprehensive export options for database operations and analysis.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| usql.exe | Universal SQL client | Connect and query multiple database types |

## Supported Database Drivers

### Relational Databases
- **PostgreSQL** (`postgres://`, `postgresql://`)
- **MySQL** / **MariaDB** (`mysql://`, `maria://`)
- **SQLite** (`sqlite3://`, `file://`)
- **Microsoft SQL Server** (`sqlserver://`, `mssql://`)
- **Oracle Database** (`oracle://`, `ora://`)
- **IBM DB2** (`db2://`)

### Cloud Databases
- **Amazon Redshift** (`redshift://`)
- **Google BigQuery** (`bigquery://`, `bq://`)
- **Snowflake** (`snowflake://`)
- **Azure SQL Database** (`azuresql://`)
- **CockroachDB** (`cockroach://`, `crdb://`)
- **TiDB** (`tidb://`)

### NoSQL and Analytics
- **MongoDB** (`mongodb://`, `mongo://`)
- **Apache Cassandra** (`cassandra://`)
- **ClickHouse** (`clickhouse://`)
- **InfluxDB** (`influx://`)
- **Elasticsearch** (`elastic://`)
- **Neo4j** (`neo4j://`)

### In-Memory and Embedded
- **Redis** (`redis://`)
- **Apache Ignite** (`ignite://`)
- **H2 Database** (`h2://`)
- **DuckDB** (`duckdb://`)
- **Apache Drill** (`drill://`)

## Connection Examples

### PostgreSQL Connections
```bash
# Basic connection
usql postgres://user:password@localhost/dbname

# Connection with SSL
usql "postgres://user:password@localhost/dbname?sslmode=require"

# Connection with specific port
usql postgres://user:password@localhost:5433/dbname

# Connection using environment variables
export PGUSER=myuser PGPASSWORD=mypass PGDATABASE=mydb
usql postgres://localhost
```

### MySQL/MariaDB Connections
```bash
# Standard MySQL connection
usql mysql://user:password@localhost/database

# MariaDB connection
usql maria://user:password@localhost:3307/database

# MySQL with SSL and charset
usql "mysql://user:password@localhost/db?tls=true&charset=utf8mb4"

# Local socket connection
usql mysql://user:password@localhost/db?socket=/var/run/mysqld/mysqld.sock
```

### Cloud Database Connections
```bash
# Amazon Redshift
usql redshift://user:password@cluster.region.redshift.amazonaws.com:5439/database

# Google BigQuery (requires service account)
usql bigquery://project-id/dataset

# Snowflake
usql snowflake://user:password@account.snowflakecomputing.com/database/schema

# Azure SQL Database
usql azuresql://user:password@server.database.windows.net/database
```

### NoSQL Database Connections
```bash
# MongoDB
usql mongodb://user:password@localhost:27017/database

# Redis
usql redis://localhost:6379/0

# Cassandra
usql cassandra://user:password@localhost:9042/keyspace

# ClickHouse
usql clickhouse://user:password@localhost:8123/database
```

## Interactive SQL Operations

### Basic Query Operations
```sql
-- Connect and run interactive queries
usql postgres://localhost/mydb

-- Simple SELECT queries
SELECT * FROM users LIMIT 10;

-- Joins and complex queries
SELECT u.name, p.title 
FROM users u 
JOIN posts p ON u.id = p.user_id 
WHERE u.active = true;

-- Aggregation queries
SELECT department, COUNT(*), AVG(salary) 
FROM employees 
GROUP BY department 
ORDER BY AVG(salary) DESC;
```

### Schema Inspection and Metadata
```sql
-- List all tables
\dt

-- Describe table structure
\d table_name

-- List all databases
\l

-- List all schemas
\dn

-- Show current connection info
\conninfo

-- List all indexes
\di

-- Show table sizes
\dt+
```

### Transaction Management
```sql
-- Begin transaction
BEGIN;

-- Commit transaction
COMMIT;

-- Rollback transaction
ROLLBACK;

-- Savepoint operations
SAVEPOINT sp1;
ROLLBACK TO sp1;
RELEASE SAVEPOINT sp1;
```

## Advanced Features and Commands

### Meta Commands
```bash
# Connect to different database
\c postgres://localhost/other_db

# Execute SQL file
\i script.sql

# Output query results to file
\o output.txt
SELECT * FROM large_table;
\o

# Change output format
\pset format csv
\pset format json
\pset format table
\pset format vertical

# Toggle timing display
\timing on
```

### Data Export and Import
```sql
-- Export to CSV
\pset format csv
\o export.csv
SELECT * FROM users;
\o

-- Export to JSON
\pset format json
\o users.json
SELECT row_to_json(t) FROM (SELECT * FROM users) t;
\o

-- Copy data (PostgreSQL specific)
\copy users TO 'users.csv' CSV HEADER;
\copy users FROM 'import.csv' CSV HEADER;
```

### Query Performance Analysis
```sql
-- Enable timing
\timing on

-- Explain query plan
EXPLAIN SELECT * FROM large_table WHERE indexed_column = 'value';

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM users u JOIN orders o ON u.id = o.user_id;

-- Show execution statistics
\timing
SELECT COUNT(*) FROM large_table;
```

## Scripting and Automation

### Batch Processing Script
```bash
#!/bin/bash
# Batch database operations with usql

DB_URL=$1
SCRIPT_DIR=$2
LOG_FILE="/tmp/usql_batch_$(date +%Y%m%d_%H%M%S).log"

echo "Starting batch processing..." | tee $LOG_FILE

# Process all SQL files in directory
for sql_file in "$SCRIPT_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        echo "Executing: $(basename $sql_file)" | tee -a $LOG_FILE
        
        # Execute SQL file and capture results
        if usql "$DB_URL" -f "$sql_file" >> $LOG_FILE 2>&1; then
            echo "✓ Success: $(basename $sql_file)" | tee -a $LOG_FILE
        else
            echo "✗ Failed: $(basename $sql_file)" | tee -a $LOG_FILE
        fi
    fi
done

echo "Batch processing complete. Log: $LOG_FILE"
```

### Multi-Database Migration Script
```bash
#!/bin/bash
# Migrate data between different database types

SOURCE_DB=$1
TARGET_DB=$2
TABLE_NAME=$3
TEMP_FILE="/tmp/migration_${TABLE_NAME}_$(date +%Y%m%d_%H%M%S).csv"

echo "Migrating table: $TABLE_NAME"
echo "From: $SOURCE_DB"
echo "To: $TARGET_DB"

# Export data from source database
echo "Exporting data from source..."
usql "$SOURCE_DB" -c "\pset format csv" -c "\o $TEMP_FILE" -c "SELECT * FROM $TABLE_NAME;"

if [ ! -f "$TEMP_FILE" ]; then
    echo "Error: Export failed"
    exit 1
fi

# Get row count
row_count=$(wc -l < "$TEMP_FILE")
echo "Exported $row_count rows"

# Create table structure in target (if needed)
echo "Creating table structure in target..."
usql "$SOURCE_DB" -c "\d $TABLE_NAME" | grep -E "(Column|Type)" > structure.txt

# Import data to target database
echo "Importing data to target..."
# Note: Import method depends on target database type
case "$TARGET_DB" in
    postgres://*)
        usql "$TARGET_DB" -c "\copy $TABLE_NAME FROM '$TEMP_FILE' CSV HEADER;"
        ;;
    mysql://*)
        usql "$TARGET_DB" -c "LOAD DATA LOCAL INFILE '$TEMP_FILE' INTO TABLE $TABLE_NAME FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
        ;;
    sqlite3://*)
        usql "$TARGET_DB" -c ".mode csv" -c ".import $TEMP_FILE $TABLE_NAME"
        ;;
    *)
        echo "Manual import required for target database type"
        echo "CSV file available at: $TEMP_FILE"
        ;;
esac

# Verify migration
target_count=$(usql "$TARGET_DB" -c "SELECT COUNT(*) FROM $TABLE_NAME;" | tail -1)
echo "Target table now contains: $target_count rows"

# Cleanup
rm -f "$TEMP_FILE" structure.txt

echo "Migration complete"
```

### Database Health Check Script
```bash
#!/bin/bash
# Database health check using usql

DATABASE_URL=$1
REPORT_FILE="/tmp/db_health_$(date +%Y%m%d_%H%M%S).txt"

echo "Database Health Check Report" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "Database: $DATABASE_URL" >> $REPORT_FILE
echo "=======================================" >> $REPORT_FILE

# Connection test
echo "Testing database connection..." | tee -a $REPORT_FILE
if usql "$DATABASE_URL" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ Connection: OK" | tee -a $REPORT_FILE
else
    echo "✗ Connection: FAILED" | tee -a $REPORT_FILE
    exit 1
fi

# Basic statistics
echo "" >> $REPORT_FILE
echo "Database Statistics:" >> $REPORT_FILE

# Table count
table_count=$(usql "$DATABASE_URL" -c "\dt" | wc -l)
echo "Total tables: $table_count" >> $REPORT_FILE

# Database size (PostgreSQL example)
if [[ $DATABASE_URL == postgres* ]]; then
    db_size=$(usql "$DATABASE_URL" -c "SELECT pg_size_pretty(pg_database_size(current_database()));" | tail -1)
    echo "Database size: $db_size" >> $REPORT_FILE
    
    # Active connections
    active_conn=$(usql "$DATABASE_URL" -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';" | tail -1)
    echo "Active connections: $active_conn" >> $REPORT_FILE
fi

# Long running queries (PostgreSQL)
if [[ $DATABASE_URL == postgres* ]]; then
    echo "" >> $REPORT_FILE
    echo "Long running queries (>5 minutes):" >> $REPORT_FILE
    usql "$DATABASE_URL" -c "
        SELECT pid, now() - pg_stat_activity.query_start AS duration, query 
        FROM pg_stat_activity 
        WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE
echo "Health check complete." >> $REPORT_FILE
echo "Report saved: $REPORT_FILE"
```

## Cross-Database Analytics

### Multi-Database Reporting
```bash
#!/bin/bash
# Generate reports from multiple databases

POSTGRES_URL="postgres://user:pass@localhost/analytics"
MYSQL_URL="mysql://user:pass@localhost/ecommerce"
MONGO_URL="mongodb://localhost:27017/logs"
REPORT_DIR="/tmp/multi_db_report_$(date +%Y%m%d)"

mkdir -p "$REPORT_DIR"

echo "Generating multi-database analytics report..."

# PostgreSQL Analytics
echo "Fetching PostgreSQL analytics..."
usql "$POSTGRES_URL" > "$REPORT_DIR/postgres_report.txt" << 'EOF'
\pset format table
SELECT 'User Analytics' as report_section;
SELECT 
    DATE_TRUNC('day', created_at) as date,
    COUNT(*) as new_users,
    COUNT(CASE WHEN is_premium THEN 1 END) as premium_users
FROM users 
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY date;
EOF

# MySQL E-commerce Data
echo "Fetching MySQL e-commerce data..."
usql "$MYSQL_URL" > "$REPORT_DIR/mysql_report.txt" << 'EOF'
SELECT 'Sales Analytics' as report_section;
SELECT 
    DATE(order_date) as date,
    COUNT(*) as total_orders,
    SUM(total_amount) as revenue,
    AVG(total_amount) as avg_order_value
FROM orders 
WHERE order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(order_date)
ORDER BY date;
EOF

# MongoDB Logs (if supported)
echo "Fetching MongoDB logs..."
usql "$MONGO_URL" > "$REPORT_DIR/mongo_report.txt" << 'EOF'
db.access_logs.aggregate([
    {$match: {timestamp: {$gte: new Date(Date.now() - 30*24*60*60*1000)}}},
    {$group: {
        _id: {$dateToString: {format: "%Y-%m-%d", date: "$timestamp"}},
        page_views: {$sum: 1},
        unique_visitors: {$addToSet: "$user_id"}
    }},
    {$project: {
        date: "$_id",
        page_views: 1,
        unique_visitors: {$size: "$unique_visitors"}
    }},
    {$sort: {date: 1}}
])
EOF

# Combine reports
echo "Generating combined report..."
cat > "$REPORT_DIR/combined_report.md" << EOF
# Multi-Database Analytics Report
Generated: $(date)

## PostgreSQL User Analytics
\`\`\`
$(cat "$REPORT_DIR/postgres_report.txt")
\`\`\`

## MySQL E-commerce Analytics
\`\`\`
$(cat "$REPORT_DIR/mysql_report.txt")
\`\`\`

## MongoDB Access Logs
\`\`\`
$(cat "$REPORT_DIR/mongo_report.txt")
\`\`\`
EOF

echo "Multi-database report complete: $REPORT_DIR/combined_report.md"
```

### Data Synchronization Between Databases
```bash
#!/bin/bash
# Synchronize data between different database types

SOURCE_DB=$1  # Source database URL
TARGET_DB=$2  # Target database URL
SYNC_TABLE=$3 # Table to synchronize
ID_COLUMN=${4:-"id"}  # Primary key column

TEMP_DIR="/tmp/usql_sync_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEMP_DIR"

echo "Synchronizing table: $SYNC_TABLE"
echo "From: $SOURCE_DB"
echo "To: $TARGET_DB"

# Get latest timestamp from target
echo "Finding last sync point..."
LAST_SYNC=$(usql "$TARGET_DB" -c "SELECT COALESCE(MAX(updated_at), '1970-01-01') FROM $SYNC_TABLE;" 2>/dev/null | tail -1)

if [ -z "$LAST_SYNC" ]; then
    LAST_SYNC="1970-01-01"
fi

echo "Last sync: $LAST_SYNC"

# Export incremental data from source
echo "Exporting incremental data..."
usql "$SOURCE_DB" > "$TEMP_DIR/incremental.csv" << EOF
\pset format csv
\o
SELECT * FROM $SYNC_TABLE 
WHERE updated_at > '$LAST_SYNC' 
ORDER BY $ID_COLUMN;
EOF

# Check if there's data to sync
if [ ! -s "$TEMP_DIR/incremental.csv" ]; then
    echo "No new data to synchronize"
    rm -rf "$TEMP_DIR"
    exit 0
fi

row_count=$(wc -l < "$TEMP_DIR/incremental.csv")
echo "Found $row_count records to sync"

# Create temporary staging table
echo "Creating staging table..."
usql "$TARGET_DB" << EOF
DROP TABLE IF EXISTS ${SYNC_TABLE}_staging;
CREATE TABLE ${SYNC_TABLE}_staging AS SELECT * FROM $SYNC_TABLE WHERE 1=0;
EOF

# Import to staging table
echo "Importing to staging..."
usql "$TARGET_DB" -c "\copy ${SYNC_TABLE}_staging FROM '$TEMP_DIR/incremental.csv' CSV HEADER;"

# Merge data (upsert)
echo "Merging data..."
usql "$TARGET_DB" << EOF
-- Update existing records
UPDATE $SYNC_TABLE 
SET updated_at = s.updated_at,
    -- Add other columns as needed
FROM ${SYNC_TABLE}_staging s 
WHERE $SYNC_TABLE.$ID_COLUMN = s.$ID_COLUMN;

-- Insert new records
INSERT INTO $SYNC_TABLE 
SELECT s.* 
FROM ${SYNC_TABLE}_staging s 
LEFT JOIN $SYNC_TABLE t ON s.$ID_COLUMN = t.$ID_COLUMN 
WHERE t.$ID_COLUMN IS NULL;

-- Cleanup
DROP TABLE ${SYNC_TABLE}_staging;
EOF

echo "Synchronization complete"

# Cleanup
rm -rf "$TEMP_DIR"
```

## Configuration and Customization

### Configuration File (~/.usqlrc)
```sql
-- USQL configuration file
\set PROMPT1 '%M:%> %n@%/%R%#%x '
\set PROMPT2 '%M:%> %n@%/%R%#%x '

-- Default formatting
\pset linestyle unicode
\pset border 2
\pset format table

-- Enable timing by default
\timing on

-- Set default null display
\pset null '<null>'

-- History settings
\set HISTSIZE 1000
\set HISTCONTROL ignoredups

-- Common aliases
\set rtsize 'SELECT schemaname, tablename, attname, n_distinct, correlation FROM pg_stats;'
\set activity 'SELECT datname, pid, usename, application_name, client_addr, state, query FROM pg_stat_activity;'
```

### Environment Variables
```bash
# Set default database URL
export DATABASE_URL="postgres://user:password@localhost/mydb"

# Set history file location
export USQL_HISTORY="/path/to/custom/history"

# Disable history
export USQL_NO_HISTORY=1

# Set default output format
export USQL_FORMAT="csv"

# Connection timeout
export USQL_CONNECT_TIMEOUT=30
```

## Performance Optimization

### Query Optimization Techniques
```sql
-- Use EXPLAIN to analyze query plans
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM large_table 
WHERE indexed_column = 'value';

-- Use proper indexing
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_order_date ON orders(order_date);

-- Optimize JOINs
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.active = true
GROUP BY u.id, u.name;

-- Use CTEs for complex queries
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        SUM(total_amount) as revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue, 
       LAG(revenue) OVER (ORDER BY month) as prev_month_revenue
FROM monthly_sales;
```

### Bulk Operations
```sql
-- Batch inserts
BEGIN;
INSERT INTO logs (timestamp, level, message) VALUES
    (NOW(), 'INFO', 'Message 1'),
    (NOW(), 'ERROR', 'Message 2'),
    (NOW(), 'DEBUG', 'Message 3');
COMMIT;

-- Bulk updates
UPDATE products 
SET price = price * 1.1 
WHERE category = 'electronics';

-- Efficient data loading
\copy products FROM 'products.csv' CSV HEADER;
```

## Use Cases

### Database Administration
- Multi-database monitoring and maintenance
- Schema comparison and synchronization
- Data migration and ETL operations
- Performance analysis and optimization

### Data Analysis and Reporting
- Cross-database analytics and reporting
- Ad-hoc query execution and exploration
- Data export and visualization preparation
- Business intelligence and data science workflows

### Development and Testing
- Database schema development and testing
- Data seeding and test data generation
- CI/CD pipeline database operations
- Local development environment management

### DevOps and Automation
- Database deployment and configuration management
- Monitoring and health check automation
- Backup and recovery operations
- Infrastructure as code database provisioning

## Installation
Universal SQL client for connecting to multiple database types.
Essential tool for database administration, development, and analytics workflows.

## Dependencies
- Network connectivity to target databases
- Database-specific drivers (included)
- Authentication credentials for database connections
- Sufficient memory for query result processing

## Supported Platforms
- Windows, macOS, Linux
- 32-bit and 64-bit architectures
- Container environments (Docker, Kubernetes)
- Cloud platforms and serverless environments

---
*Part of PORTX Portable Development Environment*