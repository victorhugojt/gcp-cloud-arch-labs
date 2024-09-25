export ZONE=us-east4-c
export CLUSTER_NAME=onlineboutique-cluster-388
export CHANNEL=rapid
export MACHINE=e2-standard-2


gcloud container clusters create ${CLUSTER_NAME} \
    --release-channel ${CHANNEL} \
    --zone ${ZONE} \
    --machine-type ${MACHINE} \
    --num-nodes=2


gcloud config set container/cluster ${CLUSTER_NAME}


kubectl create namespace dev && \
kubectl create namespace prod


git clone https://github.com/GoogleCloudPlatform/microservices-demo.git &&
cd microservices-demo && kubectl apply -f ./release/kubernetes-manifests.yaml --namespace dev


kubectl get service OnlineBoutique

kubectl get ingress OnlineBoutique


WEb --> [frontend-externa]


gcloud container node-pools list --cluster ${CLUSTER_NAME} --zone ${ZONE}

export DEFAULT_POOL_NAME=default-pool
export NEW_POOL_NAME=optimized-pool-5642
export POOL_MACHINE=custom-2-3584

gcloud container node-pools create ${NEW_POOL_NAME} \
    --cluster ${CLUSTER_NAME} \
    --machine-type ${POOL_MACHINE} \
    --num-nodes=2 \
    --zone ${ZONE}

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=${DEFAULT_POOL_NAME} -o=name); do
  kubectl cordon "$node";
done

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=${DEFAULT_POOL_NAME} -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node";
done

gcloud container node-pools delete ${DEFAULT_POOL_NAME} \
    --cluster ${CLUSTER_NAME} \
    --zone ${ZONE}

# Task 3. Apply a frontend update


kubectl get pods -A

kubectl describe deployment frontend-7dcd79f498-sj5lj | grep ^Replicas

kubectl create poddisruptionbudget onlineboutique-frontend-pdb --selector run=frontend --min-available 1

kubectl create poddisruptionbudget gb-pdb --selector run=gb-frontend --min-available 4

cd microservices-demo
cat ./release/kubernetes-manifests.yam

vi ./release/kubernetes-manifests.yam
# gcr.io/qwiklabs-resources/onlineboutique-frontend:v2.1
# ImagePullPolicy to Always
kubectl apply -f ./release/kubernetes-manifests.yaml --namespace dev


kubectl autoscale deployment frontend --cpu-percent=50 --min=1 --max=5


kubectl get deployment

kubectl autoscale deployment frontend --cpu-percent=50 --min=1 --max=6

kubectl get hpa

gcloud beta container clusters update ${CLUSTER_NAME} --enable-autoscaling --min-nodes 1 --max-nodes 6  --zone ${ZONE}

kubectl autoscale deployment frontend --cpu-percent=50 --min=1 --max=13



kubectl exec $(kubectl get pod --namespace=dev | grep 'loadgenerator' | cut -f1 -d ' ') -it --namespace=dev -- bash -c 'export USERS=8000; locust --host="http://34.86.196.121" --headless -u "8000" 2>&1'