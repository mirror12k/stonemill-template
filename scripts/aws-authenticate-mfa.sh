#!/bin/bash
set -e

if [[ -z $(aws configure get aws_access_key_id) ]]; then
	if [[ -e .aws.credentials ]]; then
		echo "configuring aws credentials from .aws.credentials..."
		AWS_ACCESS_KEY_ID=$(cat .aws.credentials | grep -Po "(?<=^AWS_ACCESS_KEY_ID=)([^\n]+)")
		AWS_SECRET_ACCESS_KEY=$(cat .aws.credentials | grep -Po "(?<=^AWS_SECRET_ACCESS_KEY=)([^\n]+)")

		aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
		aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
	else
		echo "no .aws.credentials file found. skipping configuration..."
		exit
	fi
fi

AWS_USERNAME=$(aws sts get-caller-identity | jq -r '.Arn | split("/")[1]')
AWS_MFA_DEVICE_ARN=$(aws iam list-mfa-devices --user-name "$AWS_USERNAME" | jq -r '.MFADevices[0].SerialNumber')

if [[ "$AWS_MFA_DEVICE_ARN" != "null" ]]; then
	echo -n "please enter your mfa token for device $AWS_MFA_DEVICE_ARN: "

	MFA_TOKEN=""
	while IFS= read -r -s -n 1 c; do
	    if [[ $c == $'\0' ]]; then
	        break
	    fi
	    MFA_TOKEN="${MFA_TOKEN}$c"
	    echo -n "*"
	done
	echo

	AWS_CREDS=$(aws sts get-session-token --serial-number "$AWS_MFA_DEVICE_ARN" --token-code "$MFA_TOKEN" --duration-seconds 7200)
	# echo "creds: $AWS_CREDS"
	AWS_ACCESS_KEY_ID=$(echo "$AWS_CREDS" | jq -r ".Credentials.AccessKeyId")
	AWS_SECRET_ACCESS_KEY=$(echo "$AWS_CREDS" | jq -r ".Credentials.SecretAccessKey")
	AWS_SESSION_TOKEN=$(echo "$AWS_CREDS" | jq -r ".Credentials.SessionToken")
	echo "aws configured with id: $AWS_ACCESS_KEY_ID"
	aws configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}"
	aws configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}"
	aws configure set aws_session_token "${AWS_SESSION_TOKEN}"

	exit
else
	echo "no mfa device found, aws configured with fixed id: $AWS_ACCESS_KEY_ID"
	exit
fi

