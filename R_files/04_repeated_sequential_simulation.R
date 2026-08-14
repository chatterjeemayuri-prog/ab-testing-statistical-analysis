# ============================================================
# 04_repeated_sequential_simulation.R
#
# Purpose:
#   Repeat the sequential A/B experiment many times and record
#   the quantities needed for the later stopping-rule analysis.
#
#   At every replicate and interim we record:
#     - overall ATE estimate
#     - mean estimated CATE
#     - SD of estimated CATE
#     - minimum / maximum estimated CATE
#     - fraction with CATE < 0
#     - fraction with CATE <= -0.02
#     - mean true CATE
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

set.seed(20260814)

B <- 500
N <- 4000

allocation_probability <- 0.50

interim_fractions <- c(
  0.25,
  0.40,
  0.55,
  0.70,
  0.85,
  1.00
)

interim_sizes <-
  floor(
    N * interim_fractions
  )


# Meaningful individual-level harm:
# estimated probability reduction of at least 2 percentage points.

CATE_harm_threshold <- -0.02


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
# 5. One interim analysis
# ============================================================

analyse_interim <- function(
    data,
    interim_size,
    CATE_harm_threshold
) {
  
  dat <- data[
    seq_len(interim_size),
    ,
    drop = FALSE
  ]
  
  
  # ----------------------------------------------------------
  # Overall ATE
  # ----------------------------------------------------------
  
  control_rate <- mean(
    dat$outcome[
      dat$treatment == 0
    ]
  )
  
  treatment_rate <- mean(
    dat$outcome[
      dat$treatment == 1
    ]
  )
  
  ATE_hat <- treatment_rate -
    control_rate
  
  
  # ----------------------------------------------------------
  # Treatment-by-covariate logistic model
  # ----------------------------------------------------------
  
  model <- glm(
    outcome ~ treatment * X,
    data = dat,
    family = binomial(
      link = "logit"
    )
  )
  
  
  # ----------------------------------------------------------
  # Counterfactual predictions
  # ----------------------------------------------------------
  
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
  
  
  # ----------------------------------------------------------
  # CATE summaries
  # ----------------------------------------------------------
  
  mean_CATE_hat <- mean(
    CATE_hat
  )
  
  sd_CATE_hat <- sd(
    CATE_hat
  )
  
  min_CATE_hat <- min(
    CATE_hat
  )
  
  max_CATE_hat <- max(
    CATE_hat
  )
  
  
  # ----------------------------------------------------------
  # Fraction with any estimated harm
  # ----------------------------------------------------------
  
  fraction_negative_CATE <- mean(
    CATE_hat < 0
  )
  
  
  # ----------------------------------------------------------
  # Fraction with meaningful estimated harm
  #
  # This is the NEW quantity required by the stopping analysis.
  #
  # Meaningful harm means:
  #
  #       estimated CATE <= -0.02
  #
  # i.e. treatment is estimated to reduce the outcome
  # probability by at least 2 percentage points.
  # ----------------------------------------------------------
  
  fraction_CATE_meaningfully_harmed <- mean(
    CATE_hat <= CATE_harm_threshold
  )
  
  
  # ----------------------------------------------------------
  # Truth for simulation diagnostics
  # ----------------------------------------------------------
  
  mean_true_CATE <- mean(
    dat$true_CATE
  )
  
  
  # ----------------------------------------------------------
  # Return one-row summary
  # ----------------------------------------------------------
  
  data.frame(
    
    ATE_hat =
      ATE_hat,
    
    mean_CATE_hat =
      mean_CATE_hat,
    
    sd_CATE_hat =
      sd_CATE_hat,
    
    min_CATE_hat =
      min_CATE_hat,
    
    max_CATE_hat =
      max_CATE_hat,
    
    fraction_negative_CATE =
      fraction_negative_CATE,
    
    fraction_CATE_meaningfully_harmed =
      fraction_CATE_meaningfully_harmed,
    
    mean_true_CATE =
      mean_true_CATE
  )
}


# ============================================================
# 6. Repeated simulation
# ============================================================

cat("\n")
cat("============================================================\n")
cat("REPEATED SEQUENTIAL SIMULATION\n")
cat("============================================================\n\n")

cat(
  "Replicates:",
  B,
  "\n"
)

cat(
  "Sample size:",
  N,
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


all_results <- vector(
  "list",
  B * 2 * length(interim_sizes)
)

result_index <- 1


# ============================================================
# Main simulation loop
# ============================================================

for (b in seq_len(B)) {
  
  # Fresh randomized experiment for this replicate.
  
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
  # Scenario A
  # ----------------------------------------------------------
  
  for (j in seq_along(interim_sizes)) {
    
    n <- interim_sizes[j]
    
    summary_A <- analyse_interim(
      data =
        data_A,
      
      interim_size =
        n,
      
      CATE_harm_threshold =
        CATE_harm_threshold
    )
    
    all_results[[result_index]] <-
      cbind(
        
        data.frame(
          
          replicate =
            b,
          
          scenario =
            "A_threshold",
          
          interim_n =
            n,
          
          information_fraction =
            n / N
        ),
        
        summary_A
      )
    
    result_index <- result_index + 1
  }
  
  
  # ----------------------------------------------------------
  # Scenario B
  # ----------------------------------------------------------
  
  for (j in seq_along(interim_sizes)) {
    
    n <- interim_sizes[j]
    
    summary_B <- analyse_interim(
      data =
        data_B,
      
      interim_size =
        n,
      
      CATE_harm_threshold =
        CATE_harm_threshold
    )
    
    all_results[[result_index]] <-
      cbind(
        
        data.frame(
          
          replicate =
            b,
          
          scenario =
            "B_smooth_logistic",
          
          interim_n =
            n,
          
          information_fraction =
            n / N
        ),
        
        summary_B
      )
    
    result_index <- result_index + 1
  }
  
  
  # ----------------------------------------------------------
  # Progress message
  # ----------------------------------------------------------
  
  if (b %% 50 == 0) {
    
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
# 7. Combine results
# ============================================================

simulation_results <- do.call(
  rbind,
  all_results
)


# ============================================================
# 8. IMPORTANT VALIDATION
# ============================================================

if (
  !(
    "fraction_CATE_meaningfully_harmed"
    %in%
    names(simulation_results)
  )
) {
  
  stop(
    paste(
      "VALIDATION FAILED:",
      "fraction_CATE_meaningfully_harmed",
      "was not created."
    )
  )
}


# ============================================================
# 9. Save replicate-level results
# ============================================================

replicate_file <- file.path(
  results_dir,
  "repeated_sequential_results.csv"
)

write.csv(
  simulation_results,
  replicate_file,
  row.names = FALSE
)


# ============================================================
# 10. Mean summaries
# ============================================================

summary_by_interim <- aggregate(
  
  cbind(
    
    ATE_hat,
    
    mean_CATE_hat,
    
    sd_CATE_hat,
    
    min_CATE_hat,
    
    max_CATE_hat,
    
    fraction_negative_CATE,
    
    fraction_CATE_meaningfully_harmed,
    
    mean_true_CATE
    
  ) ~
    
    scenario +
    interim_n +
    information_fraction,
  
  data =
    simulation_results,
  
  FUN =
    mean
)


# ============================================================
# 11. Quantile summaries
# ============================================================

quantile_summary <- aggregate(
  
  cbind(
    
    ATE_hat,
    
    mean_CATE_hat,
    
    fraction_negative_CATE,
    
    fraction_CATE_meaningfully_harmed
    
  ) ~
    
    scenario +
    interim_n,
  
  data =
    simulation_results,
  
  FUN =
    function(x) {
      
      c(
        
        q025 =
          quantile(
            x,
            0.025
          ),
        
        median =
          quantile(
            x,
            0.50
          ),
        
        q975 =
          quantile(
            x,
            0.975
          )
      )
    }
)


# ============================================================
# 12. Save summaries
# ============================================================

summary_file <- file.path(
  results_dir,
  "repeated_sequential_summary.csv"
)

write.csv(
  summary_by_interim,
  summary_file,
  row.names = FALSE
)


quantile_file <- file.path(
  results_dir,
  "repeated_sequential_quantiles.csv"
)

write.csv(
  quantile_summary,
  quantile_file,
  row.names = FALSE
)


# ============================================================
# 13. Final validation and output
# ============================================================

cat("\n")
cat("============================================================\n")
cat("REPEATED SIMULATION COMPLETED\n")
cat("============================================================\n\n")

cat(
  "Required column check: fraction_CATE_meaningfully_harmed = PRESENT\n\n"
)

cat(
  "Replicate-level results:\n",
  replicate_file,
  "\n\n"
)

cat(
  "Mean summary:\n",
  summary_file,
  "\n\n"
)

cat(
  "Quantile summary:\n",
  quantile_file,
  "\n\n"
)

cat(
  "Mean results by scenario and interim:\n\n"
)

print(
  summary_by_interim
)