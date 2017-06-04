#!/bin/bash

root_folder_path=$1;
log_file_path=$2;

today_name=$(date +'%Y-%m-%d');
yesterday_name=$(date --date="-1 day" +'%Y-%m-%d');
log_file_name="${yesterday_name//-/}_weblog.log";
current_log_folder=$root_folder_path/logs/$yesterday_name

echo "root folder path : $root_folder_path"
echo "day folder name : $yesterday_name"

#dün için bir folder ekliyoruz
mkdir -p "$current_log_folder"

#parametre olarak geçilen log dosyasını yeni oluşturduğumuz klasöre kopyalıyoruz
mv $log_file_path $current_log_folder/$log_file_name

echo "" > /weblog/weblog.log
chown syslog:syslog /weblog/weblog.log
/sbin/service rsyslog restart
echo "Completed /sbin/service rsyslog restart"

#domaine ait logların olduğu dosyanın zaman damgasını servise gönderiyoruz
echo "Starting time locked....."
java -jar $root_folder_path/scripts/ZamaneConsole-2.0.5.jar -z $current_log_folder/$log_file_name http://zd.kamusm.gov.tr 80 XXXX YYYY sha-256
#touch "$current_log_folder/$log_file_name.zd"
echo "Completed time locked"

#log dosyasını ve zaman damgasını zipliyoruz
echo "Zip starting....."
zip -r -j $current_log_folder.zip $current_log_folder/*
rm -r $current_log_folder
echo "Zip completed"

azure_storage_connection_string='..........';
container_name='netscaler'

echo "Creating container : $container_name ..........."
    az storage container create -n $container_name --connection-string $azure_storage_connection_string
echo "Created container : $container_name"

find $root_folder_path/logs -name "*.zip" | while read fname; do
    filePath=${fname#${root_folder_path}}
    echo "File name : $fname"
    echo "Uploading file : $filePath .........."
    az storage blob upload -f $fname -c $container_name -n  "$(date +'%Y')/$(basename $fname)" --connection-string $azure_storage_connection_string
    mv $root_folder_path/logs/${yesterday_name}.zip /weblog/backup
    echo "Uploaded file : $filePath"
done;


#slack e notification gönderiyoruz
echo "Started slack notification"
zip_file_size_gb=`du -h "$root_folder_path/logs/current_log_folder.zip" | cut -f1`
remain_zd_credit=`java -jar $root_folder_path/scripts/ZamaneConsole-2.0.5.jar -k http://zd.kamusm.gov.tr 80 XXXX YYYY`
json="{\"channel\": \"#azure\",\"username\": \"Citrix Log\", \"text\": \"$yesterday_name gününe ait logun ziplenmiş boyutu :$zip_file_size_gb \n kalan kredi : $remain_zd_credit\"}"
curl -s -d "payload=$json" https://hooks.slack.com/services/XXXXYYYYY
echo "Sended slack notification"