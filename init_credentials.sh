#---------------------------------------------------------------
#Generates temperory credentials for assumed role and init terraform
#Credentials is valid for 1 hour
#---------------------------------------------------------------


#Setup Temp Credentials------------------------------
## Run dos2unix in case of error als check the .aws/credentials file for junk character

role_arn='arn:aws:iam::xxxxxxxxxxxxx:role/iam-devops-role'
role_session_name='DevOps-session'
profile_name='Tech-challenge'
source_profile='devops-env'     ##Replace default profile with the current name and add secrets keys


temp_role=$(aws sts assume-role \
        --role-arn $role_arn \
        --profile $source_profile \
        --role-session-name $role_session_name)

export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $profile_name
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $profile_name
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $profile_name
aws configure set region ap-southeast-1 --profile $profile_name

set x
echo '-----------------------------'
echo 'Profile created - '$profile_name
echo 'Role assumed    - '$role_arn
echo 'Valid for       -  60 minutes'
echo '-----------------------------'