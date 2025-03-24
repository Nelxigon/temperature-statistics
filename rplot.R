library(ggplot2)
library(lubridate)
library(dplyr)
setwd("~/Documents/WorkStuff/room-data")
data <- read.csv('logfile.csv', stringsAsFactors = FALSE)

# ------------------ EXTRACT DATA ------------------ #

# Combine date and time fields into a single datetime field
data$datetime <- dmy_hms(paste(data$X29.05.2024, data$X15.15.00))

# Ensure temperature is numeric (if not already)
temperature <- as.numeric(data$X25)
humidity <- as.numeric(data$X45)

# ------------------ Approach 1 - Group Days ------------------ #

# Round datetime to nearest 15-minute interval (optional)
data$datetime <- as.POSIXct(round(as.numeric(data$datetime) / (60 * 60)) * (60 * 60), origin = "1970-01-01")

# Insert N/A values
insert_na <- function(values, positions) {
  na_inserted <- rep(NA, length(values) * (length(positions) + 1))
  index <- seq(1, length(na_inserted), by = length(positions) + 1)
  na_inserted[index] <- values
  return(na_inserted)
}
temp_old <- temperature
temperature <- insert_na(result, c(2, 3))

# Extract day and hour from datetime for grouping
data <- data %>%
  mutate(day = as.Date(datetime),
         hour = as.numeric(format(datetime, "%H")) + as.numeric(format(datetime, "%M")) / 60)

# Plot the data
ggplot(data, aes(x = hour, y = temp_old, group = day, color = as.factor(day))) +
  geom_line() +
  scale_x_continuous(breaks = seq(0, 24, by = 1), limits = c(0, 24)) +
  scale_y_continuous(breaks = seq(floor(min(temp_old)), ceiling(max(temp_old)), by = 1)) +
  labs(x = "Hour of Day", y = "Temperature (°C)", color = "Date") +
  theme_minimal()

# ------------------ Approach 2 - Calculate means ------------------ #

# Mean temperature per 5 mins
groups <- rep(1:(12*24), length.out = length(temperature))
mean_temp <- tapply(temperature, groups, mean)
df <- data.frame(mean_temp)
df$timestamps <- data$hour[1:288]

# Mean humidity per 5 mins
groups <- rep(1:(12*24), length.out = length(humidity))
df$mean_hum <- tapply(humidity, groups, mean)

# Plot temperature for each day
ggplot(df, aes(x = timestamps, y = mean_temp)) +
  geom_line(color = "blue") +
  scale_x_continuous(breaks = seq(0, 24, by = 1), limits = c(0, 24)) +
  scale_y_continuous(breaks = seq(25,30, by = 0.5), limits = c(25, 30)) +
  labs(x = "Hour of Day", y = "Temperature (°C)", color = "Date") +
  theme_minimal()

# Plot humidity for each day
ggplot(df, aes(x = timestamps, y = mean_hum)) +
  geom_line(color = "green") +
  scale_x_continuous(breaks = seq(0, 24, by = 1), limits = c(0, 24)) +
  scale_y_continuous(breaks = seq(floor(min(humidity)), ceiling(max(humidity)), by = 1), limits = c(42,45)) +
  labs(x = "Hour of Day", y = "Humidity (%)", color = "Date") +
  theme_minimal()

# ------------------ SHOW FULL DATA ------------------ #

# Plot the temperature over time
ggplot(data, aes(x = datetime, y = temperature)) +
  geom_line(color = "blue") +
  labs(title = "Temperature over Time", x = "Datetime", y = "Temperature (°C)") +
  scale_x_datetime(date_breaks = "2 hours", date_labels = "%H:%M") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Plot the humidity over time
ggplot(data, aes(x = datetime, y = humidity)) +
  geom_line(color = "green") +
  labs(title = "Humidity over Time", x = "Datetime", y = "Humidity (%)") +
  scale_x_datetime(date_breaks = "2 hours", date_labels = "%H:%M") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
