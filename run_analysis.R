# Load library: "data.table and "dplyr"
# Download and unzip datafile:
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Read training table
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)

# read test table
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)

# Tast 1: Merge the training and the test sets to create one data set
subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(activityTrain, activityTest)
features <- rbind(featuresTrain, featuresTest)

# Name columns
colnames(features) <- t(featureNames[2])

# Merge data in features, activity and subject
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
completeData <- cbind(features, activity, subject)

# Task 2: Extract only the measurements on the mean and standard deviation for each measurement
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case = TRUE)

# Adding activity and subject columns (after the last column 561) and looking at the dimension:
requiredColumns <- c(columnsWithMeanSTD, 562, 563)
dim(completeData)

# Extract data with the selected columns in requiredColumns. And then look at RequiredColumns. 
extractedData <- completeData[,requiredColumns]
dim(extractedData)

# Task 3: Use descriptive activity names to name the activities in the data set:
extractedData$Activity <- as.character(extractedData$Activity)
for (i in 1:6){
        extractedData$Activity[extractedData$Activity == i] <- as.character(activityLabels[i,2])
}

# Then factor the activity variable
extractedData$Activity <- as.factor(extractedData$Activity)

# Tast 4: Lable the dataset with descriptive variable names
# First, look at the data: 
names(extractedData)

# Then we can replace acronyms
names(extractedData)<-gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData)<-gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData)<-gsub("BodyBody", "Body", names(extractedData))
names(extractedData)<-gsub("Mag", "Magnitude", names(extractedData))
names(extractedData)<-gsub("^t", "Time", names(extractedData))
names(extractedData)<-gsub("^f", "Frequency", names(extractedData))
names(extractedData)<-gsub("tBody", "TimeBody", names(extractedData))
names(extractedData)<-gsub("-mean()", "Mean", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-std()", "STD", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-freq()", "Frequency", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("angle", "Angle", names(extractedData))
names(extractedData)<-gsub("gravity", "Gravity", names(extractedData))

# This will store new names in extractedData

# Task 5: From the dataset in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject. 
extractedData$Subject <- as.factor(extractedData$Subject)
extractedData <- data.table(extractedData)

# then create a tidy dataset with average for each activity and subject. And we finish with writing it to a data file called Tidy.txt.
tidyData <- aggregate(. ~Subject + Activity, extractedData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)


