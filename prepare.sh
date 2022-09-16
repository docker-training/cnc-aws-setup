#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
# get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "using account: $ACCOUNT_ID" 

if [ -z "${USER_COUNT}" ]; then
    echo "This deployment script requires the number of student users you plan to use so it can make quota suggestions."
    echo "You can also set this by doing: export USER_COUNT=15"
    echo
    read -p "Number of student users you plan to use: " USER_COUNT
fi

# update cloudformation template with account ID\
cp -a ./templates/cf.yaml .
sed -i 's/REPLACEME/'"$ACCOUNT_ID"'/g' cf.yaml

#deploy cloudformation that creates IAM policies and creates student users. 
if (aws cloudformation describe-stacks --stack-name mcc-bootstrap-stack > /dev/null 2>&1)
then
 echo "required cloudformation stack exists. Good. Moving on...."
else
   aws cloudformation deploy \
    --stack-name mcc-bootstrap-stack \
    --template-file cf.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
fi

# Check how many users can be supported by this account by looking at the quotas for us-east-1. 
#echo "Checking service quotas"
EC2Q=$(aws service-quotas get-service-quota --service-code ec2 --quota-code L-34B43A08 | grep  "Value" | awk '{ print $2 }' | tr -d ,)
#echo "Your EC2 quota is: $EC2Q"
if [[ $(echo "$EC2Q/$USER_COUNT" | bc) -ge 50 ]]
then  
   echo "Your EC2 quota is good."
   echo ""
else
   echo -e "${RED}Your EC2 quota is too low to support that many students.${NC} You must raise your service quota for ec2 service with the quota code L-34B43A08"
   echo "This quota must be atleast: " $(echo "$USER_COUNT*50" | bc)
   echo "aws service-quotas request-service-quota-increase --service-code ec2 --quota-code L-34B43A08 --desired-value" $(($USER_COUNT*50))
   echo " "
fi

ELBQ=$(aws service-quotas get-service-quota --service-code elasticloadbalancing --quota-code L-E9E9831D | grep  "Value" | awk '{ print $2 }' | tr -d ,)
#echo "Your Classic ELB quota is: $ELBQ"
if [[ $(echo "$ELBQ/$USER_COUNT" | bc) -ge 13 ]]
then  
   echo "Your ELB quota is good."
   echo ""
else
   echo -e "${RED}Your ELB quota is too low to support that many students.${NC} You must raise your service quota for elasticloadbalancing service with the quota code L-E9E9831D"
   echo "This quota must be atleast: " $(echo "$USER_COUNT*13" | bc)
   echo "aws service-quotas request-service-quota-increase  --service-code elasticloadbalancing --quota-code L-E9E9831D --desired-value" $(($USER_COUNT*13))
   echo " "
fi

ELB2Q=$(aws service-quotas get-service-quota --service-code elasticloadbalancing --quota-code L-69A177A2 | grep  "Value" | awk '{ print $2 }' | tr -d ,)
#echo "Your Network ELB quota is: $ELB2Q"
if [[ $(echo "$ELB2Q/$USER_COUNT" | bc) -ge 2 ]]
then  
   echo "Your ELBv2 quota is good."
   echo ""
else
   echo -e "${RED}Your ELB quota is too low to support that many students.${NC} You must raise your service quota for elasticloadbalancing service with the quota code L-69A177A2"
   echo "This quota must be atleast: " $(($USER_COUNT*2))
   echo "aws service-quotas request-service-quota-increase --service-code elasticloadbalancing --quota-code L-69A177A2 --desired-value" $(($USER_COUNT*2))
   echo " "
fi

EBSQ=$(aws service-quotas get-service-quota --service-code ebs --quota-code L-D18FCD1D | grep  "Value" | awk '{ print $2 }' | tr -d ,)
#echo "Your EBS quota is: $EBSQ"
if [[ $(echo "$EBSQ/$USER_COUNT" | bc ) -ge 2 ]]
then  
   echo "Your EBS quota is good."
   echo ""
else
   echo -e "${RED}Your EBS quota is too low to support that many students.${NC} You must raise your service quota for ebs service with the quota code L-D18FCD1D"
   echo "This quota must be atleast: " $(($USER_COUNT*2))
   echo "Use this command to request the increase: "
   echo "aws service-quotas request-service-quota-increase --service-code ebs --quota-code L-D18FCD1D --desired-value" $(($USER_COUNT*2))
   echo " "
fi

VPCQ=$(aws service-quotas get-service-quota --service-code vpc --quota-code L-F678F1CE | grep  "Value" | awk '{ print $2 }' | tr -d ,)
#echo "Your VPC quota is: $VPCQ"
if [[ $(echo "$VPCQ/$USER_COUNT" | bc) -ge 1 ]]
then  
   echo "Your VPC quota is good."
   echo ""
else
   echo -e "${RED}Your ELB quota is too low to support that many students.${NC} You must raise your service quota for vpc service with the quota code L-F678F1CE"
   echo "This quota must be atleast: " $(($USER_COUNT*1))
   echo "Use this command to request the increase: "
   echo "aws service-quotas request-service-quota-increase --service-code vpc --quota-code L-F678F1CE --desired-value" $(($USER_COUNT*1))
   echo " "
fi

EIPQ=$(aws service-quotas get-service-quota --service-code ec2 --quota-code L-0263D0A3 | grep  "Value" | awk '{ print $2 }' | tr -d ,)
#echo "Your VPC quota is: $EIPQ"
if [[ $(echo "$EIPQ/$USER_COUNT" | bc ) -ge 1 ]]
then  
   echo "Your EIP quota is good."
   echo ""
else
   echo -e "${RED} Your EIP quota is too low to support that many students.${NC} You must raise your service quota for ec2 service with the quota code L-0263D0A3"
   echo "This quota must be atleast: " $(($USER_COUNT*1))
   echo "Use this command to request the increase: "
   echo "aws service-quotas request-service-quota-increase --service-code ec2 --quota-code L-0263D0A3 --desired-value" $(($USER_COUNT*1))
   echo " "
fi

NATGQ=$(aws service-quotas get-service-quota --service-code vpc --quota-code L-FE5A380F | grep  "Value" | awk '{ print $2 }' | tr -d ,)
#echo "Your VPC quota is: $NATGQ"
if [[ $(echo "$NATGQ/$USER_COUNT" | bc) -ge 2 ]]
then  
   echo "Your NAT Gateway per AZ quota is good."
   echo ""
else
   echo -e "${RED}Your NAT Gateway per AZ quota is too low to support that many students.${NC} You must raise your service quota for vpc service with the quota code L-FE5A380F"
   echo "This quota must be atleast: " $(($USER_COUNT*2))
   echo "Use this command to request the increase: "
   echo "aws service-quotas request-service-quota-increase --service-code vpc --quota-code L-FE5A380F --desired-value" $(($USER_COUNT*1))
   echo " "
fi
