export ZONE=Zone

gcloud config set compute/zone ${ZONE}


gcloud container clusters create "Cluster Name" --zone="Zone" --num-nodes=2


kubectl create namespace dev && \
kubectl create namespace prod


git clone https://github.com/GoogleCloudPlatform/microservices-demo.git &&
cd microservices-demo && kubectl apply -f ./release/kubernetes-manifests.yaml --namespace dev


kubectl get service OnlineBoutique


[frontend-externa]:8089


gcloud container node-pools create "Pool Name" \
  --cluster="Cluster Name" \
  --machine-type=custom-2-3584 \
  --num-nodes=2 \
  --zone=${ZONE}

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=my-node-pool -o=name); do
  kubectl cordon "$node";
done

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=my-node-pool -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node";
done

