library(digest)

# get the data
tweets <- read.csv("~/projects/5uni_twitter/tweets/tweets_from_db.csv", header=T, colClasses=c("character", "character", "character", "character"))
scholars <- read.csv("~/projects/5uni_twitter/scholars/scholars_from_db.csv", header=T, colClasses="character")

# tidy columns
tweets$created_at <- as.POSIXct(as.character(tweets$created_at), format = "%a %b %d %H:%M:%S +0000 %Y", tz="GMT")
scholars$dept<-sub("Department of ", "", scholars$dept)
tweets$last20<-0


# mark each scholar's last 20 tweets
tweets.byCreator <- lapply(unique(tweets$scholar_id), function(scholar_id) tweets[tweets$scholar_id == scholar_id,] )
tweets.last20.list <- lapply(tweets.byCreator, function(tweets) tweets[rev(order(tweets$created_at)),][1:min(20, nrow(tweets)),"id"])
tweets.last20 <- do.call("c", tweets.last20.list)
tweets[tweets$id %in% tweets.last20, "last20"] <- 1


# add author department to the tweets
tweets<-merge(data.frame(scholar_id=scholars$scholar_id, dept=scholars$dept), tweets, all.y=TRUE, by="scholar_id")

# shuffle and save
tweets$hash <- apply(tweets, 1, function(x) digest(x["id"], algo="md5")) # for main coding, training
tweets<-tweets[order(-tweets$last20, tweets$hash),]

tweets<-cbind(tweets[c(7, 6,1,3,4,2,5)])
write.csv(tweets, file="~/projects/5uni_twitter/tweets/tweets_all.csv", row.names=F)





