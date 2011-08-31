read -p "enter password: " pw
curl https://alm:$pw@alm.cloudant.com/five_uni_twitter/_all_docs?include_docs=true > /home/jason/projects/5uni-twitter/bak/db.bak
