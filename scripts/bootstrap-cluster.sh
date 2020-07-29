#!/usr/bin/env bash

# Check NOTES.md for inspirations

kubectl apply -f postgres/secret.yaml
mkdir /tmp/k8s-hasura-test
kubectl apply -f postgres/persistvol.yaml # this MUST FINISH before you can go forth https://github.com/kubernetes/kubernetes/issues/44370#issuecomment-528435944
kubectl apply -f postgres/pvc.yaml
kubectl apply -f postgres/deployment-service.yaml

kubectl apply -f hasura/secret.yaml
kubectl apply -f hasura/deployment-service.yaml

kubectl apply -f nginx-ingress/cloud-generic.yaml
kubectl apply -f nginx-ingress/mandatory.yaml

kubectl apply -f hasura/ingress-insecure.yaml