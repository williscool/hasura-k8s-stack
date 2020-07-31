kubectl wait --for=condition=Available service/ingress-nginx
kubectl -n ingress-nginx port-forward --address localhost,0.0.0.0 service/ingress-nginx 8080:80 &
wsl-open http://kubernetes.docker.internal:8080/console/