# Slide 10 - "Increased Center Efficiency"
# Average PER (Player Efficiency Rating) for each position, every season 2002-2024
# Uses the same data as the model (data/historical_data.csv). Run from the repo root.
# Note: this data shows the same story (centers rise the most), but the slide's
# 2024 numbers are higher for every position, so the original used a slightly
# different data set or filter.

library(tidyverse)

# Define the five primary positions
primary_positions <- c("PG", "SG", "SF", "PF", "C")

historical_data <- read.csv('data/historical_data.csv')

# Average PER by season and position (only players with 500+ minutes)
per_by_position <- historical_data %>%
  filter(pos %in% primary_positions, season >= 2002, mp >= 500) %>%
  group_by(season, pos) %>%
  summarise(
    AveragePER = mean(per, na.rm = TRUE)
  ) %>%
  ungroup()

# Plot the data
plot <- per_by_position %>%
  ggplot(aes(x = season, y = AveragePER, color = pos)) +
  geom_line(linetype = "dashed") +
  geom_point() +
  labs(
    title = "Average PER by Position (2002-2024)",
    x = "Season",
    y = "Average PER",
    color = "Position"
  ) +
  theme_minimal()

# Display the plot
plot
