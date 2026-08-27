# Rutgers SQL/Python Data Project README.

## Overview:
This project is related to psychophysiology research I am performing with faculty at Rutgers University in the Spring—Summer of 2026.

**Primary Research Question:** How does a paced breathing maneuver (i.e., 6 breaths per minute) influence the cardiovascular system, compared to normal breathing during resting conditions?

**Dependent Variables:**
- Heart Rate Variability (HRV) indices
- Respiratory measures

**Independent Variables:**
- Time
- BMI (height + weight)
- Age
- Sex (Male vs. Female)
- Race
- Ethnicity
- Group (Healthy control, Addiction, Athlete)

## **Extract, Transform, Load (ETL) Data:**
1) Using MySQL, querying a pre-existing psychosocial data (e.g., demographics) and physiological data (e.g., heart rate variability and respiratory measures) from 10 different research studies whose data has been partially stored in their own respective relational databases (schemas).
2) Cleaning and wrangling the data using a combination of SQL and Python. This step also included identifying missing data, locating the missing data (when possible), and loading the data to the appropriate database for wrangling/cleaning/analysis.
- Missing data that was located was uploaded into MySQL Workbench through direct import or using Python via the Jupyter Notebook titled [import_csv2mysql_python_good_04172026.ipynb](https://github.com/Tom-Gooding/Portfolio/blob/main/Data_Projects/Rutgers_SQL_Project/import_csv2mysql_python_good_04172026.ipynb)
4) Cleaned physiological and demographic data were exported from MySQL, imported into Python, and joined together in Python for subsequent data visualization and data analysis.

## **Exploratory Data Analysis (EDA):**
1. After data was uploaded to Python, minor data cleaning/wrangling was performed to ensure physiological and demographic datasets merged properly. A LEFT JOIN of demographic data onto physiology data was performed as if participants didn't have physiological data, we weren't interested in keeping them for the intended analyses.
2. EDA included:
   - Identifying columns of interest (key physiological variables)
   - Data counts and missingness for key variables.
   - Plotting histograms, stripplots, and boxplots to examine data distribution.
   - Calculating descriptive statistics (mean, median, quartiles, ranges).
   - Basic correlations were performed and a correlation matrix of physiological variables was created and plotted as a heatmap. 
3. EDA was performed on entire dataset and for each individual database (schema) to inspect the subsets of data from each individual study (schema).

## **Data Analysis:**
1. Heart rate variability data was prepared for data analysis. Frequency HRV measures (e.g., Low frequency, high frequency) and a few time HRV measures (e.g., RMSSD, Pnn50) were log transformed.
2. For each variable, tests of normality and homoscedasticity were performed to determine whether or not data was normally distributed and/or had equal variance between groups
3. 


**To be Continued...**
