#!/bin/bash
#After initial installation the master is redis-node-0
#Run the benchmark on redis-node-2 so that we can restart the master
wait_for_pods () {
  while : ; do
    c=$(kubectl get pods | grep $1 | grep 2/2 | wc -l)
    if [ $c -eq $2 ]; then break; fi
  done
}

echo "Check if all pods are running"
wait_for_pods "redis" 3

#echo "FLUSH ALL DATA"
#kubectl exec -it redis-node-0 -c redis -- redis-cli FLUSHALL
#sleep 1
echo "Initial keyspace"
kubectl exec -it redis-node-0 -c redis -- redis-cli info keyspace
kubectl exec -it redis-node-1 -c redis -- redis-cli info keyspace
kubectl exec -it redis-node-2 -c redis -- redis-cli info keyspace
sleep 1
#Start filling the master about 1 million keys only using the SET test:
kubectl exec -it redis-node-0 -- redis-benchmark -t set -n 100000 -r 10000000&

echo "Sleeping 5"
sleep 5

echo "Killing the master"
kubectl delete pod redis-node-0

echo "Waiting for benchmark to finish"
wait
kubectl exec -it redis-node-2 -c redis -- redis-cli info keyspace
kubectl exec -it redis-node-1 -c redis -- redis-cli info keyspace
echo "Waiting for the killed pod to come back"
wait_for_pods "redis-node-0" 1
kubectl exec -it redis-node-0 -c redis -- redis-cli info keyspace
