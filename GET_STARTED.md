# PostgreSQL Setup & Getting Started Guide

## Prerequisites

- PostgreSQL 12+ installed on your system
- A SQL client (psql, pgAdmin, DBeaver, or VS Code with PostgreSQL extension)

## Installation

### Windows
1. Download PostgreSQL from [postgresql.org](https://www.postgresql.org/download/windows/)
2. Run the installer and follow the setup wizard
3. Remember the password you set for the `postgres` user
4. Install pgAdmin (recommended for GUI)

### macOS
```bash
brew install postgresql
brew services start postgresql
```

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

---

## Setting Up Your Learning Database

### Using psql (Command Line)

1. **Connect to PostgreSQL**
   ```bash
   psql -U postgres
   ```
   Enter your password when prompted.

2. **Create the learning database**
   ```sql
   CREATE DATABASE learn_sql;
   ```

3. **Connect to the new database**
   ```sql
   \c learn_sql;
   ```

4. **Run setup scripts in order**
   ```sql
   \i 'path/to/scripts/01-setup.sql'
   \i 'path/to/scripts/02-sample-data.sql'
   ```

### Using pgAdmin (GUI)

1. Open pgAdmin
2. Right-click "Databases" → Create → Database
3. Name it "learn_sql" and click Create
4. Right-click the database → Query Tool
5. Open and run the SQL scripts

### Using DBeaver

1. Open DBeaver
2. New Database Connection → PostgreSQL
3. Enter connection details
4. Create new database "learn_sql"
5. Right-click → SQL Editor → New SQL Script
6. Paste and run the setup scripts

---

## File Structure & Organization

```
📁 learn-sql/
├── README.md                          # Main overview
├── 01-BASIC.md                        # Basics tutorial
├── 02-INTERMEDIATE.md                 # Intermediate tutorial
├── 03-ADVANCED.md                     # Advanced tutorial
├── QUICK_REFERENCE.sql                # SQL cheat sheet
├── GET_STARTED.md                     # This file
└── 📁 scripts/
    ├── 01-setup.sql                   # Create schema
    ├── 02-sample-data.sql             # Insert sample data
    ├── 03-exercises.sql               # Practice exercises
    └── 04-advanced-examples.sql       # Advanced examples
```

---

## Learning Path

### Week 1: Basics
- Read [01-BASIC.md](./01-BASIC.md)
- Run `01-setup.sql` and `02-sample-data.sql`
- Practice exercises from `03-exercises.sql` (Basic section)
- Master: SELECT, WHERE, INSERT, UPDATE, DELETE

### Week 2: Intermediate
- Read [02-INTERMEDIATE.md](./02-INTERMEDIATE.md)
- Practice JOIN operations
- Master GROUP BY and aggregate functions
- Work with subqueries
- Practice exercises from `03-exercises.sql` (Intermediate section)

### Week 3: Advanced
- Read [03-ADVANCED.md](./03-ADVANCED.md)
- Learn window functions
- Master CTEs and recursive queries
- Understand transactions and triggers
- Practice exercises from `03-exercises.sql` (Advanced section)

### Ongoing: Practice
- Review [QUICK_REFERENCE.sql](./QUICK_REFERENCE.sql) daily
- Run `04-advanced-examples.sql` to see real-world patterns
- Experiment with modifying queries
- Create your own test tables and queries

---

## Quick Start: Running Your First Query

1. **Connect to learn_sql database**
   ```bash
   psql -U postgres -d learn_sql
   ```

2. **Run a simple query**
   ```sql
   SELECT * FROM users LIMIT 5;
   ```

3. **Try updates**
   ```sql
   SELECT first_name, age FROM users WHERE age > 30;
   ```

4. **Explore joins**
   ```sql
   SELECT e.emp_name, d.dept_name 
   FROM employees e
   JOIN departments d ON e.dept_id = d.dept_id;
   ```

---

## Common Commands in psql

```sql
\l                           -- List all databases
\c database_name             -- Connect to database
\dt                          -- List all tables
\d table_name                -- Describe table
\i file_path                 -- Import/run SQL file
\q                           -- Quit
\h SELECT                    -- Help on command (e.g., SELECT)
\?                           -- List all commands
```

---

## Running SQL Scripts

### From psql
```sql
\i 'C:/learn/sql/scripts/01-setup.sql'
```

### From command line
```bash
psql -U postgres -d learn_sql -f scripts/01-setup.sql
```

### From file
1. Open the SQL file in your editor
2. Copy and paste into Query Tool
3. Execute (Ctrl+Enter or Click Run button)

---

## Recommended Tools

### Command Line
- **psql** - Built-in, lightweight, great for automation
  ```bash
  psql -U postgres -d learn_sql
  ```

### GUI Tools (Free)
- **pgAdmin** - Full-featured, web-based
  - Download: [pgadmin.org](https://www.pgadmin.org/)
  
- **DBeaver** - Modern, supports multiple databases
  - Download: [dbeaver.io](https://dbeaver.io/)

### VS Code Extension
- **SQLTools** - Query within VS Code
  - Search "SQLTools" in Extensions

---

## Troubleshooting

### "Password authentication failed"
- Check your PostgreSQL password
- Default user is usually "postgres"
- Can reset password in pgAdmin

### "Database does not exist"
- Verify database name: `\l` in psql
- Create with: `CREATE DATABASE learn_sql;`

### "Permission denied"
- Ensure you're logged in as correct user
- Check role permissions in pgAdmin

### "Cannot import SQL file"
- Use full file path
- Use forward slashes: `C:/path/to/file.sql`
- Not: `C:\path\to\file.sql`

### Exercises not working?
- Ensure all setup scripts ran successfully
- Check data exists: `SELECT COUNT(*) FROM employees;`
- Verify table names: `\dt`

---

## Tips for Success

✅ **DO:**
- Start with BASIC and progress gradually
- Read the theory first, then write queries
- Use `LIMIT` to check results safely
- Write comments in your queries
- Practice modifying existing queries
- Use `EXPLAIN` to understand performance

❌ **DON'T:**
- Skip BASIC and jump to ADVANCED
- Use `DELETE` or `UPDATE` without `WHERE`
- Copy-paste without understanding
- Rush through exercises
- Ignore error messages

---

## Practice Exercises

### Easy (After BASIC)
```sql
-- Find all employees in Sales department
SELECT * FROM employees WHERE dept_id = 1;

-- List employees by salary (highest first)
SELECT emp_name, salary FROM employees ORDER BY salary DESC;
```

### Medium (After INTERMEDIATE)
```sql
-- Count employees per department
SELECT d.dept_name, COUNT(e.emp_id)
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Find employees with above-average salary
SELECT * FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### Hard (After ADVANCED)
```sql
-- Rank employees by salary within department
SELECT emp_name, salary,
       RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC)
FROM employees;

-- Show employee hierarchy
WITH RECURSIVE emp_tree AS (
    SELECT emp_id, emp_name, manager_id, 1 as level
    FROM emp_hierarchy WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.manager_id, et.level + 1
    FROM emp_hierarchy e
    JOIN emp_tree et ON e.manager_id = et.emp_id
)
SELECT REPEAT('  ', level-1) || emp_name FROM emp_tree;
```

---

## Next Steps After Completing Tutorial

1. **Real Database Design**
   - Design a database for a project you're interested in
   - Normalize your schema
   - Add appropriate indexes

2. **Learn Advanced Features**
   - Full-text search
   - Partitioning for large tables
   - Replication and backups

3. **Performance Tuning**
   - Use EXPLAIN ANALYZE
   - Create composite indexes
   - Optimize slow queries

4. **Database Administration**
   - User management and permissions
   - Backup and recovery procedures
   - Monitoring and logging

5. **Real-World Applications**
   - Connect database to Python/Node.js/etc
   - Build a web application with PostgreSQL backend
   - Work with data analysis tools

---

## Useful Resources

- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **W3Schools SQL Tutorial**: https://www.w3schools.com/sql/
- **Mode Analytics SQL Tutorial**: https://mode.com/sql-tutorial/
- **PostgreSQL Official Tutorials**: https://www.postgresql.org/docs/current/tutorial.html

---

## Summary

1. ✅ Install PostgreSQL
2. ✅ Create learn_sql database
3. ✅ Run 01-setup.sql
4. ✅ Run 02-sample-data.sql
5. ✅ Read 01-BASIC.md
6. ✅ Practice with 03-exercises.sql
7. ✅ Progress through INTERMEDIATE and ADVANCED
8. ✅ Reference QUICK_REFERENCE.sql as needed
9. ✅ Build your own projects!

**Happy Learning! 🚀**
