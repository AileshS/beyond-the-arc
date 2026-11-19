# Builds data/historical_data.csv: one row per NBA player-season (1997-2024) with the
# advanced, per-game and shooting stats the position model uses.
#
# Source: Basketball-Reference stats as packaged by Sumitro Datta, the same Kaggle dataset
# cited in the deck ("NBA Stats (1947-present)"), mirrored at
# https://github.com/sumitrodatta/bball-reference-datasets
# Run from the repo root: source("scripts/build_historical_data.R")

library(dplyr)
library(readr)

base_url <- "https://raw.githubusercontent.com/sumitrodatta/bball-reference-datasets/master/Data/"
read_bref <- function(file) read_csv(paste0(base_url, URLencode(file)), show_col_types = FALSE)

# Players traded mid-season have one row per team plus a combined row (TOT, or 2TM/3TM...).
# Keep the combined row so each player-season appears once.
one_row_per_season <- function(df) {
  df %>%
    filter(lg == "NBA") %>%
    group_by(season, player_id) %>%
    filter(n() == 1 | grepl("^(TOT|[0-9]TM)$", team)) %>%
    ungroup()
}

advanced <- read_bref("Advanced.csv") %>% one_row_per_season() %>%
  select(season, player, player_id, age, team, pos, g, mp, per, ows, dws)
per_game <- read_bref("Player Per Game.csv") %>% one_row_per_season() %>%
  select(-lg, -player, -age, -team, -pos, -g, -gs)
shooting <- read_bref("Player Shooting.csv") %>% one_row_per_season() %>%
  select(-lg, -player, -age, -team, -pos, -g, -gs, -mp, -fg_percent)

historical_data <- advanced %>%
  inner_join(per_game, by = c("season", "player_id")) %>%
  inner_join(shooting, by = c("season", "player_id")) %>%
  filter(season >= 1997, season <= 2024)

dir.create("data", showWarnings = FALSE)
write_csv(historical_data, "data/historical_data.csv")
cat("Wrote", nrow(historical_data), "player-seasons\n")
