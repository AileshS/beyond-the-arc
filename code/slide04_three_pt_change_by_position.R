# Slide 4 - Percentage change in three-point attempts by position, relative to 2002

library(modelr)
library(tidyverse)
library(hoopR)

# Load NBA player box scores for the specified seasons
playerBox <- load_nba_player_box(seasons = c(2002:2024))

# Define the five primary positions
primary_positions <- c("PG", "SG", "SF", "PF", "C")

# Filter data to include only the five primary positions and three-point field goal attempts
three_point_attempts_by_position <- playerBox %>%
  filter(athlete_position_abbreviation %in% primary_positions) %>%
  group_by(season, athlete_position_abbreviation) %>%
  summarise(
    Total3PA = sum(three_point_field_goals_attempted, na.rm = TRUE) # Summarize total three-point attempts
  ) %>%
  ungroup()

# Calculate percentage changes from 2002
percentage_changes <- three_point_attempts_by_position %>%
  group_by(athlete_position_abbreviation) %>%
  arrange(season) %>%
  mutate(
    Total3PA_2002 = Total3PA[season == 2002],
    PercentChange = (Total3PA - Total3PA_2002) / Total3PA_2002 * 100
  ) %>%
  filter(season != 2002) # Exclude 2002 from the plot

# Plot the data
plot <- percentage_changes %>%
  ggplot(aes(x = season, y = PercentChange, color = athlete_position_abbreviation)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Percentage Change in Three-Point Field Goal Attempts by Position (2002-2024)",
    x = "Season",
    y = "Percentage Change (%)",
    color = "Position"
  ) +
  theme_minimal()

# Display the plot
plot
