-- ============================================================================
-- 02-sample-data.sql - Sample Data Population
-- ============================================================================
-- Run this after 01-setup.sql to populate the database with sample data

-- ============================================================================
-- USERS TABLE
-- ============================================================================

INSERT INTO users (first_name, last_name, email, age) VALUES
('John', 'Doe', 'john@example.com', 30),
('Jane', 'Smith', 'jane@example.com', 28),
('Bob', 'Johnson', 'bob@example.com', 35),
('Alice', 'Williams', 'alice@example.com', 29),
('Charlie', 'Brown', 'charlie@example.com', 42),
('Diana', 'Davis', 'diana@example.com', 26),
('Eve', 'Miller', 'eve@example.com', 31),
('Frank', 'Wilson', 'frank@example.com', 45),
('Grace', 'Moore', 'grace@example.com', 27),
('Henry', 'Taylor', 'henry@example.com', 33);

-- ============================================================================
-- DEPARTMENTS TABLE
-- ============================================================================

INSERT INTO departments (dept_name, location, budget) VALUES
('Sales', 'New York', 500000),
('Engineering', 'San Francisco', 800000),
('HR', 'New York', 200000),
('Marketing', 'Boston', 300000),
('Finance', 'Chicago', 400000);

-- ============================================================================
-- EMPLOYEES TABLE
-- ============================================================================

INSERT INTO employees (emp_name, dept_id, salary, hire_date, manager_id) VALUES
-- Sales Department
('Alice Johnson', 1, 55000, '2020-01-15', NULL),
('Bob Smith', 1, 52000, '2020-06-01', 1),
('Charlie Davis', 1, 48000, '2021-03-10', 1),

-- Engineering Department
('Diana Wilson', 2, 85000, '2019-02-20', NULL),
('Eve Taylor', 2, 78000, '2020-05-15', 4),
('Frank Miller', 2, 75000, '2020-08-10', 4),
('Grace Lee', 2, 72000, '2021-01-20', 4),

-- HR Department
('Henry Brown', 3, 60000, '2019-09-01', NULL),
('Ivy Martinez', 3, 55000, '2020-11-15', 8),

-- Marketing Department
('Jack Anderson', 4, 58000, '2020-04-10', NULL),
('Karen White', 4, 52000, '2021-02-01', 10),

-- Finance Department
('Leo Thomas', 5, 70000, '2019-07-15', NULL),
('Mia Jackson', 5, 65000, '2020-09-20', 12),
('Noah Harris', 5, 60000, '2021-05-10', 12);

-- ============================================================================
-- PROJECTS TABLE
-- ============================================================================

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget, status) VALUES
('Website Redesign', 2, '2024-01-01', '2024-06-30', 150000, 'Active'),
('Customer Analytics', 4, '2024-02-01', '2024-12-31', 120000, 'Active'),
('Mobile App', 2, '2024-03-15', '2025-03-15', 250000, 'Planning'),
('Sales Process Automation', 1, '2023-06-01', '2024-02-28', 80000, 'Completed'),
('Data Migration', 2, '2024-05-01', '2024-08-31', 100000, 'In Progress'),
('Cloud Infrastructure', 2, '2024-04-01', '2024-12-31', 200000, 'In Progress'),
('Market Research', 4, '2024-01-15', '2024-04-15', 45000, 'Completed');

-- ============================================================================
-- PROJECT ASSIGNMENTS TABLE
-- ============================================================================

INSERT INTO project_assignments (emp_id, project_id, role, assigned_date) VALUES
-- Website Redesign (Project 1)
(4, 1, 'Project Manager', '2024-01-01'),
(5, 1, 'Senior Developer', '2024-01-01'),
(6, 1, 'Developer', '2024-01-15'),

-- Customer Analytics (Project 2)
(10, 2, 'Project Manager', '2024-02-01'),
(11, 2, 'Analyst', '2024-02-01'),
(13, 2, 'Data Analyst', '2024-02-15'),

-- Mobile App (Project 3)
(4, 3, 'Technical Lead', '2024-03-15'),
(5, 3, 'Senior Developer', '2024-03-15'),
(7, 3, 'Developer', '2024-04-01'),

-- Sales Process Automation (Project 4)
(1, 4, 'Business Analyst', '2023-06-01'),
(5, 4, 'Developer', '2023-07-01'),

-- Data Migration (Project 5)
(6, 5, 'Database Admin', '2024-05-01'),
(7, 5, 'Engineer', '2024-05-01'),

-- Cloud Infrastructure (Project 6)
(4, 6, 'Tech Lead', '2024-04-01'),
(6, 6, 'Infrastructure Engineer', '2024-04-01'),

-- Market Research (Project 7)
(10, 7, 'Lead Researcher', '2024-01-15'),
(11, 7, 'Analyst', '2024-01-20');

-- ============================================================================
-- EMPLOYEE HIERARCHY TABLE (for advanced queries)
-- ============================================================================

INSERT INTO emp_hierarchy (emp_name, manager_id, hire_date) VALUES
('CEO - Sarah Thompson', NULL, '2010-01-01'),
('VP Engineering - Diana Wilson', 1, '2015-02-01'),
('VP Sales - Alice Johnson', 1, '2015-03-01'),
('VP HR - Henry Brown', 1, '2016-01-01'),
('Engineering Manager - Eve Taylor', 2, '2018-05-01'),
('Senior Engineer - Frank Miller', 5, '2019-06-01'),
('Engineer - Grace Lee', 5, '2020-01-01'),
('Sales Manager - Bob Smith', 3, '2018-04-01'),
('Sales Rep - Charlie Davis', 8, '2020-03-01'),
('HR Specialist - Ivy Martinez', 4, '2019-11-01');

-- ============================================================================
-- USERS WITH JSON DATA
-- ============================================================================

INSERT INTO users_with_data (user_name, email, metadata) VALUES
('Alice Cooper', 'alice.c@example.com', 
 '{"age": 30, "city": "NYC", "hobbies": ["reading", "coding"], "phone": "555-0001"}'),
('Bob Dylan', 'bob.d@example.com', 
 '{"age": 25, "city": "LA", "hobbies": ["music", "gaming"], "phone": "555-0002"}'),
('Charlie Parker', 'charlie.p@example.com', 
 '{"age": 35, "city": "Chicago", "hobbies": ["jazz", "sports"], "phone": "555-0003"}'),
('Diana Prince', 'diana.p@example.com', 
 '{"age": 28, "city": "Boston", "hobbies": ["writing", "travel"], "phone": "555-0004"}'),
('Eve Adams', 'eve.a@example.com', 
 '{"age": 32, "city": "Seattle", "hobbies": ["hiking", "photography"], "phone": "555-0005"}');

-- ============================================================================
-- VERIFY DATA
-- ============================================================================

\echo 'Sample data inserted successfully!'
\echo ''
\echo 'Summary:'
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_departments FROM departments;
SELECT COUNT(*) as total_employees FROM employees;
SELECT COUNT(*) as total_projects FROM projects;
SELECT COUNT(*) as total_assignments FROM project_assignments;
