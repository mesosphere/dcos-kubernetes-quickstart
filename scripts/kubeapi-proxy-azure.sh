#!/bin/bash

# Add access for kubeapi via 6443 port

# Update main.tf file
cat ../resources/main-k8s-api.tf.azure >> ../.deploy/main.tf
