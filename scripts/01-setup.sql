-- ============================================================================
-- 01-setup.sql - Initial Database Setup and Schema
-- ============================================================================
-- This script creates the database schema with sample tables
-- Run this first to set up your learning environment

-- Create database (if not using CREATE DATABASE, connect to existing database)
-- CREATE DATABASE learn_sql;

-- ============================================================================
-- BASIC TABLES
-- ============================================================================

DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INTEGER CHECK (age >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INTERMEDIATE TABLES
-- ============================================================================

DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    budget DECIMAL(15, 2) DEFAULT 0
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    salary DECIMAL(10, 2) CHECK (salary >= 0),
    hire_date DATE DEFAULT CURRENT_DATE,
    manager_id INTEGER REFERENCES employees(emp_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INTERMEDIATE TABLES - Additional for Learning
-- ============================================================================

DROP TABLE IF EXISTS projects CASCADE;

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12, 2),
    status VARCHAR(20) DEFAULT 'Active'
);

DROP TABLE IF EXISTS project_assignments CASCADE;

CREATE TABLE project_assignments (
    assignment_id SERIAL PRIMARY KEY,
    emp_id INTEGER REFERENCES employees(emp_id),
    project_id INTEGER REFERENCES projects(project_id),
    role VARCHAR(50),
    assigned_date DATE DEFAULT CURRENT_DATE,
    UNIQUE(emp_id, project_id)
);

-- ============================================================================
-- ADVANCED TABLES - Employee Management
-- ============================================================================

DROP TABLE IF EXISTS emp_hierarchy CASCADE;

CREATE TABLE emp_hierarchy (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    manager_id INTEGER REFERENCES emp_hierarchy(emp_id),
    hire_date DATE DEFAULT CURRENT_DATE
);

-- ============================================================================
-- ADVANCED TABLES - Audit and Logging
-- ============================================================================

DROP TABLE IF EXISTS employee_audit CASCADE;

CREATE TABLE employee_audit (
    audit_id SERIAL PRIMARY KEY,
    emp_id INTEGER,
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation VARCHAR(10),  -- INSERT, UPDATE, DELETE
    changed_by VARCHAR(100) DEFAULT CURRENT_USER
);

-- ============================================================================
-- ADVANCED TABLES - JSON Data
-- ============================================================================

DROP TABLE IF EXISTS users_with_data CASCADE;

CREATE TABLE users_with_data (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Performance indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_employees_dept ON employees(dept_id);
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_emp_hierarchy_manager ON emp_hierarchy(manager_id);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Employee information with department
CREATE OR REPLACE VIEW v_employee_info AS
SELECT 
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name,
    e.hire_date,
    m.emp_name AS manager_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Department summary
CREATE OR REPLACE VIEW v_dept_summary AS
SELECT 
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    SUM(e.salary) AS total_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- ============================================================================
-- PRINT COMPLETION MESSAGE
-- ============================================================================

\echo 'Database setup complete! Tables created successfully.'
\echo 'Run 02-sample-data.sql next to populate sample data.'
