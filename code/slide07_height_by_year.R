# Slide 7 - "Change of Height in the NBA"
# Average player height (inches) every season 2000-2022, with a straight trend line
# and the linear model shown under the chart.
#
# DATA NEEDED: none of the files in this folder have player heights.
# The chart stops at 2022, which matches the Kaggle "NBA Players" data set
# (all_seasons.csv, heights in cm, seasons 1996-97 to 2022-23):
#   https://www.kaggle.com/datasets/justinas/nba-players-data
# Download it and save it as data/all_seasons.csv, then run from the R folder.
#
# Note: this data shows heights going down, but its numbers are about 0.4 inches
# taller than the slide (79.0 vs 78.7 in 2000), and it drops suddenly in 2019 when
# the NBA started measuring players without shoes. So the original slide used a
# different height data set, and this won't reproduce its exact regression numbers.

library(modelr)
library(tidyverse)

players <- read.csv('data/all_seasons.csv')

# Average height per season, in inches
# (season looks like "2000-01", so the first 4 characters are the year)
height_by_year <- players %>%
  mutate(Year = as.numeric(substr(season, 1, 4)),
         height_in = player_height / 2.54) %>%
  filter(Year >= 2000) %>%
  group_by(Year) %>%
  summarise(Height = round(mean(height_in, na.rm = TRUE), 1)) %>%
  ungroup()

# Shaded area chart with a black regression line (same style as slide 2)
plot <- height_by_year %>%
  ggplot(aes(x = Year, y = Height)) +
  geom_area(fill = "salmon", color = "orangered", alpha = 0.6) +
  geom_point(color = "orangered") +
  geom_smooth(method = "lm", color = "black", se = FALSE) +
  coord_cartesian(ylim = c(min(height_by_year$Height), NA)) +
  labs(
    title = "Height by Year",
    x = "Year",
    y = "Height"
  )

# Display the plot
plot

# Linear model: how much average height changes each year
model2 = lm(data = height_by_year, Height ~ Year)
summary(model2)
rsquare(model2, height_by_year)
