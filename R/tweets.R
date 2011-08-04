library(digest)

# get the data
tweets <- read.csv("~/projects/5uni_twitter/tweets/tweets_from_db.csv", header=T, colClasses=c("character", "character", "character", "character"))
scholars <- read.csv("~/projects/5uni_twitter/scholars/scholars_from_db.csv", header=T, colClasses="character")

# tidy columns
tweets$created_at <- as.POSIXct(as.character(tweets$created_at), format = "%a %b %d %H:%M:%S +0000 %Y", tz="GMT")
scholars$dept<-sub("Department of ", "", scholars$dept)


# make a list of tweets by creator, limited to the latest 20 tweets each, and convert it to a data frame
tweets.byCreator <- lapply(unique(tweets$scholar), function(scholar) tweets[tweets$scholar == scholar,] )
tweets.byCreator<- lapply(tweets.byCreator, function(tweets) tweets[rev(order(tweets$created_at)),][1:min(20, nrow(tweets)),])
tweets <- do.call("rbind", tweets.byCreator)

# add author department to the tweets
tweets<-merge(data.frame(scholar_id=scholars$scholar_id, dept=scholars$dept), tweets, all.y=TRUE, by="scholar_id")

# shuffle and save
tweets$hash <- apply(tweets, 1, function(x) digest(x["id"], algo="md5")) # for main coding, training
tweets<-tweets[order(tweets$hash),]
tweets<-cbind(tweets[c(6,1,3,4,2,5)])
write.csv(tweets, file="~/projects/5uni_twitter/tweets/tweets_all.csv", row.names=F)





