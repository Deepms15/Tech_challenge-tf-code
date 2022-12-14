#Init terraform------------------------------
bucket="terraform-backend-s3bucket-name-newly-created-for-statefiles"
key="fabric/terraform.tfstate" ## change the key fabric folder based on the resources
region="ap-southeast-1"
profile_name='Tech-challenge'


# initialize the backend variable
terraform init \
        -backend-config="bucket=$bucket" \
        -backend-config="key=$key" \
        -backend-config="region=$region" \
        -backend-config="profile=$profile_name" \
        -reconfigure