# Process for setting up and destroying AWS resources for the CN211 Class

## Requirements

This process relies on the following dependencies being installed and configured:
- AWS ClI
- [Cloud Nuke]
- bash
- bc

[Cloud Nuke]:https://github.com/gruntwork-io/cloud-nuke

## Prepare the account

Before deploying resources you will need to configure deploy the appropriate IAM resources. 

``` bash
bash prepare.sh 
```

This script will prmpt for the AWS acocunt ID that you are deploying to. This must be the same account as the one that you have your AWS cli configured to use. This scirpt will deploy a cloudformation stack that will create various IAM policies and create an IAM user and group. 

## Deploy student users

Run the belopw script, it will promt you for the number of student users to create: 

``` bash
bash generate-users.sh
```

> Its a good idea to deploy more users than you will need. Generally I will deploy the amount of students, including the instructor + 3.

This scipt will create a set of files that will be needed for the cleanup process. Do not delete them. 

You will find the credentials that you can provide to your students in the student-credentials.txt file. Only provide one set of credentials per student.


## Remove students

Running the below script will cleanup the student users but will not delete any resources they have created. 

``` bash
bash delete-students.sh
```

This will delete the IAM credentials for any user that is listed in the students.txt file that was created during the deploy student phase. 

## Destroy AWS Resources

Best practice is to use an AWS acocunt that is used only for the CN211 class. You can manually delete resources from this account, or you can try the examples below using the `cloud-nuke` script. 

### Destroy AWS resources in all regions:

``` bash
cloud-nuke aws \
   --exclude-resource-type iam \
   --exclude-resource-type iam-role \
   --exclude-resource-type cloudwatch-loggroup \
   --exclude-resource-type cloudwatch-dashboard 
```
If you would like to be sure what resources will be deleted before actually deleting them, run the above command with the `--dry-run` option. If you need to exclude other resource types you can review the documentation for cloud-nuke. 

### Check what resources remain:

``` bash
cloud-nuke inspect-aws
```
