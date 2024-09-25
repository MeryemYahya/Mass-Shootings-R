#install packages
install.packages("devtools")   # Install the devtools package for package development tools
install.packages("tidyverse")  # Collection of packages for data manipulation and visualization
install.packages("psych")      # Package for psychological research and statistical functions
install.packages("Hmisc")      # Miscellaneous useful functions including correlation
install.packages("wordcloud2") # Word cloud generation
install.packages("cluster")    # Functions for clustering analysis
install.packages("lubridate")  # For working with date and time data
install.packages("ggmap")      # Google Maps and other maps visualization
install.packages("frequency")  # Frequency analysis and visualization
install.packages('dplyr')      # Data manipulation and analysis


#import library
library(cluster)       # Clustering algorithms
library(wordcloud2)    # Word cloud visualization
library(tidyverse)     # Data manipulation and visualization
library(psych)         # Descriptive statistics and analysis
library(Hmisc)         # Miscellaneous statistical functions
library(lubridate)     # Handling date/time data
library(stringr)       # String manipulation functions
library(ggmap)         # Map visualization using Google Maps
library(readr)         # For reading .csv files and other text data
library(frequency)     # Frequency table generation
library(dplyr)         # Data manipulation and analysis

#import data
dataset <- read_csv("Mother Jones - Mass Shootings Database, 1982 - 2021 - Sheet1 (1).csv")
US_Region <- read_csv("US Region-State Mapping.csv")

# Data overview
colnames(dataset)  # Display column names
dim(dataset)       # Get dimensions of the dataset (rows, columns)
glimpse(dataset)   # Quick overview of the dataset
str(dataset)       # Structure of the dataset

#------------------------------DATA WRANGLING---------------------------------

#location / state / region

# Separate 'location' column into 'City' and 'State'
dataset <- separate(dataset , location...2 , c('City' , 'State') , sep=", ")
dataset$State[dataset$State == "Lousiana"] <- "Louisiana"  # Fix typo in State name
# Left join dataset with US_Region to add region info based on 'State'
dataset <- left_join(dataset, US_Region ,  by = c("State") )

# Assign "NA" to missing Region values
dataset$Region <- ifelse(is.na(dataset$Region) , "NA" , dataset$Region)
unique(dataset$Region)  # Display unique categories in Region

# Standardizing race categories
unique(dataset$race)
dataset$race[dataset$race == "white"] <- "White"
dataset$race[dataset$race == "black"] <- "Black"
dataset$race[dataset$race == "-"] <- "Unknown"
dataset$race[dataset$race == "unclear"] <- "Unknown"

# Standardizing gender categories
unique(dataset$gender)
dataset$gender[dataset$gender == "Male"] <- "M"
dataset$gender[dataset$gender == "Female"] <- "F"
dataset$gender[dataset$gender == "Male & Female"] <- "Both"

# Handling date and decade information
dataset$date <- mdy(dataset$date)  # Convert 'date' to date format
dataset$month <- month(dataset$date ,label=TRUE,abbr=TRUE)  # Extract month from date
dataset$month <- as.character(dataset$month)  # Convert month to character for analysis

# Function to calculate the decade
floor_decade = function(value){ return(value - value %% 10) }  
dataset$decade <- floor_decade(dataset$year)  # Calculate decade from year
dataset$decade <- as.character(dataset$decade)
unique(dataset$decade)

# Fix location..8 inconsistencies
unique(dataset$location...8)
dataset$location...8[dataset$location...8 == "\nWorkplace"] <- "Workplace"
dataset$location...8[dataset$location...8 == "Other\n"] <- "Other"

# Standardizing 'prior_signs_mental_health_issues' column
unique(dataset$prior_signs_mental_health_issues)
dataset$prior_signs_mental_health_issues[dataset$prior_signs_mental_health_issues== "yes"] <- "Yes"
dataset$prior_signs_mental_health_issues[dataset$prior_signs_mental_health_issues== "-"] <- "Unknown"
dataset$prior_signs_mental_health_issues[dataset$prior_signs_mental_health_issues== "Unclear"] <- "Unknown"

# Standardizing 'weapons_obtained_legally' column
unique(dataset$weapons_obtained_legally)
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "\nYes"] <- "Yes"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "yes"] <- "Yes"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "-"] <- "Unknown"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "Kelley passed federal criminal background checks; the US Air Force failed to provide information on his criminal history to the FBI"] <- "TBD"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "Yes (\"some of the weapons were purchased legally and some of them may not have been\")"] <- "Yes"

# Convert shooter age to numeric
dataset$age_of_shooter <- as.numeric(dataset$age_of_shooter)

#-----------------------------------DATA PRE PROCESSING AND VISUALIZATION------------------------------------

# Selecting relevant columns for analysis
dt <- as_tibble(dataset)
names(dt)

dt <- dt[c( "City" ,"State" ,"date","fatalities" , "injured", "total_victims" , "location...8" ,"age_of_shooter" , "prior_signs_mental_health_issues" ,"weapons_obtained_legally","race" , "gender" ,"latitude" , "longitude" , "type" , "year" , "Region" , "Division" , "month" , "decade")]

# Rename selected columns for better readability
dt <- rename(dt , location = location...8)
dt <- rename(dt , age = age_of_shooter)
dt <- rename(dt , mental_health_issues = prior_signs_mental_health_issues)

# Quantitative Variables
dt.quant <- dt[c( "fatalities" , "injured", "total_victims" ,"age")]

# Correlation analysis
cor(dt.quant)
cor.test(dt.quant$total_victims , dt.quant$age)
rcorr(as.matrix(dt.quant))

# Descriptive statistics
describe(dt.quant)
summary(dt.quant)
describeBy(dt.quant)

# Boxplot for visualizing distributions
boxplot(dt.quant)
boxplot(dt.quant$age)
rug(dt.quant$age, side = 2)  # Adds tick marks for 'age'

# Histograms to display distributions
hist(dt.quant)
hist(dt.quant$age, col = c("orange"), main = paste("Histogram for Age"), ylab = "Frequency", xlab = "Age")
hist(dt.quant$fatalities, main = paste("Fatalities Histogram"), ylab = "Frequency", xlab = "Fatalities")
hist(dt.quant$injured, main = paste("Injured Histogram"), ylab = "Frequency", xlab = "Injured")
hist(dt.quant$total_victims, main = paste("Total Victims Histogram"), ylab = "Frequency", xlab = "Total Victims")

# Qualitative Variables
dt.qual <- dt[c("location" , "mental_health_issues" , "weapons_obtained_legally" , "race" , "gender", "type" , "year" , "Region" , "Division" , "month" , "decade")]

# Display frequency of qualitative variables
for(i in 1:ncol(dt.qual)) {  
  print(names(dt.qual[ , i]))  # Print variable name
  print(describe(dt.qual[ , i]))  # Descriptive statistics for the variable
}

# Generate frequency tables and export to HTML
options(frequency_open_output = TRUE)
for(i in 1:ncol(dt.qual)) {  
  freq(dt.qual[ , i])  # Frequency analysis
}

# Barplots for qualitative data
for(i in 1:ncol(dt.qual)) {  
  barplot(table(dt.qual[ , i]), main=names(dt.qual[ , i]))  # Plot bar charts
  Sys.sleep(4)  # Pause for 4 seconds between plots
}

# Dot charts for qualitative data
for(i in 1:ncol(dt.qual)) {  
  dotchart(as.matrix( table(dt.qual[ , i]) ) , main = names(dt.qual[ , i]))  # Dot plot
  Sys.sleep(4)  # Pause for 4 seconds between plots
}

# Group descriptive statistics by categories
describeBy(dt.quant , group=dt$race)
describeBy(dt.quant , group=dt$gender)
describeBy(dt.quant , group=dt$Region)

# Scatter plots for total victims, injured, and fatalities by age
pairs(dt.quant)
plot(dt.quant$total_victims , dt.quant$age , xlab = "Total Victims" , ylab = "Age")
plot(dt.quant$fatalities , dt.quant$age , xlab="Fatalities" , ylab = "Age")
plot(dt.quant$injured , dt.quant$age , xlab="Injured" , ylab = "Age")

# Visualize total victims by various categorical variables: gender, race, month, decade, etc.

# Bar chart: Total victims by gender
ggplot() + geom_col(data=dt , aes(x=gender , y = total_victims ))

# Bar chart: Total victims by race
ggplot() + geom_col(data=dt , aes(x=race , y = total_victims ))

# Bar chart: Total victims by month
ggplot() + geom_col(data=dt , aes(x=month , y = total_victims ))

# Bar chart: Total victims by decade
ggplot() + geom_col(data=dt , aes(x=decade , y = total_victims ))

# Bar chart: Total victims by location
ggplot() + geom_col(data=dt , aes(x=location , y = total_victims ))

# Bar chart: Total victims by mental health issues status
ggplot() + geom_col(data=dt , aes(x=mental_health_issues , y = total_victims ))

# Bar chart: Total victims by legal weapon acquisition status
ggplot() + geom_col(data=dt , aes(x=weapons_obtained_legally , y = total_victims ))

# Bar chart: Total victims by region
ggplot() + geom_col(data=dt , aes(x=Region , y = total_victims ))

# Bar chart: Total victims by type of shooting
ggplot() + geom_col(data=dt , aes(x=type , y = total_victims ))

# Bar chart: Total victims by division
ggplot() + geom_col(data=dt , aes(x=Division , y = total_victims ))


#--------------------------- Summing up data for ggplot visualizations ----------------------------

# Sum total victims by year
tv_year_sum <- aggregate(dt$total_victims ~ dt$year, FUN = sum)
# Bar chart: Sum of total victims by year (with flipped coordinates)
ggplot(tv_year_sum, aes(x=`dt$year`, `dt$total_victims`)) + geom_bar(stat="identity") + coord_flip()

# Mean total victims by year
tv_year_mean <- aggregate(dt$total_victims ~ dt$year, FUN = mean)
# Bar chart: Mean of total victims by year (with flipped coordinates)
ggplot(tv_year_mean, aes(x=`dt$year`, `dt$total_victims`)) + geom_bar(stat="identity") + coord_flip()

#-------------------------- Injured data visualizations --------------------------------

# Sum of injured by year
i_year_sum <- aggregate(dt$injured ~ dt$year, FUN = sum)
# Bar chart: Sum of injured by year (with flipped coordinates)
ggplot(i_year_sum, aes(x=`dt$year`, `dt$injured`)) + geom_bar(stat="identity") + coord_flip()

# Mean of injured by year
i_year_mean <- aggregate(dt$injured ~ dt$year, FUN = mean)
# Bar chart: Mean of injured by year (with flipped coordinates)
ggplot(i_year_mean, aes(x=`dt$year`, `dt$injured`)) + geom_bar(stat="identity") + coord_flip()

#--------------------------- Fatalities data visualizations ----------------------------

# Sum of fatalities by year
f_year_sum <- aggregate(dt$fatalities ~ dt$year, FUN = sum)
# Bar chart: Sum of fatalities by year (with flipped coordinates)
ggplot(f_year_sum, aes(x=`dt$year`, `dt$fatalities`)) + geom_bar(stat="identity") + coord_flip()

# Mean of fatalities by year
f_year_mean <- aggregate(dt$fatalities ~ dt$year, FUN = mean)
# Bar chart: Mean of fatalities by year (with flipped coordinates)
ggplot(f_year_mean, aes(x=`dt$year`, `dt$fatalities`)) + geom_bar(stat="identity") + coord_flip()

#-------------------------- Month-wise and year-wise victim data -------------------------

# Bar chart: Total victims by month for each year (faceted by year)
ggplot(data=dt, aes(x=month, y=total_victims, group=year)) + geom_col() + facet_wrap(vars(year))

# Bar chart: Fatalities by month for each year (faceted by year)
ggplot(data=dt, aes(x=month, y=fatalities, group=year)) + geom_col() + facet_wrap(vars(year))

# Bar chart: Injured by month for each year (faceted by year)
ggplot(data=dt, aes(x=month, y=injured, group=year)) + geom_col() + facet_wrap(vars(year))

# Mean victims by month for each year (faceted by year)
ggplot(data=dt, aes(x=month, y=injured, group=year)) + stat_summary(fun="mean", geom="bar") + facet_wrap(vars(year))
ggplot(data=dt, aes(x=month, y=fatalities, group=year)) + stat_summary(fun="mean", geom="bar") + facet_wrap(vars(year))
ggplot(data=dt, aes(x=month, y=total_victims, group=year)) + stat_summary(fun="mean", geom="bar") + facet_wrap(vars(year))

#-------------------------- Decade, year, and month-wise breakdowns by race and gender -------------------------

# Bar chart: Total victims by decade, grouped by race and filled by age (faceted by race and gender)
ggplot(data=dt, aes(x=decade, y=total_victims, group=race, fill=age)) + geom_col() + facet_wrap(vars(race, gender)) + theme_bw()

# Bar chart: Total victims by year, grouped by race and filled by age (faceted by race and gender)
ggplot(data=dt, aes(x=year, y=total_victims, group=race, fill=age)) + geom_col() + facet_wrap(vars(race, gender)) + theme_bw()

# Bar chart: Total victims by month, grouped by race and filled by age (faceted by race and gender)
ggplot(data=dt, aes(x=month, y=total_victims, group=race, fill=age)) + geom_col() + facet_wrap(vars(race, gender)) + theme_bw()

#--------------------------- Summary charts by decade and race ----------------------------

# Bar chart: Total victims by decade, grouped by race (faceted by race)
ggplot(data=dt, aes(x=decade, y=total_victims, group=race)) + geom_col() + facet_wrap(vars(race)) + theme_bw()

# Bar chart: Mean total victims by decade, grouped by race (faceted by race)
ggplot(data=dt, aes(x=decade, y=total_victims, group=race)) + stat_summary(fun="mean", geom="col") + facet_wrap(vars(race)) + theme_bw()

#---------------------------- Word cloud visualizations -----------------------------------

# Word cloud: City vs total victims
wc <- select(dt, City, total_victims)
wordcloud2(wc, minRotation = -pi/6, maxRotation = -pi/6, minSize = 10, rotateRatio = 1)

# Word cloud: State vs total victims
wc1 <- select(dt, State, total_victims)
wordcloud2(wc1, minRotation = -pi/6, maxRotation = -pi/6, minSize = 10, rotateRatio = 1)

#---------------------------- Geospatial visualizations -----------------------------------

# Get map of the US using bounding box and visualize shooting locations on the map
register_stadiamaps("YOUR-API-KEY-HERE" , write = TRUE) #https://docs.stadiamaps.com/guides/migrating-from-stamen-map-tiles/#ggmap
us <- c(left = -125, bottom = 25.75, right = -67, top = 49)
map <- get_stadiamap(us, zoom = 5, maptype = "stamen_terrain") %>% ggmap()
#“stamen_terrain”, “stamen_toner”, “stamen_toner_lite”, “stamen_watercolor”, “alidade_smooth”, “alidade_smooth_dark”, “outdoors”, “stamen_terrain_background”, “stamen_toner_background”, “stamen_terrain_labels”, “stamen_terrain_lines”, “stamen_toner_labels”, “stamen_toner_lines”

# Scatter plot: Location of shootings on the map (red points)
map + geom_point(aes(x=dt$longitude, y=dt$latitude), data=dataset, colour="red", size=2)

# Density heatmap: Shooting density across the US
map + stat_density2d(aes(x=longitude, y=latitude, fill=..level.., alpha=..level..), size=2, bins=4, data=dt, geom='polygon') + 
scale_fill_gradient('Shooting\nDensity') + scale_alpha(range=c(.4, .75), guide="none") + 
guides(fill=guide_colorbar(barwidth=1.5, barheight=10))
