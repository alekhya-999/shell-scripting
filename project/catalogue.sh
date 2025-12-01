source ./common.sh
app_name=catalouge
hostname="enter privateIP of mongodbvm"

cp mongo.repo /etc/yum.repos.d/mongo.repo

NODEJS


dnf install mongodb-mongosh -y
mongosh --host $hostname </app/db/master-data.js