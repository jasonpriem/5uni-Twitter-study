# get the data
tweets <- read.csv("~/projects/5uni_twitter/tweets_from_db.csv", header=T, colClasses=c("character", "character", "character", "character"))
scholars <- read.csv("~/projects/5uni_twitter/scholars_from_db.csv", header=T, colClasses="character")

# tidy columns
tweets$created_at <- as.POSIXct(as.character(tweets$created_at), format = "%a %b %d %H:%M:%S +0000 %Y", tz="GMT")
scholars$dept<-sub("Department of ", "", scholars$dept)

# make a list of tweets by creator, limited to the latest 20 tweets each, and convert it to a data frame
tweets.byCreator <- lapply(unique(tweets$scholar), function(scholar) tweets[tweets$scholar == scholar,] )
tweets.byCreator<- lapply(tweets.byCreator, function(tweets) tweets[rev(order(tweets$created_at)),][1:min(20, nrow(tweets)),])
tweets <- do.call("rbind", tweets.byCreator)

# add author metadata to the tweets
tweets<-merge(data.frame(scholar=scholars$scholar, dept=scholars$dept), tweets, all.y=TRUE, by="scholar")

# reorder and save
tweets<-cbind(tweets[c(1,3,4,2,5)])
write.csv(tweets, file="~/projects/5uni_twitter/tweets_to_code.csv", row.names=F)


