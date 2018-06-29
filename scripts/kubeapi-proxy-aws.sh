#!/bin/bash

# Add access for kubeapi via 6443 port

#
unamestr=`uname`
if [[ "$unamestr" == "Linux" ]]
then
  SED='sed -i'
else
  SED='sed -i ""'
fi

# Update main.tf file
${SED} -i "" '/http-https-security-group/!{p;d;};n;n;r ../resources/main-k8s-api.tf.aws' ../.deploy/main.tf
