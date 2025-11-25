dnf module disable redis -y
dnf module enable redis:7 -y

dnf install redis -y 

sed -i "/127.0.0.1/0.0.0.0"

systemctl enable redis 
systemctl start redis 