#!/bin/bash
set -e
cd "$(dirname "$0")" && cd ..

ACTION=$1
STAGE="beta" # Default stage

usage() {
    echo "Usage: $0 -deploy [-prod]"
    echo "       $0 -autodeploy [-prod]"
    echo "       $0 -destroy [-prod]"
    echo "Options:"
    echo "       -deploy         Deploy the infrastructure"
    echo "       -autodeploy     Deploy the infrastructure without manual confirmation"
    echo "       -destroy        Destroy the infrastructure"
    echo "       -prod           Set the stage to production"
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -deploy)
            ACTION="deploy"
            shift
            ;;
        -autodeploy)
            ACTION="autodeploy"
            shift
            ;;
        -destroy)
            ACTION="destroy"
            shift
            ;;
        -prod)
            STAGE="prod"
            shift
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$ACTION" ]; then
    echo "Error: No action specified."
    usage
fi

cd infrastructure

echo "[i] running init"
terraform init "-backend-config=config/backend-config.$STAGE.hcl"

case "$ACTION" in
    deploy)
        echo "[i] running deployment!"
        terraform apply -var "stage=${STAGE}"
        ;;
    autodeploy)
        echo "[i] running auto deployment!"
        terraform apply -auto-approve -var "stage=${STAGE}"
        ;;
    destroy)
        echo "[i] running destroy!!!"
        terraform destroy -var "stage=${STAGE}"
        ;;
esac

echo "[i] done!"
