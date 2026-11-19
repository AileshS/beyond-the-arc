# Slide 12 - "Our Model - Multinomial Logistic Regression"
# Trains the model that predicts a player's position from his stats, then shows
# its accuracy and confusion matrix.
# Slides 13-17 run this file first with source(), so they all use the same model.
# Run everything from the repo root.
# Based on original_models.R, with the random forest swapped for nnet::multinom.

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(caret)
library(nnet)
library(tidyr)
library(reshape2)

# Step 1: Load Data
valid_positions <- c('C', 'SF', 'PF', 'PG', 'SG')

# Load data
all_data <- read.csv('data/historical_data.csv')

# Only the 5 main positions, and only players with 800+ minutes
all_data <- all_data %>%
  filter(pos %in% valid_positions) %>%
  filter(mp >= 800)

# The model was trained on 2010-2024
historical_data <- all_data %>%
  filter(season >= 2010 & season <= 2024)

# Function to preprocess data
# `reference` = the pool of players we measure against. Each stat becomes
# "how far above/below the pool's average is this player?". When scoring new
# players we pass the training pool, so a 2024 player is compared to every player
# the model learned from, not just other 2024 players.
preprocess_data <- function(df, reference = df) {
  df[is.na(df)] <- 0
  reference[is.na(reference)] <- 0
  features <- df %>% select(per, x3p_per_game, x2p_per_game, ft_per_game,
                            orb_per_game, drb_per_game, ast_per_game, stl_per_game,
                            blk_per_game, tov_per_game, pf_per_game, e_fg_percent,
                            avg_dist_fga, num_of_dunks, percent_corner_3s_of_3pa)

  # PG is the baseline position: every coefficient is "compared to a PG"
  labels <- relevel(as.factor(df$pos), ref = 'PG')

  columns_to_normalize <- c('per', 'avg_dist_fga', 'x3p_per_game',
                            'x2p_per_game', 'ft_per_game', 'orb_per_game',
                            'drb_per_game', 'ast_per_game', 'stl_per_game',
                            'blk_per_game', 'tov_per_game', 'pf_per_game', 'num_of_dunks')

  # Normalize columns using the reference pool's averages and standard deviations
  pool_averages <- colMeans(reference[, columns_to_normalize])
  pool_sds <- apply(reference[, columns_to_normalize], 2, sd)
  normalized_features <- as.data.frame(scale(features[, columns_to_normalize],
                                             center = pool_averages, scale = pool_sds))

  # Columns to leave as they are (percentage columns, already between 0 and 1)
  columns_to_leave <- c('e_fg_percent', 'percent_corner_3s_of_3pa')

  unchanged_df <- features[, columns_to_leave]

  # Combine normalized and unchanged columns
  final_features <- cbind(normalized_features, unchanged_df)

  return(list(features = final_features, labels = labels))
}

# Train a multinomial logistic regression on whatever seasons you give it.
# 80% of players are used to train, 20% are held back to check accuracy.
train_position_model <- function(df) {
  processed_data <- preprocess_data(df)
  features <- processed_data$features
  labels <- processed_data$labels

  # Split data into training and validation sets
  set.seed(1)
  train_index <- createDataPartition(labels, p = 0.8, list = FALSE)
  X_train <- features[train_index, ]
  y_train <- labels[train_index]
  X_val <- features[-train_index, ]
  y_val <- labels[-train_index]

  # Train Multinomial Logistic Regression model
  model <- multinom(y_train ~ ., data = cbind(X_train, y_train), maxit = 1000, trace = FALSE)

  # Remember which pool of players this model was trained on
  model$reference <- df

  list(model = model, X_val = X_val, y_val = y_val)
}

# Run the model on every player in one season and return their position probabilities.
# Players are measured against the model's training pool (all of its seasons together).
predict_season <- function(model, season_year) {
  season_data <- all_data %>% filter(season == season_year)
  processed <- preprocess_data(season_data, reference = model$reference)
  probabilities <- predict(model, processed$features, type = "probs")
  season_data %>% mutate(predicted_position = predict(model, processed$features),
                         predicted_probabilities = split(probabilities, seq(nrow(probabilities))))
}

# ---- Train the main model (2010-2024) ----
trained <- train_position_model(historical_data)
model <- trained$model
X_val <- trained$X_val
y_val <- trained$y_val

# Make predictions
y_pred <- predict(model, X_val)
accuracy <- mean(y_pred == y_val)
print(accuracy)

# Confusion Matrix
confusion_matrix <- confusionMatrix(y_pred, y_val)
print(confusion_matrix)

# Plot confusion matrix (positions in alphabetical order, like the slide)
conf_matrix <- as.data.frame(confusion_matrix$table)
conf_matrix <- conf_matrix %>% mutate(Prediction = factor(Prediction, levels = sort(valid_positions)),
                                      Reference = factor(Reference, levels = sort(valid_positions)))

confusion_plot <- ggplot(conf_matrix, aes(x = Reference, y = Prediction)) +
  geom_tile(aes(fill = Freq), color = "white") +
  scale_fill_gradient(low = "white", high = "blue") +
  geom_text(aes(label = Freq), vjust = 1) +
  labs(x = "True label", y = "Predicted label", title = "Confusion Matrix for Multinomial Logistic Regression Model") +
  theme_minimal()

confusion_plot

# ---- "Old-school" model, used by slides 15, 16 and 17 ----
# Same model, but trained only on seasons before the three-point boom took off.
# Slides 15-17 use it to ask: "compared to how positions USED to be played,
# what position does this player look like?" Change the years here and all three
# slides update together.
old_school_seasons <- 2010:2015
old_school_label <- paste0(min(old_school_seasons), "-", max(old_school_seasons))

old_school_trained <- train_position_model(all_data %>% filter(season %in% old_school_seasons))
old_school_model <- old_school_trained$model

# Accuracy of the old-school model on its own held-back players
print(mean(predict(old_school_model, old_school_trained$X_val) == old_school_trained$y_val))
