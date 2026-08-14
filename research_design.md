# Research Design

## Working Research Question

This project investigates the statistical and decision-making consequences of sequentially monitoring A/B experiments when treatment-effect heterogeneity is evaluated and potentially used to guide treatment decisions.

The central research question is:

> **When sequential A/B-testing procedures are used to discover heterogeneous treatment effects, how do different analysis and stopping strategies trade off statistical validity, detection speed, subgroup-effect estimation, and downstream decision quality?**

The study will conduct a controlled simulation-based comparison of established analytical strategies rather than proposing a new statistical testing procedure. Because the data-generating mechanisms will be known, the study will evaluate each strategy against the underlying treatment-effect structure and the optimal treatment decision under the simulated truth.

The investigation will focus on four primary questions:

1. **Statistical validity:** How do fixed-horizon and sequential analysis strategies differ in Type-I error, power, false subgroup discovery, bias, and uncertainty calibration?

2. **Detection efficiency:** How do different sequential monitoring and stopping strategies trade off the speed of detecting genuine treatment-effect heterogeneity against sample size and the probability of failing to reach a reliable conclusion?

3. **Subgroup-effect reliability:** How much selection-induced optimism arises when treatment-effect estimates are obtained for data-driven subgroups, and how does independent or subsequent evaluation affect this optimism?

4. **Decision quality:** Do methods with stronger statistical performance necessarily produce better treatment decisions? This will be evaluated using decision-oriented quantities such as treatment-rule value and regret relative to the optimal treatment rule under the known data-generating mechanism.

The project will therefore connect four stages of the experimental decision process:

\[
\text{Sequential monitoring}
\rightarrow
\text{HTE discovery}
\rightarrow
\text{Treatment-effect estimation}
\rightarrow
\text{Treatment decision}.
\]

The objective is to provide a reproducible, decision-oriented benchmark of established approaches under controlled experimental conditions, with particular attention to the trade-off between early detection, statistical reliability, and downstream decision quality.

## Study Framework

The study will use controlled simulation experiments to evaluate established A/B-testing and heterogeneous-treatment-effect analysis strategies under known data-generating mechanisms.

The fundamental unit of the simulation will be a randomized A/B experiment with a binary outcome. For individual \(i\), let

- \(A_i\) denote randomized treatment assignment, with \(A_i=0\) for control and \(A_i=1\) for treatment;
- \(Y_i\) denote the observed binary outcome;
- \(X_i\) denote a vector of pre-treatment covariates.

Treatment assignment will be randomized according to

\[
A_i \sim \operatorname{Bernoulli}(\pi),
\]

where the allocation probability \(\pi\) will be specified as part of the simulation design.

The outcome will be generated from a known data-generating mechanism. The corresponding conditional treatment effect will be defined as

\[
\tau(x)
=
E\{Y(1)-Y(0)\mid X=x\}.
\]

Different simulation scenarios will specify different forms of \(\tau(x)\), including settings with:

1. no treatment-effect heterogeneity;
2. homogeneous treatment effects;
3. heterogeneous treatment effects that depend on a small number of covariates;
4. heterogeneous effects with nonlinear or subgroup-specific structure; and
5. heterogeneous effects in which the beneficial population represents only a subset of the overall experimental population.

The simulation will distinguish between **prognostic covariates**, which affect the outcome but do not modify the treatment effect, and **predictive covariates**, which genuinely modify the treatment effect.

For each simulated experiment, observations will accumulate sequentially. At predefined interim sample sizes, an analysis strategy will be applied to the data available at that point.

The analysis strategy will determine whether:

- evidence for treatment-effect heterogeneity has been obtained;
- a candidate subgroup or treatment rule has been identified;
- the experiment should continue;
- or a treatment decision should be considered.

The study will compare fixed-horizon and sequential analysis strategies. Sequential strategies may differ in their testing and stopping rules, while fixed-horizon strategies will provide a reference point against which the consequences of continuous monitoring can be evaluated.

When a treatment rule or subgroup is selected, its estimated treatment effect will be distinguished from its true treatment effect under the known data-generating mechanism.

For a treatment rule \(d(x)\in\{0,1\}\), its population value will be defined as

\[
V(d)
=
E\{Y(d(X))\}.
\]

Because the data-generating mechanism is known, the simulation will also define an optimal treatment rule \(d^*(x)\) under each scenario. This permits evaluation of the decision quality of an estimated rule through quantities such as

\[
\operatorname{Regret}(\widehat d)
=
V(d^*)-V(\widehat d).
\]

The simulation will therefore evaluate the complete experimental decision process:

\[
\text{Data generation}
\rightarrow
\text{Sequential monitoring}
\rightarrow
\text{HTE discovery}
\rightarrow
\text{Treatment-effect estimation}
\rightarrow
\text{Treatment decision}.
\]

This framework separates statistical evidence from downstream decision quality. A procedure may identify treatment-effect heterogeneity with high statistical power while still producing a treatment rule with poor value or substantial regret. Conversely, a more conservative procedure may delay detection while producing more reliable treatment decisions.

The final simulation scenarios, analytical strategies, stopping rules, and numerical parameter values will be specified separately before computational experiments are implemented.

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
