#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Disabling  Nginx Sever"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling  Nginx Server"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx Server"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing Content"

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating expense user"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html/ &>>$LOGFILE
VALIDATE $? "Removing existing Content"
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracked frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"

