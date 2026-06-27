# ============================================================================
# Low Birth Weight Demo - Solutions
# Companion to d1_low_birth_weight_demo.R
# ----------------------------------------------------------------------------
# This file is self-contained: it loads the packages and rebuilds the cleaned,
# labelled lbw_data, then works through the answers to exercises (a)-(d).
# ============================================================================


# ----------------------------------------------------------------------------
# Setup: packages and cleaned data
# ----------------------------------------------------------------------------

if (!requireNamespace("pacman", quietly = TRUE)) {  # check whether pacman is installed
  install.packages("pacman")                        # install pacman once if it is missing
}                                                    # end of the install check

pacman::p_load(   # install (if needed) and load every package below in one step
  MASS,           # supplies the birthwt (low birth weight) dataset; load first
  tidyverse,      # dplyr, ggplot2, forcats, readr, tibble, etc.; load last
  skimr,          # skim() for rich, type-aware summaries
  janitor,        # clean_names() and tabyl() for tidy tabulations
  here            # build file paths relative to the project root
)

lbw_data <- MASS::birthwt |>                  # take the birthwt data from MASS
  as_tibble() |>                              # convert to a tibble for tidier printing
  clean_names() |>                            # standardise the column names to snake_case
  mutate(                                     # create the labelled columns
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
  ) |>                                        # end of mutate()
  mutate(                                     # convert the new text labels to factors
    across(c(low_fct, smoke_fct, race_fct), as_factor)  # apply as_factor() to all three
  )                                           # end of mutate()


# ----------------------------------------------------------------------------
# (a) Render the script as HTML, PDF, and Word
# ----------------------------------------------------------------------------
# Run these from the console (rmarkdown is called by name, not loaded):
#
#   rmarkdown::render("d1_low_birth_weight_demo.R", output_format = "html_document")
#   rmarkdown::render("d1_low_birth_weight_demo.R", output_format = "word_document")
#   rmarkdown::render("d1_low_birth_weight_demo.R", output_format = "pdf_document")  # needs LaTeX


# ----------------------------------------------------------------------------
# (b) Two additional summary tables
# ----------------------------------------------------------------------------

# (b.1) Mean maternal age and weight by low-birth-weight status
age_lwt_by_low_tbl <- lbw_data |>           # start from the labelled dataset
  group_by(low_fct) |>                      # one group per birth-weight category
  summarise(                                # collapse each group to a single row
    n_births    = n(),                      # number of births in the group
    mean_age    = round(mean(age), 1),      # mean maternal age, in years
    mean_lwt_lb = round(mean(lwt), 1)       # mean maternal weight, in pounds
  ) |>                                       # end of summarise()
  ungroup()                                 # drop the grouping for safe downstream use

age_lwt_by_low_tbl                          # print the table

# (b.2) Cross-tabulation of smoking status against low-birth-weight status
smoke_low_crosstab <- lbw_data |>           # start from the labelled dataset
  tabyl(smoke_fct, low_fct) |>              # counts of smoke_fct against low_fct
  adorn_totals(where = c("row", "col")) |>  # add row and column totals
  adorn_percentages(denominator = "row") |> # turn counts into within-row proportions
  adorn_pct_formatting(digits = 1) |>       # format those proportions as percentages
  adorn_ns(position = "front")              # show the raw counts alongside the percentages

smoke_low_crosstab                          # print the cross-tabulation


# ----------------------------------------------------------------------------
# (c) Two additional figures
# ----------------------------------------------------------------------------

# (c.1) Histogram of birth weight
bwt_hist <- lbw_data |>                                                 # start from the dataset
  ggplot(aes(x = bwt)) +                                                # map birth weight to the x-axis
  geom_histogram(binwidth = 250, fill = "#3182bd", colour = "white") +  # 250 g bins, white borders
  geom_vline(xintercept = 2500, linetype = "dashed", colour = "red") +  # mark the 2500 g threshold
  labs(                                                                 # set human-readable labels
    title = "Distribution of birth weight",                            # the plot title
    x = "Birth weight (g)",                                            # the x-axis label
    y = "Number of births"                                             # the y-axis label
  ) +                                                                   # end of labs()
  theme_minimal(base_size = 12)                                        # use a clean, readable theme

bwt_hist                                                               # print the histogram

# (c.2) Scatter plot of maternal weight against birth weight
lwt_bwt_scatter <- lbw_data |>                                # start from the dataset
  ggplot(aes(x = lwt, y = bwt, colour = low_fct)) +           # map weight, birth weight, low status
  geom_point(alpha = 0.7) +                                   # draw the individual points
  geom_smooth(method = "lm", se = TRUE) +                     # add a linear trend with confidence band
  labs(                                                       # set human-readable labels
    title = "Maternal weight vs birth weight",                # the plot title
    x = "Mother's weight at LMP (lb)",                        # the x-axis label
    y = "Birth weight (g)",                                   # the y-axis label
    colour = "Birth weight group"                             # the legend title
  ) +                                                          # end of labs()
  theme_minimal(base_size = 12)                               # use a clean, readable theme

lwt_bwt_scatter                                               # print the scatter plot


# ----------------------------------------------------------------------------
# (d) Write the cleaned data to disk in the appropriate folder
# ----------------------------------------------------------------------------
# Raw inputs stay untouched in data/raw/; cleaned, validated data belongs in
# data/processed/. here() builds the path from the project root, so it works
# regardless of the current working directory.

processed_dir <- here("data", "processed")              # path to the processed-data folder
dir.create(processed_dir, recursive = TRUE,             # create it (and any parent folders)
           showWarnings = FALSE)                        # stay quiet if it already exists

lbw_data |>                                             # take the cleaned, labelled dataset
  write_csv(here("data", "processed", "lbw_clean.csv")) # save it as a CSV in data/processed/

# confirm the file was written
file.exists(here("data", "processed", "lbw_clean.csv")) # should return TRUE
# ============================================================================
