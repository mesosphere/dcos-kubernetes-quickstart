#!/bin/bash

API_NAME=$1
API_IP=$2
API_PORT=$3

echo " "
echo "Waiting for ${API_NAME} to be ready..."
if [[ "${API_NAME}" = "Kubernetes API" ]]
then
  until curl -o /dev/null -skIf -w "%{http_code}" https://${API_IP}:${API_PORT} | grep -w "401\|403" >/dev/null 2>&1; do sleep 1; done
else
  until curl -o /dev/null -skIf https://${API_IP}:${API_PORT}; do sleep 1; done
fi
echo
