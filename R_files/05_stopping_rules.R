# ============================================================
# 05_stopping_rules.R
#
# Purpose:
#   Apply transparent baseline stopping rules to the repeated
#   sequential simulation.
#
#   RULE 1: ATE-based harm stopping
#   RULE 2: CATE-based harm-fraction stopping
#
#   No CLASH implementation is included here.
#   No stability-enhanced rule is included yet.
#
#   This script establishes the baseline decision framework
#   against which the later stability-based rule can be compared.
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
# 2. Input
# ------------------------------------------------------------

input_file <-
  file.path(
    results_dir,
    "repeated_sequential_results.csv"
  )

if (!file.exists(input_file)) {

  stop(
    "Could not find:\n",
    input_file,
    "\nRun 04_repeated_sequential_simulation.R first."
  )
}


simulation_results <-
  read.csv(
    input_file,
    stringsAsFactors = FALSE
  )


# ============================================================
# 3. Decision parameters
# ============================================================

# Minimum harmful ATE on the probability scale.
#
# Example:
#   -0.01 means treatment is considered meaningfully harmful
#   if estimated ATE is at or below -1 percentage point.

ATE_harm_threshold <-
  -0.01


# Minimum CATE harm threshold.
#
# A person is classified as meaningfully harmed when
#
#       estimated CATE <= -delta
#
# Here delta = 0.02 corresponds to a 2 percentage-point
# decrease in outcome probability.

CATE_harm_threshold <-
  -0.02


# Minimum fraction of the population estimated to be meaningfully
# harmed.

harm_fraction_threshold <-
  0.50


# ------------------------------------------------------------
# Optional statistical-evidence requirement
# ------------------------------------------------------------
#
# For this first baseline we deliberately use point estimates.
#
# We are NOT yet adding confidence intervals, alpha spending,
# or multiplicity correction.
#
# That will be addressed when we construct the formal
# sequential stopping methodology.


# ============================================================
# 4. Baseline stopping rules
# ============================================================


# ------------------------------------------------------------
# Rule 1: ATE-based stopping
# ------------------------------------------------------------

simulation_results$stop_ATE <-
  simulation_results$ATE_hat <=
  ATE_harm_threshold


# ------------------------------------------------------------
# Rule 2: CATE-based stopping
# ------------------------------------------------------------

simulation_results$stop_CATE <-
  simulation_results$fraction_negative_CATE >=
  harm_fraction_threshold


# ------------------------------------------------------------
# 5. Determine first stopping interim
# ------------------------------------------------------------

first_stop <- function(
    stop_indicator,
    interim_n
) {

  if (
    any(stop_indicator)
  ) {

    return(
      min(
        interim_n[
          stop_indicator
        ]
      )
    )

  } else {

    return(
      NA_real_
    )
  }
}


# ------------------------------------------------------------
# Apply within each replicate and scenario
# ------------------------------------------------------------

group_keys <-
  unique(
    simulation_results[
      c(
        "replicate",
        "scenario"
      )
    ]
  )


decision_rows <-
  vector(
    "list",
    nrow(group_keys)
  )


for (
  i in seq_len(
    nrow(group_keys)
  )
) {

  current_replicate <-
    group_keys$replicate[i]

  current_scenario <-
    group_keys$scenario[i]


  current_data <-
    simulation_results[
      simulation_results$replicate ==
        current_replicate &
      simulation_results$scenario ==
        current_scenario,
      ,
      drop = FALSE
    ]


  current_data <-
    current_data[
      order(
        current_data$interim_n
      ),
      ,
      drop = FALSE
    ]


  stop_n_ATE <-
    first_stop(
      current_data$stop_ATE,
      current_data$interim_n
    )


  stop_n_CATE <-
    first_stop(
      current_data$stop_CATE,
      current_data$interim_n
    )


  decision_rows[[i]] <-
    data.frame(

      replicate =
        current_replicate,

      scenario =
        current_scenario,

      first_stop_ATE =
        stop_n_ATE,

      first_stop_CATE =
        stop_n_CATE,

      stopped_ATE =
        !is.na(stop_n_ATE),

      stopped_CATE =
        !is.na(stop_n_CATE)
    )
}


decision_summary <-
  do.call(
    rbind,
    decision_rows
  )


# ============================================================
# 6. Add true decision status
# ============================================================
#
# The true population ATE differs between scenarios:
#
# Scenario A:
#     approximately -0.01
#
# Scenario B:
#     approximately -0.037
#
# For this baseline exercise, we classify a scenario as
# "truly meaningfully harmful" when its true mean CATE is
# <= the ATE threshold.
#
# This is a simulation truth label, not something available
# to the stopping procedure.


true_effect_by_scenario <-
  aggregate(
    mean_true_CATE ~ scenario,
    data =
      simulation_results,
    FUN =
      mean
  )


true_effect_by_scenario$truly_harmful <-
  true_effect_by_scenario$mean_true_CATE <=
  ATE_harm_threshold


decision_summary <-
  merge(
    decision_summary,
    true_effect_by_scenario[
      c(
        "scenario",
        "mean_true_CATE",
        "truly_harmful"
      )
    ],
    by =
      "scenario",
    all.x =
      TRUE
  )


# ============================================================
# 7. Stopping performance summary
# ============================================================

performance_summary <-
  aggregate(
    cbind(
      stopped_ATE,
      stopped_CATE
    ) ~ scenario,
    data =
      decision_summary,
    FUN =
      mean
  )


# ------------------------------------------------------------
# False-stop / missed-stop interpretation
# ------------------------------------------------------------

performance_summary$true_harmful <-
  true_effect_by_scenario$truly_harmful[
    match(
      performance_summary$scenario,
      true_effect_by_scenario$scenario
    )
  ]


performance_summary$ATE_false_stop <-
  ifelse(
    performance_summary$true_harmful,
    NA_real_,
    performance_summary$stopped_ATE
  )


performance_summary$CATE_false_stop <-
  ifelse(
    performance_summary$true_harmful,
    NA_real_,
    performance_summary$stopped_CATE
  )


performance_summary$ATE_missed_stop <-
  ifelse(
    performance_summary$true_harmful,
    1 -
      performance_summary$stopped_ATE,
    NA_real_
  )


performance_summary$CATE_missed_stop <-
  ifelse(
    performance_summary$true_harmful,
    1 -
      performance_summary$stopped_CATE,
    NA_real_
  )


# ============================================================
# 8. Stopping-time summaries
# ============================================================

mean_stop_times <-
  data.frame(

    scenario =
      unique(
        decision_summary$scenario
      )
  )


mean_stop_times$mean_first_stop_ATE <-
  sapply(
    mean_stop_times$scenario,
    function(s) {

      x <-
        decision_summary$first_stop_ATE[
          decision_summary$scenario == s
        ]

      if (
        all(is.na(x))
      ) {
        NA_real_
      } else {
        mean(
          x,
          na.rm = TRUE
        )
      }
    }
  )


mean_stop_times$mean_first_stop_CATE <-
  sapply(
    mean_stop_times$scenario,
    function(s) {

      x <-
        decision_summary$first_stop_CATE[
          decision_summary$scenario == s
        ]

      if (
        all(is.na(x))
      ) {
        NA_real_
      } else {
        mean(
          x,
          na.rm = TRUE
        )
      }
    }
  )


# ============================================================
# 9. Save outputs
# ============================================================

write.csv(
  decision_summary,
  file.path(
    results_dir,
    "stopping_decisions.csv"
  ),
  row.names = FALSE
)


write.csv(
  performance_summary,
  file.path(
    results_dir,
    "stopping_performance_summary.csv"
  ),
  row.names = FALSE
)


write.csv(
  mean_stop_times,
  file.path(
    results_dir,
    "mean_stopping_times.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 10. Print results
# ============================================================

cat("\n")
cat("============================================================\n")
cat("BASELINE STOPPING RULES\n")
cat("============================================================\n\n")

cat(
  "ATE harm threshold:",
  ATE_harm_threshold,
  "\n"
)

cat(
  "CATE harm threshold:",
  CATE_harm_threshold,
  "\n"
)

cat(
  "Harmful-fraction threshold:",
  harm_fraction_threshold,
  "\n\n"
)

cat("Stopping performance:\n\n")

print(
  performance_summary
)

cat("\nMean stopping times:\n\n")

print(
  mean_stop_times
)

cat("\n")
cat("Results saved to:\n")
cat(
  file.path(
    results_dir,
    "stopping_decisions.csv"
  ),
  "\n"
)

cat(
  file.path(
    results_dir,
    "stopping_performance_summary.csv"
  ),
  "\n"
)

cat(
  file.path(
    results_dir,
    "mean_stopping_times.csv"
  ),
  "\n"
)
