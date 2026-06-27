# Content map: AMCHSS RMDA resources → DMgtAsia Intro to R module

How the AMCHSS Research Methodology & Data Analysis (RMDA) workshop material maps onto this
module. Mapped June 2026.

## The source

- **RMDA Workshop** (AMC Data Science Lab, SCTIMST, Trivandrum): a 3-day course for healthcare
  professionals on research methods and data analysis in R.
  - Day 1: research design, ODK, Zotero, R/RStudio intro.
  - Day 2: data handling (read/write/visualise), variable types, descriptive stats, Quarto.
  - Day 3: inferential statistics, hypothesis testing, regression, publication tables, epi
    measures.
- **Online book:** <https://amchss.github.io/rmda_book/> (the "Introduction to R" chapter at
  `/intro_r.html` is the reference for R basics: objects, vectors, data types, operators,
  functions, packages, data frames, reading data).
- **Website:** <https://amchss.github.io/rmda_website/> (Home, Schedule, Exercise, About).

## The exercises (all on `low_birth_weight.csv`)

`low_birth_weight.csv` is the birthwt dataset: 189 rows, 10 columns
(`low, age, lwt, race, smoke, ptl, ht, ui, ftv, bwt`). It is the single running dataset for
every RMDA exercise. Copied to `data/low_birth_weight.csv`; the exercise files are in
`exercises/rmda/`.

| Exercise | Topic | Fits |
|----------|-------|------|
| **Ex 1** Understanding R Project | install, Projects, working directory, folders, packages, scripts | **Session-I / Setup** |
| **Ex 2** Importing & Exporting Data | `read_csv`, data formats, export to `.rds` | **Session-III / Session-IV** |
| **Ex 3** Data Visualization | histogram, box plot, scatter with `ggplot2` | **Session-IV** (and a viz topic) |
| **Ex 4** Data Wrangling | `dplyr` verbs, `count`, summaries, min/max | **Session-III / Session-IV** |
| Ex 6 Hypothesis Testing & CI | t-test, proportion test, ANOVA, chi-square | future **Statistics** module |
| Ex 7 Regression Analysis | linear, multiple, logistic regression | future **Statistics** module |
| Ex 8 Summary Tables (gtsummary) | `tbl_summary`, stratified tables, regression tables | future **Statistics** module |

## How to use this

- **This module (Introduction to R & RStudio)** aligns to RMDA Day 1 to early Day 2. Use
  **Ex 1 to Ex 4** as the hands-on spine:
  - Ex 1 supports Session-I (Foundations) and Setup.
  - Ex 2 and Ex 4 reinforce Session-III (Working with Data).
  - Ex 3 (visualisation) and Ex 4 (wrangling) become the core of Session-IV (Exercises),
    replacing or sitting alongside the `MASS::birthwt` demo (same dataset, so they are
    interchangeable; prefer `low_birth_weight.csv` for consistency with the RMDA book).
- **Exercises 6 to 8** (inference, regression, gtsummary) are Day 3 / statistics content.
  They belong to a **separate later module** (Statistics / Inference for Public Health), not
  this introduction. Kept in `exercises/rmda/` for reference and to seed that module.

## Note on the dataset

`low_birth_weight.csv` (10 columns) is the canonical RMDA dataset and matches the RMDA book and
all seven exercises. It supersedes the earlier `lbw_clean.csv` (kept for the IQRAA-derived
demo). Prefer `low_birth_weight.csv` going forward.
