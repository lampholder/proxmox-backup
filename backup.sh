#!/bin/bash
# Backups live at https://console.aws.amazon.com/s3/home?region=eu-west-1#&bucket=backup-pve&prefix=

d=`date +%Y%m%d`
((
set -e
echo "Backup start `date`"
rm -rf /root/backup/$d
mkdir /root/backup/$d
for id in `/usr/sbin/vzlist --all | awk '{print $1}' | tail -n +2`; 
do 
    /usr/bin/vzdump $id -mode snapshot --dumpdir /root/backup/$d --compress gzip
    for file in `ls /root/backup/$d`;
    do
        /usr/local/bin/aws s3 cp /root/backup/$d/$file s3://backup-pve/$d/
        rm /root/backup/$d/$file
    done
done
rm -rf /root/backup/$d
echo "Backup complete `date`"
) 2>&1) | tee /root/backup/backup_$d.log
/usr/local/bin/aws s3 cp /root/backup/backup_$d.log s3://backup-pve/$d/
