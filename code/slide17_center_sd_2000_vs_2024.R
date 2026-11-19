# Slide 17 - "Can we Compare ALL Centers Between Eras?"
# For every center, take the standard deviation of his 5 position probabilities.
# Low SD = probabilities are spread out = he plays like several positions.
# High SD = one position dominates = a "pure" center.
# Then average the SDs for 2000 centers and 2024 centers.

source('code/slide12_multinomial_model.R')

calculate_sd <- function(probabilities) {
  sd_prob <- sd(probabilities)
  return(sd_prob)
}

# Average SD of all centers in one season (using the old-school model from slide 12,
# so 2000 and 2024 centers are both judged by the same older idea of each position)
average_center_sd <- function(season_year) {
  centers <- predict_season(old_school_model, season_year) %>%
    filter(pos == 'C') %>%
    rowwise() %>%
    mutate(sd_probabilities = calculate_sd(unlist(predicted_probabilities))) %>%
    ungroup()

  data.frame(Year = as.character(season_year), Average_SD = mean(centers$sd_probabilities))
}

sd_by_year <- rbind(average_center_sd(2000), average_center_sd(2024))
print(sd_by_year)

sd_plot <- ggplot(sd_by_year, aes(x = Year, y = Average_SD, fill = Year)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_text(aes(label = round(Average_SD, 4)), vjust = -0.5) +
  coord_cartesian(ylim = c(0.15, NA)) +
  labs(x = "Year", y = "Average Standard Deviation", title = "Average Standard Deviation of Position Probabilities") +
  theme_minimal()

sd_plot
