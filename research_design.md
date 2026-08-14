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

The study will use controlled simulation experiments to represent randomized A/B tests with a binary conversion outcome.

Each simulated experiment will contain (n) individuals. For individual (i), the following variables will be generated:

* (A_i): randomized treatment assignment, where (A_i=0) denotes the control group and (A_i=1) denotes the treatment group.
* (X_i): a continuous pre-treatment covariate representing information available before treatment assignment.
* (Z_i): a categorical pre-treatment subgroup variable.
* (Y_i): a binary outcome representing whether the individual converts.

Treatment assignment will be randomized according to

[
A_i \sim \operatorname{Bernoulli}(0.5).
]

The outcome will follow a Bernoulli distribution,

[
Y_i \sim \operatorname{Bernoulli}(p_i),
]

with conversion probability determined through a logistic data-generating model:

[
\operatorname{logit}(p_i)
=========================

\beta_0
+\beta_A A_i
+\beta_X X_i
+\beta_Z Z_i
+\beta_{AX}(A_iX_i)
+\beta_{AZ}(A_iZ_i).
]

The treatment-by-covariate and treatment-by-subgroup interaction terms allow the underlying treatment effect to vary across individuals and subgroups.

The simulation framework will therefore allow the study to distinguish between:

1. a null treatment effect;
2. a homogeneous treatment effect;
3. treatment effects that vary with pre-treatment covariates;
4. treatment effects that vary across subgroups; and
5. combinations of these sources of heterogeneity.

Because the data-generating mechanism is controlled, the true parameters will be known in each simulation scenario. This will allow the statistical procedures to be evaluated against known ground truth rather than only against observed data.

Numerical parameter values and the specific simulation scenarios will be defined separately before the computational experiments are implemented.

