---
title: "readme"
author: "MinJun"
date: '2020 3 4 '
output: html_document
---

## Explanation about the script  
The script largely consists of four parts  
  
1.Downloading and unzipping datasets  
2.Assigning datasets to respective variables  
3.Merging datasets  
4.Melting and casting data to see what we want  
5.Exporting the output  

### Downloading and unzipping datasets  
First I have created data directory to store data. Then I have assigned the url to fileURL. then I have downloaded the data and unzipped it.  
  
```{r}
if (!dir.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile="./data/SamsungDataset.zip")
unzip("./data/SamsungDataset.zip",exdir="./data")
pathdir <- "./data/UCI HAR Dataset/"
```

### Assigning datasets to respective variables  
Then I used fread to read all the relevant text files in the folder that I have unzipped. I used fread to minimize the speed of importing. I found this way of assigning all the variables at the beginning is highly intuitive for handling several datasets.  
  
```{r}
features <- fread(file.path(pathdir,"features.txt"), col.names = c("index", "features"))
activity_labels <-fread(file.path(pathdir,"activity_labels.txt"),col.names=c("index","label"))
subject_training <- fread(file.path(pathdir,"train/subject_train.txt"), col.names="subject")
subject_test <- fread(file.path(pathdir,"test/subject_test.txt"), col.names="subject")
xtrain <- fread(file.path(pathdir,"train/X_train.txt"))
ytrain <- fread(file.path(pathdir,"train/y_train.txt"), col.names=("activity"))
xtest <- fread(file.path(pathdir,"test/X_test.txt"))
ytest <- fread(file.path(pathdir,"test/y_test.txt"), col.names="activity")
```


### Merging datasets  
I merged test datasets to corresponding training datasets using rbind. While I do this, I had to use regular expressions to grep mean/standarddeviation within the variable name. Then I merged subject, activity and features using cbind. Similarly, I factored activity numbers to replace with corresponding labels.
  
```{r}
#row-binding training and test subject dataset
subject_wanted <- rbind(subject_training,subject_test)

#row-binding training and test X (features) dataset
colnames(xtrain) <- features$features
colnames(xtest) <- features$features
xmerged <- rbind(xtrain,xtest)
x_wanted <- xmerged[,grep("(mean|std)\\(\\)",names(xtrain)),with=FALSE]

#row-binding training and test y (activity) dataset
y_wanted <- rbind(ytrain,ytest)
y_wanted$activity <- factor(y_wanted$activity,levels=activity_labels$index,labels=activity_labels$label)

#column-binding all datasets 
df <- cbind(subject_wanted,y_wanted,x_wanted)
```
  
### Melting and casting data to see what we want
I used melt function to create a table that measures variables according to subject and activity.Then I casted this table using dcast. I intended to print mean values for all variables according to subject and activity.   
  
```{r}
dfmelt <- melt(df,id.vars=c("subject","activity"), measure.vars = colnames(df)[c(3:length(colnames(df)))])
answer <- dcast(dfmelt,subject+activity ~ variable,mean)
```

### Exporting the output  
I simply exported the final answer to txt file.

```{r}
write.table (x = answer, file = "answer.txt", row.names=FALSE)
```
---
## Codebook
1. Subject : Different number corresponds to a different experiment volunteer  
2. activity : the activity that a volunteer carried out  
3. rest of the variables is better explained with the following :  

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

tBodyAcc-XYZ
tGravityAcc-XYZ
tBodyAccJerk-XYZ
tBodyGyro-XYZ
tBodyGyroJerk-XYZ
tBodyAccMag
tGravityAccMag
tBodyAccJerkMag
tBodyGyroMag
tBodyGyroJerkMag
fBodyAcc-XYZ
fBodyAccJerk-XYZ
fBodyGyro-XYZ
fBodyAccMag
fBodyAccJerkMag
fBodyGyroMag
fBodyGyroJerkMag

The set of variables that were estimated from these signals are: 

mean(): Mean value
std(): Standard deviation