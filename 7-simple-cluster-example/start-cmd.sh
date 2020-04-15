#!/bin/bash

NDAP_IP_PORT=$(terraform output | grep "Connect_NDAP_IP_ADDRESS" | awk '{ print $3 }')
PRIVATE_KEY=$(terraform output | grep "Private_key_name" | awk '{ print $3 }')
NDAP_IP=$(basename ${NDAP_IP_PORT} :8080)
echo $NDAP_IP
ssh -i $PRIVATE_KEY root@${NDAP_IP} "hostname"
