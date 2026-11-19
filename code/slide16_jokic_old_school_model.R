# Slide 16 - "Do the best centers today play like centers in the past?"
# Ask the old-school model (trained on old_school_seasons, set in slide 12) what
# position Nikola Jokic's 2024 stats look like. Compare with the main (2010-2024) model.
# Note: the deck says this model was trained on 2000-2010. To match that exactly,
# change old_school_seasons in slide 12 (slides 15 and 17 will change too).

source('code/slide15_al_horford_2015_vs_2024.R') # gives us both models and get_player_probabilities()

# Change this name to try other top centers (e.g. 'Joel Embiid', 'Anthony Davis')
center_name <- 'Nikola Jokić'

jokic_old_school_model <- get_player_probabilities(old_school_model, center_name, 2024,
                                                   title_end = paste("Trained on", old_school_label, "Data"), digits = 2)
jokic_main_model <- get_player_probabilities(model, center_name, 2024, digits = 2)

grid.arrange(jokic_old_school_model, jokic_main_model, ncol = 2)
