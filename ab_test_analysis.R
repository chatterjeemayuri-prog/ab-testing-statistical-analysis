# A/B Testing and Statistical Hypothesis Testing in R

# Set seed for reproducibility
set.seed(123)

# Simulate data for two groups
n <- 100

group_A <- rnorm(n, mean = 50, sd = 10)
group_B <- rnorm(n, mean = 55, sd = 10)

# Create data frame
data <- data.frame(
  group = c(rep("A", n), rep("B", n)),
  value = c(group_A, group_B)
)

# Summary statistics
summary_A <- mean(group_A)
summary_B <- mean(group_B)

print(paste("Mean of Group A:", round(summary_A, 2)))
print(paste("Mean of Group B:", round(summary_B, 2)))

# Perform two-sample t-test
test_result <- t.test(group_A, group_B)

print("T-test results:")
print(test_result)

# Visualization
library(ggplot2)

ggplot(data, aes(x = group, y = value, fill = group)) +
  geom_boxplot() +
  labs(
    title = "A/B Test Comparison",
    x = "Group",
    y = "Outcome Value"
  ) +
  theme_minimal()
