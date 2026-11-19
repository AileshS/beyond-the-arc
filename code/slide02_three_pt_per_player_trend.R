# Slide 2 - "What was the Three Point Revolution?"
# Average three-point attempts per game for each player, every season (2002-2024),
# with a straight trend line and the linear model shown under the chart.

library(modelr)
library(tidyverse)
library(hoopR)

# Load NBA player box scores for the specified seasons
playerBox <- load_nba_player_box(seasons = c(2002:2024))

# Average 3PA per player per game, for each season
# (each row of playerBox is one player in one game)
three_point_attempts_per_player <- playerBox %>%
  filter(did_not_play == FALSE) %>% # Only players who got on the court
  group_by(season) %>%
  summarise(
    ThreePA_per_Player = mean(three_point_field_goals_attempted, na.rm = TRUE)
  ) %>%
  ungroup()

# Shaded area chart with a black regression line
plot <- three_point_attempts_per_player %>%
  ggplot(aes(x = season, y = ThreePA_per_Player)) +
  geom_area(fill = "salmon", alpha = 0.6) +
  geom_point(color = "salmon", size = 3) +
  geom_smooth(method = "lm", color = "black", se = FALSE) +
  coord_cartesian(ylim = c(min(three_point_attempts_per_player$ThreePA_per_Player), NA)) +
  labs(
    title = "Three Point Attempts Per Game Per Player Per Season",
    x = "Year",
    y = "Three Point Attempts"
  )

# Display the plot
plot

# Linear model: how much 3PA per player goes up each season
model2 = lm(data = three_point_attempts_per_player, ThreePA_per_Player ~ season)
summary(model2)
rsquare(model2, three_point_attempts_per_player)
