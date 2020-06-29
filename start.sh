#!/bin/bash -e

usage()
{
cat << EOF
USAGE: `basename $0` [options]
    -k  key pair name (e.g. dpeerlab-chunj)
    -i  instance type(e.g. t2.large)
EOF
}

# US East, Virginia
ami_id="ami-0226a8af83fcecb43"

# default instance type
instance_type="t2.large"

while getopts "k:i:h" OPTION
do
    case $OPTION in
        k) keypair_name=$OPTARG ;;
        i) instance_type=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$keypair_name" ] || [ -z "$instance_type" ]
then
    usage
    exit 1
fi

echo "Launching..."
aws ec2 run-instances \
    --image-id=${ami_id} \
    --count=1 \
    --instance-type=${instance_type} \
    --key-name=${keypair_name} \
    --security-groups=security-group-ssh-http \
    --iam-instance-profile Name=s3-full-access \
    --region us-east-1 \
    --output json | tee my-ec2-rstudio.json

instance_id=`python -c 'import json; fin=open("my-ec2-rstudio.json", "rt"); data=json.load(fin); print(data["Instances"][0]["InstanceId"]); fin.close()'`

echo "Tagging the instance..."
aws ec2 create-tags \
    --resources=${instance_id} \
    --tags Key=Name,Value=RStudio Key=Owner,Value=${keypair_name}

echo "Waiting until the instance is running..."
aws ec2 wait instance-running \
    --instance-ids ${instance_id}

echo "Retrieving public DNS name..."
aws ec2 describe-instances --instance-ids ${instance_id} | tee my-ec2-rstudio.json

public_dns_name=`python -c 'import json; fin=open("my-ec2-rstudio.json", "rt"); data=json.load(fin); print(data["Reservations"][0]["Instances"][0]["PublicDnsName"]); fin.close()'`

echo "Waiting until the instance status becomes OK..."
aws ec2 wait instance-status-ok \
    --instance-ids ${instance_id}

echo "Opening RStudio on your local browser..."
open http://${public_dns_name}:80
echo "DONE."

echo
echo "RStudio URL: http://$public_dns_name:80"
echo "Instance ID: $instance_id"
echo "User Name: rstudio"
