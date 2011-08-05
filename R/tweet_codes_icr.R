library(concord)
library(digest)
tweets <- read.csv("~/projects/5uni_twitter/tweets/tweets_all_coded.csv", header=T, colClasses=c("character"))
tweets<-tweets[tweets$last20==1,]
tweets<-tweets[order(tweets$hash),]

# save a subset of tweets for icr
tweets$hash2 <- apply(tweets, 1, function(x) digest(x["hash"], algo="md5")) 
tweets.icr <- tweets[944:nrow(tweets),] # discard tweets that were in the training set

tweets.icr <- tweets.icr[order(tweets.icr$hash2),]
tweets.icr.write <- tweets.icr[274:410,] # 136 tweets in icr sample, as recommended by (Riffe, Lacy and Fico, 2005, p145)
tweets.icr.write$code <- NULL
write.csv(tweets.icr.write, file="~/projects/5uni_twitter/tweets/tweets_icr3.csv", row.names=F) 

# K8lin codes her tweets, then we read her codes back in
tweets.icr.k <- read.csv("~/projects/5uni_twitter/tweets/tweets_icr3_k8lin_coded.csv", header=T, colClasses=c("character"))

# test against the codes we already have
tweets.icr.j <- tweets.icr[274:410,] # manually check which rows are in the k8lin icr sample...
codes<-cbind(factor(tweets.icr.j$code), factor(tweets.icr.k$code))
cohen.kappa(codes, "score")

cbind(tweets.icr.j$code, tweets.icr.k$code)
