#!/bin/bash
LASTRUN_DATE=$(cat ./lastrun)
echo " This will delete the following users:"
echo $(cat students-$LASTRUN_DATE.txt)
read -p "Continue (y/n)?" choice
case "$choice" in 
  y|Y ) echo "yes";;
  n|N ) echo "no";;
  * ) echo "invalid";;
esac

for student in `cat students-$LASTRUN_DATE.txt`;
do 
   echo "deleting user $student"
   KEYID=$(aws iam list-access-keys --user-name $student | jq '.AccessKeyMetadata[0]["AccessKeyId"]'| tr -d '"')
   aws iam delete-access-key --access-key-id $KEYID --user-name $student 
   aws iam remove-user-from-group --user-name $student --group-name bootstrapper.cluster-api-provider-aws.kaas.mirantis.com >> log.txt
   aws iam delete-user --user-name $student
done