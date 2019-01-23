#!/bin/bash

echo " "
echo "Waiting for AWS CSI driver to be ready..."

while true;
do 
    DESIRED_NODE_PODS="$(kubectl get ds -n kube-system ebs-csi-node -o jsonpath='{.status.desiredNumberScheduled}')"
    READY_NODE_PODS="$(kubectl get ds -n kube-system ebs-csi-node -o jsonpath='{.status.numberReady}')" 
    if [ $DESIRED_NODE_PODS = $READY_NODE_PODS ] ; then
        break
    fi
    echo "Waiting for DaemonSet 'ebs-csi-node' to be ready, desired: $DESIRED_NODE_PODS, got $READY_NODE_PODS..."
    sleep 5
done

while true;
do
    READY_CONTROLLER_PODS="$(kubectl get statefulset -n kube-system ebs-csi-controller -o jsonpath='{.status.readyReplicas}')"
    if [ "$READY_CONTROLLER_PODS" = "1" ] ; then
        break
    fi
    echo "Waiting for StatefulSet 'ebs-csi-controller' to be ready..."
    sleep 5
done