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

## Simulation Dimensions

The simulation study will vary six primary dimensions that determine the difficulty and reliability of treatment-effect heterogeneity discovery.

### 1. Sample size

The total number of observations in each experiment will be varied across small, moderate, and large sample-size regimes.

This dimension will be used to investigate finite-sample limitations in the estimation and detection of treatment-effect heterogeneity.

### 2. Number of candidate treatment modifiers

The number of pre-treatment covariates and subgroup variables available for potential treatment-effect modification will be varied.

Only a subset of these variables will contain genuine treatment-effect heterogeneity. Increasing the number of candidate modifiers will therefore increase the size of the search space and the opportunity for false discoveries.

### 3. Sparsity of true treatment heterogeneity

The number and proportion of candidate variables that genuinely modify treatment response will be varied.

The study will therefore consider both relatively sparse settings, in which only a small number of variables modify treatment response, and less sparse settings with a larger number of genuine modifiers.

### 4. Strength of treatment-effect heterogeneity

The magnitude of genuine treatment-effect modification will be varied across weak, moderate, and strong regimes.

This will allow the study to investigate the boundary between the existence of treatment heterogeneity and its reliable statistical detection.

### 5. Sequential monitoring intensity

Selected experiments will be evaluated at multiple interim sample sizes.

The frequency of interim analyses will be varied to investigate whether repeated opportunities to inspect accumulating data and search for treatment-effect heterogeneity increase false discoveries or otherwise affect statistical decision-making.

### 6. Correlation among candidate covariates

The dependence structure among candidate pre-treatment covariates will be varied.

Scenarios with weakly correlated covariates will be compared with scenarios containing stronger correlation. This will allow the study to investigate whether correlated candidate modifiers make it more difficult to distinguish genuine treatment-effect modifiers from variables that are associated with them.

### Simulation design principle

The full simulation study will not evaluate every possible combination of these dimensions. Such a design would produce an unnecessarily large and difficult-to-interpret simulation space.

Instead, the study will use a structured set of scenarios. Baseline scenarios will establish reference operating characteristics, followed by targeted perturbations of individual dimensions and a smaller number of combined stress scenarios.

The final simulation grid will be specified before computational experiments are conducted.

## Baseline Scenario

A baseline simulation scenario will be established as the reference point for the subsequent simulation experiments.

The baseline will represent a relatively well-behaved randomized A/B experiment with the following characteristics:

* a binary conversion outcome;
* randomized treatment assignment with equal allocation between treatment and control;
* a moderate total sample size;
* a moderate baseline conversion probability;
* a small number of pre-treatment covariates that may be prognostic for the outcome;
* no genuine treatment-effect heterogeneity;
* candidate treatment modifiers that are available for analysis but do not genuinely modify the treatment effect;
* no sequential monitoring or interim analysis.

The baseline scenario is intentionally designed to contain **no true treatment-effect heterogeneity**. This provides a reference environment in which any apparent treatment-effect modifiers identified by the analytical procedures are false discoveries.

The baseline will therefore be used primarily to evaluate:

* empirical Type-I error;
* false treatment-effect modifier discovery;
* calibration of uncertainty estimates;
* estimation bias;
* confidence-interval coverage; and
* the stability of statistical decisions under repeated simulation.

All numerical parameters for the baseline scenario will be selected and justified separately before the simulation is implemented.

## Parameter Selection Protocol

Numerical parameters for the simulation study will be selected using a combination of empirical plausibility, methodological literature, and deliberately constructed stress scenarios.

### Empirically plausible regimes

Where appropriate, baseline values and ranges will be motivated by realistic A/B-testing settings. This will include quantities such as:

* baseline conversion probability;
* treatment-effect magnitude;
* sample size;
* treatment allocation ratio; and
* plausible dependence among pre-treatment covariates.

The objective is to ensure that the reference scenarios represent credible experimental settings rather than arbitrary numerical examples.

### Literature-motivated regimes

For methodological quantities for which no single empirical value is appropriate, parameter ranges will be informed by relevant statistical literature, particularly literature concerning:

* treatment-effect heterogeneity;
* multiple testing and false discoveries;
* sequential monitoring;
* covariate adjustment; and
* high-dimensional or correlated candidate treatment modifiers.

Relevant sources will be documented so that the choices can be evaluated and reproduced.

### Deliberate stress scenarios

In addition to reference scenarios, the simulation study will include deliberately difficult settings designed to identify conditions under which treatment-effect discovery and downstream decisions become unreliable.

Examples may include combinations of:

* many candidate treatment modifiers;
* weak genuine heterogeneity;
* strong correlation among candidate covariates;
* limited sample sizes; and
* frequent interim analyses.

These scenarios will be explicitly identified as stress tests rather than representative experimental settings.

### Scenario classification

Each simulation scenario will be classified as one of:

1. **Reference:** a plausible and relatively well-behaved experimental setting.
2. **Perturbation:** a controlled change to one or more features of the reference setting used to isolate a specific methodological effect.
3. **Stress test:** a deliberately difficult configuration used to investigate the limits of reliable treatment-effect discovery.

The simulation design will prioritize interpretability over the exhaustive enumeration of parameter combinations. Each scenario will therefore be included because it addresses a specific research question or tests a clearly defined methodological hypothesis.

All numerical parameter choices and their justification will be recorded before the corresponding computational experiments are conducted.
