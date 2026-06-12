# SQL BASICS - PostgreSQL Tutorial

## What is SQL?

**SQL (Structured Query Language)** is a standardized language for managing and manipulating relational databases. It allows you to:
- Create and modify database structures
- Insert, update, and retrieve data
- Set up security and access controls

## What is PostgreSQL?

PostgreSQL is a powerful, open-source relational database system that:
- Supports advanced SQL features
- Provides ACID compliance (Atomicity, Consistency, Isolation, Durability)
- Offers excellent performance and reliability
- Is free and widely used in industry

---

## 1. DATABASE AND TABLE BASICS

### Creating a Database
```sql
CREATE DATABASE learn_sql;
```

### Connecting to a Database
```sql
\c learn_sql;  -- In psql command line
```

### Data Types in PostgreSQL

| Type | Description | Example |
|------|-------------|---------|
| SERIAL | Auto-incrementing integer (1, 2, 3...) | `user_id SERIAL` |
| INTEGER | Whole numbers | 42, -100 |
| BIGINT | Large whole numbers | 9223372036854775807 |
| SMALLINT | Small whole numbers | 32767 |
| DECIMAL/NUMERIC | Fixed-point numbers | 10.50 |
| FLOAT/REAL | Floating-point numbers | 3.14159 |
| VARCHAR(n) | Text with max length | 'Hello' |
| TEXT | Unlimited text | 'Long text...' |
| DATE | Calendar date | '2024-01-15' |
| TIMESTAMP | Date and time | '2024-01-15 10:30:00' |
| BOOLEAN | True or False | TRUE, FALSE |

**SERIAL Explained**: SERIAL is a special type that automatically generates the next integer value for each new row. It's perfect for creating unique ID numbers (primary keys). You don't need to insert a value—PostgreSQL assigns it automatically!

### Creating a Table
```sql
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**About SERIAL**: When you insert rows without specifying `user_id`, PostgreSQL automatically assigns 1, 2, 3, etc. Example:
```sql
-- You only provide these columns
INSERT INTO users (first_name, last_name, email, age) 
VALUES ('John', 'Doe', 'john@example.com', 30);

-- PostgreSQL automatically sets user_id = 1

-- Next insert gets user_id = 2 automatically
INSERT INTO users (first_name, last_name, email, age) 
VALUES ('Jane', 'Smith', 'jane@example.com', 28);
```

### Key Constraints

- **PRIMARY KEY**: Uniquely identifies each row
- **NOT NULL**: Column must have a value
- **UNIQUE**: All values in column must be unique
- **DEFAULT**: Provides a default value
- **CHECK**: Ensures values meet a condition
- **FOREIGN KEY**: Links to another table

### Viewing Tables
```sql
\dt                    -- List all tables (psql)
\d table_name;         -- Show table structure
DESC table_name;       -- Show table structure
```

---

## 2. INSERT DATA

### Insert Single Row
```sql
INSERT INTO users (first_name, last_name, email, age)
VALUES ('John', 'Doe', 'john@example.com', 30);
```

### Insert Multiple Rows
```sql
INSERT INTO users (first_name, last_name, email, age) VALUES
('Jane', 'Smith', 'jane@example.com', 28),
('Bob', 'Johnson', 'bob@example.com', 35),
('Alice', 'Williams', 'alice@example.com', 29);
```

---

## 3. SELECT STATEMENTS

### Select All Columns
```sql
SELECT * FROM users;
```

### Select Specific Columns
```sql
SELECT first_name, last_name, email FROM users;
```

### Select with Alias
```sql
SELECT 
    first_name AS "First Name",
    last_name AS "Last Name",
    email AS "Email Address"
FROM users;
```

### LIMIT and OFFSET
```sql
SELECT * FROM users LIMIT 10;              -- First 10 rows
SELECT * FROM users LIMIT 10 OFFSET 5;     -- Skip 5, then 10 rows
```

---

## 4. WHERE CLAUSE - FILTERING DATA

### Basic Conditions
```sql
-- Equals
SELECT * FROM users WHERE age = 30;

-- Not equals
SELECT * FROM users WHERE age != 30;
SELECT * FROM users WHERE age <> 30;

-- Comparison operators
SELECT * FROM users WHERE age > 25;
SELECT * FROM users WHERE age >= 25;
SELECT * FROM users WHERE age < 35;
SELECT * FROM users WHERE age <= 35;
```

### Logical Operators
```sql
-- AND - Both conditions must be true
SELECT * FROM users 
WHERE age > 25 AND age < 35;

-- OR - At least one condition must be true
SELECT * FROM users 
WHERE first_name = 'John' OR first_name = 'Jane';

-- NOT - Negates a condition
SELECT * FROM users 
WHERE NOT age > 30;
```

### IN Operator
```sql
SELECT * FROM users 
WHERE first_name IN ('John', 'Jane', 'Bob');
```

### BETWEEN Operator
```sql
SELECT * FROM users 
WHERE age BETWEEN 25 AND 35;
```

### Pattern Matching - LIKE
```sql
-- Starts with 'J'
SELECT * FROM users WHERE first_name LIKE 'J%';

-- Ends with 'n'
SELECT * FROM users WHERE last_name LIKE '%n';

-- Contains 'oh'
SELECT * FROM users WHERE first_name LIKE '%oh%';

-- Single character wildcard
SELECT * FROM users WHERE first_name LIKE 'J_hn';
```

### IS NULL / IS NOT NULL
```sql
SELECT * FROM users WHERE email IS NULL;
SELECT * FROM users WHERE email IS NOT NULL;
```

---

## 5. UPDATE DATA

### Update Single Column
```sql
UPDATE users 
SET age = 31 
WHERE user_id = 1;
```

### Update Multiple Columns
```sql
UPDATE users 
SET age = 32, email = 'john.doe@example.com'
WHERE user_id = 1;
```

### Update with Condition
```sql
UPDATE users 
SET age = age + 1 
WHERE age < 30;
```

⚠️ **Warning**: Always use WHERE clause. Without it, ALL rows will be updated!

---

## 6. DELETE DATA

### Delete Specific Rows
```sql
DELETE FROM users 
WHERE user_id = 1;
```

### Delete with Condition
```sql
DELETE FROM users 
WHERE age > 50;
```

⚠️ **Warning**: Always use WHERE clause. Without it, ALL rows will be deleted!

---

## 7. SORTING DATA - ORDER BY

### Sort Ascending
```sql
SELECT * FROM users 
ORDER BY age ASC;
```

### Sort Descending
```sql
SELECT * FROM users 
ORDER BY age DESC;
```

### Sort by Multiple Columns
```sql
SELECT * FROM users 
ORDER BY last_name ASC, first_name ASC;
```

---

## 8. DISTINCT VALUES

```sql
-- Get unique first names
SELECT DISTINCT first_name FROM users;

-- Count distinct values
SELECT COUNT(DISTINCT age) FROM users;
```

---

## 9. PRACTICE EXERCISES

### Exercise 1: Basic SELECT
```sql
-- Select all users older than 25
SELECT * FROM users WHERE age > 25;
```

### Exercise 2: Filtering with AND
```sql
-- Select users named 'John' who are older than 28
SELECT * FROM users 
WHERE first_name = 'John' AND age > 28;
```

### Exercise 3: Sorting
```sql
-- Get all users sorted by age in descending order
SELECT * FROM users 
ORDER BY age DESC;
```

### Exercise 4: LIKE Pattern
```sql
-- Find all email addresses containing 'example'
SELECT first_name, email FROM users 
WHERE email LIKE '%example%';
```

### Exercise 5: Update with Condition
```sql
-- Increase age by 1 for all users under 30
UPDATE users 
SET age = age + 1 
WHERE age < 30;
```

---

**Next**: Move to [02-INTERMEDIATE.md](./02-INTERMEDIATE.md) to learn about JOINs and advanced queries!
