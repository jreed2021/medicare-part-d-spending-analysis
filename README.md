# Medicare Part D Spending & Utilization Analysis (2020–2024)

**Healthcare analytics portfolio project | Python · pandas · MySQL · SQL · Tableau**

[**Explore the interactive Tableau dashboard**](https://public.tableau.com/app/profile/janessa.reed/viz/MedicarePartDSpendingUtilizationAnalysis/MedicarePartDSpendingUtilizationAnalysis) · [**Read the executive report**](reports/executive_report.pdf)

## Executive overview

This project analyzes publicly reported **Centers for Medicare & Medicaid Services (CMS) Medicare Part D Spending by Drug** data for 2020–2024 to understand changes in prescription drug expenditures and utilization. It combines data-quality checks, reproducible Python analysis, SQL reporting, and an executive Tableau dashboard.

**Business question:** Which medications account for the most reported gross spending, how do changes in prescription fills and spending per claim relate to spending trends, and which products warrant closer financial review?

The work is a portfolio case study using public, aggregated CMS records—not an analysis of an individual insurer's claims or net pharmacy costs.

## Interactive dashboard

**[View the Medicare Part D Executive Performance Dashboard on Tableau Public](https://public.tableau.com/app/profile/janessa.reed/viz/MedicarePartDSpendingUtilizationAnalysis/MedicarePartDSpendingUtilizationAnalysis)**

The dashboard contains:
- Three 2024 KPIs: **gross spending**, **year-over-year spending growth**, and **prescription fills growth**.
- Annual gross spending trend, 2020–2024.
- Top 10 medications by 2024 gross spending.
- A 2023–2024 comparison of claims growth and average spending-per-claim growth for selected drugs.

## Key findings

| Measure | Finding |
|---|---:|
| 2024 reported gross drug spending | **$288.67 billion** |
| 2023–2024 gross spending growth | **+4.66%** |
| 2023–2024 prescription fills growth | **+5.87%** |
| 2023–2024 average spending per fill change | **approximately −1.14%** |
| Top 10 drugs' share of 2024 gross spending | **28.51%** |
| Largest 2024 gross spending drug | **Eliquis — approximately $20.77B** |
| Highest 2024 prescription fill count | **Atorvastatin — approximately 73.35M fills** |
| Largest 2023–2024 absolute spending increase among drugs reported in both years | **Mounjaro — approximately +$3.98B** |

### Interpretation

**Total spending increased while average spending per fill decreased.** Reported 2024 spending grew 4.66% alongside a 5.87% increase in prescription fills, more than offsetting the approximately 1.14% decline in average spending per fill. These are aggregate accounting relationships, not proof of a particular pricing, prescribing, or coverage change.

**Spending and utilization rankings differ.** Atorvastatin had far more fills than Eliquis, yet Eliquis generated substantially greater gross spending because its spending per fill was much higher. This illustrates why total spending, claims volume, and spending per claim must be interpreted together.

**High-growth products warrant follow-up.** Among drugs with reported data in both 2023 and 2024, Mounjaro's reported gross spending increased approximately $3.98B. Its fills increased 180.29%, while spending per claim decreased 4.26%. Ozempic and Jardiance also showed substantial fills growth alongside lower spending per claim. These changes support further investigation, not automatic conclusions about prices or appropriateness.

## Data quality and validation

The source CSV contains **14,536 records and 46 columns**, with **3,625 `Overall` drug records** in 2024. It includes both overall drug totals and manufacturer-specific records for the same drug. Summing both levels together **double-counts spending**:

| 2024 aggregation | Reported total |
|---|---:|
| All rows, unfiltered | Approximately $577.34B |
| `Mftr_Name = 'Overall'` only | **$288,667,842,058.40** |

Data-quality checks included:
- No exact duplicate rows in the original CSV; no duplicate brand/generic keys among `Overall` records.
- Independent reconciliation of CMS-reported 2024 average spending per claim against total spending divided by total claims: **0 of 3,625 overall records differed by more than $0.01** (maximum absolute difference about $0.00000412).
- Review of 2024 outlier flags among overall records: **395 flagged**, **3,212 not flagged**, and **18 missing**.
- Preservation of missing historical values rather than automatically treating missingness as zero.
- Cross-validation of annual reported spending between Python and MySQL after reshaping the source dataset.

A CMS outlier flag does **not** itself establish that a claim is wrong or fraudulent.

## Analytical workflow

1. **Business framing:** Define utilization and spending questions and leadership-facing metrics.
2. **Python exploration:** Inspect source structure, missingness, duplicate keys, aggregation levels, and drug-specific trends.
3. **Financial validation:** Reconcile reported average spending per fill and check CMS outlier flags.
4. **MySQL database:** Load original source records into a staging table and reshape five annual column groups into a drug-year analytical table (**72,680 rows**, including missing historical observations).
5. **SQL analysis:** Use CTEs, conditional aggregation, `LAG()`, ranking, and year-over-year calculations to evaluate spending, utilization, high-spending products, concentration, and spending drivers.
6. **Tableau reporting:** Publish an executive dashboard using overall drug records only (**18,125 drug-year rows** across five years).
7. **Business communication:** Document findings, caveats, and priorities in an executive report.

## Repository structure

```text
medicare-part-d-spending-analysis/
├── README.md
├── notebooks/
│   └── Medicare_Part_D_Complete_Analysis.ipynb
├── sql/
│   ├── 01_database_setup.sql
│   └── 02_analytical_queries.sql
├── data/
│   ├── DSD_PTD_RY26_P04_V10_DY24_BGM.csv
│   ├── medicare_partd_tableau.csv
│   └── spending_drivers_2024.csv
├── reports/
│   └── executive_report.pdf
└── references/
    ├── DSD_PTD_RY26_20260603_Methodology_WDDSE_508.pdf
    └── Medicare Part D Spending by Drug Data Dictionary 20260603_508.pdf
```

**Note:** This is the intended organized layout. GitHub links to files will work once the uploaded files are moved into these folders. The published Tableau dashboard is linked above; its workbook is hosted on Tableau Public.

## Tools and methods

| Tool | How it was used |
|---|---|
| Python / pandas | Importing, cleaning, reshaping, validation, descriptive analysis, and percentage-change calculations |
| MySQL / SQL | Staging and analytical tables, aggregation, window functions, rankings, and cross-system reconciliation |
| Tableau Public | KPI cards, annual trend chart, top-spending drug ranking, and utilization/spending-driver comparison |
| GitHub | Documentation, versioned source analysis, SQL scripts, and portfolio presentation |

## How to review or reproduce

**Read-only review:** Open the Tableau link, the [executive report](reports/executive_report.pdf), the [Python notebook](notebooks/Medicare_Part_D_Complete_Analysis.ipynb), or the [SQL queries](sql/02_analytical_queries.sql).

**Python:** Install `pandas`, `numpy`, and any other libraries imported by the notebook in your own environment, then open the notebook in Jupyter or VS Code. Point its CSV read step at `data/DSD_PTD_RY26_P04_V10_DY24_BGM.csv` if necessary and run the analysis. The notebook and source dataset are provided for review.

**MySQL:** The [setup script](sql/01_database_setup.sql) and [analytical queries](sql/02_analytical_queries.sql) document the database approach. A new MySQL environment must have the source data loaded and the analytical `partd_drug_year` table populated before running the analytical queries. Never publish database passwords or a populated `.env` file.

## Limitations

- Spending represents **reported gross expenditures**, not net insurer or Medicare costs after confidential rebates, discounts, and other concessions.
- CMS drug data are **aggregated**, not patient-level; changes in brand and generic fills cannot prove that individual patients switched products.
- Missing or suppressed historical observations mean that cross-year results do not necessarily describe a constant cohort of drugs.
- Average spending per claim is **not the same as drug unit price**. Product mix, quantities, dosage units, and other factors can affect it.
- The top-spending and matched-drug growth analyses are **descriptive**, not evidence of inappropriate utilization or a basis for restricting beneficiary access.
- This project does not measure individual Part D plan performance, benefit design, or clinical outcomes.

## Source and documentation

- **CMS:** [Medicare Part D Spending by Drug](https://data.cms.gov/summary-statistics-on-use-and-payments/medicare-medicaid-spending-by-drug/medicare-part-d-spending-by-drug).
- **CMS methodology and data dictionary:** The June 2026 documents supplied with this repository in [`references/`](references/).

---

*Portfolio project demonstrating healthcare financial analytics, data-quality controls, reproducible Python and SQL workflows, and executive dashboard communication.*
