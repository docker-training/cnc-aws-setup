#!/bin/bash

if [ -z "${USER_COUNT}" ]; then
    echo "This deployment script requires the number of student users to generate."
    echo "You can also set this by doing: export USER_COUNT=15"
    echo
    read -p "Number of student users to create: " USER_COUNT
fi
DATE=$(date +%s) 
echo $DATE > lastrun
#prep files

for count in `seq 1 $USER_COUNT`;
do
   echo "student-$count" >> students-$DATE.txt 
   echo "creating user student-$count ....."
   aws iam create-user --user-name student-$count >> log.txt
   aws iam add-user-to-group --user-name student-$count --group-name bootstrapper.cluster-api-provider-aws.kaas.mirantis.com >> log.txt
   echo "# Credentials for student-$count:" >> student-credentials.txt
   aws iam create-access-key --user-name student-$count --output=table >> student-credentials.txt 
done

#print helpful information

echo "You can find helpful info in the following files:"
echo "   List of student users names         : ./students-$DATE.txt"
echo "   Logs from commands                  : ./log.txt"
echo "   Credentials for each student account: ./student-credentials.txt"
echo ""
echo "Be sure to save the student list and the student-credentials somewhere safe. You will need to provide the credentials to your student in class."
echo ""
echo "To delete these users run: ./delete-students.sh"