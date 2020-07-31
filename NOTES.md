# works on kind in docker for win if you are using metallb 
# checkout https://github.com/kubernetes-sigs/kind/issues/702#issuecomment-664569840
# to see how to set that up

# https://severalnines.com/database-blog/using-kubernetes-deploy-postgresql
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

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install --create-namespace \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.16.0 \
  --set installCRDs=true

  # https://github.com/jetstack/cert-manager/issues/1873#issuecomment-595313837
kubectl wait --for=condition=Available deployment/cert-manager-webhook -n cert-manager
kubectl apply -f cert-manager/dev-self-signed-cert-and-issuer.yaml


# create letsencrypt staging and prod issuers
# only do this on non local clusters... if your cluser is on localhost use self signed stuff..
# other wise the cluster stops respoding to kubectl and you have to delete it and restart
# I think cert-manager enters an infinte loop of failing to get certs from letsencrypt
kubectl apply -f cert-manager/le-staging-issuer.yaml
kubectl apply -f cert-manager/le-prod-issuer.yaml


kubectl -n ingress-nginx port-forward --address localhost,0.0.0.0 service/ingress-nginx 8080:80

visit
http://kubernetes.docker.internal/console/

note: I think the redirect url at the root / route is broken if you don't have https setup ... still working on that
solution? just go strait to /console as above


useful commands

```
kubectl get ingress

kubectl get events # super useful for debugging wiernedss with PersistentVolume stuff
```

scratch

sources:

https://hasura.io/docs/1.0/graphql/manual/deployment/kubernetes/updating.html#kubernetes-update
https://stackoverflow.com/questions/59255445/how-can-i-access-nginx-ingress-on-my-local
