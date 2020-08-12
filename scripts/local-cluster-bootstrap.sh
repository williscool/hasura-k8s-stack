#!/usr/bin/env bash

# TODO: move this to node so is easier check exceptions https://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
# acctyally now that I think about it this is also good test case for pulumi
#  https://www.pulumi.com/docs/guides/adopting/from_kubernetes/#deploying-a-single-kubernetes-yaml-file
# exceptions https://pulumi-community.slack.com/archives/C84L4E3N1/p1592948569327000?thread_ts=1592944538.326900&cid=C84L4E3N1

# Check NOTES.md for inspirations

kubectl apply -f postgres/secret.yaml
mkdir /tmp/k8s-hasura-test
kubectl apply -f postgres/persistvol.yaml # this MUST FINISH before you can go forth https://github.com/kubernetes/kubernetes/issues/44370#issuecomment-528435944
kubectl apply -f postgres/pvc.yaml
kubectl apply -f postgres/deployment-service.yaml

kubectl wait --for=condition=Available --timeout=180s deployments/postgres

kubectl apply -f hasura/secret.yaml
kubectl apply -f hasura/deployment-service.yaml

kubectl apply -f nginx-ingress/cloud-generic.yaml
kubectl apply -f nginx-ingress/mandatory.yaml

# uncomment if you don't like dealing with ssl and having to run service on 80 and 443
#kubectl apply -f hasura/ingress-insecure.yaml
kubectl apply -f hasura/ingress.yaml # NOTE: if you run ssl ingress you must port-forward on 443 also!

# 
# # TODO: move to helmfile
# https://cert-manager.io/docs/installation/kubernetes/#note-helm-v2
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install --create-namespace \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.16.0 \
  --set installCRDs=true

# https://github.com/jetstack/cert-manager/issues/1873#issuecomment-595313837
kubectl wait --for=condition=Available --timeout=180s deployment/cert-manager-webhook -n cert-manager
kubectl apply -f cert-manager/dev-self-signed-cert-and-issuer.yaml

# # create letsencrypt staging and prod issuers
# obvi for prod and staging 
#
# kubectl apply -f cert-manager/le-staging-issuer.yaml
# kubectl apply -f cert-manager/le-prod-issuer.yaml

# https://codelearn.me/2019/01/13/wsl-windows-toast.html
# https://github.com/microsoft/WSL/issues/2466#issuecomment-662184581

if grep -q Microsoft /proc/version; then
 powershell.exe 'New-BurntToastNotification -Text "hasura cluster is Up!" -Sound "Default" -SnoozeAndDismiss'
fi

echo "
commands to run stuff

# http
sudo kubectl -n ingress-nginx port-forward --address localhost,0.0.0.0 service/ingress-nginx 80:80

# ssl
sudo kubectl -n ingress-nginx port-forward --address localhost,0.0.0.0 service/ingress-nginx 443:443

# postgres
kubectl port-forward --address localhost,0.0.0.0 deployment/postgres 5432:5432

"