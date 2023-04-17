#!/bin/bash
LIST=$(ls info/logs | awk '{print $0}')
for i in $LIST
do
	aws s3 cp info/logs/$i s3://info-dsm-backup/logs/$i
done