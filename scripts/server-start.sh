kubectl wait --for=condition=Available service/ingress-nginx
hasura console --endpoint https://kubernetes.docker.internal/ --insecure-skip-tls-verify --admin-secret "accessKey"
kubectl -n ingress-nginx port-forward --address localhost,0.0.0.0 service/ingress-nginx 443:443 &
kubectl -n ingress-nginx port-forward --address localhost,0.0.0.0 service/ingress-nginx 80:80 &
wsl-open http://kubernetes.docker.internal:8080/console/