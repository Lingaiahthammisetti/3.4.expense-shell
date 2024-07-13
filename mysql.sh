#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Script started executing at:$TIMESTAMP"
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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installation of MYSQL Sever"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling of MYSQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting the MYSQL Server"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
VALIDATE $? "Setting up Root Password"

