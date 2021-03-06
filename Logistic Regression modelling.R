##########################################
### Fitting Logistic Regression Model ####
##########################################

library(readr)
dat <- read_csv("C:/Users/Saiful_desv/Desktop/Rention-data-analysis-master/Rention model.csv", 
                na = "NULL")



#### Colnames cleaning:

names(dat) = gsub(pattern = "c59320_retnmdl_eda_dataset_v1.", replacement = "", x = names(dat))
dat$Year_month <- zoo::as.yearmon(paste(dat$close_year, dat$close_month), "%Y %b")


# Number of missing value per variable
sapply(dat, function(y) sum(length(which(is.na(y)))))


dat <- na.omit(dat)
## Keeping relevant 
dat <- dat[,-c(1:4,6,7,13)]
dat$DV <- ifelse(dat$sold == 'Y',1,0)
dat <- dat[,-1]

### Data splitting
library(caret)
intrain <- createDataPartition(y = dat$DV, p= 0.80, list = FALSE)
train <- dat[intrain,]
test <- dat[-intrain,]


dim(test)
dim(train)

### Fitting model:

library(car)
fitted <- glm(DV ~ ., data = train, family = "binomial")
vif(fitted)

## Refined model 1 (Removing prebbd_re)


fitted2 <- glm(DV ~ Year_month+duration_yrs+market+segment_sub+
                 fundng_ty+sic_division+bbd+postbbd_re+rnwl_fund, data = train, family = "binomial")

vif(fitted2)


## Refined model 2 (Removing fundng_ty)

fitted3 <- glm(DV ~ Year_month+duration_yrs+market+segment_sub
               +sic_division+bbd+postbbd_re+rnwl_fund, data = train, family = "binomial")

vif(fitted3)


##### Summary of finally refined model:

summary(fitted3)


colnames(train)

test <- test[,c("Year_month","duration_yrs","market","segment_sub"
                ,"sic_division","bbd","postbbd_re","rnwl_fund","DV")]





## Predicting the test data:
test_pred <- predict(fitted3,newdata = test,type="response")


## Confusion matrix
con_tab <- confusionMatrix(as.numeric(test_pred>0.5),test$DV)


## Accuracy

corr <- con_tab[1,1]+con_tab[2,2]
accuracy <- (corr/sum(con_tab))*100

paste("Fitted model accuracy is ",accuracy,"%",sep = "")

