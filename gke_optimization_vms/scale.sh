gcloud config list project

gcloud container clusters get-credentials hello-demo-cluster --zone "ZONE"

kubectl scale deployment hello-server --replicas=2

gcloud container clusters resize hello-demo-cluster --node-pool my-node-pool \
    --num-nodes 3 --zone "ZONE"

gcloud container node-pools create larger-pool \
  --cluster=hello-demo-cluster \
  --machine-type=e2-standard-2 \
  --num-nodes=1 \
  --zone="ZONE"

Cordon the existing node pool: This operation marks the nodes in the existing node pool (node) as unschedulable. Kubernetes stops scheduling new Pods to these nodes once you mark them as unschedulable.
Drain the existing node pool: This operation evicts the workloads running on the nodes of the existing node pool (node) gracefully.

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=my-node-pool -o=name); do
  kubectl cordon "$node";
done

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=my-node-pool -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node";
done

kubectl get pods -o=wide

# With the pods migrated, it's safe to delete the old node pool:

gcloud container node-pools delete my-node-pool --cluster hello-demo-cluster --zone "ZONE"

# look for binpacking

gcloud container clusters create regional-demo --region=us-east4 --num-nodes=1


cat << EOF > pod-1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  labels:
    security: demo
spec:
  containers:
  - name: container-1
    image: wbitt/network-multitool
EOF


# if you look back at the pod-2.yaml file you created, you can see that Pod Anti Affinity is a defined rule. 
# This enables you to ensure that the pod is not scheduled on the same node as pod-1. This is done by matching an expression based on pod-1’s security: demo label. 
# Pod Affinity is used to ensure pods are scheduled on the same node, while Pod Anti Affinity is used to ensure pods are not scheduled on the same node.

cat << EOF > pod-2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-2
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - demo
        topologyKey: "kubernetes.io/hostname"
  containers:
  - name: container-2
    image: gcr.io/google-samples/node-hello:1.0
EOF


kubectl exec -it pod-1 -- sh


ping 10.116.0.8


sed -i 's/podAntiAffinity/podAffinity/g' pod-2.yaml


ping 10.116.2.4

# https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters