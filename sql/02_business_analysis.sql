-- Sales & Operations Performance Analysis
-- 02_business_analysis.sql

-- 1. Overall KPIs
SELECT
    COUNT(*) AS total_interactions,
    SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) AS total_sales,
    SUM(sales_amount) AS total_revenue
FROM sales_interactions;


-- 2. Top 10 agents by revenue, with team and shift
SELECT
    si.agent_id,
    a.team,
    a.shift,
    COUNT(CASE WHEN si.outcome = 'Sale' THEN 1 END) AS number_of_sales,
    SUM(si.sales_amount) AS total_revenue,
    ROUND(
        AVG(CASE WHEN si.outcome = 'Sale' THEN si.sales_amount END),
        2
    ) AS avg_sale_value
FROM sales_interactions si
INNER JOIN agents a
    ON si.agent_id = a.agent_id
GROUP BY
    si.agent_id,
    a.team,
    a.shift
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. Conversion rate by shift
SELECT
    shift,
    COUNT(*) AS total_interactions,
    SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) AS total_sales,
    ROUND(
        SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM sales_interactions
GROUP BY shift
ORDER BY conversion_rate DESC;


-- 4. Team performance
SELECT
    team,
    COUNT(*) AS total_interactions,
    SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) AS total_sales,
    ROUND(
        SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate,
    SUM(sales_amount) AS total_revenue
FROM sales_interactions
GROUP BY team
ORDER BY total_revenue DESC;


-- 5. Average sale value by team
SELECT
    team,
    COUNT(CASE WHEN outcome = 'Sale' THEN 1 END) AS total_sales,
    SUM(sales_amount) AS total_revenue,
    ROUND(
        AVG(CASE WHEN outcome = 'Sale' THEN sales_amount END),
        2
    ) AS avg_sale_value
FROM sales_interactions
GROUP BY team
ORDER BY avg_sale_value DESC;


-- 6. Monthly sales trend
SELECT
    TO_CHAR(date, 'YYYY-MM') AS month,
    COUNT(*) AS total_interactions,
    SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) AS total_sales,
    ROUND(
        SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate,
    SUM(sales_amount) AS total_revenue
FROM sales_interactions
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY month;


-- 7. Inbound vs Outbound performance
SELECT
    interaction_type,
    COUNT(*) AS total_interactions,
    SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) AS total_sales,
    ROUND(
        SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate,
    SUM(sales_amount) AS total_revenue
FROM sales_interactions
GROUP BY interaction_type
ORDER BY conversion_rate DESC;


-- 8. Product performance
SELECT
    product,
    COUNT(*) AS total_interactions,
    SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) AS total_sales,
    ROUND(
        SUM(CASE WHEN outcome = 'Sale' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate,
    SUM(sales_amount) AS total_revenue,
    ROUND(
        AVG(CASE WHEN outcome = 'Sale' THEN sales_amount END),
        2
    ) AS avg_sale_value
FROM sales_interactions
GROUP BY product
ORDER BY total_revenue DESC;


-- 9. Target achievement by agent and month
WITH monthly_sales AS (
    SELECT
        agent_id,
        TO_CHAR(date, 'YYYY-MM') AS month,
        SUM(sales_amount) AS actual_sales
    FROM sales_interactions
    GROUP BY
        agent_id,
        TO_CHAR(date, 'YYYY-MM')
)

SELECT
    ms.agent_id,
    ms.month,
    ms.actual_sales,
    st.sales_target,
    ROUND(
        ms.actual_sales * 100.0 / st.sales_target,
        2
    ) AS target_achievement_pct
FROM monthly_sales ms
INNER JOIN sales_targets st
    ON ms.agent_id = st.agent_id
    AND ms.month = st.month
ORDER BY
    ms.month,
    target_achievement_pct DESC;


-- 10. Target achievement by month
WITH monthly_sales AS (
    SELECT
        agent_id,
        TO_CHAR(date, 'YYYY-MM') AS month,
        SUM(sales_amount) AS actual_sales
    FROM sales_interactions
    GROUP BY
        agent_id,
        TO_CHAR(date, 'YYYY-MM')
)

SELECT
    ms.month,
    SUM(ms.actual_sales) AS total_actual_sales,
    SUM(st.sales_target) AS total_target,
    ROUND(
        SUM(ms.actual_sales) * 100.0
        / SUM(st.sales_target),
        2
    ) AS target_achievement_pct
FROM monthly_sales ms
INNER JOIN sales_targets st
    ON ms.agent_id = st.agent_id
    AND ms.month = st.month
GROUP BY ms.month
ORDER BY ms.month;


-- 11. Target achievement by team
WITH team_monthly_sales AS (
    SELECT
        team,
        agent_id,
        TO_CHAR(date, 'YYYY-MM') AS month,
        SUM(sales_amount) AS actual_sales
    FROM sales_interactions
    GROUP BY
        team,
        agent_id,
        TO_CHAR(date, 'YYYY-MM')
)

SELECT
    tms.team,
    SUM(tms.actual_sales) AS total_actual_sales,
    SUM(st.sales_target) AS total_target,
    ROUND(
        SUM(tms.actual_sales) * 100.0
        / SUM(st.sales_target),
        2
    ) AS target_achievement_pct
FROM team_monthly_sales tms
INNER JOIN sales_targets st
    ON tms.agent_id = st.agent_id
    AND tms.month = st.month
GROUP BY tms.team
ORDER BY target_achievement_pct DESC;
