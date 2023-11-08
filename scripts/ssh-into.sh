#!/bin/sh
cd "$(dirname "$0")" && cd ..

INSTANCE_NAME=$1

if [ "$INSTANCE_NAME" = "" ]; then
    echo "[!] missing instance name argument!"
    exit
fi

echo "[+] getting instance ip from infrastructure..."
INSTANCE_ID=$(cat "infrastructure/terraform.tfstate" | jq -r ".outputs.${INSTANCE_NAME}_instance_id.value")

echo "INSTANCE_ID: $INSTANCE_ID"
INSTANCE_IP=$(aws ec2 describe-instances --region "us-east-1" \
	--filters "Name=instance-state-name,Values=running" "Name=instance-id,Values=$INSTANCE_ID" \
	--query 'Reservations[*].Instances[*].[PublicIpAddress]' \
	--output text)
echo "INSTANCE_IP: $INSTANCE_IP"

SSH_COMMAND="ssh -i .keys/${INSTANCE_NAME}_key ubuntu@${INSTANCE_IP} -o StrictHostKeyChecking=no"
echo "[+] executing ssh: $SSH_COMMAND"
sh -c "$SSH_COMMAND"
