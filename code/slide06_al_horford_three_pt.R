# Slide 6 - Three-point field goals made and attempted per season for Al Horford
# (same code as slide 5, just a different player and green colors)

library(modelr)
library(tidyverse)
library(hoopR)

player_name <- "Al Horford"

# Load NBA player box scores for the specified seasons
playerBox <- load_nba_player_box(seasons = c(2002:2024))

# Regular-season three-point attempts and makes for the player
player_data <- playerBox %>%
  filter(athlete_display_name == player_name, season_type == 2) %>%
  group_by(season) %>%
  summarise(
    Total3PA = sum(three_point_field_goals_attempted, na.rm = TRUE),
    Total3PM = sum(three_point_field_goals_made, na.rm = TRUE)
  ) %>%
  ungroup()

# Convert the data to long format for plotting
player_data_long <- player_data %>%
  pivot_longer(cols = c(Total3PA, Total3PM), names_to = "Metric", values_to = "Count")

# Plot the data as a histogram
plot <- player_data_long %>%
  ggplot(aes(x = season, y = Count, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Total3PA" = "darkgreen", "Total3PM" = "green3")) +
  labs(
    title = paste("Three-Point Field Goals Made and Attempted by", player_name, "Per Season"),
    x = "Season",
    y = "Count",
    fill = "Metric"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Display the plot
plot
