#!/bin/sh
fileName=DB/$(date "+%Y%m%d")Backup.sql
mysqldump --login-path=mysql.conf info_prod > $fileName
aws s3 cp $fileName s3://info-dsm-backup/$fileName
