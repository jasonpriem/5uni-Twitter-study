read -p "enter password: " pw
curl https://alm:$pw@alm.cloudant.com/five_uni_twitter/_design/main/_list/csv/tweets > /home/jason/projects/5uni-twitter/data/tweets_from_db.csv
