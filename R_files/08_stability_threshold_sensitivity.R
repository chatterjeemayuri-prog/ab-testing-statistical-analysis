# ============================================================
# 08_stability_threshold_sensitivity.R
#
# Purpose:
#   Examine how the Jaccard stability threshold affects the
#   stability-enhanced CATE stopping rule.
#
# Baseline CATE criterion:
#
#   fraction with estimated CATE <= -0.02 >= 0.50
#
# Stability criterion:
#
#   Jaccard similarity between consecutive harmful sets
#   >= selected Jaccard threshold.
#
# Thresholds examined:
#
#   0.50, 0.60, 0.70, 0.75, 0.80, 0.90
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
# 2. Input
# ------------------------------------------------------------

stability_file <-
  file.path(
    results_dir,
    "cate_stability_results.csv"
  )


if (!file.exists(stability_file)) {
  
  stop(
    "Could not find:\n",
    stability_file,
    "\nRun 07_cate_stability_metrics.R first."
  )
}


stability_results <-
  read.csv(
    stability_file,
    stringsAsFactors = FALSE
  )


# ------------------------------------------------------------
# 3. Check required columns
# ------------------------------------------------------------

required_columns <- c(
  "replicate",
  "scenario",
  "previous_n",
  "current_n",
  "jaccard_similarity",
  "current_harm_fraction"
)


missing_columns <-
  setdiff(
    required_columns,
    names(stability_results)
  )


if (length(missing_columns) > 0) {
  
  stop(
    "Missing required columns: ",
    paste(
      missing_columns,
      collapse = ", "
    )
  )
}


# ============================================================
# 4. Decision parameters
# ============================================================

harm_fraction_threshold <-
  0.50


jaccard_thresholds <- c(
  0.50,
  0.60,
  0.70,
  0.75,
  0.80,
  0.90
)


# ============================================================
# 5. Sort input
# ============================================================

stability_results <-
  stability_results[
    order(
      stability_results$scenario,
      stability_results$replicate,
      stability_results$current_n
    ),
    ,
    drop = FALSE
  ]


# ============================================================
# 6. Identify replicate/scenario combinations
# ============================================================

group_keys <-
  unique(
    stability_results[
      c(
        "replicate",
        "scenario"
      )
    ]
  )


# ============================================================
# 7. Create empty results data frame
# ============================================================

threshold_results <-
  data.frame(
    replicate = numeric(),
    scenario = character(),
    jaccard_threshold = numeric(),
    naive_first_stop_n = numeric(),
    stable_first_stop_n = numeric(),
    naive_stopped = logical(),
    stable_stopped = logical(),
    final_harm_fraction = numeric(),
    final_harm_decision = logical(),
    naive_agrees_final = logical(),
    stable_agrees_final = logical(),
    naive_reversal = logical(),
    stable_reversal = logical(),
    stringsAsFactors = FALSE
  )


# ============================================================
# 8. Evaluate every Jaccard threshold
# ============================================================

for (
  threshold in jaccard_thresholds
) {
  
  cat(
    "\nProcessing Jaccard threshold:",
    threshold,
    "\n"
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
    
    
    # --------------------------------------------------------
    # Select one replicate/scenario
    # --------------------------------------------------------
    
    dat <-
      stability_results[
        stability_results$replicate ==
          current_replicate &
          stability_results$scenario ==
          current_scenario,
        ,
        drop = FALSE
      ]
    
    
    dat <-
      dat[
        order(
          dat$current_n
        ),
        ,
        drop = FALSE
      ]
    
    
    # --------------------------------------------------------
    # NAIVE CATE STOPPING
    #
    # Stop when:
    #
    #   current harmful fraction >= 0.50
    # --------------------------------------------------------
    
    naive_criterion <-
      dat$current_harm_fraction >=
      harm_fraction_threshold
    
    
    if (
      any(
        naive_criterion
      )
    ) {
      
      naive_stop_n <-
        min(
          dat$current_n[
            naive_criterion
          ]
        )
      
    } else {
      
      naive_stop_n <-
        NA_real_
    }
    
    
    # --------------------------------------------------------
    # STABILITY-ENHANCED CATE STOPPING
    #
    # Stop when BOTH:
    #
    #   harmful fraction >= 0.50
    #
    # AND
    #
    #   Jaccard similarity >= selected threshold
    # --------------------------------------------------------
    
    stable_criterion <-
      (
        dat$current_harm_fraction >=
          harm_fraction_threshold
      ) &
      (
        dat$jaccard_similarity >=
          threshold
      )
    
    
    if (
      any(
        stable_criterion
      )
    ) {
      
      stable_stop_n <-
        min(
          dat$current_n[
            stable_criterion
          ]
        )
      
    } else {
      
      stable_stop_n <-
        NA_real_
    }
    
    
    # --------------------------------------------------------
    # Final decision
    #
    # The last transition ends at n = 4000.
    # --------------------------------------------------------
    
    final_fraction <-
      dat$current_harm_fraction[
        nrow(dat)
      ]
    
    
    final_decision <-
      final_fraction >=
      harm_fraction_threshold
    
    
    # --------------------------------------------------------
    # Stop indicators
    # --------------------------------------------------------
    
    naive_stopped <-
      !is.na(
        naive_stop_n
      )
    
    stable_stopped <-
      !is.na(
        stable_stop_n
      )
    
    
    # --------------------------------------------------------
    # Agreement with final decision
    # --------------------------------------------------------
    
    if (
      naive_stopped
    ) {
      
      naive_agrees_final <-
        final_decision
      
    } else {
      
      naive_agrees_final <-
        !final_decision
    }
    
    
    if (
      stable_stopped
    ) {
      
      stable_agrees_final <-
        final_decision
      
    } else {
      
      stable_agrees_final <-
        !final_decision
    }
    
    
    # --------------------------------------------------------
    # Reversal
    #
    # Stopping for harm followed by a non-harmful final result.
    # --------------------------------------------------------
    
    naive_reversal <-
      naive_stopped &
      !final_decision
    
    
    stable_reversal <-
      stable_stopped &
      !final_decision
    
    
    # --------------------------------------------------------
    # Add result directly to data frame
    #
    # No list indexing is used here.
    # --------------------------------------------------------
    
    new_row <-
      data.frame(
        replicate =
          current_replicate,
        
        scenario =
          current_scenario,
        
        jaccard_threshold =
          threshold,
        
        naive_first_stop_n =
          naive_stop_n,
        
        stable_first_stop_n =
          stable_stop_n,
        
        naive_stopped =
          naive_stopped,
        
        stable_stopped =
          stable_stopped,
        
        final_harm_fraction =
          final_fraction,
        
        final_harm_decision =
          final_decision,
        
        naive_agrees_final =
          naive_agrees_final,
        
        stable_agrees_final =
          stable_agrees_final,
        
        naive_reversal =
          naive_reversal,
        
        stable_reversal =
          stable_reversal,
        
        stringsAsFactors = FALSE
      )
    
    
    threshold_results <-
      rbind(
        threshold_results,
        new_row
      )
  }
}


# ============================================================
# 9. Performance summary
# ============================================================

threshold_performance <-
  aggregate(
    
    cbind(
      naive_stopped,
      stable_stopped,
      naive_agrees_final,
      stable_agrees_final,
      naive_reversal,
      stable_reversal
    ) ~
      
      scenario +
      jaccard_threshold,
    
    data =
      threshold_results,
    
    FUN =
      mean
  )


# ============================================================
# 10. Mean stopping times
# ============================================================

mean_stopping_times <-
  aggregate(
    
    cbind(
      naive_first_stop_n,
      stable_first_stop_n
    ) ~
      
      scenario +
      jaccard_threshold,
    
    data =
      threshold_results,
    
    FUN =
      function(x) {
        
        if (
          all(
            is.na(x)
          )
        ) {
          
          return(
            NA_real_
          )
          
        } else {
          
          return(
            mean(
              x,
              na.rm = TRUE
            )
          )
        }
      }
  )


# ============================================================
# 11. Median stopping times
# ============================================================

median_stopping_times <-
  aggregate(
    
    cbind(
      naive_first_stop_n,
      stable_first_stop_n
    ) ~
      
      scenario +
      jaccard_threshold,
    
    data =
      threshold_results,
    
    FUN =
      function(x) {
        
        if (
          all(
            is.na(x)
          )
        ) {
          
          return(
            NA_real_
          )
          
        } else {
          
          return(
            median(
              x,
              na.rm = TRUE
            )
          )
        }
      }
  )


# ============================================================
# 12. Save results
# ============================================================

write.csv(
  threshold_results,
  file.path(
    results_dir,
    "stability_threshold_results.csv"
  ),
  row.names = FALSE
)


write.csv(
  threshold_performance,
  file.path(
    results_dir,
    "stability_threshold_performance.csv"
  ),
  row.names = FALSE
)


write.csv(
  mean_stopping_times,
  file.path(
    results_dir,
    "stability_threshold_mean_stopping_times.csv"
  ),
  row.names = FALSE
)


write.csv(
  median_stopping_times,
  file.path(
    results_dir,
    "stability_threshold_median_stopping_times.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 13. Final output
# ============================================================

cat("\n")
cat("============================================================\n")
cat("STABILITY THRESHOLD SENSITIVITY COMPLETED\n")
cat("============================================================\n\n")


cat(
  "Harm-fraction threshold:",
  harm_fraction_threshold,
  "\n"
)


cat(
  "Jaccard thresholds tested:",
  paste(
    jaccard_thresholds,
    collapse = ", "
  ),
  "\n\n"
)


cat(
  "Performance by threshold:\n\n"
)

print(
  threshold_performance
)


cat(
  "\nMean stopping times:\n\n"
)

print(
  mean_stopping_times
)


cat(
  "\nMedian stopping times:\n\n"
)

print(
  median_stopping_times
)


cat(
  "\nResults saved to:\n",
  results_dir,
  "\n"
)