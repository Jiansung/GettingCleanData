#loading pacakges
library(dplyr)
library(plyr)
library(data.table)
library(lubridate)

#downloading and unzipping data
if (!dir.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile="./data/SamsungDataset.zip")
unzip("./data/SamsungDataset.zip",exdir="./data")
pathdir <- "./data/UCI HAR Dataset/"

#reading data and assigning initial names
features <- fread(file.path(pathdir,"features.txt"), col.names = c("index", "features"))
activity_labels <-fread(file.path(pathdir,"activity_labels.txt"),col.names=c("index","label"))
subject_training <- fread(file.path(pathdir,"train/subject_train.txt"), col.names="subject")
subject_test <- fread(file.path(pathdir,"test/subject_test.txt"), col.names="subject")
xtrain <- fread(file.path(pathdir,"train/X_train.txt"))
ytrain <- fread(file.path(pathdir,"train/y_train.txt"), col.names=("activity"))
xtest <- fread(file.path(pathdir,"test/X_test.txt"))
ytest <- fread(file.path(pathdir,"test/y_test.txt"), col.names="activity")

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

#melting variables and casting dataframes
dfmelt <- melt(df,id.vars=c("subject","activity"), measure.vars = colnames(df)[c(3:length(colnames(df)))])
answer <- dcast(dfmelt,subject+activity ~ variable,mean)

#exporting to txt file
write.table (x = answer, file = "answer.txt", row.names=FALSE)

