# A/B Testing and Statistical Hypothesis Testing in R

## Project Overview
This project demonstrates how statistical hypothesis testing is used to evaluate differences between two groups in an A/B test. The goal is to determine whether an observed difference is statistically significant and can inform decision-making.

## Problem Statement
- Compare two groups (Control vs Treatment)
- Evaluate whether a change leads to a measurable improvement
- Use statistical testing to validate results

## Methodology
- Data simulation for two experimental groups  
- Exploratory data analysis (EDA)  
- Two-sample t-test  
- Confidence interval estimation  
- Visualization of group differences  

## Key Concepts
- Null hypothesis (H0) vs Alternative hypothesis (H1)  
- p-value interpretation  
- Statistical significance vs practical significance  
- Type I and Type II errors  
- Confidence intervals  

## Results
- Computed test statistics and p-values  
- Determined whether to reject or fail to reject H0  
- Quantified uncertainty using confidence intervals  

## Business Interpretation
- Helps validate product or feature changes  
- Supports data-driven decision-making  
- Reduces risk of incorrect conclusions  

## Tech Stack
- R  
- ggplot2  
- dplyr  

## How to Run
1. Open `ab_test_analysis.R`  
2. Run the script in R or RStudio  
3. The script will:
   - Simulate experiment data  
   - Perform statistical tests  
   - Output results and visualizations  

## Repository Structure
```
ab-testing-statistical-analysis/
│
├── ab_test_analysis.R   # Main analysis script
└── README.md           # Project documentation
```

## Future Improvements
- Extend to non-parametric tests  
- Add Bayesian A/B testing approach  
- Handle real-world datasets instead of simulated data  
- Automate experiment evaluation pipeline  
- Add dashboard for result visualization  