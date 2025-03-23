create_table_one <- function(diabetes) {
  lbls <- list(
    glyhb ~ "Hemoglobin A1c",
    ratio ~ "Waist/Hip Ratio",
    age ~ "Age",
    chol ~ "Cholesterol",
    gender ~ "Sex",
    frame ~ "Body Frame"
  )

  diabetes |>
    select(diabetic, glyhb, ratio, age, chol, gender, frame) |>
    filter(!is.na(diabetic)) |>
    tbl_summary(by = diabetic, label = lbls) |>
    add_difference(include = all_continuous())
}

listify_descriptions <- function(diabetes) {
  diabetes <- diabetes |>
    # calculate basic statistics by diabetes status
    group_by(diabetic) |>
    summarise(n = n(), across(c(glyhb, ratio, age), \(x) mean(x, na.rm = TRUE))) |>
    # clean up data to include in text
    mutate(
      across(where(is.numeric), round),
      diabetic = fct_na_value_to_level(diabetic, level = "Missing")
    )

  # split into a list of data frames by diabetes status
  split(diabetes, diabetes$diabetic)
}

create_figure_one <- function(diabetes) {
  fig1a <- diabetes |>
    drop_na() |>
    ggplot(aes(ratio, glyhb)) +
    geom_point(shape = 21, fill = "grey80", color = "white", size = 2) +
    geom_smooth(
      linewidth = 1,
      color = "steelblue",
      se = FALSE,
      method = "lm",
      formula = y ~ x
    ) +
    scale_x_log10() +
    theme_minimal(14) +
    labs(
      x = "Hip/waist ratio",
      y = "Hemoglobin A1c",
      tag = "A"
    )

  fig1b <- diabetes |>
    drop_na() |>
    mutate(diabetic = factor(diabetic, levels = c("Healthy", "Diabetic"))) |>
    ggplot(aes(ratio, fill = diabetic)) +
    geom_density(color = "white", alpha = .8) +
    theme_minimal(14) +
    theme(
      legend.title = element_blank(),
      legend.position = "bottom"
    ) +
    labs(x = "Hip/waist ratio", tag = "B") +
    scale_fill_manual(values = c("steelblue", "firebrick"))

  fig1a + fig1b
}


create_table_two <- function(diabetes) {
  lbls_reg <- list(age ~ "Age", ratio ~ "Waist/Hip Ratio")

  diabetes <- diabetes |>
    drop_na() |>
    mutate(diabetic = factor(diabetic, levels = c("Healthy", "Diabetic")))

  linear_mod_tbl <- lm(glyhb ~ ratio + age, data = diabetes) |>
    tbl_regression(label = lbls_reg)

  logistic_mod_tbl <- glm(
    factor(diabetic) ~ ratio + age,
    data = diabetes,
    family = binomial()
  ) |>
    tbl_regression(label = lbls_reg, exponentiate = TRUE)

  tbl_merge(
    tbls = list(linear_mod_tbl, logistic_mod_tbl),
    tab_spanner = c(
      "**Linear model (HbA1c)**",
      "**Logistic model (Diabetes status)**"
    )
  )
}
