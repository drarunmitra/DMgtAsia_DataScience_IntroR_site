# ============================================================================
# Exploring the Low Birth Weight Dataset
# ============================================================================


# ----------------------------------------------------------------------------
# 1. Install and load the necessary packages
# ----------------------------------------------------------------------------
# pacman::p_load() installs a package only if it is missing, then loads it.
# Load MASS before tidyverse so the tidyverse verbs win any name clashes
# (e.g. dplyr::select() over MASS::select()).

if (!requireNamespace("pacman", quietly = TRUE)) {  # check whether pacman is installed
  install.packages("pacman")                        # install pacman once if it is missing
}                                                    # end of the install check

pacman::p_load(   # install (if needed) and load every package below in one step
  MASS,           # supplies the birthwt (low birth weight) dataset; load first
  tidyverse,      # dplyr, ggplot2, forcats, readr, tibble, etc.; load last
  skimr,          # skim() for rich, type-aware summaries
  janitor,        # clean_names() for tidy, consistent column names
  here            # build file paths relative to the project root
)


# ----------------------------------------------------------------------------
# 2. Load the low birth weight dataset from MASS
# ----------------------------------------------------------------------------
# birthwt records 189 births at a US medical centre, with an indicator for low
# birth weight (< 2500 g) and several maternal risk factors. Copy it locally and
# apply clean_names() so every column follows a consistent snake_case style.

lbw_data <- MASS::birthwt |>   # take the birthwt data frame from the MASS package
  as_tibble() |>               # convert it to a tibble for tidier printing
  clean_names()                # standardise the column names to snake_case


# ----------------------------------------------------------------------------
# 3. Examine the data
# ----------------------------------------------------------------------------
# Three complementary lenses: base R, dplyr::glimpse(), and skimr::skim().

# --- 3a. Base R: shape and structure ---
dim(lbw_data)      # dimensions of the data: rows then columns
nrow(lbw_data)     # number of rows (one row = one birth)
ncol(lbw_data)     # number of columns (one column = one variable)
names(lbw_data)    # the column (variable) names
str(lbw_data)      # structure: the type and first values of each column
summary(lbw_data)  # per-column summary (quartiles for numbers, counts otherwise)
head(lbw_data)     # the first six rows of the data
tail(lbw_data)     # the last six rows of the data

# --- 3b. dplyr::glimpse(): one line per column ---
glimpse(lbw_data)  # name, type, and leading values for every column

# --- 3c. skimr::skim(): rich summary ---
skim(lbw_data)     # missingness, statistics, and inline histograms by type


# ----------------------------------------------------------------------------
# 4. Read the dataset documentation
# ----------------------------------------------------------------------------
# Run one of these interactively to open the help page in the Help pane.

# ?MASS::birthwt                    # opens the help page for the dataset
# help(birthwt, package = "MASS")   # equivalent way to open the same help page

# Variables in birthwt:
#   low   - birth weight < 2500 g (1 = yes, 0 = no)
#   age   - mother's age in years
#   lwt   - mother's weight in pounds at last menstrual period
#   race  - mother's race (1 = white, 2 = black, 3 = other)
#   smoke - smoking during pregnancy (1 = yes, 0 = no)
#   ptl   - number of previous premature labours
#   ht    - history of hypertension (1 = yes, 0 = no)
#   ui    - presence of uterine irritability (1 = yes, 0 = no)
#   ftv   - physician visits in the first trimester
#   bwt   - birth weight in grams


# ----------------------------------------------------------------------------
# 5. Prepare two summary tables with dplyr verbs
# ----------------------------------------------------------------------------
# First add human-readable labels for the coded categorical variables with
# case_when(), so the tables and plots that follow read clearly.

lbw_data <- lbw_data |>                       # update the dataset, keeping the same name
  mutate(                                     # create new, labelled columns
    low_fct = case_when(                      # readable label for the low-birth-weight flag
      low == 0 ~ "Normal (>= 2500 g)",        # code 0 means normal birth weight
      low == 1 ~ "Low (< 2500 g)"             # code 1 means low birth weight
    ),                                        # end of low_fct labels
    smoke_fct = case_when(                    # readable label for smoking status
      smoke == 0 ~ "Non-smoker",              # code 0 means did not smoke
      smoke == 1 ~ "Smoker"                   # code 1 means smoked during pregnancy
    ),                                        # end of smoke_fct labels
    race_fct = case_when(                     # readable label for race
      race == 1 ~ "White",                    # code 1 = white
      race == 2 ~ "Black",                    # code 2 = black
      race == 3 ~ "Other"                     # code 3 = other
    )                                         # end of race_fct labels
  ) |>                                        # end of the first mutate()
  mutate(                                     # convert the new text labels to factors
    across(c(low_fct, smoke_fct, race_fct), as_factor)  # apply as_factor() to all three
  )                                           # end of the second mutate()

# --- Table 1: Birth weight by maternal smoking status ---
# group_by() then summarise() is the workhorse pattern for grouped summaries.

bwt_by_smoke_tbl <- lbw_data |>           # start from the labelled dataset
  group_by(smoke_fct) |>                  # form one group per smoking status
  summarise(                              # collapse each group to a single row
    n_births   = n(),                     # count of births in the group
    mean_bwt_g = round(mean(bwt), 1),     # mean birth weight, rounded to whole grams
    sd_bwt_g   = round(sd(bwt), 2),       # standard deviation of birth weight
    pct_low    = round(mean(low) * 100, 1)  # percentage of births that were low weight
  ) |>                                    # end of summarise()
  ungroup()                               # drop the grouping for safe downstream use

bwt_by_smoke_tbl                          # print Table 1

# --- Table 2: Low birth weight rate by race ---
# Count outcomes within each group, derive a percentage, then sort by risk.

low_by_race_tbl <- lbw_data |>            # start from the labelled dataset
  group_by(race_fct) |>                   # form one group per race category
  summarise(                              # collapse each group to a single row
    n_total = n(),                        # total births in the group
    n_low   = sum(low),                   # number of low-birth-weight births
    pct_low = round(sum(low) / n() * 100, 1)  # low-birth-weight percentage
  ) |>                                    # end of summarise()
  arrange(desc(pct_low)) |>               # sort from highest to lowest percentage
  ungroup()                               # drop the grouping for safe downstream use

low_by_race_tbl                           # print Table 2


# ----------------------------------------------------------------------------
# 6. Prepare two plots
# ----------------------------------------------------------------------------
# One in base graphics, one with ggplot2, so you can compare the two styles.

# --- Plot 1: Base R boxplot ---
# Birth weight by smoking status, with the 2500 g clinical threshold marked.

boxplot(                                              # draw a base-R boxplot
  bwt ~ smoke_fct,                                    # birth weight split by smoking status
  data = lbw_data,                                    # the data frame to read from
  main = "Birth weight by maternal smoking status",   # the plot title
  xlab = "Smoking status",                            # the x-axis label
  ylab = "Birth weight (g)",                          # the y-axis label
  col  = c("#9ecae1", "#fc9272")                      # one fill colour per box
)                                                     # end of boxplot()
abline(h = 2500, lty = 2, col = "red")                # add a dashed line at the 2500 g threshold

# --- Plot 2: ggplot2 boxplot ---
# Birth weight by race, split by smoking status, built up layer by layer.

lbw_plot <- lbw_data |>                                                # start from the dataset
  ggplot(aes(x = race_fct, y = bwt, fill = smoke_fct)) +               # map race, birth weight, smoking
  geom_boxplot(alpha = 0.85) +                                         # draw the boxplots, slightly transparent
  geom_hline(yintercept = 2500, linetype = "dashed", colour = "red") + # add the 2500 g threshold line
  labs(                                                                # set human-readable labels
    title = "Birth weight by race and smoking status",                 # the plot title
    x = "Mother's race",                                               # the x-axis label
    y = "Birth weight (g)",                                            # the y-axis label
    fill = "Smoking status"                                            # the legend title
  ) +                                                                  # end of labs()
  theme_minimal(base_size = 12)                                        # use a clean theme with readable text

lbw_plot                                                               # print the ggplot


# ============================================================================
# 7. Exercises
# ============================================================================
#
# (a) Render this script as HTML, PDF, and Word.
#     A plain .R script can be rendered with rmarkdown; it does not need to be
#     loaded above, it is called by name. From the console:
#
#       rmarkdown::render("d1_low_birth_weight_demo.R", output_format = "html_document")
#       rmarkdown::render("d1_low_birth_weight_demo.R", output_format = "word_document")
#       rmarkdown::render("d1_low_birth_weight_demo.R", output_format = "pdf_document")   # needs LaTeX, e.g. tinytex::install_tinytex()
#
#     Use output_format = "all" to build every format at once.
#
# (b) Create two additional summary tables, for example:
#       1. Mean maternal age (age) and weight (lwt) by low-birth-weight status (low_fct).
#       2. A cross-tabulation of smoke_fct against low_fct
#          (try janitor::tabyl(lbw_data, smoke_fct, low_fct) with adorn_*() helpers).
#
# (c) Create two additional figures, for example:
#       1. A histogram of bwt (base hist() or ggplot2::geom_histogram()).
#       2. A scatter plot of mother's weight (lwt) against birth weight (bwt),
#          coloured by low_fct, with a smoother (geom_smooth()).
#
# (d) Write the cleaned, labelled data to disk in the appropriate folder.
#     Raw inputs stay untouched in data/raw/; cleaned data belongs in
#     data/processed/. Use here() to build the path and readr::write_csv()
#     to save lbw_data as data/processed/lbw_clean.csv.
#
# Worked answers are in the companion file: d1_low_birth_weight_solutions.R
# ============================================================================
