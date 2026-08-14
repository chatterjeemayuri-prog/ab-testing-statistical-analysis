# ============================================================
# 03_sequential_simulation.R
#
# Purpose:
#   Turn the fixed simulated A/B experiment into a sequential
#   experiment by evaluating treatment-effect heterogeneity at
#   a series of interim sample sizes.
#
#   IMPORTANT:
#   This is the sequential simulation framework only.
#   It does NOT implement CLASH or an early-stopping rule yet.
#
#   At each interim:
#       1. use data available so far;
#       2. fit the same CATE model as in 02_cate_estimation.R;
#       3. estimate CATEs;
#       4. record how the estimated heterogeneity changes.
#
#   This gives us the baseline needed before introducing
#   sequential stopping.
#
# ============================================================


# ------------------------------------------------------------
# 1. Project paths
# ------------------------------------------------------------

project_root <-
  "C:/Users/chatt/OneDrive/Documents/GitHub Files/ab_testing"

results_dir <-
  file.path(
    project_root,
    "results"
  )


# ------------------------------------------------------------
# 2. Input files
# ------------------------------------------------------------

scenario_A_file <-
  file.path(
    results_dir,
    "simulation_data_scenario_A.csv"
  )

scenario_B_file <-
  file.path(
    results_dir,
    "simulation_data_scenario_B.csv"
  )


if (!file.exists(scenario_A_file)) {
  stop(
    "Scenario A file not found:\n",
    scenario_A_file,
    "\nRun 01_data_generation.R first."
  )
}

if (!file.exists(scenario_B_file)) {
  stop(
    "Scenario B file not found:\n",
    scenario_B_file,
    "\nRun 01_data_generation.R first."
  )
}


# ------------------------------------------------------------
# 3. Load data
# ------------------------------------------------------------

scenario_A <-
  read.csv(
    scenario_A_file,
    stringsAsFactors = FALSE
  )

scenario_B <-
  read.csv(
    scenario_B_file,
    stringsAsFactors = FALSE
  )


# ============================================================
# 4. Define interim sample sizes
# ============================================================

# We use cumulative interims rather than independent samples.
#
# The same randomized experiment is therefore examined at
# progressively larger information levels.

interim_fractions <-
  c(
    0.25,
    0.40,
    0.55,
    0.70,
    0.85,
    1.00
  )


# ------------------------------------------------------------
# Convert fractions to actual sample sizes
# ------------------------------------------------------------

interim_sizes <-
  floor(
    nrow(scenario_A) *
      interim_fractions
  )

interim_sizes <-
  unique(
    interim_sizes
  )


cat("\n")
cat("============================================================\n")
cat("SEQUENTIAL SIMULATION\n")
cat("============================================================\n\n")

cat(
  "Interim sample sizes:\n"
)

print(interim_sizes)


# ============================================================
# 5. Function for one interim analysis
# ============================================================

run_interim_analysis <- function(
    data,
    interim_size,
    scenario_name
) {

  # ----------------------------------------------------------
  # Take the first observations accumulated so far.
  # ----------------------------------------------------------

  interim_data <-
    data[
      seq_len(interim_size),
      ,
      drop = FALSE
    ]


  # ----------------------------------------------------------
  # Fit the same CATE model used previously.
  # ----------------------------------------------------------

  model <-
    glm(
      outcome ~ treatment * X,
      data = interim_data,
      family = binomial(
        link = "logit"
      )
    )


  # ----------------------------------------------------------
  # Counterfactual predictions for every individual currently
  # observed.
  # ----------------------------------------------------------

  data_0 <-
    interim_data

  data_0$treatment <-
    0


  data_1 <-
    interim_data

  data_1$treatment <-
    1


  M0 <-
    model.matrix(
      ~ treatment * X,
      data = data_0
    )

  M1 <-
    model.matrix(
      ~ treatment * X,
      data = data_1
    )


  beta <-
    coef(model)


  p0_hat <-
    plogis(
      as.vector(
        M0 %*% beta
      )
    )


  p1_hat <-
    plogis(
      as.vector(
        M1 %*% beta
      )
    )


  CATE_hat <-
    p1_hat -
    p0_hat


  # ----------------------------------------------------------
  # Overall A/B estimate at this interim
  # ----------------------------------------------------------

  control_rate <-
    mean(
      interim_data$outcome[
        interim_data$treatment == 0
      ]
    )


  treatment_rate <-
    mean(
      interim_data$outcome[
        interim_data$treatment == 1
      ]
    )


  ATE_hat <-
    treatment_rate -
    control_rate


  # ----------------------------------------------------------
  # Summaries of estimated heterogeneity
  # ----------------------------------------------------------

  mean_CATE <-
    mean(
      CATE_hat
    )


  sd_CATE <-
    sd(
      CATE_hat
    )


  min_CATE <-
    min(
      CATE_hat
    )


  max_CATE <-
    max(
      CATE_hat
    )


  # ----------------------------------------------------------
  # Fraction of estimated population with negative CATE
  # ----------------------------------------------------------

  fraction_negative <-
    mean(
      CATE_hat < 0
    )


  # ----------------------------------------------------------
  # Truth, retained only for simulation diagnostics
  # ----------------------------------------------------------

  mean_true_CATE <-
    mean(
      interim_data$true_CATE
    )


  # ----------------------------------------------------------
  # Return one-row summary
  # ----------------------------------------------------------

  data.frame(

    scenario =
      scenario_name,

    interim_n =
      interim_size,

    information_fraction =
      interim_size /
      nrow(data),

    treatment_rate =
      mean(
        interim_data$treatment
      ),

    ATE_hat =
      ATE_hat,

    mean_CATE_hat =
      mean_CATE,

    sd_CATE_hat =
      sd_CATE,

    min_CATE_hat =
      min_CATE,

    max_CATE_hat =
      max_CATE,

    fraction_negative_CATE =
      fraction_negative,

    mean_true_CATE =
      mean_true_CATE
  )
}


# ============================================================
# 6. Run Scenario A sequentially
# ============================================================

cat("\n")
cat("============================================================\n")
cat("SCENARIO A\n")
cat("============================================================\n\n")


sequential_A_list <-
  lapply(
    interim_sizes,
    function(n) {

      run_interim_analysis(
        data =
          scenario_A,

        interim_size =
          n,

        scenario_name =
          "A_threshold"
      )
    }
  )


sequential_A <-
  do.call(
    rbind,
    sequential_A_list
  )


print(
  sequential_A
)


# ============================================================
# 7. Run Scenario B sequentially
# ============================================================

cat("\n")
cat("============================================================\n")
cat("SCENARIO B\n")
cat("============================================================\n\n")


sequential_B_list <-
  lapply(
    interim_sizes,
    function(n) {

      run_interim_analysis(
        data =
          scenario_B,

        interim_size =
          n,

        scenario_name =
          "B_smooth_logistic"
      )
    }
  )


sequential_B <-
  do.call(
    rbind,
    sequential_B_list
  )


print(
  sequential_B
)


# ============================================================
# 8. Combine results
# ============================================================

sequential_results <-
  rbind(
    sequential_A,
    sequential_B
  )


# ============================================================
# 9. Save results
# ============================================================

write.csv(
  sequential_results,
  file.path(
    results_dir,
    "sequential_CATE_summary.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 10. Final output
# ============================================================

cat("\n")
cat("============================================================\n")
cat("SEQUENTIAL SIMULATION COMPLETED\n")
cat("============================================================\n\n")

cat(
  "Results saved to:\n",
  file.path(
    results_dir,
    "sequential_CATE_summary.csv"
  ),
  "\n\n"
)

print(
  sequential_results
)
