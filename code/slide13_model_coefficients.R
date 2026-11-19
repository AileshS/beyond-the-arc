# Slide 13 - "Evaluating our Model - What are the Coefficients?"
# Each coefficient = how much that stat changes the log-odds of being that
# position instead of a PG (the baseline).

source('code/slide12_multinomial_model.R')

# One row per position (C, PF, SF, SG), one column per stat
coefficients <- coef(model)
print(coefficients)

# P-values: multinom doesn't give them, so we work them out from the standard errors
z_scores <- coefficients / summary(model)$standard.errors
p_values <- 2 * (1 - pnorm(abs(z_scores)))
print(p_values)

# Which stats had the smallest p-values? (average over the 4 positions)
print(sort(colMeans(p_values[, -1])))

# Long format for plotting, without the intercept
coef_long <- melt(coefficients[, -1], varnames = c("Position", "Feature"), value.name = "Coefficient")

# Sideways bar chart, biggest average coefficient at the top
coef_plot <- ggplot(coef_long, aes(x = reorder(Feature, Coefficient, mean), y = Coefficient, fill = Position)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  labs(x = "Feature", y = "Coefficient",
       title = "Coefficients of Multinomial Logistic Regression - Compared to Baseline PG Position") +
  theme_minimal()

coef_plot
