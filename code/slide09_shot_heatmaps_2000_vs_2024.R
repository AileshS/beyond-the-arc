# Slide 9 - Shot-location heat maps for the whole league, 1999-00 vs 2023-24
# The original used nbastatR, which isn't on CRAN. hoopR gets the same shots
# from the same NBA stats website, so we use that instead (no extra install).
# Each season is about 100,000+ shots, so the download can take a minute.

library(hoopR)
library(tidyverse)
library(gridExtra)

# Define a color palette for the heat maps with more intermediate shades
color_palette <- scale_fill_gradientn(
  colors = c("white", "yellow", "orange", "darkorange2", "red", "darkred"),
  values = scales::rescale(c(0, 0.1, 0.2, 0.3, 0.5, 1)),
  limits = c(0, NA),
  na.value = "white"
)

# Download every team's shots for one season and draw the heat map
# (season = the year the season ends, so 2000 means 1999-00)
make_heatmap <- function(season_year) {
  # hoopR wants the season written like "1999-00"
  season_name <- paste0(season_year - 1, "-", substr(season_year, 3, 4))

  # player_id = 0 and team_id = 0 means "every player on every team"
  shots <- nba_shotchartdetail(season = season_name, season_type = "Regular Season",
                               player_id = 0, team_id = 0, context_measure = "FGA")$Shot_Chart_Detail

  # Drop shots with no recorded location, convert court units to feet
  shots <- shots %>%
    mutate(locationX = as.numeric(LOC_X), locationY = as.numeric(LOC_Y)) %>%
    filter(!(locationX == 0 & locationY == 0)) %>%
    mutate(locationX_ft = locationX / 9.92, locationY_ft = locationY / 10.5)

  shots %>%
    ggplot(aes(x = locationX_ft, y = locationY_ft)) +
    geom_bin2d(bins = 100, alpha = .8) +
    color_palette +
    theme_bw() +
    labs(
      title = paste("Shot attempts in", season_name, "NBA season"),
      caption = "Data accessed via hoopR",
      fill = "Shot Density"
    ) +
    theme(legend.position = "bottom") +
    coord_cartesian(ylim = c(0, 30))
}

shots2000_heatmap <- make_heatmap(2000)
shots2024_heatmap <- make_heatmap(2024)

# Display the heat maps side by side
grid.arrange(shots2000_heatmap, shots2024_heatmap, ncol = 2)
