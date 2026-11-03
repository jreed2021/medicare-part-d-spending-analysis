-- Medicare Part D analytic queries | MySQL 8+
-- Requires user's previously populated medicare_partd.partd_drug_year table.
-- All national gross spending summaries use Mftr_Name = 'Overall'.
USE medicare_partd;

-- 1. Cross-system reconciliation: 2024 overall national gross spending
SELECT ROUND(SUM(Tot_Spndng), 2) AS gross_spending_2024
FROM partd_drug_year WHERE report_year = 2024 AND Mftr_Name = 'Overall';

-- 2. Annual totals and percent change
WITH yr AS (
 SELECT report_year, SUM(Tot_Spndng) AS spending, SUM(Tot_Clms) AS fills
 FROM partd_drug_year WHERE Mftr_Name = 'Overall' GROUP BY report_year
), prior AS (
 SELECT *, LAG(spending) OVER (ORDER BY report_year) AS prev_spending,
 LAG(fills) OVER (ORDER BY report_year) AS prev_fills FROM yr
)
SELECT report_year, ROUND(spending,2) AS gross_spending, fills,
 ROUND(spending / NULLIF(fills,0),2) AS spending_per_fill,
 ROUND((spending / NULLIF(prev_spending,0)-1)*100,2) AS spending_growth_pct,
 ROUND((fills / NULLIF(prev_fills,0)-1)*100,2) AS fills_growth_pct
FROM prior ORDER BY report_year;

-- 3. Top ten 2024 drugs by gross spending
SELECT Brnd_Name, Gnrc_Name, Tot_Clms AS fills,
 ROUND(Tot_Spndng,2) AS gross_spending,
 ROUND(Avg_Spnd_Per_Clm,2) AS spending_per_fill
FROM partd_drug_year
WHERE report_year = 2024 AND Mftr_Name = 'Overall'
ORDER BY Tot_Spndng DESC LIMIT 10;

-- 4. Top ten spending concentration
WITH ranked AS (
 SELECT Tot_Spndng,
 ROW_NUMBER() OVER (ORDER BY Tot_Spndng DESC, source_row_id) AS rn
 FROM partd_drug_year WHERE report_year = 2024 AND Mftr_Name = 'Overall'
)
SELECT ROUND(SUM(Tot_Spndng),2) AS gross_spending,
 ROUND(SUM(CASE WHEN rn <= 10 THEN Tot_Spndng ELSE 0 END),2) AS top_10_spending,
 ROUND(100 * SUM(CASE WHEN rn <= 10 THEN Tot_Spndng ELSE 0 END)
 / NULLIF(SUM(Tot_Spndng),0),2) AS top_10_share_pct
FROM ranked;

-- 5. Largest absolute matched-drug spending increases and spending drivers
WITH comparison AS (
 SELECT source_row_id, Brnd_Name, Gnrc_Name,
 MAX(CASE WHEN report_year=2023 THEN Tot_Spndng END) AS spend23,
 MAX(CASE WHEN report_year=2024 THEN Tot_Spndng END) AS spend24,
 MAX(CASE WHEN report_year=2023 THEN Tot_Clms END) AS claims23,
 MAX(CASE WHEN report_year=2024 THEN Tot_Clms END) AS claims24
 FROM partd_drug_year
 WHERE Mftr_Name='Overall' AND report_year IN (2023,2024)
 GROUP BY source_row_id, Brnd_Name, Gnrc_Name
)
SELECT Brnd_Name, Gnrc_Name,
 ROUND(spend24-spend23,2) AS gross_spending_change,
 ROUND(100*(spend24/NULLIF(spend23,0)-1),2) AS spending_growth_pct,
 ROUND(100*(claims24/NULLIF(claims23,0)-1),2) AS claims_growth_pct,
 ROUND(100*((spend24/NULLIF(claims24,0)) /
 NULLIF((spend23/NULLIF(claims23,0)),0)-1),2) AS spending_per_fill_growth_pct
FROM comparison
WHERE spend23 IS NOT NULL AND spend24 IS NOT NULL
 AND claims23 > 0 AND claims24 > 0
ORDER BY gross_spending_change DESC LIMIT 10;

-- 6. Source raw row count and aggregation-level validation
SELECT COUNT(*) AS raw_rows,
 SUM(CASE WHEN Mftr_Name='Overall' THEN 1 ELSE 0 END) AS overall_rows,
 SUM(CASE WHEN Mftr_Name<>'Overall' THEN 1 ELSE 0 END) AS manufacturer_rows
FROM cms_partd_raw;

-- 7. Long-format validation (counts include historical NULL spending)
SELECT report_year, COUNT(*) AS rows_in_year,
 COUNT(Tot_Spndng) AS rows_with_spending,
 ROUND(SUM(CASE WHEN Mftr_Name='Overall' THEN Tot_Spndng ELSE 0 END),2) AS overall_spending
FROM partd_drug_year
GROUP BY report_year ORDER BY report_year;

-- 8. 2024 reconciliation check (within one cent)
SELECT COUNT(*) AS drug_records,
 MAX(ABS(Tot_Spndng/NULLIF(Tot_Clms,0)-Avg_Spnd_Per_Clm)) AS max_difference,
 SUM(CASE WHEN ABS(Tot_Spndng/NULLIF(Tot_Clms,0)-Avg_Spnd_Per_Clm)>0.01 THEN 1 ELSE 0 END) AS over_one_cent
FROM partd_drug_year WHERE report_year=2024 AND Mftr_Name='Overall';

-- 9. Outlier flags, including NULL
SELECT CASE WHEN Outlier_Flag IS NULL THEN 'Missing' ELSE CAST(Outlier_Flag AS CHAR) END AS flag,
 COUNT(*) AS records FROM partd_drug_year
WHERE report_year=2024 AND Mftr_Name='Overall'
GROUP BY flag ORDER BY flag;

-- 10. Top ten by prescription fills
SELECT Brnd_Name, Gnrc_Name, Tot_Clms, Tot_Spndng, Avg_Spnd_Per_Clm
FROM partd_drug_year WHERE report_year=2024 AND Mftr_Name='Overall'
ORDER BY Tot_Clms DESC LIMIT 10;

-- 11. Highest cost per fill among drugs with at least 1000 fills
SELECT Brnd_Name, Gnrc_Name, Tot_Clms, Tot_Spndng, Avg_Spnd_Per_Clm
FROM partd_drug_year WHERE report_year=2024 AND Mftr_Name='Overall' AND Tot_Clms>=1000
ORDER BY Avg_Spnd_Per_Clm DESC LIMIT 10;
