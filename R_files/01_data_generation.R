# ============================================================
# 01_data_generation.R
#
# Purpose:
#   Generate two controlled randomized A/B experiments for
#   validating heterogeneous treatment-effect estimation.
#
#   Scenario A:
#       Threshold-based treatment-effect heterogeneity.
#       This deliberately does NOT match the linear interaction
#       analysis model.
#
#   Scenario B:
#       Smooth logistic treatment-effect heterogeneity.
#       This exactly matches the analysis model used in
#       02_cate_estimation.R.
#
# Project:
#   Stability of Heterogeneous Early-Stopping Decisions
#   in Sequential A/B Experiments
# ============================================================

# ------------------------------------------------------------
# 1. Reproducibility and project paths
# ------------------------------------------------------------

set.seed(20260814)

project_root <- "C:/Users/chatt/OneDrive/Documents/GitHub Files/ab_testing"

results_dir <- file.path(
  project_root,
  "results"
)

dir.create(
  results_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ------------------------------------------------------------
# 2. Common parameters
# ------------------------------------------------------------

N <- 4000
allocation_probability <- 0.50

# Scenario A
harmed_group_probability <- 0.25
baseline_probability_A <- 0.10
harm_effect_A <- -0.04


# ============================================================
# SCENARIO A
# Threshold-based heterogeneity
# ============================================================

X_A <- rnorm(
  N,
  mean = 0,
  sd = 1
)

subgroup_threshold_A <- qnorm(
  1 - harmed_group_probability
)

harmed_group_A <- as.integer(
  X_A > subgroup_threshold_A
)

treatment_A <- rbinom(
  N,
  size = 1,
  prob = allocation_probability
)

p_control_A <- rep(
  baseline_probability_A,
  N
)

p_treatment_A <- p_control_A +
  harm_effect_A * harmed_group_A

stopifnot(
  all(p_control_A >= 0 & p_control_A <= 1),
  all(p_treatment_A >= 0 & p_treatment_A <= 1)
)

Y0_A <- rbinom(
  N,
  size = 1,
  prob = p_control_A
)

Y1_A <- rbinom(
  N,
  size = 1,
  prob = p_treatment_A
)

outcome_A <- ifelse(
  treatment_A == 1,
  Y1_A,
  Y0_A
)

true_CATE_A <- p_treatment_A - p_control_A

scenario_A <- data.frame(
  id = seq_len(N),
  X = X_A,
  harmed_group = harmed_group_A,
  treatment = treatment_A,
  outcome = outcome_A,
  p_control = p_control_A,
  p_treatment = p_treatment_A,
  true_CATE = true_CATE_A
)


# ============================================================
# SCENARIO B
# Smooth logistic heterogeneity
#
# Analysis model:
#
#   logit P(Y=1 | A,X)
#       = beta_0 + beta_X X + beta_A A + beta_AX A X
#
# X is uniform on [-1,1].
#
# beta_A + beta_AX X is negative throughout [-1,1],
# so treatment is harmful everywhere while harm varies
# smoothly with X.
# ============================================================

beta_0_B <- qlogis(0.10)
beta_X_B <- 0.20
beta_A_B <- -0.50
beta_AX_B <- -0.30

X_B <- runif(
  N,
  min = -1,
  max = 1
)

treatment_B <- rbinom(
  N,
  size = 1,
  prob = allocation_probability
)

eta_control_B <-
  beta_0_B +
  beta_X_B * X_B

eta_treatment_B <-
  beta_0_B +
  beta_X_B * X_B +
  beta_A_B +
  beta_AX_B * X_B

p_control_B <- plogis(
  eta_control_B
)

p_treatment_B <- plogis(
  eta_treatment_B
)

stopifnot(
  all(p_control_B >= 0 & p_control_B <= 1),
  all(p_treatment_B >= 0 & p_treatment_B <= 1)
)

Y0_B <- rbinom(
  N,
  size = 1,
  prob = p_control_B
)

Y1_B <- rbinom(
  N,
  size = 1,
  prob = p_treatment_B
)

outcome_B <- ifelse(
  treatment_B == 1,
  Y1_B,
  Y0_B
)

true_CATE_B <- p_treatment_B - p_control_B

scenario_B <- data.frame(
  id = seq_len(N),
  X = X_B,
  treatment = treatment_B,
  outcome = outcome_B,
  p_control = p_control_B,
  p_treatment = p_treatment_B,
  true_CATE = true_CATE_B
)


# ============================================================
# 3. Save simulated data
# ============================================================

write.csv(
  scenario_A,
  file.path(results_dir, "simulation_data_scenario_A.csv"),
  row.names = FALSE
)

write.csv(
  scenario_B,
  file.path(results_dir, "simulation_data_scenario_B.csv"),
  row.names = FALSE
)


# ============================================================
# 4. Save simulation parameters
# ============================================================

simulation_parameters <- data.frame(
  parameter = c(
    "N",
    "allocation_probability",
    "harmed_group_probability",
    "scenario_A_baseline_probability",
    "scenario_A_harm_effect",
    "scenario_B_beta_0",
    "scenario_B_beta_X",
    "scenario_B_beta_A",
    "scenario_B_beta_AX"
  ),
  value = c(
    N,
    allocation_probability,
    harmed_group_probability,
    baseline_probability_A,
    harm_effect_A,
    beta_0_B,
    beta_X_B,
    beta_A_B,
    beta_AX_B
  )
)

write.csv(
  simulation_parameters,
  file.path(results_dir, "simulation_parameters.csv"),
  row.names = FALSE
)


# ============================================================
# 5. Validation summaries
# ============================================================

validation_A <- data.frame(
  scenario = "A_threshold",
  sample_size = nrow(scenario_A),
  treatment_rate = mean(scenario_A$treatment),
  harmed_group_rate = mean(scenario_A$harmed_group),
  mean_true_CATE = mean(scenario_A$true_CATE),
  min_true_CATE = min(scenario_A$true_CATE),
  max_true_CATE = max(scenario_A$true_CATE),
  mean_control_probability = mean(scenario_A$p_control),
  mean_treatment_probability = mean(scenario_A$p_treatment)
)

validation_B <- data.frame(
  scenario = "B_smooth_logistic",
  sample_size = nrow(scenario_B),
  treatment_rate = mean(scenario_B$treatment),
  harmed_group_rate = NA_real_,
  mean_true_CATE = mean(scenario_B$true_CATE),
  min_true_CATE = min(scenario_B$true_CATE),
  max_true_CATE = max(scenario_B$true_CATE),
  mean_control_probability = mean(scenario_B$p_control),
  mean_treatment_probability = mean(scenario_B$p_treatment)
)

validation_table <- rbind(
  validation_A,
  validation_B
)

write.csv(
  validation_table,
  file.path(results_dir, "simulation_validation.csv"),
  row.names = FALSE
)


# ============================================================
# 6. Print validation results
# ============================================================

cat("\n============================================================\n")
cat("SIMULATION VALIDATION\n")
cat("============================================================\n\n")

cat("SCENARIO A: Threshold heterogeneity\n\n")
print(validation_A)

cat("\nTrue CATE by subgroup:\n\n")
print(
  aggregate(
    true_CATE ~ harmed_group,
    data = scenario_A,
    FUN = mean
  )
)

cat("\nSCENARIO B: Smooth logistic heterogeneity\n\n")
print(validation_B)

cat("\nQuantiles of the true CATE in Scenario B:\n\n")
print(
  quantile(
    scenario_B$true_CATE,
    probs = c(0, 0.05, 0.25, 0.50, 0.75, 0.95, 1)
  )
)


# ============================================================
# 7. Final validation checks
# ============================================================

# Scenario A: exact threshold structure
stopifnot(
  all(
    scenario_A$true_CATE[
      scenario_A$harmed_group == 0
    ] == 0
  )
)

stopifnot(
  all(
    scenario_A$true_CATE[
      scenario_A$harmed_group == 1
    ] == harm_effect_A
  )
)

# Scenario B: treatment is harmful everywhere
stopifnot(
  all(scenario_B$true_CATE < 0)
)

# Scenario B: genuine smooth heterogeneity
stopifnot(
  sd(scenario_B$true_CATE) > 0
)

# All probabilities are valid
stopifnot(
  all(scenario_B$p_control >= 0 & scenario_B$p_control <= 1),
  all(scenario_B$p_treatment >= 0 & scenario_B$p_treatment <= 1)
)

cat("\n============================================================\n")
cat("ALL VALIDATION CHECKS PASSED\n")
cat("============================================================\n\n")
