#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_folder = "/var/log/expense-log"
timestamp = $(date +%Y-%m-%d-%H-%M-%S)
log_file =$(echo $0 | cut -d "." -f1 )
log_file_name = "$logs_folder/$logs_file-$timestamp.log"

validate(){
    if [ $1 -ne 0 ]
    then 
        echo "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"

    fi
}

check_root(){
    if [ $USERID -ne 0 ]
    then 
        echo "ERROR :: you must have sudo access to execute this script"
        exit 1
    fi  
}
echo "Script started executing at : $timestamp" &>>$log_file_name

check_root

dnf install mysql-server -y &>>$log_file_name
validate $? "INSTALLING MYSQL SERVER"

systemctl enable mysqld &>>$log_file_name
validate $? "ENABLING MYSQL SERVER"

systemctl start mysqld &>>$log_file_name
validate $? "STARTING MYSQL SERVER"

mysql -h mysql.daws82s.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then 
    echo "MYSQL root password not setup " &>>$log_file_name
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate $? "SETTING ROOT PASSWORD "
else
    echo -e "MySql Root password already setup .... $Y SKIPPING $N"
fi