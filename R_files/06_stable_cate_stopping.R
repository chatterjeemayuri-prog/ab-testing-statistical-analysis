# ============================================================
# 06_stable_cate_stopping.R
#
# Purpose:
#
#   Compare two heterogeneous-treatment-effect stopping rules:
#
#   1. NAIVE CATE STOPPING
#        Stop at the first interim where the estimated fraction
#        of the population with meaningful harm is >= 50%.
#
#   2. STABLE CATE STOPPING
#        Stop only when the same criterion is satisfied at TWO
#        CONSECUTIVE interim analyses.
#
#   Meaningful harm:
#
#        estimated CATE <= -0.02
#
#   Stopping criterion:
#
#        fraction meaningfully harmed >= 0.50
#
#   The purpose is to quantify whether requiring persistence
#   of the heterogeneous signal reduces unstable early decisions.
#
#   NO CLASH implementation is included here.
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
# 2. Input file
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


# ------------------------------------------------------------
# 3. Verify required variables
# ------------------------------------------------------------

required_columns <- c(
  "replicate",
  "scenario",
  "interim_n",
  "information_fraction",
  "fraction_CATE_meaningfully_harmed"
)


missing_columns <-
  setdiff(
    required_columns,
    names(simulation_results)
  )


if (length(missing_columns) > 0) {
  
  stop(
    "The following required columns are missing:\n",
    paste(
      missing_columns,
      collapse = ", "
    ),
    "\nRun the corrected 04_repeated_sequential_simulation.R."
  )
}


# ============================================================
# 4. Decision parameters
# ============================================================

harm_fraction_threshold <-
  0.50


stability_interims_required <-
  2


# ============================================================
# 5. Sort the data
# ============================================================

simulation_results <-
  simulation_results[
    order(
      simulation_results$scenario,
      simulation_results$replicate,
      simulation_results$interim_n
    ),
    ,
    drop = FALSE
  ]


# ============================================================
# 6. Function to identify first naive and stable stop
# ============================================================

get_stopping_decisions <- function(
    dat,
    harm_fraction_threshold
) {
  
  dat <-
    dat[
      order(
        dat$interim_n
      ),
      ,
      drop = FALSE
    ]
  
  
  # ----------------------------------------------------------
  # Indicator for whether the CATE criterion is satisfied
  # ----------------------------------------------------------
  
  criterion_met <-
    dat$fraction_CATE_meaningfully_harmed >=
    harm_fraction_threshold
  
  
  # ----------------------------------------------------------
  # Naive rule
  #
  # Stop at the first interim satisfying the criterion.
  # ----------------------------------------------------------
  
  if (
    any(
      criterion_met
    )
  ) {
    
    naive_stop_n <-
      min(
        dat$interim_n[
          criterion_met
        ]
      )
    
  } else {
    
    naive_stop_n <-
      NA_real_
  }
  
  
  # ----------------------------------------------------------
  # Stable rule
  #
  # Stop at the first interim where:
  #
  #   current interim satisfies criterion
  #
  # AND
  #
  #   immediately preceding interim also satisfies criterion.
  #
  # ----------------------------------------------------------
  
  stable_stop_n <-
    NA_real_
  
  
  if (
    length(criterion_met) >= 2
  ) {
    
    consecutive_met <-
      criterion_met[-1] &
      criterion_met[-length(criterion_met)]
    
    
    if (
      any(
        consecutive_met
      )
    ) {
      
      # The second member of the first qualifying pair
      # is the actual stable stopping interim.
      
      qualifying_positions <-
        which(
          consecutive_met
        ) + 1
      
      first_position <-
        min(
          qualifying_positions
        )
      
      stable_stop_n <-
        dat$interim_n[
          first_position
        ]
    }
  }
  
  
  # ----------------------------------------------------------
  # Final-interim criterion
  #
  # This is the decision that would be made if we waited
  # until the end of the simulated experiment.
  # ----------------------------------------------------------
  
  final_fraction <-
    dat$fraction_CATE_meaningfully_harmed[
      nrow(dat)
    ]
  
  
  final_decision <-
    final_fraction >=
    harm_fraction_threshold
  
  
  # ----------------------------------------------------------
  # Did the early decision agree with the final decision?
  # ----------------------------------------------------------
  
  naive_stopped <-
    !is.na(
      naive_stop_n
    )
  
  
  stable_stopped <-
    !is.na(
      stable_stop_n
    )
  
  
  naive_agrees_final <-
    if (
      naive_stopped
    ) {
      
      final_decision
      
    } else {
      
      !final_decision
    }
  
  
  stable_agrees_final <-
    if (
      stable_stopped
    ) {
      
      final_decision
      
    } else {
      
      !final_decision
    }
  
  
  # ----------------------------------------------------------
  # Did the decision reverse after stopping?
  #
  # A reversal occurs when the stopping rule stopped for harm
  # but the final interim no longer satisfies the criterion.
  # ----------------------------------------------------------
  
  naive_reversal <-
    naive_stopped &
    !final_decision
  
  
  stable_reversal <-
    stable_stopped &
    !final_decision
  
  
  # ----------------------------------------------------------
  # Return one row
  # ----------------------------------------------------------
  
  data.frame(
    
    replicate =
      dat$replicate[1],
    
    scenario =
      dat$scenario[1],
    
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
      stable_reversal
  )
}


# ============================================================
# 7. Apply stopping rules to every replicate
# ============================================================

group_keys <-
  unique(
    simulation_results[
      c(
        "replicate",
        "scenario"
      )
    ]
  )


decision_list <-
  vector(
    "list",
    nrow(
      group_keys
    )
  )


for (
  i in seq_len(
    nrow(
      group_keys
    )
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
  
  
  decision_list[[i]] <-
    get_stopping_decisions(
      dat =
        current_data,
      
      harm_fraction_threshold =
        harm_fraction_threshold
    )
}


decision_results <-
  do.call(
    rbind,
    decision_list
  )


# ============================================================
# 8. Stopping performance summary
# ============================================================

stopping_performance <-
  aggregate(
    
    cbind(
      
      naive_stopped,
      
      stable_stopped,
      
      naive_agrees_final,
      
      stable_agrees_final,
      
      naive_reversal,
      
      stable_reversal
      
    ) ~
      
      scenario,
    
    data =
      decision_results,
    
    FUN =
      mean
  )


# ============================================================
# 9. Mean stopping times
# ============================================================

mean_stopping_times <-
  data.frame(
    
    scenario =
      unique(
        decision_results$scenario
      )
  )


mean_stopping_times$mean_naive_stop_n <-
  sapply(
    
    mean_stopping_times$scenario,
    
    function(s) {
      
      x <-
        decision_results$naive_first_stop_n[
          decision_results$scenario ==
            s
        ]
      
      
      if (
        all(
          is.na(x)
        )
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


mean_stopping_times$mean_stable_stop_n <-
  sapply(
    
    mean_stopping_times$scenario,
    
    function(s) {
      
      x <-
        decision_results$stable_first_stop_n[
          decision_results$scenario ==
            s
        ]
      
      
      if (
        all(
          is.na(x)
        )
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
# 10. Stopping-time distribution
# ============================================================

stopping_time_distribution <-
  aggregate(
    
    cbind(
      
      naive_first_stop_n,
      
      stable_first_stop_n
      
    ) ~
      
      scenario,
    
    data =
      decision_results,
    
    FUN =
      function(x) {
        
        c(
          
          q025 =
            quantile(
              x,
              0.025,
              na.rm = TRUE
            ),
          
          median =
            quantile(
              x,
              0.50,
              na.rm = TRUE
            ),
          
          q975 =
            quantile(
              x,
              0.975,
              na.rm = TRUE
            )
        )
      }
  )


# ============================================================
# 11. Save outputs
# ============================================================

decision_file <-
  file.path(
    results_dir,
    "stable_cate_decisions.csv"
  )


performance_file <-
  file.path(
    results_dir,
    "stable_cate_performance_summary.csv"
  )


stopping_time_file <-
  file.path(
    results_dir,
    "stable_cate_mean_stopping_times.csv"
  )


distribution_file <-
  file.path(
    results_dir,
    "stable_cate_stopping_time_distribution.csv"
  )


write.csv(
  decision_results,
  decision_file,
  row.names = FALSE
)


write.csv(
  stopping_performance,
  performance_file,
  row.names = FALSE
)


write.csv(
  mean_stopping_times,
  stopping_time_file,
  row.names = FALSE
)


write.csv(
  stopping_time_distribution,
  distribution_file,
  row.names = FALSE
)


# ============================================================
# 12. Final output
# ============================================================

cat("\n")
cat("============================================================\n")
cat("STABILITY-BASED CATE STOPPING COMPLETED\n")
cat("============================================================\n\n")


cat(
  "Harm-fraction threshold:",
  harm_fraction_threshold,
  "\n"
)


cat(
  "Required consecutive interims:",
  stability_interims_required,
  "\n\n"
)


cat(
  "Stopping performance:\n\n"
)

print(
  stopping_performance
)


cat(
  "\nMean stopping times:\n\n"
)

print(
  mean_stopping_times
)


cat(
  "\nStopping-time distribution:\n\n"
)

print(
  stopping_time_distribution
)


cat(
  "\nResults saved to:\n",
  results_dir,
  "\n"
)