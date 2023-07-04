# Clearing the Global environment
rm(list=ls())
# Installing and lodaing packages 
library(ggplot2) #data visualization
library(ggthemes)#add-on to our main ggplot2
library(lubridate)# time categories
library(dplyr)#data manipulation
library(tidyr)#tidy data
library(scales)#graphical scales


# Creating a variable to hold colors of our choice for later use

colors = c("#CC1011", "#665555", "#05a399", "#cfcaca", "#f5e840", "#0683c9", "#e075b0")
           

# Importing datasets into R
apr14 <- read.csv("C:/Users/acer/Downloads/Uber-dataset/Uber-dataset/uber-raw-data-apr14.csv/uber-raw-data-apr14.csv")
may14 <- read.csv("C:/Users/acer/Downloads/Uber-dataset/Uber-dataset/uber-raw-data-may14.csv/uber-raw-data-may14.csv")
jun14 <- read.csv("C:/Users/acer/Downloads/Uber-dataset/Uber-dataset/uber-raw-data-jun14.csv/uber-raw-data-jun14.csv")
jul14 <- read.csv("C:/Users/acer/Downloads/Uber-dataset/Uber-dataset/uber-raw-data-jul14.csv/uber-raw-data-jul14.csv")
aug14 <- read.csv("C:/Users/acer/Downloads/Uber-dataset/Uber-dataset/uber-raw-data-aug14.csv/uber-raw-data-aug14.csv")
sep14 <- read.csv("C:/Users/acer/Downloads/Uber-dataset/Uber-dataset/uber-raw-data-sep14.csv/uber-raw-data-sep14.csv")


# Combining datas of the 6 months into a single dataframe

data_2014 <- rbind(apr14,may14,jun14,jul14,aug14,sep14)
Head(data_2014)

# Cutting down existing Date.Time variable into multiple variables and changing the type into date time format in the "data_2014" dataframe 
data_2014$Date.Time <- as.POSIXct(data_2014$Date.Time, format = "%m/%d/%Y %H:%M:%S")

data_2014$Time <- format(as.POSIXct(data_2014$Date.Time, format = "%m/%d/%Y %H:%M:%S"), format="%H:%M:%S")

data_2014$Date.Time <- ymd_hms(data_2014$Date.Time)

which(is.na(data_2014$Date.Time))

data_2014 <- na.omit(data_2014)

data_2014$day <- factor(day(data_2014$Date.Time))
data_2014$month <- factor(month(data_2014$Date.Time, label = TRUE))
data_2014$year <- factor(year(data_2014$Date.Time))
data_2014$dayofweek <- factor(wday(data_2014$Date.Time, label = TRUE))


data_2014$hour <- factor(hour(hms(data_2014$Time)))
data_2014$minute <- factor(minute(hms(data_2014$Time)))
data_2014$second <- factor(second(hms(data_2014$Time)))


# Creating a new data frame to show number of trips per hour 

hour_data <- data_2014 %>%
  group_by(hour) %>%
  summarize(Count=n())

View(hour_data)


# Creating a new data frame to show number of trips per hour in each month

month_hour <- data_2014 %>%
  group_by(month, hour) %>%
  summarize(Count = n())

View(month_hour)

# Plotting Number of Trips by Hour and Month
ggplot(data = month_hour)+ 
  geom_bar(mapping=aes(x = hour,y = Count, fill = month), stat = "identity") +
  ggtitle("Trips by Hour and Month") +
  scale_y_continuous(labels = comma)


# Creating a new data frame to show number of trips per day of the month

day_group <- data_2014 %>%
  group_by(day) %>%
  summarize(Count = n()) 
 
View(day_group)

# Plotting Number of Trips by each day of the month
ggplot(day_group, aes(day, Count)) + 
  geom_bar( stat = "identity", fill = "steelblue") +
  labs(title = "Trips by Day of the month") +
  theme(legend.position = "none") +
  scale_y_continuous(labels = comma)


# Creating a new data frame to show number of trips per day in each month

day_month_group <- data_2014 %>%
  group_by(month, day) %>%
  summarize(Count = n())

View(day_month_group)

# Plotting Number of Trips by Day and Month
ggplot(day_month_group, aes(day, Count, fill = month)) + 
  geom_bar( stat = "identity") +
  labs(title = "Trips by Day and Month") +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = colors)


# Creating a new data frame to show number of trips per month

month_group <- data_2014 %>%
  group_by(month) %>%
  summarize(Total = n()) 

View(month_group)

# Plotting Number of Trips by Month
ggplot(month_group , aes(month, Total, fill = month)) + 
  geom_bar( stat = "identity") +
  labs(title="Trips by Month") +
  theme(legend.position = "none") +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = colors)


# Creating a new data frame to show number of trips per day of the week in each month

month_weekday <- data_2014 %>%
  group_by(month, dayofweek) %>%
  summarize(Count = n())

# Plotting Number of Trips by Day of the Week and Month
ggplot(month_weekday, aes(month, Count, fill = dayofweek)) + 
  geom_bar( stat = "identity", position = "dodge") +
  labs(title = "Trips by Day and Month") +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = colors)


# Plotting Number of Trips by Bases

ggplot(data_2014, aes(Base)) + 
  geom_bar(fill = "darkred") +
  scale_y_continuous(labels = comma) +
  labs(title = "Trips by Bases")

ggplot(data_2014, aes(Base, fill = month)) + 
  geom_bar(position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Trips by Bases and Month") +
  scale_fill_manual(values = colors)

ggplot(data_2014, aes(Base, fill = dayofweek)) + 
  geom_bar(position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Trips by Bases and DayofWeek") +
  scale_fill_manual(values = colors)


#Creating a Heatmap visualization of day, hour and month

ggplot(day_month_group, aes(day, month, fill = Count)) +
  geom_tile(color = "white") +
  labs(title = "Heat Map by Month and Day")

ggplot(month_weekday, aes(dayofweek, month, fill = Count)) +
  geom_tile(color = "white") +
  labs(title = "Heat Map by Month and Day of Week")

month_base <-  data_2014 %>%
  group_by(Base, month) %>%
  summarize(Count = n()) 

day0fweek_bases <-  data_2014 %>%
  group_by(Base, dayofweek) %>%
  summarize(Count = n()) 

ggplot(month_base, aes(Base, month, fill = Count)) +
  geom_tile(color = "white") +
  labs(title = "Heat Map by Month and Bases")


ggplot(dayOfweek_bases, aes(Base, dayofweek, fill = Total)) +
  geom_tile(color = "white") +
  labs(title = "Heat Map by Bases and Day of Week")

