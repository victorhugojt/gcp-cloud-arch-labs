export ZONE=Zone
export CLUSTER_NAME=Cluster Name
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


gcloud container node-pools list --cluster ${CLUSTER_NAME}

export DEFAULT_POOL_NAME=PUT_HERE
export NEW_POOL_NAME=POOL NAME
export POOL_MACHINE=custom-2-3584

gcloud container node-pools create ${NEW_POOL_NAME} \
    --cluster ${CLUSTER_NAME} \
    --machine-type ${MACHINE} \
    --num-nodes=2

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=${DEFAULT_POOL_NAME} -o=name); do
  kubectl cordon "$node";
done

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=${DEFAULT_POOL_NAME} -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node";
done

gcloud container node-pools delete ${DEFAULT_POOL_NAME} \
    --cluster ${CLUSTER_NAME}

# Task 3. Apply a frontend update
