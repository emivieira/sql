-- These are practices from a Mode.com lesson about SQL window functions
-- The dataset is from Washington DC's Capital Bikeshare Program, where each row represents one ride


-- Calculates a running total of ride durations, ordered by start time
SELECT
  duration_seconds
  ,SUM(duration_seconds) OVER (ORDER BY start_time) AS running_total
FROM tutorial.dc_bikeshare_q1_2012;


-- Calculates a running total of ride durations for each start terminal,
-- ordered by start time and limited to rides before Jan 8, 2012
SELECT
  start_terminal
  ,duration_seconds
  ,SUM(duration_seconds) OVER (
    PARTITION BY start_terminal   -- restart the running total for each start terminal
    ORDER BY start_time           -- use the chronological order of the rides (it treats every partition as separate)
  ) AS running_total
FROM tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';


-- For comparison, this query doesn't use the ORDER BY clause like the previous one.
-- Because of that, it calculates the total ride duration for each start terminal,
-- limited to rides before Jan 8, 2012
SELECT
  start_terminal
  ,duration_seconds
  ,SUM(duration_seconds) OVER (
    PARTITION BY start_terminal   -- total ride duration per start terminal (not progressive)
  ) AS start_terminal_total
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';
  
  
-- Calculates the duration of each ride as a percentage of
-- the total time accrued by riders from each start terminal
SELECT
  start_terminal
  ,duration_seconds
  ,( duration_seconds / 
    SUM(duration_seconds) OVER (PARTITION BY start_terminal)
  ) * 100 AS ride_percentage_of_start_terminal_total
  ,SUM(duration_seconds) OVER (
    PARTITION BY start_terminal   -- restart the total for each start terminal
  ) AS start_terminal_total
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';
  

-- Using aggregate functions with window functions:
-- Shows the duration of each ride from each start terminal,
-- along with the total ride duration, ride count, and average ride duration
-- per start terminal (same values repeated for all rides in the group)
SELECT
  start_terminal
  ,duration_seconds
  ,SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS total_duration    -- total duration per start terminal
  ,COUNT(duration_seconds) OVER (PARTITION BY start_terminal) AS ride_count  -- ride count per start terminal
  ,AVG(duration_seconds) OVER (PARTITION BY start_terminal) AS avg_duration      -- average ride duration per start terminal
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';
  

-- Using window functions for running calculations with aggregate functions:
-- Shows the ride duration for each ride from each start terminal,
-- along with the running total, running ride count, and running average ride duration
-- calculated progressively in chronological order (based on start_time)
SELECT
  start_terminal
  ,duration_seconds
  ,SUM(duration_seconds) OVER (PARTITION BY start_terminal ORDER BY start_time) AS running_total -- running total duration per start terminal
  ,COUNT(duration_seconds) OVER (PARTITION BY start_terminal ORDER BY start_time) AS running_count -- running ride count per start terminal
  ,AVG(duration_seconds) OVER (PARTITION BY start_terminal ORDER BY start_time) AS running_avg -- running average ride duration per start terminal
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE 
  start_time < '2012-01-08';
  

-- Calculates a running total of bike ride durations grouped by end_terminal
-- with ride durations sorted in descending order
-- Useful to understand how the longest rides contribute to the running total
SELECT
  end_terminal
  ,duration_seconds
  ,SUM(duration_seconds) OVER (PARTITION BY end_terminal ORDER BY duration_seconds DESC) AS running_total -- running total duration per end terminal
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE 
  start_time < '2012-01-08';


-- Shows the row number based on the start time
-- If more than one row has the same start time, each will receive a unique row number
-- The database engine will assign those row numbers arbitrarily among the tied rows
SELECT
  start_terminal
  ,start_time
  ,duration_seconds
  ,ROW_NUMBER() OVER (ORDER BY start_time) AS row_number
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';


-- For each start terminal, shows the row number based on the ride start time
SELECT
  start_terminal
  ,start_time
  ,duration_seconds
  ,ROW_NUMBER() OVER (PARTITION BY start_terminal ORDER BY start_time) AS row_number
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';
  

-- Shows the rank number based on the start time
-- If more than one row has the same start time, each will receive the same rank
-- The next rank will skip numbers according to the number of tied rows
SELECT
  start_terminal
  ,duration_seconds
  ,RANK() OVER (PARTITION BY start_terminal ORDER BY start_time) AS rank
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';
  

-- Shows the dense rank number based on the start time
-- If more than one row has the same start time, each will receive the same rank
-- The next rank will not skip numbers
SELECT
  start_terminal
  ,duration_seconds
  ,DENSE_RANK() OVER (PARTITION BY start_terminal ORDER BY start_time) AS dense_rank
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08';


-- Shows the 5 longest rides from each starting terminal, ordered by terminal,
-- and longest to shortest rides within each terminal
-- Limit to rides that occurred before Jan. 8, 2012
SELECT *
FROM (
  SELECT
    start_terminal
    ,duration_seconds
    ,RANK() OVER (PARTITION BY start_terminal ORDER BY duration_seconds DESC) AS rank_number
  FROM
    tutorial.dc_bikeshare_q1_2012
  WHERE
    start_time < '2012-01-08'
  ) ranking
WHERE
  ranking.rank_number <= 5;
  

-- Uses the NTILE function to divide the rides from each start terminal
-- into the specified tiles (distribution groups) based on ride duration:
-- quartiles (4 groups), quintiles (5 groups), and percentiles (100 groups).
-- The lower the duration, the lower the group number.
-- Rides are ordered by duration within each terminal.
SELECT
  start_terminal
  ,duration_seconds
  ,NTILE(4) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS quartile
  ,NTILE(5) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS quintile
  ,NTILE(100) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS percentile
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
ORDER BY
  start_terminal, duration_seconds;
  
  
-- Shows the duration of each trip and the percentile into which
-- that duration falls across the entire dataset — not partitioned by terminal
SELECT
  duration_seconds
  ,NTILE(100) OVER(ORDER BY duration_seconds) AS percentile -- divides the dataset into percentiles based on duration
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
ORDER BY duration_seconds DESC;


-- For each start terminal, shows the duration value of the previous row using LAG
-- and the duration value of the next row using LEAD
SELECT
  start_terminal
  ,duration_seconds
  ,LAG(duration_seconds, 1) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS lag
  ,LEAD(duration_seconds, 1) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS lead
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
ORDER BY
  start_terminal, duration_seconds;
  
  
-- For each start terminal, calculates the difference between
-- the duration value of the current row and the previous row
SELECT
  start_terminal
  ,duration_seconds
  ,duration_seconds - LAG(duration_seconds, 1) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS difference
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
ORDER BY
  start_terminal, duration_seconds;
  
  
-- For each start terminal, calculates the difference between
-- the duration value of the current row and the previous row
-- Filters out rows where the difference is NULL (first row of each group)
SELECT
  *
FROM (
  SELECT
    start_terminal
    ,duration_seconds
    ,duration_seconds - LAG(duration_seconds, 1) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS difference
  FROM
    tutorial.dc_bikeshare_q1_2012
  WHERE
    start_time < '2012-01-08'
  ORDER BY
    start_terminal, duration_seconds
) lags
WHERE
  lags.difference IS NOT NULL;
  
  
-- Uses a window alias to apply the same partition and order across multiple NTILE functions,
-- improving readability and avoiding repetition of the same clause.
-- Divides the rides from each start terminal into the specified tiles based on ride duration.
SELECT
  start_terminal
  ,duration_seconds
  ,NTILE(4) OVER ntile_window AS quartile
  ,NTILE(5) OVER ntile_window AS quintile
  ,NTILE(100) OVER ntile_window AS percentile
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
WINDOW ntile_window AS
  (PARTITION BY start_terminal ORDER BY duration_seconds)
ORDER BY
  start_terminal, duration_seconds;