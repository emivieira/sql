# SQL Window Functions

This folder contains practice exercises and case studies focused on SQL Window Functions.

*"How to analyze trends and rankings without collapsing rows"*

```sql
-- Example: calculates a running total of ride durations
-- for each start terminal, ordered by start time
SELECT
  start_terminal,
  duration_seconds,
  SUM(duration_seconds) OVER (PARTITION BY start_terminal ORDER BY start_time) AS running_total
FROM dc_bikeshare;
```

---

## 💡 Business Applications Examples
1. **User Retention**: Perform cohort analysis and track behavior over time using date-based partitions.
2. **A/B Testing**: Compare group-level metrics and windowed averages or ranks.
3. **Anomaly Detection**: Spot outliers and unexpected shifts using NTILE-based ranks and moving averages.
4. **Revenue Trends**: Calculate running totals or average revenue over time to identify growth patterns or seasonality.

## 📂 Contents

### [bikeshare-analysis/](bikeshare-analysis)
Exercises from [Mode Analytics SQL Tutorial](https://mode.com/sql-tutorial/sql-window-functions/), using data from Washington DC's Capital Bikeshare Program.  

**Covers**:  
- `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`  
- Time-series analysis with `LAG()` and `LEAD()` 
- `NTILE()`
- `OVER()` with aggregates
- Performance implications of `PARTITION BY`

---

## Topics Covered Across Projects

- Ranking and row numbering
- Windowed aggregates
- Lead-lag comparison
- Partitioning and ordering logic
- Real-world use cases with public datasets

---

**More datasets and examples will be added soon.**

