# lazysql Package Manual

## Package Information
- **Package Name**: lazysql
- **Category**: Database Tools
- **Type**: Database Terminal UI
- **License**: MIT

## Description
Terminal UI for SQL database management with intuitive keyboard navigation.

Interactive terminal interface for managing SQL databases with visual query editing, result browsing, and database administration.
Supports multiple database engines with a unified interface for database operations.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| lazysql.exe | Interactive SQL database management interface | Manage databases with terminal UI |

## Common Usage Examples

### Database Connections
```bash
# Connect to MySQL database
lazysql mysql://user:password@localhost:3306/database

# Connect to PostgreSQL
lazysql postgres://user:password@localhost:5432/database

# Connect to SQLite
lazysql sqlite:///path/to/database.db

# Connect with connection string
lazysql "mysql://root:secret@localhost/myapp"
```

### Connection Configuration
```bash
# Using environment variables
export DB_HOST=localhost
export DB_USER=admin
export DB_PASS=password
export DB_NAME=production
lazysql mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME

# Configuration file
lazysql --config ~/.config/lazysql/config.yml

# Interactive connection setup
lazysql --setup
```

## Interface Overview

### Main Panels
- **Tables**: Database tables and views
- **Query Editor**: SQL query composition
- **Results**: Query results and data browsing
- **Schema**: Database structure and metadata
- **History**: Query execution history

### Navigation
- **Tab**: Switch between panels
- **j/k**: Navigate up/down within lists
- **h/l**: Navigate left/right between columns
- **Enter**: Select/execute action
- **Esc**: Cancel/go back

## Table Management

### Table Operations
```bash
# Table actions:
Enter           # Browse table data
i               # Show table info/schema
d               # Describe table structure
r               # Refresh table list
s               # Show table statistics
```

### Data Browsing
```bash
# Data navigation:
j/k             # Navigate rows
h/l             # Navigate columns
Page Up/Down    # Page through results
Home/End        # First/last row
/               # Search in data
```

### Table Schema
```bash
# Schema information displayed:
- Column names and types
- Primary and foreign keys
- Indexes and constraints
- Table statistics
- Row counts
```

## Query Editor

### SQL Query Composition
```bash
# Query editor operations:
i               # Enter insert mode
Esc             # Exit insert mode
Ctrl+e          # Execute query
Ctrl+s          # Save query
Ctrl+o          # Open saved query
Ctrl+n          # New query
```

### Query Execution
```bash
# Execution options:
F5              # Execute query
Ctrl+Enter      # Execute selected text
F9              # Execute with timing
Shift+F5        # Execute and explain plan
```

### Query Management
```bash
# Query operations:
Ctrl+s          # Save current query
Ctrl+o          # Open saved query
Ctrl+h          # Query history
Ctrl+f          # Format SQL
Ctrl+/          # Comment/uncomment
```

## Results and Data Manipulation

### Result Navigation
```bash
# Result browsing:
j/k             # Next/previous row
h/l             # Previous/next column
g/G             # First/last row
0/$             # First/last column
Page Up/Down    # Page navigation
```

### Data Filtering
```bash
# Filtering and search:
/               # Search in results
n/N             # Next/previous match
f               # Filter columns
w               # Filter WHERE clause
o               # Sort by column
```

### Data Export
```bash
# Export options:
e               # Export to CSV
j               # Export to JSON
x               # Export to Excel
c               # Copy to clipboard
p               # Print results
```

## Database Administration

### Schema Exploration
```bash
# Schema navigation:
t               # List tables
v               # List views
i               # List indexes
p               # List procedures
f               # List functions
u               # List users
```

### Database Operations
```bash
# Admin operations:
Ctrl+r          # Refresh connection
Ctrl+d          # Change database
Ctrl+t          # Show database info
Ctrl+p          # Show process list
Ctrl+k          # Kill query/connection
```

### Index and Performance
```bash
# Performance analysis:
x               # Explain query plan
s               # Show slow queries
p               # Show performance stats
i               # Analyze indexes
o               # Optimize tables
```

## Multi-Database Support

### MySQL/MariaDB
```bash
# MySQL specific features:
- SHOW PROCESSLIST
- SHOW ENGINE STATUS
- Binary log analysis
- Replication status
- MyISAM/InnoDB tables
```

### PostgreSQL
```bash
# PostgreSQL specific features:
- pg_stat_activity
- Query plan visualization
- Extension management
- Vacuum and analyze
- Schema browsing
```

### SQLite
```bash
# SQLite specific features:
- .schema commands
- Pragma settings
- Vacuum operations
- Attach databases
- FTS (Full-Text Search)
```

## Configuration and Customization

### Configuration File (~/.config/lazysql/config.yml)
```yaml
database:
  default_limit: 1000
  timeout: 30
  auto_commit: true

ui:
  theme: "dark"
  show_line_numbers: true
  word_wrap: false
  tab_size: 4

editor:
  syntax_highlighting: true
  auto_complete: true
  vim_mode: false

connections:
  - name: "local_mysql"
    driver: "mysql"
    dsn: "root:password@localhost:3306/test"
  - name: "prod_postgres"
    driver: "postgres"
    dsn: "user:pass@prod-db:5432/app"
```

### Custom Key Bindings
```yaml
keybindings:
  global:
    quit: "q"
    help: "?"
    refresh: "r"
  query_editor:
    execute: "F5"
    save: "Ctrl+s"
    format: "Ctrl+f"
  results:
    export_csv: "e"
    copy: "c"
    filter: "f"
```

### Themes
```yaml
themes:
  dark:
    background: "#1e1e1e"
    foreground: "#d4d4d4"
    accent: "#007acc"
    error: "#f44747"
  light:
    background: "#ffffff"
    foreground: "#333333"
    accent: "#0066cc"
    error: "#cc0000"
```

## Advanced Features

### Query History
```bash
# History management:
Ctrl+h          # Show query history
Up/Down         # Navigate history
Enter           # Load historical query
d               # Delete history entry
```

### Bookmarks and Favorites
```bash
# Bookmark management:
Ctrl+b          # Bookmark current query
Ctrl+m          # Manage bookmarks
f               # Mark table as favorite
F               # Show favorite tables
```

### Multiple Connections
```bash
# Connection management:
Ctrl+c          # New connection
Ctrl+w          # Close connection
Ctrl+Tab        # Switch connections
Alt+1-9         # Quick connection switch
```

## Workflow Examples

### Data Analysis Workflow
```bash
1. Connect to database
2. Browse tables (t)
3. Select interesting table (Enter)
4. Filter data (f)
5. Export results (e)
6. Switch to query editor (Tab)
7. Write analysis queries
8. Save important queries (Ctrl+s)
```

### Development Workflow
```bash
1. Connect to development database
2. Open query editor
3. Write DDL/DML queries
4. Execute and test (F5)
5. Check results
6. Modify and re-execute
7. Save working queries
```

### Administration Workflow
```bash
1. Connect to production database
2. Check process list (Ctrl+p)
3. Monitor slow queries (s)
4. Analyze performance (x)
5. Optimize tables (o)
6. Export reports (e)
```

## Error Handling and Debugging

### Query Debugging
```bash
# Debug features:
- Syntax error highlighting
- Execution time display
- Row count information
- Error message display
- Query plan analysis
```

### Connection Issues
```bash
# Connection troubleshooting:
- Connection timeout handling
- Retry mechanisms
- Connection status display
- Error logging
- Network diagnostics
```

## Integration with Other Tools

### SQL File Management
```bash
# External file integration:
Ctrl+o          # Open SQL file
Ctrl+s          # Save to file
Ctrl+i          # Import SQL script
Ctrl+e          # Export schema
```

### Command Line Integration
```bash
# CLI compatibility:
# Works with existing SQL scripts
# Supports standard SQL syntax
# Compatible with database CLIs
# Integrates with version control
```

## Use Cases

### Database Development
- Query development and testing
- Schema exploration and design
- Data analysis and reporting
- Performance optimization

### Database Administration
- User and permission management
- Performance monitoring
- Backup and maintenance
- Troubleshooting and diagnostics

### Data Analysis
- Ad-hoc data exploration
- Report generation
- Data validation
- Business intelligence queries

### Learning and Training
- SQL learning and practice
- Database concept exploration
- Query optimization techniques
- Database design principles

## Installation
Interactive SQL database management tool with terminal-based interface.
Essential for database operations, query development, and data analysis.

## Dependencies
- Database drivers for target systems
- Network connectivity to database servers
- Valid database credentials
- Terminal with color support for optimal experience

## Performance Features
- Efficient query execution
- Result streaming for large datasets
- Connection pooling
- Memory-optimized data display
- Responsive terminal interface

---
*Part of PORTX Portable Development Environment*