## BACKGROUND

# Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect 
# a large amount of data about personal activity relatively inexpensively. These type of devices
# are part of the quantified self movement – a group of enthusiasts who take measurements about 
# themselves regularly to improve their health, to find patterns in their behavior, or because 
# they are tech geeks. One thing that people regularly do is quantify how much of a particular 
# activity they do, but they rarely quantify how well they do it. In this project, your goal will
# be to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. 
# They were asked to perform barbell lifts correctly and incorrectly in 5 different ways. 
# More information is available from the website here: http://groupware.les.inf.puc-rio.br/har


## GOAL

# The goal of the project is to predict the manner in which the participants did the exercise. 
# This is the "classe" variable in the training set. Other variables may be used to predict the outcome. 
# A report must be written, describing how the model was built, how cross validation was used, 
# what the expected out of sample error is, and why specific choices were made. 


## DATA

# The training data can be found here: https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv
# The test data can be found here: https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv

# The data for this project come from this source: http://groupware.les.inf.puc-rio.br/har. 
# If you use the document you create for this class for any purpose please cite them as they have 
# been very generous in allowing their data to be used for this kind of assignment.


## DATA PREPROCESSING

# Clear console
rm(list=ls())
cat('\014')

# Load packages 
library(caret)
library(corrplot)
library(caTools)
library(ggplot2)
library(knitr)
library(plyr)
library(randomForest)

# Download the data
download.file("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv", 
              destfile = "training_set.csv")
download.file("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv", 
              destfile = "test_set.csv")

# Create datasets
training_set = read.csv("training_set.csv")
test_set = read.csv("test_set.csv")

# Remove personal ID fields - not relevant to the model
training_set = training_set[, -(1:5)]
test_set  = test_set[, -(1:5)]

# Classify all columns with blanks and errors as NA for easier removal
training_set[training_set == ""] = NA
training_set[training_set =="#DIV/0!"] = NA

test_set[test_set == ""] = NA
test_set[test_set =="#DIV/0!"] = NA

# Remove all NAs from dataset
training_setNAs = sapply(training_set, function(x) mean(is.na(x))) > 0.95
training_set = training_set[, training_setNAs==FALSE]
test_set  = test_set[, training_setNAs==FALSE]

# Split dataset for training and testing
set.seed(123)
split = sample.split(training_set$classe, SplitRatio = 0.8)
training_setSplit = subset(training_set, split == TRUE)
test_setSplit = subset(training_set, split == FALSE)

## MODEL SELECTION

# There are several regression models available to analyze our data - 
# Multiple Linear Regression, Polynomial Regression, Support Vector Regression, Decision Tree 
# and Random Forest However, due to the presence of a lot of noise in the data and potential 
# nonlinearity I will be using a Random Forest. I believe RF will deal well with non linearity 
# in the data without the need for interaction terms, data transformations (as in the case of 
# Polynomial Regression) and will be more accurate than Multiple/Polynomial/Support Vector Regression.


# Create RF Model - Train model
set.seed(123)
RFModel = randomForest(classe ~ ., data=training_setSplit)

# Applying RF to test split - Test model
RFPredictor = predict(RFModel, test_setSplit, type = "class")

# Constructing a Confusion Matrix
RFConfMatrix = confusionMatrix(RFPredictor, test_setSplit$classe)
RFConfMatrix

#Out of Sample Error
1 - RFConfMatrix$overall['Accuracy']

# Plotting a Confusion Matrix
plot(RFConfMatrix$table, col = RFConfMatrix$byClass, 
     main = paste("RF Model - Accuracy =",
                  round(RFConfMatrix$overall['Accuracy'], 3)))

# The Random Forest model yields 99% accuracy which is surprisingly very good.

# Applying model to Test dataset
# RFPredictorTest = predict(RFModel, test_set, type = "class")
# RFPredictorTest


#########
