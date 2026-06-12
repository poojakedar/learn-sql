-- ============================================================================
-- 03-exercises.sql - Practice Exercises with Solutions
-- ============================================================================
-- Use this to practice queries and verify your understanding
-- Each section has exercises with explanations

-- ============================================================================
-- BASIC EXERCISES
-- ============================================================================

-- Exercise 1: SELECT all users
SELECT * FROM users;

-- Exercise 2: Select specific columns
SELECT first_name, last_name, email FROM users;

-- Exercise 3: Select with WHERE clause
SELECT * FROM users WHERE age > 30;

-- Exercise 4: Count users older than 30
SELECT COUNT(*) as users_over_30 FROM users WHERE age > 30;

-- Exercise 5: Find users by email pattern
SELECT * FROM users WHERE email LIKE '%example.com';

-- Exercise 6: Sort by age descending
SELECT first_name, last_name, age 
FROM users 
ORDER BY age DESC;

-- Exercise 7: Get average age
SELECT AVG(age) as average_age FROM users;

-- Exercise 8: Update user age
-- UPDATE users SET age = 31 WHERE first_name = 'John';

-- Exercise 9: Delete specific user
-- DELETE FROM users WHERE user_id = 10;

-- Exercise 10: Get top 5 oldest users
SELECT first_name, last_name, age 
FROM users 
ORDER BY age DESC 
LIMIT 5;

-- ============================================================================
-- INTERMEDIATE EXERCISES
-- ============================================================================

-- Exercise 1: INNER JOIN - Employee with Department
SELECT 
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
ORDER BY e.emp_name;

-- Exercise 2: LEFT JOIN - All departments with employee count
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Exercise 3: GROUP BY with aggregate functions
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as emp_count,
    AVG(e.salary) as avg_salary,
    MAX(e.salary) as max_salary,
    MIN(e.salary) as min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Exercise 4: HAVING clause - Departments with more than 2 employees
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as emp_count,
    AVG(e.salary) as avg_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 2;

-- Exercise 5: Subquery - Employees earning more than average
SELECT 
    e.emp_name,
    e.salary,
    (SELECT AVG(salary) FROM employees) as company_avg_salary
FROM employees e
WHERE e.salary > (SELECT AVG(salary) FROM employees)
ORDER BY e.salary DESC;

-- Exercise 6: Subquery with department average
SELECT 
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name,
    (SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id) as dept_avg
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id
);

-- Exercise 7: JOIN with multiple tables - Employee with Department and Manager
SELECT 
    e.emp_name,
    e.salary,
    d.dept_name,
    m.emp_name as manager_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY d.dept_name, e.emp_name;

-- Exercise 8: UNION - Combine results
SELECT emp_name as name, 'Employee' as type FROM employees
UNION
SELECT dept_name, 'Department' FROM departments;

-- Exercise 9: DISTINCT - Unique departments
SELECT DISTINCT dept_id FROM employees WHERE dept_id IS NOT NULL;

-- Exercise 10: Complex query with multiple joins and aggregates
SELECT 
    d.dept_name,
    COUNT(DISTINCT e.emp_id) as employee_count,
    COUNT(DISTINCT pa.project_id) as project_count,
    AVG(e.salary) as avg_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN project_assignments pa ON e.emp_id = pa.emp_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- ============================================================================
-- ADVANCED EXERCISES
-- ============================================================================

-- Exercise 1: Window Function - Rank employees by salary within department
SELECT 
    e.emp_name,
    e.salary,
    d.dept_name,
    RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) as salary_rank,
    ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) as row_num
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
ORDER BY e.dept_id, e.salary DESC;

-- Exercise 2: Window Function - Running total of salaries
SELECT 
    e.emp_name,
    e.salary,
    d.dept_name,
    SUM(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.salary) as running_total
FROM employees e
LEFT JOIN departments d ON e.dept_id = e.dept_id
ORDER BY e.dept_id, e.salary;

-- Exercise 3: Window Function - Compare with previous salary
SELECT 
    e.emp_name,
    e.salary,
    LAG(e.salary) OVER (ORDER BY e.salary) as prev_salary,
    e.salary - LAG(e.salary) OVER (ORDER BY e.salary) as salary_diff
FROM employees e
WHERE LAG(e.salary) OVER (ORDER BY e.salary) IS NOT NULL
ORDER BY e.salary;

-- Exercise 4: CTE - High earners
WITH high_earners AS (
    SELECT * FROM employees 
    WHERE salary > (SELECT AVG(salary) FROM employees)
)
SELECT 
    he.emp_name,
    he.salary,
    d.dept_name
FROM high_earners he
LEFT JOIN departments d ON he.dept_id = d.dept_id
ORDER BY he.salary DESC;

-- Exercise 5: CTE - Multiple levels
WITH dept_stats AS (
    SELECT 
        dept_id,
        COUNT(*) as emp_count,
        AVG(salary) as avg_salary
    FROM employees
    GROUP BY dept_id
),
high_dept AS (
    SELECT * FROM dept_stats WHERE emp_count > 2
)
SELECT 
    d.dept_name,
    hd.emp_count,
    hd.avg_salary
FROM high_dept hd
JOIN departments d ON hd.dept_id = d.dept_id;

-- Exercise 6: Recursive CTE - Employee hierarchy
WITH RECURSIVE emp_chain AS (
    -- Base case: top-level employees (no manager)
    SELECT 
        emp_id, 
        emp_name, 
        manager_id, 
        1 as level,
        emp_name as hierarchy
    FROM emp_hierarchy 
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees under each manager
    SELECT 
        e.emp_id, 
        e.emp_name, 
        e.manager_id, 
        ec.level + 1,
        ec.hierarchy || ' -> ' || e.emp_name
    FROM emp_hierarchy e
    JOIN emp_chain ec ON e.manager_id = ec.emp_id
)
SELECT 
    REPEAT('  ', level - 1) || emp_name as employee_hierarchy,
    level
FROM emp_chain
ORDER BY hierarchy;

-- Exercise 7: JSON Query - Extract user metadata
SELECT 
    u.user_name,
    u.email,
    u.metadata->>'age' as age,
    u.metadata->>'city' as city,
    u.metadata->'hobbies' as hobbies
FROM users_with_data u;

-- Exercise 8: JSON Query - Filter by JSON field
SELECT 
    u.user_name,
    u.metadata->>'city' as city
FROM users_with_data u
WHERE u.metadata->>'city' = 'NYC';

-- Exercise 9: Full-Text Search (if FTS index is created)
-- SELECT * FROM articles 
-- WHERE tsv @@ to_tsquery('english', 'database & SQL');

-- Exercise 10: Performance query with indexes
SELECT 
    e.emp_name,
    e.salary,
    d.dept_name,
    COUNT(pa.project_id) as project_count
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN project_assignments pa ON e.emp_id = pa.emp_id
WHERE e.salary > 60000
GROUP BY e.emp_id, e.emp_name, e.salary, d.dept_name
HAVING COUNT(pa.project_id) > 0
ORDER BY e.salary DESC;

-- ============================================================================
-- QUERY OPTIMIZATION EXAMPLES
-- ============================================================================

-- Check query execution plan
EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 50000;

-- Check index usage
EXPLAIN ANALYZE SELECT * FROM employees WHERE dept_id = 2;

-- Slow query (function on indexed column)
EXPLAIN SELECT * FROM employees WHERE EXTRACT(YEAR FROM hire_date) = 2024;

-- Better query (range)
EXPLAIN SELECT * FROM employees 
WHERE hire_date >= '2024-01-01' AND hire_date < '2025-01-01';

-- ============================================================================
-- VIEW QUERIES
-- ============================================================================

-- Query employee info view
SELECT * FROM v_employee_info;

-- Query department summary view
SELECT * FROM v_dept_summary ORDER BY employee_count DESC;

-- ============================================================================
-- COMMON PATTERNS
-- ============================================================================

-- Find employees with highest salary in each department
SELECT DISTINCT ON (e.dept_id) 
    e.emp_name,
    e.dept_id,
    e.salary
FROM employees e
ORDER BY e.dept_id, e.salary DESC;

-- Find nth highest salary (5th highest)
SELECT DISTINCT salary 
FROM employees 
ORDER BY salary DESC 
LIMIT 1 OFFSET 4;

-- Find employees who worked on multiple projects
SELECT 
    e.emp_name,
    COUNT(pa.project_id) as project_count
FROM employees e
JOIN project_assignments pa ON e.emp_id = pa.emp_id
GROUP BY e.emp_id, e.emp_name
HAVING COUNT(pa.project_id) > 1;

-- ============================================================================
-- END OF EXERCISES
-- ============================================================================

\echo 'Exercises complete! Try modifying queries and experimenting with different conditions.'
