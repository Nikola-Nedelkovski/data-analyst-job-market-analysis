-- Query 1: Total jobs, salary coverage, and average salary
SELECT 
    COUNT(*) AS total_jobs,
    COUNT(salary_standardized) AS jobs_with_salary,
    ROUND(AVG(salary_standardized::numeric), 0) AS avg_salary
FROM gsearch_jobs;

-- Query 2: Top 10 most in-demand skills
SELECT 
    TRIM(REPLACE(REPLACE(REPLACE(skill, '''', ''), '"', ''), ' ', '')) AS skill,
    COUNT(*) AS job_count
FROM gsearch_jobs,
UNNEST(STRING_TO_ARRAY(REPLACE(REPLACE(description_tokens, '[', ''), ']', ''), ',')) AS skill
WHERE description_tokens IS NOT NULL 
    AND description_tokens != '[]'
    AND TRIM(REPLACE(REPLACE(REPLACE(skill, '''', ''), '"', ''), ' ', '')) != ''
GROUP BY skill
ORDER BY job_count DESC
LIMIT 10;

-- Query 3: Average salary by skill (minimum 100 job postings)
SELECT 
    TRIM(REPLACE(REPLACE(REPLACE(skill, '''', ''), '"', ''), ' ', '')) AS skill,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_standardized::numeric), 0) AS avg_salary
FROM gsearch_jobs,
UNNEST(STRING_TO_ARRAY(REPLACE(REPLACE(description_tokens, '[', ''), ']', ''), ',')) AS skill
WHERE description_tokens IS NOT NULL 
    AND description_tokens != '[]'
    AND salary_standardized IS NOT NULL
    AND salary_standardized != ''
    AND TRIM(REPLACE(REPLACE(REPLACE(skill, '''', ''), '"', ''), ' ', '')) != ''
GROUP BY skill
HAVING COUNT(*) > 100
ORDER BY avg_salary DESC
LIMIT 10;

-- Query 4: Remote vs on-site breakdown
SELECT 
    CASE 
        WHEN work_from_home IS NOT NULL THEN 'Remote'
        ELSE 'On-site / Not specified'
    END AS work_type,
    COUNT(*) AS job_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage,
    ROUND(AVG(salary_standardized::numeric), 0) AS avg_salary
FROM gsearch_jobs
GROUP BY work_from_home
ORDER BY job_count DESC;

-- Query 5: Job type breakdown (main categories only)
SELECT 
    schedule_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_standardized::numeric), 0) AS avg_salary
FROM gsearch_jobs
WHERE schedule_type IN ('Full-time', 'Contractor', 'Part-time', 'Internship', 'Temp work')
GROUP BY schedule_type
ORDER BY job_count DESC;
