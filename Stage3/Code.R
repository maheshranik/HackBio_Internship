# Load required libraries
library(tidyverse)
library(lubridate)
library(readr)
library(dplyr)

getwd()
# Import data (replace file paths with actual files)
cases_data <- read_csv("reported_cases.csv")
deaths_data <- read_csv("reported_deaths.csv")
cfr_data <- read_csv("cfr_data.csv")

# View the structure of the datasets
str(cases_data)
str(deaths_data)
str(cfr_data)

#viewing columns 
names(cases_data)
names(deaths_data)
names(cfr_data)
# Merge the datasets by Country and Year
combined_data <- cases_data %>%
  inner_join(deaths_data, by = c("Country", "Year")) %>%
  inner_join(cfr_data, by = c("Country", "Year"))

# Check the combined dataset
str(combined_data)
names(combined_data)

# Rename the columns for simplicity
colnames(combined_data) <- c("Country", "Year", "Cases", "Deaths", "CFR")

# Check the renamed columns
head(combined_data)
# Check the column names of the dataset
colnames(combined_data)
# Check the structure of the data
str(combined_data)
# Check for missing values in the dataset
summary(combined_data)


head(combined_data)
str(combined_data)
names(combined_data)

# Convert 'Deaths' and 'CFR' columns to numeric
combined_data$Deaths <- as.numeric(combined_data$Deaths)
combined_data$CFR <- as.numeric(combined_data$CFR)

# Check for missing values in the dataset
summary(combined_data)
str(combined_data)
head(combined_data)

# Summarize cases and deaths by year
global_trends <- combined_data %>%
  group_by(Year) %>%
  summarize(Total_Cases = sum(Cases, na.rm = TRUE),
            Total_Deaths = sum(Deaths, na.rm = TRUE))




# Create the line plot for cholera cases over time by country

ggplot(combined_data, aes(x = Year, y = Cases, group = Country, color = Country)) +
  geom_line(size = 1.2) + 
  labs(title = "Cholera Cases Over Time by Country", x = "Year", y = "Total Cases") +
  theme_minimal()
# Save the plot with a larger size
ggsave("Line_plot_cholera_cases_over_time_country.png", width = 25, height = 8)

#Bar plot  to compare distinct years or categories
ggplot(combined_data, aes(x = Year, y = Cases, fill = Country)) +
  geom_bar(stat = "identity", position = "dodge") + 
  labs(title = "Cholera Cases Over Time by Country", x = "Year", y = "Total Cases") +
  theme_minimal()
# Save the plot with a larger size
ggsave("Bar_plot_cholera_cases_over_time_country.png", width = 25, height = 8)

#Area plot for (Best for Cumulative Effects or Stacked Comparisons)
ggplot(combined_data, aes(x = Year, y = Cases, fill = Country)) +
  geom_area(alpha = 0.6) + 
  labs(title = "Cumulative Cholera Cases Over Time by Country", x = "Year", y = "Total Cases") +
  theme_minimal()
# Save the plot with a larger size
ggsave("Cumulative_cholera_cases_over_time_country.png", width = 25, height = 8)
#Stacked bar plot (Best for Comparative Contributions Over Time)
ggplot(combined_data, aes(x = Year, y = Cases, fill = Country)) +
  geom_bar(stat = "identity") + 
  labs(title = "Cholera Cases by Country Over Time", x = "Year", y = "Total Cases") +
  theme_minimal()
# Save the plot with a larger size
ggsave("Stacked bar plot_cholera_cases_over_time_country.png", width = 25, height = 8)


#Annual Cases :Calculate total cases per year to identify trends.
annual_cases <- combined_data %>%
  group_by(Year) %>%
  summarize(Total_Cases = sum(Cases, na.rm = TRUE))

# View annual cases
head(annual_cases)
#Visualize annual cases
ggplot(annual_cases, aes(x = Year, y = Total_Cases,color = "Total Cases" )) +
  geom_line(size = 1.2) +
  labs(title = "Total Cholera Cases Over Time", x = "Year", y = "Total Cases") +
  scale_color_manual(values = c("Total Cases" = "blue")) +
  theme_minimal() +
  theme(legend.title = element_blank(),  # Remove the legend title for simplicity
        legend.position = "right")  # Position the legend on the right

# Save the plot with a larger size
ggsave("Lineplot_Total_Cholera_Cases_Over_Time.png", width = 10, height = 8)




# By Country Analysis _Analyze the cases by country.
country_cases <- combined_data %>%
  group_by(Country) %>%
  summarize(Total_Cases = sum(Cases, na.rm = TRUE)) %>%
  arrange(desc(Total_Cases))

# View top affected countries
head(country_cases, 10)
top_countries <- head(country_cases, 10)
#Visualize Cases by Country_Create a bar plot for the top 10 countries.
ggplot(top_countries, aes(x = reorder(Country, -Total_Cases), y = Total_Cases)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Top 10 Countries with Most Cholera Cases", x = "Country", y = "Total Cases") +
  theme_minimal() +
  coord_flip()  # Flip for better readability
ggsave("Top 10 Countries with Most Cholera Cases.png", width = 10, height = 8)

# Identify Significant Outbreaks
# Define a threshold for significant outbreaks (e.g., top 10% of annual cases)
threshold <- quantile(annual_cases$Total_Cases, 0.90)

significant_outbreaks <- annual_cases %>%
  filter(Total_Cases >= threshold)

# View significant outbreaks
print(significant_outbreaks)
# Bar Plot for Significant Outbreaks
ggplot(significant_outbreaks, aes(x = as.factor(Year), y = Total_Cases, fill = "Significant Outbreaks")) +
  geom_bar(stat = "identity") +
  labs(title = "Significant Cholera Outbreaks (Top 10% Cases)", x = "Year", y = "Total Cases") +
  theme_minimal() +
  theme(legend.position = "none")  # Remove legend since there's only one category
#Save the plot in larger size
ggsave("Significant Cholera Outbreaks Top 10percent Cases.png", width = 10, height = 8)

getwd()
#Statistical analysis to understand the relationships or predict future trends using models.
# Create a linear model to predict Total Cases over time
model <- lm(Total_Cases ~ Year, data = annual_cases)

# Add predictions to the data frame
annual_cases <- annual_cases %>%
  mutate(Predicted_Cases = predict(model, newdata = annual_cases))

# Plot observed vs. predicted cases with legend
ggplot(annual_cases, aes(x = Year)) +
  geom_line(aes(y = Total_Cases, color = "Observed Cases"), size = 1.2) +  # Observed cases
  geom_line(aes(y = Predicted_Cases, color = "Predicted Cases"), size = 1.2, linetype = "dashed") +  # Predicted cases
  labs(title = "Cholera Cases Over Time: Observed vs. Predicted", x = "Year", y = "Total Cases") +
  scale_color_manual(values = c("Observed Cases" = "blue", "Predicted Cases" = "red")) +  # Set colors
  theme_minimal() +
  theme(legend.title = element_blank())  # Remove legend title for simplicity
#Save the plot in larger size
ggsave("Cholera_Cases_Over_Time_Observed_vs_Predicted.png", width = 10, height = 8)

# Summarize total deaths by year
annual_deaths <- combined_data %>%
  group_by(Year) %>%
  summarize(Total_Deaths = sum(Deaths, na.rm = TRUE))

# View annual deaths
print(annual_deaths)
#Visualize annual deaths
# Plotting annual deaths with a legend
ggplot(annual_deaths, aes(x = Year, y = Total_Deaths, color = "Total Deaths")) +
  geom_line(size = 1.2) +  # Line color for deaths
  labs(title = "Total Cholera Deaths Over Time", x = "Year", y = "Total Deaths") +
  scale_color_manual(values = c("Total Deaths" = "red")) +  # Manually set the color for the legend
  theme_minimal() +
  theme(legend.title = element_blank(),  # Remove the legend title for simplicity
        legend.position = "right")  # Position the legend on the right
# Save the plot with a larger size
ggsave("Lineplot_Total_Cholera_Deaths_Over_Time.png", width = 10, height = 8)

# Create a combined dataset for plotting
combined_annual <- annual_cases %>%
  left_join(annual_deaths, by = "Year")

# Compare Cases and Deaths Plot cases and deaths
ggplot(combined_annual, aes(x = Year)) +
  geom_line(aes(y = Total_Cases, color = "Cases"), size = 1.2) + 
  geom_line(aes(y = Total_Deaths, color = "Deaths"), size = 1.2) +
  labs(title = "Cholera Cases and Deaths Over Time", x = "Year", y = "Count") +
  scale_color_manual(values = c("Cases" = "blue", "Deaths" = "red")) +  # Manual color mapping
  theme_minimal() +
  theme(legend.position = "bottom")


# Define a threshold for significant deaths (e.g., top 10% of annual deaths)
death_threshold <- quantile(annual_deaths$Total_Deaths, 0.90)

# Filter for significant death years
significant_deaths <- annual_deaths %>%
  filter(Total_Deaths >= death_threshold)

# View significant death years
print(significant_deaths)

# Bar Plot for Significant Deaths
ggplot(significant_deaths, aes(x = as.factor(Year), y = Total_Deaths, fill = "Significant Deaths")) +
  geom_bar(stat = "identity") +
  labs(title = "Significant Cholera Death Years (Top 10% Deaths)", x = "Year", y = "Total Deaths") +
  theme_minimal() +
  theme(legend.position = "none")  # Remove legend since there's only one category
ggsave("Significant Cholera Death Years Top 10% Deaths.png", width = 10, height = 8)
# Linear regression model
death_model <- lm(Total_Deaths ~ Total_Cases, data = combined_annual)
summary(death_model)

# Plot with regression line
ggplot(combined_annual, aes(x = Total_Cases, y = Total_Deaths)) +
  geom_line(aes(color = "Observed Cases"), size = 1.2) +  # Add legend for observed cases
  geom_smooth(method = "lm", aes(color = "Linear Model"), se = FALSE) +  # Add legend for the regression line
  labs(title = "Relationship Between Cholera Cases and Deaths", x = "Total Cases", y = "Total Deaths") +
  scale_color_manual(values = c("Observed Cases" = "blue", "Linear Model" = "red")) +  # Manual color mapping
  theme_minimal() +
  theme(legend.title = element_blank(),  # Remove the legend title for simplicity
        legend.position = "right")  # Position the legend on the right
# Save the plot with a larger size
ggsave("Relationship Between Cholera Cases and Deaths.png", width = 10, height = 8)

