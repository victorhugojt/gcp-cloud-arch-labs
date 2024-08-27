kubectl create quota test-quota \
--hard=count/pods=2,count/services.loadbalancers=1 --namespace=team-a

kubectl run app-server-2 --image=centos --namespace=team-a -- sleep infinity

kubectl run app-server-3 --image=centos --namespace=team-a -- sleep infinity

kubectl describe quota test-quota --namespace=team-a

export KUBE_EDITOR="nano"
kubectl edit quota test-quota --namespace=team-a