# ============================================================
# 07_cate_stability_metrics.R
#
# Purpose:
#   Quantify the stability of the estimated harmful population
#   between consecutive interim analyses.
#
# Meaningful harm:
#       estimated CATE <= -0.02
#
# For every replicate, scenario, and consecutive pair of
# interim analyses, calculate:
#
#   1. Change in harmful fraction
#   2. Jaccard similarity of harmful sets
#   3. Fraction newly classified as harmed
#   4. Fraction no longer classified as harmed
#   5. Mean absolute change in estimated CATE
#
# This is a diagnostic stability analysis.
# It does NOT define a new stopping rule.
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

dir.create(
  results_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ------------------------------------------------------------
# 2. Simulation settings
# ------------------------------------------------------------

N <- 4000

B <- 500

allocation_probability <- 0.50

CATE_harm_threshold <- -0.02

interim_fractions <- c(
  0.25,
  0.40,
  0.55,
  0.70,
  0.85,
  1.00
)

interim_sizes <- floor(
  N * interim_fractions
)


# ============================================================
# 3. Scenario A data-generating function
# ============================================================

generate_scenario_A <- function(
    N,
    allocation_probability
) {
  
  X <- rnorm(
    N,
    mean = 0,
    sd = 1
  )
  
  subgroup_threshold <- qnorm(
    1 - 0.25
  )
  
  harmed_group <- as.integer(
    X > subgroup_threshold
  )
  
  treatment <- rbinom(
    N,
    size = 1,
    prob = allocation_probability
  )
  
  p_control <- rep(
    0.10,
    N
  )
  
  p_treatment <- p_control -
    0.04 * harmed_group
  
  Y0 <- rbinom(
    N,
    size = 1,
    prob = p_control
  )
  
  Y1 <- rbinom(
    N,
    size = 1,
    prob = p_treatment
  )
  
  outcome <- ifelse(
    treatment == 1,
    Y1,
    Y0
  )
  
  data.frame(
    id = seq_len(N),
    X = X,
    harmed_group = harmed_group,
    treatment = treatment,
    outcome = outcome,
    p_control = p_control,
    p_treatment = p_treatment,
    true_CATE = p_treatment - p_control
  )
}


# ============================================================
# 4. Scenario B data-generating function
# ============================================================

generate_scenario_B <- function(
    N,
    allocation_probability
) {
  
  beta_0 <- qlogis(0.10)
  
  beta_X <- 0.20
  
  beta_A <- -0.50
  
  beta_AX <- -0.30
  
  X <- runif(
    N,
    min = -1,
    max = 1
  )
  
  treatment <- rbinom(
    N,
    size = 1,
    prob = allocation_probability
  )
  
  eta_control <- beta_0 +
    beta_X * X
  
  eta_treatment <- beta_0 +
    beta_X * X +
    beta_A +
    beta_AX * X
  
  p_control <- plogis(
    eta_control
  )
  
  p_treatment <- plogis(
    eta_treatment
  )
  
  Y0 <- rbinom(
    N,
    size = 1,
    prob = p_control
  )
  
  Y1 <- rbinom(
    N,
    size = 1,
    prob = p_treatment
  )
  
  outcome <- ifelse(
    treatment == 1,
    Y1,
    Y0
  )
  
  data.frame(
    id = seq_len(N),
    X = X,
    treatment = treatment,
    outcome = outcome,
    p_control = p_control,
    p_treatment = p_treatment,
    true_CATE = p_treatment - p_control
  )
}


# ============================================================
# 5. Estimate CATEs at one interim
# ============================================================

estimate_interim_CATE <- function(
    data,
    interim_size
) {
  
  dat <- data[
    seq_len(interim_size),
    ,
    drop = FALSE
  ]
  
  model <- glm(
    outcome ~ treatment * X,
    data = dat,
    family = binomial(
      link = "logit"
    )
  )
  
  dat0 <- dat
  dat0$treatment <- 0
  
  dat1 <- dat
  dat1$treatment <- 1
  
  M0 <- model.matrix(
    ~ treatment * X,
    data = dat0
  )
  
  M1 <- model.matrix(
    ~ treatment * X,
    data = dat1
  )
  
  beta <- coef(model)
  
  p0_hat <- plogis(
    as.vector(
      M0 %*% beta
    )
  )
  
  p1_hat <- plogis(
    as.vector(
      M1 %*% beta
    )
  )
  
  CATE_hat <- p1_hat - p0_hat
  
  data.frame(
    id = dat$id,
    estimated_CATE = CATE_hat
  )
}


# ============================================================
# 6. Compare two consecutive harmful sets
# ============================================================

calculate_stability <- function(
    previous,
    current,
    previous_n,
    current_n,
    replicate,
    scenario
) {
  
  # ----------------------------------------------------------
  # Match individuals by ID.
  # ----------------------------------------------------------
  
  common_ids <- intersect(
    previous$id,
    current$id
  )
  
  previous_index <- match(
    common_ids,
    previous$id
  )
  
  current_index <- match(
    common_ids,
    current$id
  )
  
  previous_CATE <-
    previous$estimated_CATE[
      previous_index
    ]
  
  current_CATE <-
    current$estimated_CATE[
      current_index
    ]
  
  
  # ----------------------------------------------------------
  # Define harmful sets.
  # ----------------------------------------------------------
  
  previous_harmed <-
    previous_CATE <=
    CATE_harm_threshold
  
  current_harmed <-
    current_CATE <=
    CATE_harm_threshold
  
  
  # ----------------------------------------------------------
  # Harm fractions.
  # ----------------------------------------------------------
  
  previous_fraction <-
    mean(
      previous_harmed
    )
  
  current_fraction <-
    mean(
      current_harmed
    )
  
  harm_fraction_change <-
    current_fraction -
    previous_fraction
  
  
  # ----------------------------------------------------------
  # Jaccard similarity.
  # ----------------------------------------------------------
  
  intersection_size <-
    sum(
      previous_harmed &
        current_harmed
    )
  
  union_size <-
    sum(
      previous_harmed |
        current_harmed
    )
  
  if (
    union_size == 0
  ) {
    
    jaccard_similarity <- 1
    
  } else {
    
    jaccard_similarity <-
      intersection_size /
      union_size
  }
  
  
  # ----------------------------------------------------------
  # Classification changes.
  # ----------------------------------------------------------
  
  newly_harmed <-
    (!previous_harmed) &
    current_harmed
  
  no_longer_harmed <-
    previous_harmed &
    (!current_harmed)
  
  fraction_newly_harmed <-
    mean(
      newly_harmed
    )
  
  fraction_no_longer_harmed <-
    mean(
      no_longer_harmed
    )
  
  
  # ----------------------------------------------------------
  # Absolute CATE change.
  # ----------------------------------------------------------
  
  mean_absolute_CATE_change <-
    mean(
      abs(
        current_CATE -
          previous_CATE
      )
    )
  
  
  # ----------------------------------------------------------
  # Return one row.
  # ----------------------------------------------------------
  
  data.frame(
    
    replicate =
      replicate,
    
    scenario =
      scenario,
    
    previous_n =
      previous_n,
    
    current_n =
      current_n,
    
    information_fraction =
      current_n / N,
    
    previous_harm_fraction =
      previous_fraction,
    
    current_harm_fraction =
      current_fraction,
    
    harm_fraction_change =
      harm_fraction_change,
    
    jaccard_similarity =
      jaccard_similarity,
    
    fraction_newly_harmed =
      fraction_newly_harmed,
    
    fraction_no_longer_harmed =
      fraction_no_longer_harmed,
    
    mean_absolute_CATE_change =
      mean_absolute_CATE_change
  )
}


# ============================================================
# 7. Reconstruct the same 500 experiments
# ============================================================

set.seed(
  20260814
)


all_results <- vector(
  "list",
  B *
    2 *
    (
      length(interim_sizes) - 1
    )
)

result_index <- 1


cat("\n")
cat("============================================================\n")
cat("CATE STABILITY ANALYSIS\n")
cat("============================================================\n\n")

cat(
  "Replicates:",
  B,
  "\n"
)

cat(
  "Interim sizes:",
  paste(
    interim_sizes,
    collapse = ", "
  ),
  "\n"
)

cat(
  "Meaningful CATE harm threshold:",
  CATE_harm_threshold,
  "\n\n"
)


# ============================================================
# 8. Main simulation loop
# ============================================================

for (
  b in seq_len(B)
) {
  
  # ----------------------------------------------------------
  # Generate Scenario A and Scenario B.
  # ----------------------------------------------------------
  
  data_A <- generate_scenario_A(
    N =
      N,
    
    allocation_probability =
      allocation_probability
  )
  
  data_B <- generate_scenario_B(
    N =
      N,
    
    allocation_probability =
      allocation_probability
  )
  
  
  # ----------------------------------------------------------
  # Store the two scenarios in a named list.
  # ----------------------------------------------------------
  
  scenario_data <- list(
    
    A_threshold =
      data_A,
    
    B_smooth_logistic =
      data_B
    
  )
  
  
  # ----------------------------------------------------------
  # Analyse each scenario.
  # ----------------------------------------------------------
  
  for (
    scenario_name in
    names(
      scenario_data
    )
  ) {
    
    current_data <-
      scenario_data[[scenario_name]]
    
    
    # --------------------------------------------------------
    # Estimate CATEs at all interim sample sizes.
    # --------------------------------------------------------
    
    estimates <- lapply(
      
      interim_sizes,
      
      function(n) {
        
        estimate_interim_CATE(
          data =
            current_data,
          
          interim_size =
            n
        )
      }
    )
    
    
    # --------------------------------------------------------
    # Compare consecutive interims.
    # --------------------------------------------------------
    
    for (
      j in
      2:length(
        interim_sizes
      )
    ) {
      
      previous_estimates <-
        estimates[[j - 1]]
      
      current_estimates <-
        estimates[[j]]
      
      
      result <-
        calculate_stability(
          
          previous =
            previous_estimates,
          
          current =
            current_estimates,
          
          previous_n =
            interim_sizes[j - 1],
          
          current_n =
            interim_sizes[j],
          
          replicate =
            b,
          
          scenario =
            scenario_name
        )
      
      
      all_results[[result_index]] <-
        result
      
      result_index <-
        result_index + 1
    }
  }
  
  
  # ----------------------------------------------------------
  # Progress message.
  # ----------------------------------------------------------
  
  if (
    b %% 50 == 0
  ) {
    
    cat(
      "Completed replicate",
      b,
      "of",
      B,
      "\n"
    )
  }
}


# ============================================================
# 9. Combine results
# ============================================================

stability_results <-
  do.call(
    rbind,
    all_results
  )


# ============================================================
# 10. Validation
# ============================================================

expected_rows <-
  B *
  2 *
  (
    length(interim_sizes) - 1
  )

if (
  nrow(
    stability_results
  ) !=
  expected_rows
) {
  
  stop(
    paste(
      "Unexpected number of rows.",
      "Expected:",
      expected_rows,
      "Observed:",
      nrow(
        stability_results
      )
    )
  )
}


# ============================================================
# 11. Save replicate-level results
# ============================================================

stability_file <-
  file.path(
    results_dir,
    "cate_stability_results.csv"
  )

write.csv(
  stability_results,
  stability_file,
  row.names = FALSE
)


# ============================================================
# 12. Summary by scenario and interim transition
# ============================================================

stability_summary <-
  aggregate(
    
    cbind(
      
      harm_fraction_change,
      
      jaccard_similarity,
      
      fraction_newly_harmed,
      
      fraction_no_longer_harmed,
      
      mean_absolute_CATE_change
      
    ) ~
      
      scenario +
      previous_n +
      current_n,
    
    data =
      stability_results,
    
    FUN =
      mean
  )


# ============================================================
# 13. Save summary
# ============================================================

summary_file <-
  file.path(
    results_dir,
    "cate_stability_summary.csv"
  )

write.csv(
  stability_summary,
  summary_file,
  row.names = FALSE
)


# ============================================================
# 14. Final output
# ============================================================

cat("\n")
cat("============================================================\n")
cat("CATE STABILITY ANALYSIS COMPLETED\n")
cat("============================================================\n\n")

cat(
  "Rows generated:",
  nrow(
    stability_results
  ),
  "\n\n"
)

cat(
  "Replicate-level results saved to:\n",
  stability_file,
  "\n\n"
)

cat(
  "Summary saved to:\n",
  summary_file,
  "\n\n"
)

cat(
  "Stability summary:\n\n"
)

print(
  stability_summary
)