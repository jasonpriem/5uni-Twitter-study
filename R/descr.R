library(ggplot2)
library(gmodels)
library(vcd)
library(RColorBrewer)
tweets <- read.csv("~/projects/5uni_twitter/tweets/tweets_all_coded.csv", header=T, colClasses=c("character", "character", "character", "character"))
schols <- read.csv("~/projects/5uni_twitter/scholars/scholars_from_db.csv", header=T, colClasses=c("character"))

# format the datasets
tweets$code <- factor(tweets$code)
tweets$scholar_id <- (as.numeric(tweets$scholar_id))
tweets$last20[tweets$last20=="1"] <- TRUE
tweets$last20[tweets$last20=="0"] <- FALSE

schols$scholar_id <- (as.numeric(schols$scholar_id))
schols$tw_statuses_count <- as.numeric(schols$tw_statuses_count)
schols$superdiscipline[schols$superdiscipline=="natural science"]<-"natural_science"
schols$twitter_users_count <- as.numeric(schols$twitter_users_count)
schols$tw_protected <- as.logical(schols$tw_protected)
schols$tw_friends_count <- as.numeric(schols$tw_friends_count)



# schols in sample
#########################################################################
# 1a: Forming the sample: removing duplicate names
redund.not <- schols[schols$is_redundant == 0,]
redund.is <- schols[schols$is_redundant == 1,]
(nrow(redund.not) + nrow(redund.is)) - nrow(schols) # sanity check...
nrow(redund.is) # discarded:
schols <- redund.not
nrow(schols) # we were left with this many: 

# 1b:Forming the sample: removing common names?
common <- schols[schols$twitter_users_count == 20,]
uncommon <- schols[schols$twitter_users_count < 20,]
(nrow(common) + nrow(uncommon)) - nrow(schols)
nrow(common) # discarded:
schols <- uncommon 
nrow(schols) # were left with this many:

# 2: Describing the sample:
CrossTable(schols$rank, schols$superdiscipline, prop.t=F) # see http://intersci.ss.uci.edu/wiki/index.php/R_CrossTab,_gmodels_package for docs
# looks like postdoc isn't that important (and all in nat_sci), we'll roll it into doctoral:
schols$rank[schols$rank %in% c("doctoral", "postdoc")] <- "nonfaculty"
CrossTable(schols$rank, schols$superdiscipline, prop.t=F)
# visualise the makup of the sample
schols.t <- table(schols$superdiscipline, schols$rank)
mosaicplot(schols.t, color=c("pink", "lightblue"), off=c(4, 2), las=3, cex.axis=1)





# Twitter accounts in sample
##########################################################################
sum(schols$twitter_users_count) 
# of these 9139 accounts had no descr, url, or location, and 390 were celebrities that were 20 oft-returned celebs
# (src: code/php/couchdb/views/user_search_results.js)
# This left 7648 profiles to check mostly manually (made limited use of timezone as an automated filter)
17177 - (9139 + 390 + 7648) # sanity check, should be 0

st <- schols[!is.na(schols$tw_screen_name),]
nrow(st) # schols from our sample with Twitter accts
nrow(st) / nrow(schols) # % schols with Twitter accts

# let's look at accounts with no tweets
st.silent <- subset(st, tw_statuses_count==0)
nrow(st.silent) # have Twitter acct but no tweets
nrow(st.silent) / nrow(st) # % silent twitter accts
nrow(subset(st.silent, tw_friends_count >= 10)) # silent, but probably is (or was) used for reading

# now protected accounts (a few of these are included in the silent count as well)
st.protected <- subset(st, tw_protected==TRUE)
nrow(st.protected)
table(st.protected$rank)

# remove silent and protected accounts (everyone with no public tweets)
st.with.public.tweets <- subset(st, scholar_id %in% tweets$scholar_id)
nrow(st) - nrow(st.with.public.tweets) # getting rid of this many accts with no public tweets
nrow(st.with.public.tweets) # keeping this many
nrow(st.with.public.tweets) / nrow(schols) # % schols with public tweets
st.no.public.tweets <- st
st <- st.with.public.tweets



# Find "Active" Twitter accounts in sample (have tweeted recently)
##########################################################################
collection.time <- as.numeric(as.POSIXct("2011-07-28 15:00", "GMT")) # UNIX timestamp when we got the tweets
tweets$age <- (collection.time - as.numeric(as.POSIXct(tweets$created_at, "GMT"))) / 86400 # each tweet's age in days

tweets.last20only <- subset(tweets, last20==TRUE) # removes a bunch of older tweets, saves time
st$latest_tweet_age <- sapply(st$scholar_id, function(id) sort(as.vector(tweets.last20only[tweets.last20only$scholar_id==id,"age"]))[1])

# finds the biggest difference between any two adjacent numbers in a given vector
max.gap <- function(x){
   ret <- 0
   x<-sort(x)
   for (i in 1:(length(x)-1)){
        ret <- max(c(x[i+1] - x[i]), ret)
   }
   return(ret)
}
st$max_gap<- sapply(st$scholar_id, function(id) max.gap(tweets[tweets$scholar_id==id, "age"]))

# take a look at the breakdown for last tweets
breaks.span <- (max(st$latest_tweet_age) - min(st$latest_tweet_age)) / 30
hist(st$latest_tweet_age, breaks=seq(0, max(st$latest_tweet_age)+breaks.span, by=breaks.span))

# we'll mark "active" users: it's been fewer than g OR d days since their last tweet (where g = user's longest previous interval between tweets, and d = 90)
st.act <- subset(st, latest_tweet_age < 90 | latest_tweet_age < max_gap)
st.act.sporadic <- (subset(st.act, latest_tweet_age >= 90))
st.abandonded <- subset(st, !(st$scholar_id %in% st.act$scholar_id))


nrow(st) - nrow(st.act) # inactive accounts
1 - (nrow(st.act) / nrow(st)) # % abandoned accts (tweeted at least once, but now inactive)
schols$act <- FALSE
schols$act[schols$scholar_id %in% st.act$scholar_id] <- TRUE

# Examine effects of discipline and rank on proportion of active tweeters
##########################################################################

# First, look at discipline
disc.t <- table(schols$superdiscipline, schols$act)
disc.t
disc.ct <- CrossTable(disc.t, chisq=TRUE)
disc.t.f <- as.data.frame(disc.ct$prop.col, stringsAsFactors=TRUE)
names(disc.t.f) <- c("discipline", "active", "count")
levels(disc.t.f$active) <- c("Nontweeting", "Tweeting")

# is discipline significant?
disc.ct$chisq

# plot % on twitter vs % in sample for discipline
tg <- ggplot(disc.t.f, aes(discipline, count))
tg <- tg +  geom_bar(position="dodge", aes(fill=active)) + coord_flip()  + ylab("percent of sample")
tg <- tg + scale_y_continuous(formatter="percent") + opts(axis.title.y=theme_blank())+ opts(legend.title = theme_blank())
tg

# second, we'll look at rank
rank.t <- table(schols$rank, schols$act)
rank.ct <- CrossTable(rank.t, chisq=TRUE)
rank.t.f <- as.data.frame(rank.ct$prop.col, stringsAsFactors=TRUE)
names(rank.t.f) <- c("rank", "active", "count")
levels(rank.t.f$active) <- c("Nontweeting", "Tweeting")

# plot % on twitter vs % in sample for rank
tg <- ggplot(rank.t.f, aes(rank, count))
tg <- tg +  geom_bar(position="dodge", aes(fill=active)) + coord_flip()  + ylab("percent of sample")
tg <- tg + scale_y_continuous(formatter="percent") + opts(axis.title.y=theme_blank())+ opts(legend.title = theme_blank())
tg

# look at discipline and rank together
st.act.t <- table(st.act$superdiscipline, st.act$rank) / table(schols$superdiscipline, schols$rank)
st.act.t
mosaicplot(st.act.t, color=c("pink", "lightblue"), off=c(4, 2), las=3, cex.axis=1)

# Frequency of schols' tweeting
##########################################################################

# because of API limit, we're missing tweets for the really heavy users; we'll add fake ones
counts <- as.data.frame(table(tweets$scholar_id))
names(counts) <- c("scholar_id", "num_tweets_collected")
schols <- merge(schols, counts, all.x=TRUE, by="scholar_id")
schols[is.na(schols$num_tweets_collected), "num_tweets_collected"] <- 0

fails <- (subset(schols.copy, tw_statuses_count != num_tweets_collected, select=c(scholar_id, tw_statuses_count, num_tweets_collected)))
plot(fails$tw_statuses_count, fails$num_tweets_collected)

sh <- subset(schols, tw_statuses_count > 3200 & tw_protected==FALSE)
sh$first_tweet_age <- sapply(sh$scholar_id, function(id) rev(sort(as.vector(tweets[tweets$scholar_id==id,"age"])))[1])
sh





sh$tw_created_at_posix <- as.POSIXct(as.character(sh$tw_created_at), format = "%a %b %d %H:%M:%S +0000 %Y", tz="GMT")

sh$acct_age <- as.vector(unclass(collection.time - sh$tw_created_at_posix))
sh$blindspot_len <- as.vector(unclass(as.POSIXct(as.character(sh$first_tweet_date), tz="GMT") - sh$tw_created_at_posix)) # number of days clipped by twitter api
sh
sh$blindspot_tweets_ct <- sh$tw_statuses_count - 3200 
sh$faketweets_spacing <- sh$blindspot_len / (sh$blindspot_tweets_ct + 1)
make.faketweets <- function(start.age, end.age, num) {
   start <- as.numeric(unclass(as.POSIXct(as.character(start))))
   end <- as.numeric(unclass(as.POSIXct(as.character(end))))
   ages <- seq(start+1, end, length.out=num+1)[-(num+1)]
   return(ages / 86400)
}
(make.faketweets(sh$tw_created_at_posix[1], sh$first_tweet_date[1],  5))
as.numeric(unclass(as.POSIXct(as.character(sh$first_tweet_date[1]), tz="GMT"))) / 86400
as.numeric(unclass(as.POSIXct(as.character((sh$tw_created_at_posix[1])), tz="GMT"))) / 86400
as.POSIXct(as.character(sh$first_tweet_date[1]))




age<-seq(61, 100, length.out=5)[-5]
age

nrow(subset(tweets, scholar_id==9029, select=text))











# visualise each user's twitter stream
##########################################################################
# merge datasets
tweets<-merge(tweets, st, all.x=TRUE, by="scholar_id")

# order scholar_id factor by number of tweets
tweets$scholar_id <- factor(tweets$scholar_id)
statuses.per.schol <- unique(data.frame(id=tweets$scholar_id, statuses_count=tweets$tw_statuses_count))
tweets$scholar_id <- factor(tweets$scholar_id, levels = levels(tweets$scholar_id)[(order(statuses.per.schol$statuses_count))])

# add a column for simplified codes
tweets$code.simple <- "not coded"
tweets$code.simple[tweets$code %in% c("ki","kpp","kpn","l")] <- "scholarly"
tweets$code.simple[tweets$code %in% c("ns", "e")] <- "not scholarly"

# select data to plot
tweets.toplot <- subset(tweets, scholar_id %in% sh$scholar_id)
tweets.toplot$scholar_id <- factor(tweets.toplot$scholar_id)

# plot
tg <- ggplot(tweets.toplot, aes(age, scholar_id))
tg <- tg + geom_point(aes(colour=code.simple), size=1, shape=20)+ scale_x_continuous(trans="reverse", limits=c(max(tweets.toplot$age), 0))
tg <- tg + scale_colour_manual(values=c("#aaaaaa", "blue", "red"))  + geom_vline(aes(x=0), color="red")
tg <- tg + opts(panel.background = theme_blank())+ opts(panel.grid.minor= theme_line(size=.1, colour="#eeeeee")) 
tg <- tg + opts(panel.grid.major=theme_blank()) + opts(panel.border=theme_rect(colour="white"))
tg <- tg + opts(axis.text.y=theme_blank()) + opts(axis.ticks=theme_blank()) + opts(axis.title.y=theme_blank()) + opts(axis.title.x=theme_blank())
tg <- tg + opts(plot.margin=unit(c(.1,.1,.1,.1), "cm"))
tg

schols.live <- schols[!is.na(schols$tw_statuses_count),]
schols.live<-schols.live[order(schols.live$tw_statuses_count),]
schols.live$quantile<-nrow(schols.live):1


g <- ggplot(schols.live, aes(quantile, tw_statuses_count))
g + geom_point() 






schols[schols$scholar_id==6771,]
