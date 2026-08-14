# ============================================================
# 09_final_figures.R
#
# Purpose:
#   Create the final publication-quality figures for the
#   mini-paper from the completed simulation results.
#
# Figures:
#
#   Figure 1:
#       Estimated harmful fraction across interim analyses
#
#   Figure 2:
#       Jaccard similarity of harmful CATE sets
#
#   Figure 3:
#       Stopping probability versus Jaccard threshold
#
#   Figure 4:
#       Reversal probability versus Jaccard threshold
#
#   Figure 5:
#       Mean stopping sample size versus Jaccard threshold
#
# All figures are saved to:
#
#   ab_testing/results/figures/
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

figures_dir <-
  file.path(
    results_dir,
    "figures"
  )

dir.create(
  figures_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ------------------------------------------------------------
# 2. Required package
# ------------------------------------------------------------

if (!requireNamespace(
  "ggplot2",
  quietly = TRUE
)) {
  
  stop(
    "Package 'ggplot2' is required.\n",
    "Install it with install.packages('ggplot2')"
  )
}

library(
  ggplot2
)


# ============================================================
# 3. Load result files
# ============================================================


# ------------------------------------------------------------
# Sequential CATE results
# ------------------------------------------------------------

sequential_file <-
  file.path(
    results_dir,
    "repeated_sequential_results.csv"
  )


if (!file.exists(sequential_file)) {
  
  stop(
    "Could not find:\n",
    sequential_file,
    "\nRun 04_repeated_sequential_simulation.R first."
  )
}


sequential_results <-
  read.csv(
    sequential_file,
    stringsAsFactors = FALSE
  )


# ------------------------------------------------------------
# CATE stability results
# ------------------------------------------------------------

stability_file <-
  file.path(
    results_dir,
    "cate_stability_summary.csv"
  )


if (!file.exists(stability_file)) {
  
  stop(
    "Could not find:\n",
    stability_file,
    "\nRun 07_cate_stability_metrics.R first."
  )
}


stability_summary <-
  read.csv(
    stability_file,
    stringsAsFactors = FALSE
  )


# ------------------------------------------------------------
# Threshold sensitivity
# ------------------------------------------------------------

threshold_performance_file <-
  file.path(
    results_dir,
    "stability_threshold_performance.csv"
  )


if (!file.exists(threshold_performance_file)) {
  
  stop(
    "Could not find:\n",
    threshold_performance_file,
    "\nRun 08_stability_threshold_sensitivity.R first."
  )
}


threshold_performance <-
  read.csv(
    threshold_performance_file,
    stringsAsFactors = FALSE
  )


mean_stopping_file <-
  file.path(
    results_dir,
    "stability_threshold_mean_stopping_times.csv"
  )


if (!file.exists(mean_stopping_file)) {
  
  stop(
    "Could not find:\n",
    mean_stopping_file,
    "\nRun 08_stability_threshold_sensitivity.R first."
  )
}


mean_stopping_times <-
  read.csv(
    mean_stopping_file,
    stringsAsFactors = FALSE
  )


# ============================================================
# 4. Common figure theme
# ============================================================

paper_theme <-
  theme_minimal(
    base_size = 12
  ) +
  theme(
    plot.title =
      element_text(
        face = "bold",
        size = 13
      ),
    
    plot.subtitle =
      element_text(
        size = 10
      ),
    
    axis.title =
      element_text(
        size = 11
      ),
    
    legend.title =
      element_text(
        size = 10
      ),
    
    legend.position =
      "bottom",
    
    panel.grid.minor =
      element_blank(),
    
    plot.margin =
      margin(
        10,
        10,
        10,
        10
      )
  )


# ============================================================
# FIGURE 1
#
# Mean estimated harmful fraction across interim analyses
# ============================================================

# Aggregate the replicate-level results first.
# This gives one mean value per scenario and interim.

harm_fraction_summary <-
  aggregate(
    fraction_CATE_meaningfully_harmed ~
      scenario +
      interim_n,
    data =
      sequential_results,
    FUN =
      mean
  )


harm_fraction_summary <-
  harm_fraction_summary[
    order(
      harm_fraction_summary$scenario,
      harm_fraction_summary$interim_n
    ),
    ,
    drop = FALSE
  ]


figure1 <-
  ggplot(
    harm_fraction_summary,
    aes(
      x =
        interim_n,
      
      y =
        fraction_CATE_meaningfully_harmed,
      
      group =
        scenario,
      
      linetype =
        scenario
    )
  ) +
  
  geom_line(
    linewidth =
      0.8
  ) +
  
  geom_point(
    size =
      2.5
  ) +
  
  geom_hline(
    yintercept =
      0.50,
    
    linetype =
      "dashed"
  ) +
  
  scale_y_continuous(
    limits =
      c(
        0,
        1
      ),
    
    labels =
      scales::percent
  ) +
  
  scale_x_continuous(
    breaks =
      c(
        1000,
        1600,
        2200,
        2800,
        3400,
        4000
      )
  ) +
  
  labs(
    title =
      "Estimated fraction experiencing meaningful harm",
    
    subtitle =
      "Mean across simulation replicates; meaningful harm defined as estimated CATE <= -0.02",
    
    x =
      "Interim sample size",
    
    y =
      "Fraction classified as harmed",
    
    linetype =
      "Scenario"
  ) +
  
  paper_theme


ggsave(
  filename =
    file.path(
      figures_dir,
      "Figure_1_harm_fraction.png"
    ),
  
  plot =
    figure1,
  
  width =
    7,
  
  height =
    4.5,
  
  dpi =
    300
)


# ============================================================
# FIGURE 2
#
# Jaccard similarity of harmful sets
# ============================================================


stability_summary$transition <-
  paste0(
    stability_summary$previous_n,
    "–",
    stability_summary$current_n
  )


stability_summary$transition <-
  factor(
    stability_summary$transition,
    
    levels =
      c(
        "1000–1600",
        "1600–2200",
        "2200–2800",
        "2800–3400",
        "3400–4000"
      )
  )


figure2 <-
  ggplot(
    stability_summary,
    aes(
      x =
        transition,
      
      y =
        jaccard_similarity,
      
      group =
        scenario,
      
      linetype =
        scenario
    )
  ) +
  
  geom_line(
    linewidth = 0.8
  ) +
  
  geom_point(
    size = 2
  ) +
  
  geom_hline(
    yintercept =
      0.75,
    
    linetype =
      "dashed"
  ) +
  
  scale_y_continuous(
    limits =
      c(
        0,
        1
      )
  ) +
  
  labs(
    title =
      "Stability of the estimated harmful population",
    
    subtitle =
      "Jaccard similarity between consecutive interim harmful sets",
    
    x =
      "Consecutive interim analyses",
    
    y =
      "Jaccard similarity",
    
    linetype =
      "Scenario"
  ) +
  
  paper_theme


ggsave(
  filename =
    file.path(
      figures_dir,
      "Figure_2_jaccard_stability.png"
    ),
  
  plot =
    figure2,
  
  width =
    7,
  
  height =
    4.5,
  
  dpi =
    300
)


# ============================================================
# FIGURE 3
#
# Stopping probability versus Jaccard threshold
# ============================================================


figure3_data <-
  threshold_performance


figure3 <-
  ggplot(
    figure3_data,
    aes(
      x =
        jaccard_threshold,
      
      y =
        stable_stopped,
      
      group =
        scenario,
      
      linetype =
        scenario
    )
  ) +
  
  geom_line(
    linewidth =
      0.8
  ) +
  
  geom_point(
    size =
      2
  ) +
  
  scale_y_continuous(
    limits =
      c(
        0,
        1
      ),
    
    labels =
      scales::percent
  ) +
  
  scale_x_continuous(
    breaks =
      c(
        0.50,
        0.60,
        0.70,
        0.75,
        0.80,
        0.90
      )
  ) +
  
  labs(
    title =
      "Sensitivity of stopping probability to the stability threshold",
    
    x =
      "Jaccard stability threshold",
    
    y =
      "Probability of stopping",
    
    linetype =
      "Scenario"
  ) +
  
  paper_theme


ggsave(
  filename =
    file.path(
      figures_dir,
      "Figure_3_stopping_probability.png"
    ),
  
  plot =
    figure3,
  
  width =
    7,
  
  height =
    4.5,
  
  dpi =
    300
)


# ============================================================
# FIGURE 4
#
# Reversal probability versus Jaccard threshold
# ============================================================


figure4 <-
  ggplot(
    threshold_performance,
    aes(
      x =
        jaccard_threshold,
      
      y =
        stable_reversal,
      
      group =
        scenario,
      
      linetype =
        scenario
    )
  ) +
  
  geom_line(
    linewidth =
      0.8
  ) +
  
  geom_point(
    size =
      2
  ) +
  
  scale_y_continuous(
    limits =
      c(
        0,
        0.30
      ),
    
    labels =
      scales::percent
  ) +
  
  scale_x_continuous(
    breaks =
      c(
        0.50,
        0.60,
        0.70,
        0.75,
        0.80,
        0.90
      )
  ) +
  
  labs(
    title =
      "Sensitivity of decision reversal to the stability threshold",
    
    subtitle =
      "Reversal = early harm decision not supported at the final interim",
    
    x =
      "Jaccard stability threshold",
    
    y =
      "Reversal probability",
    
    linetype =
      "Scenario"
  ) +
  
  paper_theme


ggsave(
  filename =
    file.path(
      figures_dir,
      "Figure_4_reversal_probability.png"
    ),
  
  plot =
    figure4,
  
  width =
    7,
  
  height =
    4.5,
  
  dpi =
    300
)


# ============================================================
# FIGURE 5
#
# Mean stopping sample size versus Jaccard threshold
# ============================================================


figure5 <-
  ggplot(
    mean_stopping_times,
    aes(
      x =
        jaccard_threshold,
      
      y =
        stable_first_stop_n,
      
      group =
        scenario,
      
      linetype =
        scenario
    )
  ) +
  
  geom_line(
    linewidth =
      0.8
  ) +
  
  geom_point(
    size =
      2
  ) +
  
  scale_x_continuous(
    breaks =
      c(
        0.50,
        0.60,
        0.70,
        0.75,
        0.80,
        0.90
      )
  ) +
  
  labs(
    title =
      "Mean stopping sample size",
    
    subtitle =
      "Stability-enhanced CATE stopping rule",
    
    x =
      "Jaccard stability threshold",
    
    y =
      "Mean stopping sample size",
    
    linetype =
      "Scenario"
  ) +
  
  paper_theme


ggsave(
  filename =
    file.path(
      figures_dir,
      "Figure_5_mean_stopping_sample_size.png"
    ),
  
  plot =
    figure5,
  
  width =
    7,
  
  height =
    4.5,
  
  dpi =
    300
)


# ============================================================
# 5. Create a compact results table
# ============================================================


# Select the 0.75 threshold as the illustrative operating
# point for the main results table.

selected_threshold <-
  threshold_performance[
    threshold_performance$jaccard_threshold ==
      0.75,
    ,
    drop = FALSE
  ]


selected_stopping <-
  mean_stopping_times[
    mean_stopping_times$jaccard_threshold ==
      0.75,
    ,
    drop = FALSE
  ]


main_results_table <-
  merge(
    selected_threshold,
    selected_stopping,
    by =
      c(
        "scenario",
        "jaccard_threshold"
      )
  )


write.csv(
  main_results_table,
  file.path(
    results_dir,
    "main_results_table.csv"
  ),
  row.names =
    FALSE
)


# ============================================================
# 6. Final validation
# ============================================================


required_figures <-
  c(
    "Figure_1_harm_fraction.png",
    "Figure_2_jaccard_stability.png",
    "Figure_3_stopping_probability.png",
    "Figure_4_reversal_probability.png",
    "Figure_5_mean_stopping_sample_size.png"
  )


figure_paths <-
  file.path(
    figures_dir,
    required_figures
  )


if (
  !all(
    file.exists(
      figure_paths
    )
  )
) {
  
  stop(
    "One or more figures were not created."
  )
}


# ============================================================
# 7. Final output
# ============================================================


cat("\n")
cat("============================================================\n")
cat("FINAL FIGURES CREATED SUCCESSFULLY\n")
cat("============================================================\n\n")


cat(
  "Figures saved to:\n",
  figures_dir,
  "\n\n"
)


cat(
  "Created figures:\n\n"
)


for (
  figure_name in required_figures
) {
  
  cat(
    "  ",
    figure_name,
    "\n"
  )
}


cat(
  "\nMain results table saved to:\n",
  file.path(
    results_dir,
    "main_results_table.csv"
  ),
  "\n"
)


cat(
  "\nSelected Jaccard threshold:",
  selected_threshold$jaccard_threshold[1],
  "\n\n"
)


cat(
  "Main results table:\n\n"
)

print(
  main_results_table
)


cat(
  "\n============================================================\n"
)