# Medicare Part D Spending & Utilization Analysis (2020–2024)

**Healthcare analytics portfolio project | Python · MySQL · Tableau**

[**Explore the published Tableau executive dashboard**](https://public.tableau.com/app/profile/janessa.reed/viz/MedicarePartDSpendingUtilizationAnalysis/MedicarePartDSpendingUtilizationAnalysis)

## Project overview
Analyzed CMS Medicare Part D Spending by Drug data to evaluate national gross expenditure trends, prescription utilization, spending concentration, and drug-level changes from 2020–2024. Designed data-quality controls to prevent double-counting, reconcile spending measures, and document CMS outlier and missingness limitations.

### Key results
| Metric | Result |
|---|---:|
| 2024 reported gross spending | **$288.67B** |
| 2024 spending growth | **+4.66%** |
| 2024 prescription-fill growth | **+5.87%** |
| 2024 average spending per fill change | **~−1.14%** |
| Spending share of top 10 drugs | **28.51%** |
| Highest gross spending (2024) | **Eliquis — $20.77B** |
| Largest 2023–2024 matched-drug dollar increase | **Mounjaro — ~$3.98B** |

## Analytical workflow
1. **Python / pandas:** loaded 14,536 source records, investigated missingness, duplicates, aggregation levels, and drug-level trend patterns.
2. **Data quality:** isolated `Mftr_Name = 'Overall'` to avoid summing overall and manufacturer-detail spending together; recalculated spending per claim and tested a $0.01 reconciliation tolerance.
3. **MySQL:** imported the raw data, created a long-format `partd_drug_year` table (72,680 rows), reconciled totals, and queried growth rates and rankings using CTEs, conditional aggregation, and window functions.
4. **Tableau:** produced an executive dashboard with three KPIs, an annual spending trend, top-10 drug spending, and a selected three-drug utilization-versus-spending-per-claim comparison.

## Repository contents
```text
.
├── README.md
├── EXECUTIVE_REPORT.md
├── executive_report.pdf
├── sql/
│   └── medicare_partd_analysis.sql
├── notebooks/
│   └── [add your completed Jupyter notebook here]
├── dashboard/
│   └── DASHBOARD_LINK.md
└── .gitignore
```

**Before publishing:** Copy your completed local Jupyter notebook into `notebooks/` and save your original Workbench queries in `sql/` if they differ from the reproducibility script provided here. Do not claim missing local files are already included. The CSV and CMS PDFs are downloadable from CMS; they are not bundled in this starter package.

## Methods and precautions
- Use only **Overall** aggregation rows for national program-wide totals.
- Keep historical missing observations as missing; do not assume `NULL = 0`.
- Average spending per fill is calculated as **SUM(spending) / SUM(fills)**, not the simple mean of drug-level averages.
- National gross spending is **before confidential rebates/price concessions** and is not plan-specific net cost.
- Annual trend comparisons are based on reported annual observations, not a constant drug cohort.
- Aggregate data cannot establish patient-level switching or clinical appropriateness.

## Data source
CMS, [Medicare Part D Spending by Drug](https://data.cms.gov/summary-statistics-on-use-and-payments/medicare-medicaid-spending-by-drug/medicare-part-d-spending-by-drug), including the published methodology and data dictionary (June 2026).

## Skills demonstrated
Python/pandas · SQL/MySQL · ETL reshaping · Data validation · Financial reconciliation · CTEs and window functions · Healthcare data interpretation · Tableau dashboarding · Executive reporting
