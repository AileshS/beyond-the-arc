# Slide 15 - "Model Application - Comparing Al Horford's Playstyle (2015 vs 2024)"
# Both seasons are scored by the old-school model (trained on old_school_seasons,
# set in slide 12), so we see how each version of Horford fits the older idea of each position.

source('code/slide12_multinomial_model.R')
library(gridExtra)

# Bar chart of one player's position probabilities in one season
# (same idea as get_player_probabilities_2024 in original_models.R, but bars instead of a pie)
get_player_probabilities <- function(model, player_name, season_year, title_end = season_year, digits = 1) {
  player_data <- predict_season(model, season_year) %>% filter(player == player_name)

  if (nrow(player_data) == 0) {
    cat("No data found for player", player_name, "in", season_year, "\n")
    return()
  }

  probabilities <- unlist(player_data$predicted_probabilities)
  position_names <- model$lev

  # Prepare data for plotting
  plot_data <- data.frame(Position = position_names, Probability = probabilities)

  # Add percentage labels
  plot_data$Percentage <- paste0(formatC(plot_data$Probability * 100, format = "f", digits = digits), "%")

  # Plot probabilities
  ggplot(plot_data, aes(x = Position, y = Probability, fill = Position)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = Percentage), vjust = -0.5) +
    labs(title = paste(player_name, "Position Probabilities -", title_end)) +
    theme_minimal()
}

horford_2015 <- get_player_probabilities(old_school_model, 'Al Horford', 2015)
horford_2024 <- get_player_probabilities(old_school_model, 'Al Horford', 2024)

grid.arrange(horford_2015, horford_2024, ncol = 2)
