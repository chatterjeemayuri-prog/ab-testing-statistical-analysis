# Research Design

## Working Research Question

This project investigates the reliability of statistical decision-making in A/B experiments under realistic sources of uncertainty and model complexity.

The central research question is:

> **How robust are A/B-testing conclusions under finite sample sizes, sequential monitoring, covariate variation, and heterogeneous treatment effects, and how can statistical modelling improve the reliability of experimental decisions?**

The study will use controlled simulation experiments to examine how different experimental conditions affect estimation, inference, and decision-making. Particular attention will be given to situations in which standard aggregate A/B-test conclusions may become unreliable or fail to capture important features of the underlying treatment effect.

The investigation will focus on three primary questions:

1. **Finite-sample behaviour:** How do sample size and treatment-effect magnitude affect the operating characteristics of standard A/B-testing procedures?

2. **Sequential monitoring:** How does repeated monitoring of an experiment affect false-positive rates and statistical decisions when conventional fixed-horizon inference is used?

3. **Treatment-effect heterogeneity and covariates:** How do pre-treatment covariates and heterogeneous treatment effects affect aggregate treatment-effect estimates, and can statistical adjustment and interaction modelling improve the reliability and interpretability of experimental conclusions?


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

