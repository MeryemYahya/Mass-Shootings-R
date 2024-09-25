# Mass Shootings Data Visualization Project

## Overview
This project presents an in-depth analysis and visualization of mass shootings in the United States using the "Mother Jones - Mass Shootings Database, 1982 - 2021" dataset. The dataset provides detailed information on incidents involving multiple firearm-related victims, and this project aims to uncover trends, regional patterns, and other insights through various data visualization techniques.

## Dataset
The dataset used in this project is sourced from the "Mother Jones - Mass Shootings Database, 1982 - 2021," which contains a comprehensive list of mass shootings in the United States between 1924 and 2022. Each entry in the dataset includes relevant details such as the location, date, number of casualties, injuries, and a description of the incident.

### Key columns include:

- **Date**: Date of the shooting
- **City**: City where the shooting occurred
- **State**: State where the shooting occurred
- **Dead**: Number of casualties
- **Injured**: Number of people injured
- **Total**: Dead + Injured
- **Description**: Description of the shooting
  
## Objectives
The project uses this data to answer and explore key questions:

- What trends can be observed in mass shootings over the years?
- Which states and cities have the highest occurrences of mass shootings?
- What are the patterns when analyzing the relationship between the shooter's age and the number of victims?
- How do mental health issues factor into incidents of mass shootings?
- How can we visualize the geographical spread of mass shootings across the United States?
- What insights can be drawn from the textual descriptions of these shootings through word clouds?

## Data Import and Overview
- Two CSV files are read: the mass shootings dataset and a mapping of U.S. regions to states.
- Initial data exploration is done using colnames(), glimpse(), and str() to examine the structure and contents.

## Data Wrangling
- **Location Parsing:** The 'location' column is split into 'City' and 'State', and state names are cleaned (e.g., fixing typos like "Lousiana" to "Louisiana").
- **Region Joining:** The dataset is merged with US_Region to map regions based on state.
- **Race & Gender Standardization:** Race and gender categories are standardized for consistency in analysis (e.g., "white" to "White", "Male & Female" to "Both").
- **Date Handling:** Dates are transformed into date objects, and decades are calculated using a custom function.
- **Fixing Inconsistencies:** Columns like location...8 (location type), prior_signs_mental_health_issues, and weapons_obtained_legally are cleaned to remove anomalies and standardize values.

## Data Preprocessing and Visualization
- **Quantitative Analysis:** Focuses on numeric variables like fatalities, injured, total victims, and age.
  - Correlation analysis (cor(), rcorr()) is performed to identify relationships between numeric variables.
  - Descriptive statistics (describe(), summary(), boxplot(), hist()) are used to visualize distributions and outliers in the dataset.
- **Qualitative Analysis:** Categorical variables like location, race, and mental health issues are analyzed.
Frequency tables are generated and barplots, dot charts, and descriptive statistics are displayed for each qualitative variable.
  
## Visualizations
The project implements a series of visualizations to explore the data and derive meaningful insights:

### 1. Bar Plots:
Mass Shootings by Mental Health and Gender: A bar plot comparing the total number of victims based on the perpetrator's mental health status and gender.
Total Victims by Decade and Region: Analysis of how the number of victims has changed over time and across different regions.
### 2. Line Graph:
Fatalities Over Time by Region: A time-series visualization depicting the trend of fatalities across different U.S. regions, helping identify patterns over the years.
### 3. Scatter Plot with Regression Line:
Age vs. Total Victims: A scatter plot to assess whether there's a relationship between the age of the shooter and the total number of victims, accompanied by a linear regression line.

### 4. Word Cloud:
Word Cloud of Shooting Locations & Perpetrator Race: Visualization of the frequency of certain locations and racial demographics of perpetrators based on textual descriptions within the dataset.

<div style="display: flex; justify-content: space-between;">
    <img src="Word_cloud_State_vs_total_victims.png" alt="Word cloud State vs total victims" width="45%"/>
    <img src="Word_Cloud_City_vs_total_victims.png" alt="Word Cloud City vs total victims" width="45%"/>
</div>

### 5. Geographical Mapping:
 **Scatter Plot on U.S. Map**: Locations of mass shootings were plotted using latitude and longitude data, with the size of the points indicating the number of victims.
 ![Scatter Plot on U.S. Map](map.png)
- **Density Heatmap**: A heatmap showed the concentration of mass shootings across different U.S. regions, offering a visual cue to identify high-risk areas.
 ![Density Heatmap](map_density.png)


## Summary
This project provides a comprehensive view of mass shootings in the U.S. and presents the data in various visual formats to assist with identifying trends, understanding patterns, and extracting actionable insights. By leveraging visualization techniques and clustering algorithms, the project aims to offer a nuanced understanding of this complex issue.

## How to Run
- Clone the repository.
- Load the dataset ("Mother Jones - Mass Shootings Database, 1982 - 2021") into your R environment.
- [Create a Stadia Maps account](https://docs.stadiamaps.com/guides/migrating-from-stamen-map-tiles/#create-a-stadia-maps-account).
- [Add API key to the code](https://docs.stadiamaps.com/guides/migrating-from-stamen-map-tiles/#ggmap).
- Run the R script to generate the visualizations and analyses.
