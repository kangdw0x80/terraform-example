#!/bin/bash

NODE_IP_PORT=$(terraform output | grep "Connect_NODE_IP_ADDRESS" | awk '{ print $3 }')
PRIVATE_KEY=$(terraform output | grep "Private_key_name" | awk '{ print $3 }')
NODE_IP=$(basename ${NODE_IP_PORT} :8080)
echo $NODE_IP
ssh -i $PRIVATE_KEY root@${NODE_IP} "hostname"
