dir_path=$(pwd)
log_file=/tmp/roboshop.log

STATUS_PRINT(){
    if [ $1 -eq 0 ]; then
       echo success
    else
       echo failure
       exit #exits the script when failure occurs
    fi 
}

SYSTEMD_SETUP(){
    echo copy application service file
    cp $dir_path/$app_name.service /etc/systemd/system/$app_name.service
    echo start application
    systemctl daemon-reload
    systemctl enable $app_name
    systemctl start $app_name
}
APP_PREREQ(){
    echo create application user
    useradd roboshop
    STATUS_PRINT $?   

    echo remove application directory
    rm -rf /app
    echo create application directory
    mkdir /app
    echo download application code
    curl -L -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 
    echo change directory to application dir
    cd /app 
    echo extract application code
    unzip /tmp/$app_name.zip
    cd /app 
    STATUS_PRINT $?
}
NODEJS(){
    echo disable default nodesjs version
    dnf module disable nodejs -y >>$log_file
    #to print whether the command is successful for not, exit status
    STATUS_PRINT $?
    echo enable nodesjs 20 version
    dnf module enable nodejs:20 -y >>$log_file
    STATUS_PRINT $?  
    echo install nodesjs
    dnf install nodejs -y >>$log_file
    STATUS_PRINT $?
    APP_PREREQ
    STATUS_PRINT $?
    echo install nodejs dependencies
    npm install >>$log_file
    STATUS_PRINT $?
    SYSTEMD_SETUP
    STATUS_PRINT $?
}

JAVA(){
    echo install maven
    dnf install maven -y
    APP_PREREQ
    echo build maven code
    mvn clean package 
    mv target/$app_name-1.0.jar $app_name.jar 
    SYSTEMD_SETUP
}

PYTHON(){
    echo install python
    dnf install python3 gcc python3-devel -y
    pip3 install -r requirements.txt
    APP_PREREQ
    SYSTEMD_SETUP
}

GOLANG(){
    dnf install golang -y
    APP_PREREQ
    go mod init dispatch
    go get 
    go build
    SYSTEMD_SETUP
}