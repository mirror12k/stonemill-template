#!/bin/bash
set -e
cd "$(dirname "$0")" && cd ..

INSTANCE_ID=$(cat "infrastructure/terraform.tfstate" | jq -r ".outputs.instance_id.value")
echo "INSTANCE_ID: $INSTANCE_ID"

ACTION=$1
if [[ "$ACTION" == "stop" ]]; then
	echo "[i] running stop..."
	aws ec2 stop-instances --region us-east-1 --instance-ids "$INSTANCE_ID"
elif [[ "$ACTION" == "start" ]]; then
	echo "[i] running start"
	aws ec2 start-instances --region us-east-1 --instance-ids "$INSTANCE_ID"
fi

echo "[i] done!"



