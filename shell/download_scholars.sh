read -p "enter password: " pw
curl https://alm:$pw@alm.cloudant.com/five_uni_twitter/_design/main/_list/csv/scholars > /home/jason/projects/5uni_twitter/scholars/scholars_from_db.csv
