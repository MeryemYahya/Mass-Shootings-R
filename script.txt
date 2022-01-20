#install packages
install.packages("tidyverse")
install.packages("psych")
install.packages("Hmisc")
install.packages("wordcloud2")
install.packages("cluster")
install.packages("lubridate")
install.packages("ggmap")
install.packages("frequency")

#import library
library(cluster)
library(wordcloud2)
library(tidyverse)
library(psych)
library(Hmisc)
library(lubridate)
library(stringr)
library(ggmap)
library(readr)
library(frequency)


#import data

dataset <- read_csv("Mother Jones - Mass Shootings Database, 1982 - 2021 - Sheet1 (1).csv")
US_Region <- read_csv("US Region-State Mapping.csv")

#
colnames(dataset)
dim(dataset)
glimpse(dataset)
str(dataset)

 
#------------------------------DATA WRANGLING---------------------------------

#location / state / region

#separation de location en city et state
dataset <- separate(dataset , location...2 , c('City' , 'State') , sep=", ")
dataset$State[dataset$State == "Lousiana"] <- "Louisiana"
#left join du dataset par region par state
dataset <- left_join(dataset, US_Region ,  by = c("State") )

dataset$Region <- ifelse(is.na(dataset$Region) , "NA" , dataset$Region)
#affiche les catégories
unique(dataset$Region)

#Race
unique(dataset$race)
dataset$race[dataset$race == "white"] <- "White"
dataset$race[dataset$race == "black"] <- "Black"
dataset$race[dataset$race == "-"] <- "Unknown"
dataset$race[dataset$race == "unclear"] <- "Unknown"

#Gender
unique(dataset$gender)
dataset$gender[dataset$gender == "Male"] <- "M"
dataset$gender[dataset$gender == "Female"] <- "F"
dataset$gender[dataset$gender == "Male & Female"] <- "Both"

#Date and decade
dataset$date <- mdy(dataset$date)
#transformer le type de date en string
dataset$month <- month(dataset$date ,label=TRUE,abbr=TRUE)
dataset$month <- as.character(dataset$month)
#fonction decade
floor_decade    = function(value){ return(value - value %% 10) }
dataset$decade <- floor_decade(dataset$year)

dataset$decade <- as.character(dataset$decade)

unique(dataset$decade)

#location..8
unique(dataset$location...8)
dataset$location...8[dataset$location...8 == "\nWorkplace"] <- "Workplace"
dataset$location...8[dataset$location...8 == "Other\n"] <- "Other"

#prior_signs_mental_health_issues
unique(dataset$prior_signs_mental_health_issues)
dataset$prior_signs_mental_health_issues[dataset$prior_signs_mental_health_issues== "yes"] <- "Yes"
dataset$prior_signs_mental_health_issues[dataset$prior_signs_mental_health_issues== "-"] <- "Unknown"
dataset$prior_signs_mental_health_issues[dataset$prior_signs_mental_health_issues== "Unclear"] <- "Unknown"

#weapons_obtained_legally
unique(dataset$weapons_obtained_legally)
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "\nYes"] <- "Yes"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "yes"] <- "Yes"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "-"] <- "Unknown"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "Kelley passed federal criminal background checks; the US Air Force failed to provide information on his criminal history to the FBI"] <- "TBD"
dataset$weapons_obtained_legally[dataset$weapons_obtained_legally == "Yes (\"some of the weapons were purchased legally and some of them may not have been\")"] <- "Yes"

#age
dataset$age_of_shooter <- as.numeric(dataset$age_of_shooter)
#-----------------------------------Etude------------------------------------

#select data

dt <- as_tibble(dataset)
names(dt)

dt <- dt[c( "City" ,"State" ,"date","fatalities" , "injured", "total_victims" , "location...8" ,"age_of_shooter" , "prior_signs_mental_health_issues" ,"weapons_obtained_legally","race" , "gender" ,"latitude" , "longitude" , "type" , "year" , "Region" , "Division" , "month" , "decade")]

#changer les noms de colonne
dt <- rename(dt , location = location...8)
dt <- rename(dt , age = age_of_shooter)
dt <- rename(dt , mental_health_issues = prior_signs_mental_health_issues)

         
#Variable quantitative

# Create data frame with only quantitative variables
dt.quant <- dt[c( "fatalities" , "injured", "total_victims" ,"age")]

# Correlation 
cor(dt.quant)
cor.test(dt.quant$total_victims , dt.quant$age)
rcorr(as.matrix(dt.quant))
#statistique descriptive
describe(dt.quant)
summary(dt.quant)
describeBy(dt.quant)

#boite a moustache
boxplot(dt.quant)
boxplot(dt.quant$age)
rug(dt.quant$age, side = 2)

#afficher les effectifs
hist(dt.quant)

hist(dt.quant$age, col = c("orange"), main = paste("Histogramme pour la variable Age"), ylab = "Effectifs", xlab = "Age")
hist(dt.quant$fatalities, main = paste("Histogramme des décès"), ylab = "Effectifs", xlab = "Décès")
hist(dt.quant$injured, main = paste("Histogramme des blessés"), ylab = "Effectifs", xlab = "Blessés")
hist(dt.quant$total_victims, main = paste("Histogramme du total des victimes"), ylab = "Effectifs", xlab = "total des victimes")


#Variable qualitative

#select qualitative data

dt.qual <- dt[c("location" , "mental_health_issues" , "weapons_obtained_legally" , "race" , "gender", "type" , "year" , "Region" , "Division" , "month" , "decade" )]


#prop
for(i in 1:ncol(dt.qual)) {  
  print(names(dt.qual[ , i]))
  print(describe(dt.qual[ , i]))
}

#freq in html file
options(frequency_open_output = TRUE)
for(i in 1:ncol(dt.qual)) {  
  freq(dt.qual[ , i])
}

#barplot
for(i in 1:ncol(dt.qual)) {  
  barplot(table(dt.qual[ , i]), main=names(dt.qual[ , i]))
  Sys.sleep(4)
}

#dotchart
for(i in 1:ncol(dt.qual)) {  
  dotchart(as.matrix( table(dt.qual[ , i]) ) , main = names(dt.qual[ , i])) 
  Sys.sleep(4)
}


#association

#describeBy group
describeBy(dt.quant , group=dt$race)
describeBy(dt.quant , group=dt$gender)
describeBy(dt.quant , group=dt$Region)

#total_victim / injured / fatalities par age
pairs(dt.quant)
plot(dt.quant$total_victims , dt.quant$age , xlab = "Total des victimes" , ylab = "age")
plot(dt.quant$fatalities , dt.quant$age , xlab="Décès" , ylab = "age" )
plot(dt.quant$injured , dt.quant$age , xlab="Blessés" , ylab = "age")



# total_victims par 
#"location" , "mental_health_issues" , "weapons_obtained_legally" , "race" , "gender", "type" , "Region" , "Division" , "month" , "decade" 
 
  ggplot() +  geom_col(data=dt , aes(x=gender , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=race , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=month , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=decade , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=location , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=mental_health_issues , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=weapons_obtained_legally , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=Region , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=type , y = total_victims ))
  ggplot() +  geom_col(data=dt , aes(x=Division , y = total_victims ))
  
#-----------------------------------ggplot-----------------------------------

#//////////////////totalvictims////////
#sum
  tv_year_sum <- aggregate( dt$total_victims  ~ dt$year, FUN = sum )
  ggplot(tv_year_sum , aes(x=`dt$year` , `dt$total_victims`))  + geom_bar(stat="identity")  + coord_flip()
#mean
tv_year_mean <- aggregate( dt$total_victims  ~ dt$year, FUN = mean )
ggplot(tv_year_mean , aes(x=`dt$year` , `dt$total_victims`))  + geom_bar(stat="identity")  + coord_flip()

#////////////////////injured////////////////

#sum
i_year_sum <- aggregate( dt$injured  ~ dt$year, FUN = sum )
ggplot(i_year_sum , aes(x=`dt$year` , `dt$injured`))  + geom_bar(stat="identity")  + coord_flip()
#mean
i_year_mean <- aggregate( dt$injured  ~ dt$year, FUN = mean )
ggplot(i_year_mean , aes(x=`dt$year` , `dt$injured`))  + geom_bar(stat="identity")  + coord_flip()

#/////////////////////fatalities//////////////////////////
#sum
f_year_sum <- aggregate( dt$fatalities  ~ dt$year, FUN = sum )
ggplot(f_year_sum , aes(x=`dt$year` , `dt$fatalities`))  + geom_bar(stat="identity")  + coord_flip()
#mean
f_year_mean <- aggregate( dt$fatalities  ~ dt$year, FUN = mean )
ggplot(f_year_mean , aes(x=`dt$year` , `dt$fatalities`))  + geom_bar(stat="identity")  + coord_flip()



#-----------------plan mois année---------

ggplot(data=dt , aes(x=month , y = total_victims  , group=year)) + geom_col() + facet_wrap(vars(year))
ggplot(data=dt , aes(x=month , y = fatalities  , group=year)) + geom_col() + facet_wrap(vars(year))
ggplot(data=dt , aes(x=month , y = injured  , group=year)) + geom_col() + facet_wrap(vars(year))

  #mean
ggplot(data=dt , aes(x=month , y = injured  , group=year)) + stat_summary(fun="mean", geom="bar") + facet_wrap(vars(year))
ggplot(data=dt , aes(x=month , y = fatalities  , group=year)) + stat_summary(fun="mean", geom="bar") + facet_wrap(vars(year))
ggplot(data=dt , aes(x=month , y = total_victims  , group=year)) + stat_summary(fun="mean", geom="bar") + facet_wrap(vars(year))


#4-a
#decade
ggplot(data=dt , aes(x=decade , y = total_victims  , group=race , fill= age)) + geom_col()  +
       facet_wrap(vars(race , gender )) +
       theme_bw()
#year
ggplot(data=dt , aes(x=year , y = total_victims  , group=race , fill= age)) + geom_col()  +
       facet_wrap(vars(race , gender )) +
     theme_bw()
#month
ggplot(data=dt , aes(x=month , y = total_victims  , group=race , fill= age)) + geom_col()  +
       facet_wrap(vars(race , gender )) +
       theme_bw()

#4-b
ggplot(data=dt , aes(x=decade , y = total_victims  , group=race)) + geom_col()  +
      facet_wrap(vars(race)) +
      theme_bw()
#4-c
ggplot(data=dt , aes(x=decade , y = total_victims  , group=race)) + stat_summary(fun="mean", geom="col")  +
      facet_wrap(vars(race)) +
     theme_bw()

#----------------------------------wordcloud---------------------------------
wc <- select(dt , City , total_victims)
#wordcloud2(wc ,color = "random-light",backgroundColor = "white")
wordcloud2(wc ,minRotation = -pi/6,maxRotation = -pi/6, minSize = 10,rotateRatio = 1)

wc1 <- select(dt , State , total_victims)
#wordcloud2(wc1 ,color = "random-light",backgroundColor = "white")
wordcloud2(wc1 ,minRotation = -pi/6,maxRotation = -pi/6, minSize = 10,rotateRatio = 1)

#-------------------------------------ggmap----------------------------------
us <- c(left = -125, bottom = 25.75, right = -67, top = 49)
map <- get_stamenmap(us, zoom = 5, maptype = "terrain") %>% ggmap()
map + geom_point(aes(x = dt$longitude, y = dt$latitude), data = dataset, colour = "red", size = 2)
map + stat_density2d(aes(x = longitude, y = latitude,  fill = ..level.. , alpha = ..level..),size = 2, bins = 4,  data = dt  , geom = 'polygon')+ scale_fill_gradient('Shooting\nDensity') + scale_alpha(range = c(.4, .75), guide = "none") + guides(fill = guide_colorbar(barwidth = 1.5, barheight = 10))




