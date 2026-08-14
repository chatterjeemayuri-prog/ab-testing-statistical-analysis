# Research Design

## Working Research Question

This project investigates the reliability of discovering heterogeneous treatment effects from A/B experiments when analysts have multiple potential treatment modifiers and repeated opportunities to inspect accumulating data.

The central research question is:

> **How reliable is treatment-effect heterogeneity discovered from sequentially monitored A/B experiments when analysts search across multiple pre-treatment covariates and subgroups, and how do statistical error-control strategies affect the quality of the resulting decisions?**

The study will use controlled simulation experiments in which the true treatment-effect structure is known. The simulated experiments will vary the number of candidate treatment modifiers, the strength and structure of genuine treatment-effect heterogeneity, sample size, and the frequency of interim analyses.

The investigation will focus on four primary questions:

1. **Heterogeneity discovery:** How reliably can genuine treatment-effect modifiers be identified when only a subset of candidate covariates truly modifies the treatment effect?

2. **False discoveries:** How frequently are irrelevant covariates or subgroups incorrectly identified as treatment-effect modifiers, particularly when many candidate interactions are examined?

3. **Sequential monitoring:** How does repeated examination of accumulating experimental data affect the reliability of heterogeneous-effect discovery and the rate of false discoveries?

4. **Decision quality:** Does controlling statistical error in the discovery of treatment heterogeneity lead to better downstream treatment decisions, and what trade-offs arise between false discoveries, missed heterogeneity, and statistical power?

The goal is not to propose a new statistical testing procedure, but to conduct a systematic simulation-based investigation of how experimental design, exploratory heterogeneity analysis, sequential monitoring, and statistical error control interact to affect the reliability of data-driven treatment decisions.

## Study Framework

The study will use controlled simulation experiments to represent randomized A/B tests in which the analyst has access to multiple pre-treatment covariates and potential treatment-effect modifiers.

Each simulated experiment will contain (n) individuals. For individual (i), the following variables will be generated:

* (A_i): randomized treatment assignment, where (A_i=0) denotes control and (A_i=1) denotes treatment.
* (Y_i): binary outcome representing whether the individual converts.
* (X_{i1},\ldots,X_{ip}): a set of continuous pre-treatment covariates available to the analyst before treatment assignment.
* (Z_i): one or more categorical pre-treatment variables representing potential subgroups.

Treatment assignment will be randomized according to

[
A_i \sim \operatorname{Bernoulli}(0.5).
]

The binary outcome will follow

[
Y_i \sim \operatorname{Bernoulli}(p_i),
]

with the conversion probability generated through a logistic model.

A general data-generating model will take the form

[
\operatorname{logit}(p_i)
=========================

\beta_0
+\beta_A A_i
+\sum_{j=1}^{p}\beta_j X_{ij}
+\sum_{k}\gamma_k Z_{ik}
+\sum_{j=1}^{p}\delta_j(A_iX_{ij})
+\sum_k\eta_k(A_iZ_{ik}).
]

The interaction terms represent treatment-effect modification. The simulation will distinguish between three types of candidate variables:

1. **True treatment modifiers:** variables for which the treatment effect genuinely depends on the covariate or subgroup.

2. **Prognostic but non-modifying variables:** variables that affect the probability of conversion but do not modify the treatment effect.

3. **Irrelevant variables:** variables that have no meaningful relationship with either the outcome or the treatment effect.

Only a subset of the available candidate variables will therefore contain genuine information about treatment-effect heterogeneity.

The number of candidate variables, the number of true treatment modifiers, the strength of their effects, and the degree of correlation between covariates will be varied across simulation scenarios.

This framework allows the study to investigate a central practical problem in A/B experimentation: an analyst may search across many possible interactions and subgroups even though only a small number represent genuine treatment-effect heterogeneity.

Because the data-generating mechanism is controlled, the true treatment-effect structure will be known for every simulated experiment. This will allow the performance of different analytical strategies to be evaluated against known ground truth.

The framework will also permit repeated interim analyses. In sequential-monitoring scenarios, the same accumulating experiment will be examined at multiple sample sizes, creating repeated opportunities to search for treatment-effect heterogeneity.

Numerical parameter values, covariance structures, sample sizes, and specific heterogeneity scenarios will be defined separately before computational experiments are implemented.

Numerical parameter values and the specific simulation scenarios will be defined separately before the computational experiments are implemented.

