#Get 100 bytes as value
val=$(head -c 100 < /dev/zero | tr '\0' '\141')
#set the redis operation set or del
operation=set
#set N values to Redis master
for a in {1..1000};do
kubectl exec redis-node-0 -c redis -- redis-cli $operation $a $val
#check the keyspace size from a slave
keyspace=$(kubectl exec redis-node-1 -c redis -- redis-cli info keyspace)
size=$(echo $keyspace | awk -F[=,] '{print $2}')
if [ $a -gt $size ]
then
  echo $size
fi
done
