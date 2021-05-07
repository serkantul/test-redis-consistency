helm repo add bitnami https://charts.bitnami.com/bitnami

kubectl delete pvc redis-data-redis-node-0
kubectl delete pvc redis-data-redis-node-1
kubectl delete pvc redis-data-redis-node-2
kubectl delete pv redis-data-redis-node-0
kubectl delete pv redis-data-redis-node-1
kubectl delete pv redis-data-redis-node-2
sleep 5
kubectl apply -f pv/pv0.yaml
kubectl apply -f pv/pv1.yaml
kubectl apply -f pv/pv2.yaml

helm upgrade --install redis bitnami/redis \
  --set auth.enabled=false,volumePermissions.enabled=true,networkPolicy.enabled=false \
  --set replica.replicaCount=3,sentinel.enabled=true,sentinel.usePassword=false \
  --set sentinel.masterSet=sebaRedis \
  -f values.yaml --version 14.1.0
