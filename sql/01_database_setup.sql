-- Sales & Operations Performance Analysis
-- 01_database_setup.sql
--
-- IMPORTANT:
-- Create the database separately while connected to the default "postgres" database:
--
--     CREATE DATABASE sales_operations;
--
-- Then connect DBeaver to the "sales_operations" database BEFORE running the table setup below.

CREATE TABLE agents (
    agent_id VARCHAR(10) PRIMARY KEY,
    team VARCHAR(20) NOT NULL,
    shift VARCHAR(20) NOT NULL
);

CREATE TABLE sales_targets (
    month CHAR(7) NOT NULL,
    agent_id VARCHAR(10) NOT NULL,
    team VARCHAR(20) NOT NULL,
    shift VARCHAR(20) NOT NULL,
    sales_target NUMERIC(10,2) NOT NULL
        CHECK (sales_target >= 0),

    PRIMARY KEY (month, agent_id),

    FOREIGN KEY (agent_id)
        REFERENCES agents(agent_id)
);

CREATE TABLE sales_interactions (
    interaction_id VARCHAR(20) PRIMARY KEY,
    date DATE NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    agent_id VARCHAR(10) NOT NULL,
    team VARCHAR(20) NOT NULL,
    shift VARCHAR(20) NOT NULL,
    interaction_type VARCHAR(20) NOT NULL,
    product VARCHAR(30) NOT NULL,
    outcome VARCHAR(20) NOT NULL,
    sales_amount NUMERIC(10,2) NOT NULL
        CHECK (sales_amount >= 0),
    handle_time_minutes NUMERIC(6,1) NOT NULL
        CHECK (handle_time_minutes > 0),

    FOREIGN KEY (agent_id)
        REFERENCES agents(agent_id)
);

-- Import the CSV files in this order:
-- 1) agents.csv                  -> agents
-- 2) sales_targets_clean.csv     -> sales_targets
-- 3) sales_interactions_clean.csv -> sales_interactions
--
-- After importing the synthetic target data, recalibrate targets for the portfolio scenario:

-- IMPORTANT: Run this UPDATE only once after importing
-- the original sales_targets_clean.csv file.
-- Re-running it will modify the targets again.

UPDATE sales_targets
SET sales_target =
    ROUND(sales_target * 0.30 / 50) * 50;
