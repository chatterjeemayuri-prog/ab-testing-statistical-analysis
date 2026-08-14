# Stability-Based Early Stopping for Heterogeneous Effects in Sequential A/B Experiments

## Overview

This repository contains the simulation study and reproducible R code for:

**Stability-Based Early Stopping for Heterogeneous Effects in Sequential A/B Experiments**

The project investigates whether the stability of an estimated harmful population can improve sequential stopping decisions when treatment effects are heterogeneous.

The central idea is to combine:

1. a CATE-based harmful-fraction criterion; and
2. a stability criterion based on Jaccard similarity between consecutive estimated harmful populations.

The resulting stopping rule requires both conditions to be satisfied before an early stopping decision is made.

---

## Research question

In a sequential A/B experiment with heterogeneous treatment effects:

> Does requiring the estimated harmful population to remain stable across consecutive interim analyses reduce premature or reversible harm-based stopping decisions?

The simulation compares a naive CATE-based stopping rule with a stability-enhanced rule.

---

## Method

### CATE estimation

For each interim analysis, treatment-effect heterogeneity is estimated using a logistic regression containing:

- treatment;
- the baseline covariate;
- treatment--covariate interaction.

The estimated conditional average treatment effect is defined on the probability scale as

\[
\widehat{\tau}(x)
=
\widehat{p}_1(x)
-
\widehat{p}_0(x).
\]

### Meaningful harm

An observation is classified as experiencing meaningful harm when

\[
\widehat{\tau}(X_i)\leq -0.02.
\]

The estimated harmful fraction is

\[
\widehat h_k
=
\frac{|\widehat{\mathcal H}_k|}{n_k}.
\]

The basic stopping criterion is

\[
\widehat h_k \geq 0.50.
\]

### Stability

For consecutive interim harmful sets,

\[
\widehat{\mathcal H}_{k-1}
\quad\text{and}\quad
\widehat{\mathcal H}_k,
\]

stability is measured using the Jaccard similarity

\[
J_k
=
\frac{
|\widehat{\mathcal H}_{k-1}
\cap
\widehat{\mathcal H}_k|
}{
|\widehat{\mathcal H}_{k-1}
\cup
\widehat{\mathcal H}_k|
}.
\]

The stability-enhanced stopping rule requires

\[
\widehat h_k \geq 0.50
\]

and

\[
J_k \geq J_0.
\]

The sensitivity analysis considers

\[
J_0
\in
\{0.50,0.60,0.70,0.75,0.80,0.90\}.
\]

The value \(J_0=0.75\) is used as an illustrative operating point, not as an optimized universal threshold.

---

## Simulation design

The simulation uses:

- 500 replicated experiments;
- 4,000 observations per experiment;
- randomized treatment allocation with probability 0.5;
- a baseline covariate;
- six interim analyses.

The interim sample sizes are

\[
1000,\;1600,\;2200,\;2800,\;3400,\;4000.
\]

Two heterogeneous-effect scenarios are considered.

### Scenario A: threshold heterogeneity

Treatment has no effect for most of the population and a harmful effect in an upper-tail subgroup of the baseline covariate.

The control outcome probability is 0.10.

Within the harmed subgroup, the treatment effect is -0.04.

This produces a relatively sharp heterogeneous treatment-effect structure.

### Scenario B: smooth logistic heterogeneity

Treatment effects vary smoothly with the baseline covariate through a logistic treatment-response model.

The resulting true CATE is approximately in the range

\[
[-0.062,-0.014],
\]

with an average effect of approximately -0.037 in the simulated population.

---

## Main findings

At the illustrative stability threshold

\[
J_0=0.75,
\]

the results are:

| Metric | Scenario A | Scenario B |
|---|---:|---:|
| Naive stopping probability | 39.2% | 99.0% |
| Stable stopping probability | 31.4% | 98.6% |
| Naive agreement with final decision | 79.2% | 98.8% |
| Stable agreement with final decision | 85.4% | 98.4% |
| Naive reversal probability | 20.8% | 1.2% |
| Stable reversal probability | 13.8% | 1.2% |
| Naive mean stopping sample size | 1,898 | 1,677 |
| Stable mean stopping sample size | 2,269 | 1,859 |

The principal pattern is that the stability criterion has its largest effect in the threshold scenario, where the estimated harmful population is less persistent across interim analyses.

Increasing the Jaccard threshold produces a trade-off:

- higher stability requirements reduce early stopping;
- reversal probability decreases;
- mean stopping sample size increases.

The smooth scenario is substantially less sensitive to the stability threshold.

---

## Repository structure

```text
ab_testing/
│
├── README.md
│
├── R_files/
│   ├── 01_data_generation.R
│   ├── 02_cate_estimation.R
│   ├── 03_sequential_simulation.R
│   ├── 04_repeated_sequential_simulation.R
│   ├── 05_stopping_rules.R
│   ├── 06_stable_cate_stopping.R
│   ├── 07_cate_stability_metrics.R
│   ├── 08_stability_threshold_sensitivity.R
│   └── 09_final_figures.R
│
├── paper/
│   ├── main.tex
│   ├── references.bib
│   └── figures/
│       ├── Figure_1_harm_fraction.png
│       ├── Figure_2_jaccard_stability.png
│       ├── Figure_3_stopping_probability.png
│       ├── Figure_4_reversal_probability.png
│       └── Figure_5_mean_stopping_sample_size.png
│
└── results/
    ├── cate_estimates_A_threshold.csv
    ├── cate_estimates_B_smooth_logistic.csv
    ├── cate_stability_results.csv
    ├── cate_stability_summary.csv
    ├── cate_validation_A_threshold.csv
    ├── cate_validation_by_subgroup.csv
    ├── cate_validation_B_smooth_logistic.csv
    ├── cate_validation_summary.csv
    ├── main_results_table.csv
    ├── mean_stopping_times.csv
    ├── repeated_sequential_quantiles.csv
    ├── repeated_sequential_results.csv
    ├── repeated_sequential_summary.csv
    ├── sequential_CATE_summary.csv
    ├── simulation_data_scenario_A.csv
    ├── simulation_data_scenario_B.csv
    ├── simulation_parameters.csv
    ├── simulation_validation.csv
    ├── stability_threshold_mean_stopping_times.csv
    ├── stability_threshold_median_stopping_times.csv
    ├── stability_threshold_performance.csv
    ├── stability_threshold_results.csv
    ├── stable_cate_decisions.csv
    ├── stable_cate_mean_stopping_times.csv
    ├── stable_cate_performance_summary.csv
    ├── stable_cate_stopping_time_distribution.csv
    ├── stopping_decisions.csv
    └── stopping_performance_summary.csv