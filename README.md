# Beyond the Arc: How the Three-Point Revolution Changed NBA Centers

A team project from **Wharton Moneyball Academy 2024**, by Ailesh Sadruddin, Jonah Milstone,
Matthieu Perrin, Rohan Tummala and Whit Turner.

**The question:** as the NBA shifted toward three-pointers, did centers change how they play?

**The deck:** [`Beyond_the_Arc_deck.pdf`](Beyond_the_Arc_deck.pdf) (21 slides).

## What we found

- **Three-point attempts rose steadily.** Attempts per player per game climbed almost in a straight line across seasons (R² ≈ 0.90).
- **Players got shorter.** Average NBA height fell by close to an inch from 2004 to 2024.
- **Centers gained the most.** Player efficiency rating (PER) rose more for centers than for any other position.
- **Modern centers play like forwards.** We trained a model that predicts a player's position from his stats alone. When it learns from the era before the three-point boom, it reads Nikola Jokić as a power forward. When it learns from recent seasons, it reads him as a center. Centers' statistical profiles are also more spread out across positions than they used to be.

## The model

A **multinomial logistic regression** (`nnet::multinom`). It takes 15 per-player stats and outputs a
probability for each of the five positions (PG, SG, SF, PF, C). The stats include made twos and
threes, rebounds, assists, effective field-goal %, average shot distance, dunks and the share of
corner threes. Stats are standardized against the training pool, so a 2024 player is measured against
the players the model learned from, not just his own season. Training data covers players with
800+ minutes. The main model is trained on 2010–2024, and an "old-school" model on earlier seasons.

## Code by slide

Run everything from the repo root, e.g. `source("code/slide12_multinomial_model.R")`.

| Slide | What it shows | File | Data |
|---|---|---|---|
| 2 | 3PA per player per game + linear model | `code/slide02_three_pt_per_player_trend.R` | hoopR |
| 4 | % change in 3PA by position | `code/slide04_three_pt_change_by_position.R` | hoopR |
| 5 | Brook Lopez 3PA / 3PM | `code/slide05_brook_lopez_three_pt.R` | hoopR |
| 6 | Al Horford 3PA / 3PM | `code/slide06_al_horford_three_pt.R` | hoopR |
| 7 | Average height by year + linear model | `code/slide07_height_by_year.R` | Kaggle `all_seasons.csv` (download needed, see file) |
| 8 | MVP table | none (made by hand in PowerPoint) | |
| 9 | Shot heat maps, 1999-00 vs 2023-24 | `code/slide09_shot_heatmaps_2000_vs_2024.R` | hoopR (original used nbastatR) |
| 10 | Average PER by position | `code/slide10_per_by_position.R` | `scripts/historical_data.csv` |
| 12 | Multinomial model + confusion matrix | `code/slide12_multinomial_model.R` | `scripts/historical_data.csv` |
| 13 | Model coefficients + p-values | `code/slide13_model_coefficients.R` | runs slide 12 first |
| 14 | Residual plot | `code/slide14_residual_plot.R` | runs slide 12 first |
| 15 | Al Horford 2015 vs 2024 (old-school model) | `code/slide15_al_horford_2015_vs_2024.R` | runs slide 12 first |
| 16 | Jokić: old-school model vs main model | `code/slide16_jokic_old_school_model.R` | runs slide 15 first |
| 17 | Average SD of center probabilities, 2000 vs 2024 (old-school model) | `code/slide17_center_sd_2000_vs_2024.R` | runs slide 12 first |


## Data

- **`data/historical_data.csv`** (included). One row per NBA player-season, 1997–2024, combining
  Basketball-Reference advanced, per-game and shooting stats. Rebuild it with
  `source("scripts/build_historical_data.R")`, which pulls from Sumitro Datta's Basketball-Reference
  dataset: the same Kaggle dataset the deck cites, mirrored on
  [GitHub](https://github.com/sumitrodatta/bball-reference-datasets). Players traded mid-season are
  counted once, using their combined-season row.
- **hoopR / NBA stats.** Slides 2–6 and 9 pull this live.
- **`data/all_seasons.csv`** (slide 7 only). The Kaggle "NBA Players" dataset, downloaded separately.

## Honest notes on reproducibility

This is a cleaned-up rebuild of the original camp code, and not every number matches the deck:

- **Slide 2 matches.** Slope 0.0956 vs 0.0957, R² 0.905 vs 0.904.
- **Model accuracy is lower.** The rebuilt model gets **66.6%** on a held-out 20% split, below the deck's 73.6%. It's the same method, but the data was rebuilt from today's version of the dataset. The biggest predictors are the same: effective FG%, defensive rebounds and assists.
- **Slides 15–17 used a random forest in the deck.** With the multinomial model:
  - **Jokić holds.** The old-school model reads his 2024 season as a PF (69.0%); the main model reads it as a C (76.1%).
  - **"Centers are more spread out" holds.** The average spread of centers' probabilities drops from 0.319 (2000) to 0.301 (2024).
  - **Horford doesn't hold.** He reads as a PF in both 2015 and 2024 (his center probability falls from 10% to 5%). The deck's claim that he rated as a center in 2015 does not come back.
- **The old-school window differs.** The deck describes it as 2000–2010; this code uses 2010–2015, set in one place in `slide12`.

## What I'd do next

- Evaluate on held-out seasons instead of a random split.
- Compare multinomial vs random forest on the same data.
