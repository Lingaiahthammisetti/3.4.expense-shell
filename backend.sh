#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password:"
read -s mysql_root_password

VALIDATE(){
if [ $1 -ne 0 ]
then 
   echo -e "$2...$R FAITURE $N"
   exit 1
else
   echo -e "$2.. $G SUCCESS $N"
fi
}

if [ $USERID -ne 0 ]
then
   echo "Please run this script with root access"
   exit 1
else
   echo "You are super user."

fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling  of default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling  of nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing  nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then 
   useradd expense &>>$LOGFILE
   VALIDATE $? "Creating expense user"
else
   echo -e "Expense user already created..$Y Skipping $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracked backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing  nodjs dependencies"

#cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
cp /root/3.4.expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend  &>>$LOGFILE
VALIDATE $? "starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.lithesh.shop -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "MYSQL Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend Server."

systemctl status backend
VALIDATE $? "backend status"