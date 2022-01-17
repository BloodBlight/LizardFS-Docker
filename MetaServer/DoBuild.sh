#Lets get the current date.
DATE=`date +%Y-%m-%d`
docker pull ubuntu:20.04
docker build -t "bloodblight/lizardfs-metaserver:$DATE" .
