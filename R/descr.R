library(ggplot2)
tweets <- read.csv("~/projects/5uni_twitter/tweets/tweets_all_coded.csv", header=T, colClasses=c("character", "character", "character", "character"))
scholars <- read.csv("~/projects/5uni_twitter/scholars/scholars_from_db.csv", header=T, colClasses="character")

# format the datasets
tweets$code <- factor(tweets$code)
scholars$scholar_id <- (as.numeric(scholars$scholar_id))
scholars$tw_statuses_count <- as.numeric(scholars$tw_statuses_count)
tweets$scholar_id <- (as.numeric(tweets$scholar_id))
tweets<-merge(tweets, scholars, all.x=TRUE, by="scholar_id")



tweets$scholar_id <- factor(tweets$scholar_id)
statuses.per.schol <- unique(data.frame(id=tweets$scholar_id, statuses_count=tweets$tw_statuses_count))
tweets$scholar_id <- factor(tweets$scholar_id, levels = levels(tweets$scholar_id)[(order(statuses.per.schol$statuses_count))])

# tweets$scholar_id <- factor(tweets$scholar_id, levels = order())
tweets$tw_statuses_count
length(as.character(tweets$scholar_id))


# make column for the age of each tweet
collection.time <- as.POSIXct("2011-07-28 13:00", "GMT")
tweets$age <- unclass(collection.time - as.POSIXct(tweets$created_at)) / 86400


tg <- ggplot(tweets, aes(age, scholar_id))
tg  + scale_x_reverse() + geom_point(aes(colour=code), size=1, shape=15)

schols.live <- scholars[!is.na(scholars$tw_statuses_count),]
schols.live<-schols.live[order(schols.live$tw_statuses_count),]
schols.live$quantile<-nrow(schols.live):1


g <- ggplot(schols.live, aes(quantile, tw_statuses_count))
g + geom_point() 






scholars[scholars$scholar_id==6771,]
