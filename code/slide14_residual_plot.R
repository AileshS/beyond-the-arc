# Slide 14 - "Residual Plot"
# For every player held back from training: residual = actual (1 if he is that
# position, 0 if not) minus the probability the model gave that position.

source('code/slide12_multinomial_model.R')

# Model's probabilities for the validation players
predicted_probabilities <- predict(model, X_val, type = "probs")

# Turn the true positions into 0/1 columns (y_valPG, y_valC, y_valPF, ...)
actual <- model.matrix(~ y_val - 1)

# Residuals = actual - predicted (columns are in the same order: PG, C, PF, SF, SG)
residuals <- as.data.frame(actual - predicted_probabilities[, levels(y_val)])
residuals$player_number <- seq_len(nrow(residuals))

# Long format so we can make one panel per position
residuals_long <- melt(residuals, id.vars = "player_number", value.name = "Residual")

residual_plot <- ggplot(residuals_long, aes(x = player_number, y = Residual, color = variable)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ variable, ncol = 3) +
  labs(x = "Fitted Value", y = "Residuals", title = "Residuals of Multinomial Logistic Regression Model") +
  theme_minimal()

residual_plot
