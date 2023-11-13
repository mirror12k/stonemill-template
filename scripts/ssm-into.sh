#!/bin/sh
cd "$(dirname "$0")" && cd ..

INSTANCE_NAME=$1

if [ "$INSTANCE_NAME" = "" ]; then
    echo "[!] missing instance name argument!"
    exit
fi

echo "[+] getting instance ip from infrastructure..."
INSTANCE_ID=$(cat "infrastructure/terraform.tfstate" | jq -r ".outputs.${INSTANCE_NAME}_instance_id.value")

echo "[+] logging in to ssm: $INSTANCE_ID"
aws ssm start-session --target "$INSTANCE_ID" --region us-east-1 --document-name AWS-StartInteractiveCommand --parameters command="cd /app && sudo su ubuntu"
