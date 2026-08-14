# ============================================================
# 02_cate_estimation.R
#
# CATE estimation for the two simulation scenarios.
#
# INPUT FILES:
#   simulation_data_scenario_A.csv
#   simulation_data_scenario_B.csv
#
# ============================================================


# ------------------------------------------------------------
# 1. Paths
# ------------------------------------------------------------

project_root <-
  "C:/Users/chatt/OneDrive/Documents/GitHub Files/ab_testing"

results_dir <-
  file.path(
    project_root,
    "results"
  )


# ------------------------------------------------------------
# 2. Load the ACTUAL files produced by data generation
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


cat("\n")
cat("============================================================\n")
cat("CATE ESTIMATION\n")
cat("============================================================\n\n")

cat(
  "Scenario A file:\n",
  scenario_A_file,
  "\n\n"
)

cat(
  "Scenario B file:\n",
  scenario_B_file,
  "\n\n"
)


if (!file.exists(scenario_A_file)) {
  stop(
    "Scenario A file does not exist:\n",
    scenario_A_file
  )
}

if (!file.exists(scenario_B_file)) {
  stop(
    "Scenario B file does not exist:\n",
    scenario_B_file
  )
}


# ------------------------------------------------------------
# 3. Read the two datasets
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


cat(
  "Scenario A loaded:",
  nrow(scenario_A),
  "rows and",
  ncol(scenario_A),
  "columns.\n"
)

cat(
  "Scenario B loaded:",
  nrow(scenario_B),
  "rows and",
  ncol(scenario_B),
  "columns.\n"
)


# ============================================================
# 4. CATE estimation function
# ============================================================

estimate_CATE <- function(
    dat,
    scenario_label
) {
  
  # ----------------------------------------------------------
  # Required variables
  # ----------------------------------------------------------
  
  required <- c(
    "id",
    "X",
    "treatment",
    "outcome",
    "true_CATE"
  )
  
  missing <- setdiff(
    required,
    names(dat)
  )
  
  if (length(missing) > 0) {
    
    stop(
      "Missing variables in ",
      scenario_label,
      ": ",
      paste(
        missing,
        collapse = ", "
      )
    )
  }
  
  
  # ----------------------------------------------------------
  # Fit logistic treatment-effect model
  #
  # logit P(Y=1)
  #
  #   = beta0
  #   + betaA A
  #   + betaX X
  #   + betaAX A*X
  # ----------------------------------------------------------
  
  model <-
    glm(
      outcome ~ treatment * X,
      data = dat,
      family = binomial(
        link = "logit"
      )
    )
  
  
  # ----------------------------------------------------------
  # Counterfactual predictions
  # ----------------------------------------------------------
  
  dat_0 <- dat
  dat_0$treatment <- 0
  
  dat_1 <- dat
  dat_1$treatment <- 1
  
  
  M0 <-
    model.matrix(
      ~ treatment * X,
      data = dat_0
    )
  
  M1 <-
    model.matrix(
      ~ treatment * X,
      data = dat_1
    )
  
  
  beta <-
    coef(model)
  
  V <-
    vcov(model)
  
  
  eta_0 <-
    as.vector(
      M0 %*% beta
    )
  
  eta_1 <-
    as.vector(
      M1 %*% beta
    )
  
  
  p_0 <-
    plogis(eta_0)
  
  p_1 <-
    plogis(eta_1)
  
  
  # ----------------------------------------------------------
  # Estimated CATE
  # ----------------------------------------------------------
  
  CATE_hat <-
    p_1 - p_0
  
  
  # ----------------------------------------------------------
  # Delta-method standard error
  # ----------------------------------------------------------
  
  derivative_0 <-
    p_0 * (1 - p_0)
  
  derivative_1 <-
    p_1 * (1 - p_1)
  
  
  gradient <-
    sweep(
      M1,
      1,
      derivative_1,
      "*"
    ) -
    sweep(
      M0,
      1,
      derivative_0,
      "*"
    )
  
  
  variance_CATE <-
    rowSums(
      (
        gradient %*% V
      ) * gradient
    )
  
  
  variance_CATE <-
    pmax(
      variance_CATE,
      0
    )
  
  
  SE_CATE <-
    sqrt(
      variance_CATE
    )
  
  
  # ----------------------------------------------------------
  # 95% confidence interval
  # ----------------------------------------------------------
  
  z <-
    qnorm(0.975)
  
  
  lower <-
    CATE_hat -
    z * SE_CATE
  
  
  upper <-
    CATE_hat +
    z * SE_CATE
  
  
  # ----------------------------------------------------------
  # Store estimates
  # ----------------------------------------------------------
  
  estimates <-
    data.frame(
      
      id =
        dat$id,
      
      X =
        dat$X,
      
      treatment =
        dat$treatment,
      
      outcome =
        dat$outcome,
      
      estimated_control_probability =
        p_0,
      
      estimated_treatment_probability =
        p_1,
      
      estimated_CATE =
        CATE_hat,
      
      cate_se =
        SE_CATE,
      
      cate_lower =
        lower,
      
      cate_upper =
        upper,
      
      true_CATE =
        dat$true_CATE
    )
  
  
  estimates$CATE_error <-
    estimates$estimated_CATE -
    estimates$true_CATE
  
  
  # ----------------------------------------------------------
  # Validation
  # ----------------------------------------------------------
  
  MAE <-
    mean(
      abs(
        estimates$CATE_error
      )
    )
  
  
  RMSE <-
    sqrt(
      mean(
        estimates$CATE_error^2
      )
    )
  
  
  bias <-
    mean(
      estimates$CATE_error
    )
  
  
  correlation <-
    cor(
      estimates$estimated_CATE,
      estimates$true_CATE
    )
  
  
  coverage <-
    mean(
      estimates$true_CATE >=
        estimates$cate_lower &
        estimates$true_CATE <=
        estimates$cate_upper
    )
  
  
  validation <-
    data.frame(
      
      scenario =
        scenario_label,
      
      MAE =
        MAE,
      
      RMSE =
        RMSE,
      
      bias =
        bias,
      
      correlation =
        correlation,
      
      CATE_95pct_coverage =
        coverage
    )
  
  
  # ----------------------------------------------------------
  # Save results
  # ----------------------------------------------------------
  
  if (
    scenario_label ==
    "A_threshold"
  ) {
    
    estimate_filename <-
      "cate_estimates_A_threshold.csv"
    
    validation_filename <-
      "cate_validation_A_threshold.csv"
    
  } else {
    
    estimate_filename <-
      "cate_estimates_B_smooth_logistic.csv"
    
    validation_filename <-
      "cate_validation_B_smooth_logistic.csv"
  }
  
  
  write.csv(
    estimates,
    file.path(
      results_dir,
      estimate_filename
    ),
    row.names = FALSE
  )
  
  
  write.csv(
    validation,
    file.path(
      results_dir,
      validation_filename
    ),
    row.names = FALSE
  )
  
  
  # ----------------------------------------------------------
  # Subgroup validation for Scenario A
  # ----------------------------------------------------------
  
  if (
    "harmed_group" %in%
    names(dat)
  ) {
    
    subgroup_data <-
      data.frame(
        
        harmed_group =
          dat$harmed_group,
        
        estimated_CATE =
          estimates$estimated_CATE,
        
        true_CATE =
          estimates$true_CATE,
        
        CATE_error =
          estimates$CATE_error,
        
        cate_se =
          estimates$cate_se
      )
    
    
    subgroup_validation <-
      aggregate(
        cbind(
          estimated_CATE,
          true_CATE,
          CATE_error,
          cate_se
        ) ~ harmed_group,
        data =
          subgroup_data,
        FUN =
          mean
      )
    
    
    write.csv(
      subgroup_validation,
      file.path(
        results_dir,
        "cate_validation_by_subgroup.csv"
      ),
      row.names = FALSE
    )
  }
  
  
  return(
    list(
      model =
        model,
      
      estimates =
        estimates,
      
      validation =
        validation
    )
  )
}


# ============================================================
# 5. Scenario A
# ============================================================

cat("\n")
cat("============================================================\n")
cat("SCENARIO A: THRESHOLD HETEROGENEITY\n")
cat("============================================================\n\n")


fit_A <-
  estimate_CATE(
    dat =
      scenario_A,
    
    scenario_label =
      "A_threshold"
  )


cat("\nModel summary:\n\n")

print(
  summary(
    fit_A$model
  )
)


cat("\nValidation:\n\n")

print(
  fit_A$validation
)


# ============================================================
# 6. Scenario B
# ============================================================

cat("\n")
cat("============================================================\n")
cat("SCENARIO B: SMOOTH LOGISTIC HETEROGENEITY\n")
cat("============================================================\n\n")


fit_B <-
  estimate_CATE(
    dat =
      scenario_B,
    
    scenario_label =
      "B_smooth_logistic"
  )


cat("\nModel summary:\n\n")

print(
  summary(
    fit_B$model
  )
)


cat("\nValidation:\n\n")

print(
  fit_B$validation
)


# ============================================================
# 7. Combined validation
# ============================================================

combined_validation <-
  rbind(
    fit_A$validation,
    fit_B$validation
  )


write.csv(
  combined_validation,
  file.path(
    results_dir,
    "cate_validation_summary.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 8. Finished
# ============================================================

cat("\n")
cat("============================================================\n")
cat("CATE ESTIMATION COMPLETED\n")
cat("============================================================\n\n")

print(
  combined_validation
)

cat(
  "\nAll results saved in:\n",
  results_dir,
  "\n"
)