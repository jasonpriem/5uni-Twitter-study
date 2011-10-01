library(ggplot2)
library(gmodels)
library(vcd)
library(gridExtra)
options(width=190)
tb <- theme_blank()
tw <- read.csv("~/projects/5uni-twitter/data/tweets_all_coded.csv", header=T, colClasses=c("character"))
s <- read.csv("~/projects/5uni-twitter/data/scholars_from_db.csv", header=T, colClasses=c("character"))


# format the datasets
tw$code <- factor(tw$code)
tw$scholar_id <- (as.numeric(tw$scholar_id))
tw$last20 <- as.logical(as.numeric(tw$last20))
tw$created_at <- as.POSIXct(tw$created_at, "GMT")

s$scholar_id <- (as.numeric(s$scholar_id))
s$is_redundant <- as.logical(as.numeric(s$is_redundant))
s$superdiscipline[s$superdiscipline=="natural science"]<-"natural_science"
s$twitter_users_count <- as.numeric(s$twitter_users_count)
s$tw_protected <- as.logical(s$tw_protected)
s$tw_statuses_count <- as.numeric(s$tw_statuses_count)
s$tw_created_at <- as.POSIXct(s$tw_created_at, format = "%a %b %d %H:%M:%S +0000 %Y", tz="GMT")
s$rank<-factor(s$rank)
s$superdiscipline <- factor(s$superdiscipline)
levels(s$superdiscipline) <- c("applied/professional", "formal science", "humanities", "natural science", "social science")

# add age/date columns
collection.time <- as.numeric(as.POSIXct("2011-07-28 15:00", "GMT")) # UNIX timestamp when we got the tweets
tw$age <- (collection.time - as.numeric(tw$created_at)) / 86400 # each tweet's age in days
s$tw_age <- (collection.time - as.numeric(s$tw_created_at)) / 86400 # each twitter acct's age in days

# scholars in sample
#########################################################################
# 1a: Forming the sample: removing duplicate names
redund.not <- s[s$is_redundant == 0,]
redund.is <- s[s$is_redundant == 1,]
(nrow(redund.not) + nrow(redund.is)) - nrow(s) # sanity check...shoudl be 0
nrow(redund.is) # discarded:
s <- redund.not
nrow(s) # we were left with this many: 

# breakdown by uni
CrossTable(s$institution)
s.plot <- s
s.plot$institution <- factor( s.plot$institution )
levels(s.plot$institution) <- c("a", "b", "c", "d", "e")
ggplot(s.plot, aes(institution)) + geom_bar() + opts(title="scholars per institution (n=8826)")

# 1b:Forming the sample: removing common names?
common <- s[s$twitter_users_count == 20,]
uncommon <- s[s$twitter_users_count < 20,]
(nrow(common) + nrow(uncommon)) - nrow(s)
nrow(common) # discarded:
s <- uncommon 
nrow(s) # were left with this many:

# 2: Describing the sample:
CrossTable(s$rank, s$superdiscipline, prop.t=F) # see http://intersci.ss.uci.edu/wiki/index.php/R_CrossTab,_gmodels_package for docs
# looks like postdoc isn't that important (and all in nat_sci), we'll roll it into doctoral:

levels(s$rank)
levels(s$rank) <- c("nonfaculty", "faculty", "nonfaculty")
CrossTable(s$rank, s$superdiscipline, prop.t=F)
# visualise the makup of the sample
s.t <- table(s$superdiscipline, s$rank)
mosaicplot(s.t, color=c("pink", "lightblue"), off=c(4, 2), las=3, cex.axis=1)





# Twitter accounts in sample
##########################################################################
sum(s$twitter_users_count) 
# of these 9139 accounts had no descr, url, or location, and 390 were celebrities that were 20 oft-returned celebs
# (src: code/php/couchdb/views/user_search_results.js)
# This left 7648 profiles to check mostly manually (made limited use of timezone as an automated filter)
17177 - (9139 + 390 + 7648) # sanity check, should be 0

s.acct <- s[!is.na(s$tw_screen_name),]
nrow(s.acct) # s from our sample with Twitter accts
nrow(s.acct) / nrow(s) # % s with Twitter accts

# let's look at accounts with no tweets
s.acct.silent <- subset(s.acct, tw_statuses_count==0)
nrow(s.acct.silent) # have Twitter acct but no tw
nrow(s.acct.silent) / nrow(s.acct) # % silent twitter accts
nrow(subset(s.acct.silent, tw_friends_count >= 10)) # silent, but probably is (or was) used for reading

# now protected accounts (a few of these are included in the silent count as well)
s.acct.protected <- subset(s.acct, tw_protected==TRUE)
nrow(s.acct.protected)
table(s.acct.protected$rank)

# remove silent and protected accounts (everyone with no public tw)
s.acct.pub <- subset(s.acct, scholar_id %in% tw$scholar_id)
nrow(s.acct) - nrow(s.acct.pub) # getting rid of this many accts with no public tw
nrow(s.acct.pub) # keeping this many
nrow(s.acct.pub) / nrow(s) # % scholars with a public tweet
sp <- s.acct.pub


# Find "Active" Twitter accounts in sample (have tweeted recently)
##########################################################################


tw.last20only <- subset(tw, last20==TRUE) # removes a bunch of older tweets, saves time
sp$latest_tweet_age <- sapply(sp$scholar_id, function(id) sort(as.vector(tw.last20only[tw.last20only$scholar_id==id,"age"]))[1])

# finds the biggest difference between any two adjacent numbers in a given vector
max.gap <- function(x){
   ret <- 0
   x<-sort(x)
   for (i in 1:(length(x)-1)){
        ret <- max(c(x[i+1] - x[i]), ret)
   }
   return(ret)
}
sp$max_gap<- sapply(sp$scholar_id, function(id) max.gap(tw[tw$scholar_id==id, "age"]))

# take a look at the breakdown for last tweet
breaks.span <- (max(sp$latest_tweet_age) - min(sp$latest_tweet_age)) / 30
hist(sp$latest_tweet_age, breaks=seq(0, max(sp$latest_tweet_age)+breaks.span, by=breaks.span))

# we'll mark "active" users: it's been fewer than g OR d days since their last tweet (where g = user's longest previous interval between tw, and d = 90)
sp.act <- subset(sp, latest_tweet_age < 90 | latest_tweet_age < max_gap)
sp.act.sporadic <- (subset(sp.act, latest_tweet_age >= 90))
sp.abandonded <- subset(sp, !(sp$scholar_id %in% sp.act$scholar_id))

nrow(sp.act) # active accounts
nrow(sp.act)  / nrow(s)
nrow(sp) - nrow(sp.act) # inactive accounts
1 - (nrow(sp.act) / nrow(sp)) # % abandoned accts (tweeted at least once, but now inactive)
act <- sp.act # shortcut name, since we'll be using this active scholar list a lot
s$act <- FALSE
s$act[s$scholar_id %in% act$scholar_id] <- TRUE

# Examine effects of discipline and rank on proportion of active tweeters
##########################################################################

# First, look at discipline
disc.t <- table(s$superdiscipline, s$act)
disc.ct <- CrossTable(disc.t, chisq=TRUE)
disc.t.f <- as.data.frame(disc.ct$prop.col, stringsAsFactors=TRUE)
names(disc.t.f) <- c("discipline", "active", "count")
levels(disc.t.f$active) <- c("Nontweeting\nscholars", "Tweeting\nscholars")
disc.t.f$discipline <- factor(disc.t.f$discipline, levels=levels(disc.t.f$discipline)[c(1,5,2,4,3)])

# is discipline significant?
disc.ct$chisq

# plot % on twitter vs % in sample for discipline
tg <- ggplot(disc.t.f, aes(active, count, fill=discipline))
tg <- tg +  geom_bar(position="fill") + ylab("percent of sample") + theme_bw()
tg <- tg + scale_y_continuous(formatter="percent") + opts(axis.title.x=tb)+ opts(legend.title = tb)
tg <- tg + opts(panel.grid.major=tb)+ opts(panel.grid.minor=tb) + opts(axis.ticks=tb) + opts(panel.border=tb, title="discipinary breakdown\nof tweeting vs. nontweeting scholars")
tg

# second, we'll look at rank
rank.t <- table(s$rank, s$act)
rank.ct <- CrossTable(rank.t, chisq=TRUE)
rank.t.f <- as.data.frame(rank.ct$prop.col, stringsAsFactors=TRUE)
names(rank.t.f) <- c("rank", "active", "count")
levels(rank.t.f$active) <- c("Nontweeting\nscholars", "Tweeting\nscholars")

# plot % on twitter vs % in sample for rank
tg <- ggplot(rank.t.f, aes(active, count, fill=rank))
tg <- tg  +  geom_bar(position="fill") + ylab("percent of sample") + theme_bw()
tg <- tg + scale_y_continuous(formatter="percent") + opts(axis.title.x=tb)+ opts(legend.title = tb)
tg <- tg + opts(panel.grid.major=tb)+ opts(panel.grid.minor=tb) + opts(axis.ticks=tb) + opts(panel.border=tb, title="rank breakdown\nof tweeting vs. nontweeting scholars")
tg

# is rank significant?
rank.ct$chisq

# look at discipline and rank together
act.t <- table(act$superdiscipline, act$rank) / table(s$superdiscipline, s$rank)
act.t
mosaicplot(act.t, color=c("pink", "lightblue"), off=c(4, 2), las=3, cex.axis=1)






# Frequency of scholars' tweeting
##########################################################################
s$tweets_per_day <-  s$tw_statuses_count / s$tw_age
act <- subset(s, act==TRUE)

plot(rev(sort(act$tw_statuses_count)), log="y") # looks like number of tweets is log-normal-distributed; let's check:
act$log_tw_statuses_count <- log(act$tw_statuses_count)
qqnorm(act$log_tw_statuses_count)
qqline(act$log_tw_statuses_count)
shapiro.test(act$log_tw_statuses_count)

model <- lm(act$log_tw_statuses_count ~ act$tw_age + act$superdiscipline + act$rank)
# plot(model)
summary(model)







# massage tweet content codes for analysis
##########################################################################

# simplify the codes (uncoded and non-english tweets are NA), add rank and discipline cols
tw$scholarly <-NA
tw$scholarly[tw$code %in% c("ki","kpp","kpn","l")] <- TRUE
tw$scholarly[tw$code %in% c("ns", "e")] <- FALSE
s.rank_disc <- s[,c("scholar_id", "rank", "superdiscipline")]
tw <- merge(tw, s.rank_disc, all.x=TRUE, by="scholar_id")
tw.last20 <- subset(tw, last20==TRUE) # only tweets that we've coded

# sanity checks
subset(tw.last20, code=="not coded") # make sure all the tweets in the last20 are coded...this should return <0 rows>
s.coded.num <- length(unique(tw.last20$scholar_id))
s.coded.num - nrow(sp) # should be 0 (should be as many scholars coded as scholars with public tweets)

# remove tweets from inactive tweeters
tw.last20.act <- (subset(tw.last20, scholar_id %in% act$scholar_id))
s.inactive.num <- s.coded.num - nrow(act) 
s.inactive.num # throwing out tweets from this many inactive scholars
tw.from.inactive.num <- nrow(tw.last20) - nrow(tw.last20.act) 
tw.from.inactive.num # throwing out this many tweets from inactive scholars
tw.from.inactive.num / nrow(tw.last20) # throwing out this much of the coded sample
t20 <- tw.last20.act # all coded, none from inactive tweeters.


# examine non-english tweets, then remove them
t20.notenglish <- subset(t20, code=="ote")
nrow(t20.notenglish) # count non-english tweets
nrow(t20.notenglish) / nrow(t20) # percent non-english tweets
act$ote_tweets_count <- sapply(act$scholar_id, function(x) nrow(subset(t20.notenglish, scholar_id == x)))

act.ote <- subset(act, ote_tweets_count > 0)
act.ote$tweets_coded_count <- sapply(act.ote$scholar_id, function(x) nrow(subset(t20, scholar_id==x)))
act.ote$prop_ote_tweets <- act.ote$ote_tweets_count / act.ote$tweets_coded_count
act.ote$scholar_id <- factor(act.ote$scholar_id, levels=act.ote$scholar_id[order(act.ote$prop_ote_tweets)])
subset(act.ote, prop_ote_tweets==1)

g <- ggplot(act.ote, aes(factor(scholar_id), prop_ote_tweets)) + geom_bar(size=.2) + scale_y_continuous(formatter="percent", breaks=c(0, .5, 1))
g + opts(axis.ticks=tb, axis.title.y=tb, axis.text.x=tb, axis.title.x=tb, title="% non-english tweets per scholar", panel.grid.minor=tb)

t20.eng <- subset(t20, code != "ote")
nrow(t20.eng) # english tweets from active tweeters
length(unique(t20.eng$scholar_id)) # active twitter users with at least one english tweet
t20 <- t20.eng

# relevel 
t20$code <- factor(t20$code)
levels(t20$code) <- c("scholars' experience", "is knowledge", "knowledge pointer (not reviewed)", "knowledge pointer (peer reviewed)", "logistic", "not scholarly")
t20$code <- factor(t20$code, levels=levels(t20$code)[order(table(t20$code))])





# analyze tweet content
##########################################################################

# examine category breakdowns for the whole sample, then by rank, superdiscipline
t20$all<-TRUE
CrossTable(table(t20$code, t20$all))
CrossTable(table(t20$scholarly, t20$all))
ggplot(t20, aes(code, ..count../sum(..count..))) + geom_bar() + coord_flip() + opts(axis.ticks=tb)+ scale_y_continuous(formatter="percent", breaks=c(.3, .6))+ opts( title="Tweet categories, by % of total tweets", axis.title.y=tb, axis.title.x=tb)

df <- NULL
fakerow <- NULL
df <- as.data.frame(CrossTable(table(t20$code, t20$superdiscipline)))
df$label <- round(df$prop.col.Freq*100)
df$t.Var1 <- factor(df$t.Var1, levels=c(levels(df$t.Var1), ""))
levels(df$t.Var2) <- c("apl/prof", "fml sci", "hum", "nat sci", "soc sci")
fakerow <- df[1,]
fakerow$t.Var1[1] <- ""
fakerow$label[1] <- ""
fakerow$prop.col.Freq[1] <- 0
fakerow
df <- rbind(fakerow, df)
ggplot(df, aes(factor(t.Var2), factor(t.Var1), size=prop.col.Freq)) + geom_point(pch=20, colour="#dddddd") + geom_text(aes(label=label, size=.01)) + scale_area(to=c(1,30)) + opts(panel.background=tb, axis.ticks=tb,legend.position="none", axis.title.x=tb, axis.title.y=tb)

df <- NULL
fakerow <- NULL
df <- as.data.frame(CrossTable(table(t20$code, t20$rank)))
df$label <- round(df$prop.col.Freq*100)
df$t.Var1 <- factor(df$t.Var1, levels=c(levels(df$t.Var1), ""))
fakerow <- df[1,]
fakerow$t.Var1[1] <- ""
fakerow$label[1] <- ""
fakerow$prop.col.Freq[1] <- 0
df <- rbind(fakerow, df)
ggplot(df, aes(factor(t.Var2), factor(t.Var1), size=prop.col.Freq)) + geom_point(pch=20, colour="#dddddd") + geom_text(aes(label=label, size=.01)) + scale_area(to=c(1,30)) + opts(panel.background=tb, axis.ticks=tb,legend.position="none", axis.title.x=tb, axis.title.y=tb)


# figure out the number and percent of scholarly tweets for each scholar in the active, english-tweeting coded tweets sample
act.t20 <- subset(act, scholar_id %in% t20$scholar_id)
t20[is.na(t20$scholarly),] # shouldn't be any NA's, because all uncoded and ote tweets are gone

act.t20$count<-sapply(act.t20$scholar_id, function(x) nrow(subset(t20, scholar_id==x)))
act.t20$scholarly_count<-sapply(act.t20$scholar_id, function(x) nrow(subset(t20, scholarly==TRUE & scholar_id==x)))
act.t20$scholarly_count_log <- log(act.t20$scholarly_count+1)
act.t20$scholarly_perc <- act.t20$scholarly_count / act.t20$count
act.t20$scholar_id <- factor(act.t20$scholar_id, levels=act.t20$scholar_id[order(act.t20$scholarly_perc)]) # order scholars by %scholarly tweets


# There are more zeros for scholarly tweets than there should be, so the log transform doesn't work. Why is that?
hist((act.t20$scholarly_count_log))
shapiro.test(act.t20$scholarly_count_log)

act.t20$has20 <- FALSE
act.t20$has20[act.t20$count == 20] <- TRUE
act.t20$has_schol_tweets <- FALSE
act.t20$has_schol_tweets[act.t20$scholarly_count > 0] <- TRUE
ggplot(act.t20, aes(has_schol_tweets, tw_age)) + geom_jitter(aes(colour=rank, shape=has20)) + scale_shape_manual(value=c(1, 16))
round(prop.table(table(act.t20$has_schol_tweets, act.t20$institution), 2)*100)
round(prop.table(table(act.t20$has_schol_tweets, act.t20$superdiscipline), 2)*100)
round(prop.table(table(act.t20$has_schol_tweets, act.t20$rank), 2)*100) # looks like this is the culprit...

ggplot(act.t20, aes(scholarly_count_log)) + geom_density() + facet_grid(.~rank) # yep, the extra zeroes in nonfaculty are making the distribution wierd.

 
 

# What factors predict number of scholarly tweets?
ggplot(act.t20, aes(superdiscipline, scholarly_perc)) + geom_boxplot(outlier.shape=NA) + coord_flip() + geom_jitter(pch=20, alpha=.2) + opts(axis.ticks=tb, panel.grid.major=tb, panel.grid.minor=tb, axis.title.y=tb ) + scale_y_continuous(formatter="percent")
ggplot(act.t20, aes(rank, scholarly_perc)) + geom_boxplot(outlier.shape=NA) + coord_flip() + geom_jitter(pch=20, alpha=.2) + opts(axis.ticks=tb, panel.grid.major=tb, panel.grid.minor=tb, axis.title.y=tb ) + scale_y_continuous(formatter="percent")

model <- lm(act.t20$scholarly_count ~ act.t20$count + act.t20$rank + act.t20$superdiscipline)
summary(model)






# visualise each user's twitter stream
##########################################################################

# order scholar_id factor by acct age
tw$scholar_id <- factor(tw$scholar_id)
tw.levels <- levels(tw$scholar_id)
ages <- sapply(tw.levels, function(x) sp[sp$scholar_id == x, "tw_age"])
levels_by_age <- tw.levels[rev(order(ages))]
tw$scholar_id <- factor(tw$scholar_id, levels = levels_by_age)

tw$acct_age_order <- tw$scholar_id
levels(tw$acct_age_order) <- 1:length(levels(tw$acct_age_order))


# add some cols:
tw$created_at <- as.POSIXct(tw$created_at, format = "%a %b %d %H:%M:%S +0000 %Y", tz="GMT")
collection.time <- as.POSIXct("2011-07-28 15:00", "GMT")
nrows <- length(levels(tw$scholar_id))


# plot
tl <- ggplot(tw, aes(created_at, acct_age_order)) + geom_point(alpha=.3, size=.5, shape=20, aes(colour=rank)) + scale_x_datetime(major="1 year") + scale_y_discrete("Twitter accounts", breaks=seq(0, nrows, by=20)) + opts(panel.background = tb, panel.grid.major=theme_line(size=.1, colour="#cccccc"), panel.grid.minor=tb, panel.border=tb, axis.ticks=tb, axis.title.x=tb, plot.margin=unit(c(.1,.1,.1,.1), "cm"),legend.position="none")

# plot percent scholarly for each account
# make a column for percent scholarly tweets for all scholars with public tweets
sp$scholarly_perc <- sapply(sp$scholar_id, function(x) nrow(subset(tw.last20, scholar_id==x & scholarly==TRUE)) / nrow(subset(tw.last20, scholar_id==x & !is.na(scholarly))))
sp$scholarly_perc[is.na(sp$scholarly_perc)] <- 0
sp$scholar_id <- factor(sp$scholar_id, levels = levels_by_age)
spp <- ggplot(sp, aes(scholar_id, scholarly_perc)) + geom_bar(width=1, aes(fill=rank)) + coord_flip() + scale_x_discrete(breaks=NA) + scale_y_continuous(breaks=c(0,1), formatter="percent") + opts(panel.background = tb, panel.grid.major=theme_line(size=.1, colour="#cccccc"), panel.grid.minor=tb, panel.border=tb, axis.text.y=tb, axis.ticks=tb, axis.title.y=tb, axis.title.x=tb, plot.margin=unit(c(.1,.1,.1,.1), "cm"),legend.position="none")

grid.arrange(tl, spp, ncol=2, widths=c(94,6))






# Describe use of Twitter features
##########################################################################
rt.regex <- "\\bRT @\\w|\\bvia @\\w"
atreply.regex <- "^@\\w"
link.regex <- "http://"

tw$is_rt <- FALSE
tw$is_atreply <- FALSE
tw$has_link <- FALSE

tw$is_rt[grep(rt.regex, tw$text, perl=TRUE)] <- TRUE
tw$is_atreply[grep(atreply.regex, tw$text, perl=TRUE)] <- TRUE
tw$has_link[grep(link.regex, tw$text, perl=TRUE)] <- TRUE

# proportion RTs, @replies, and tweets with links, by scholar
hist(tapply(as.numeric(tw$is_rt), tw$scholar_id, mean))
hist(tapply(as.numeric(tw$is_atreply), tw$scholar_id, mean))
hist(tapply(as.numeric(tw$has_link), tw$scholar_id, mean))


# make list of tweets by active scholars with >= 1 scholarly tweet
temp <- subset(act.t20, scholarly_count > 0)
length(temp$scholar_id)
tw.personae <- subset(t20, scholar_id %in% temp$scholar_id, select=c("scholar_id", "rank", "dept", "text", "code" ))
levels(tw.personae$code) <- c("e", "ki", "kpn", "kpp", "l", "ns")
write.csv(tw.personae, "/home/jason/projects/5uni_twitter/tweets/personae.csv", row.names=F)






