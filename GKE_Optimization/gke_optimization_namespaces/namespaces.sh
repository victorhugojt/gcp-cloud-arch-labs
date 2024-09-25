gcloud auth list

gcloud config list project

gsutil -m cp -r gs://spls/gsp766/gke-qwiklab ~

cd ~/gke-qwiklab

export ZONE=placeholder
gcloud config set compute/zone ${ZONE} && gcloud container clusters get-credentials multi-tenant-cluster

kubectl get namespace

kubectl api-resources --namespaced=true

kubectl get services --namespace=kube-system

kubectl create namespace team-a && \
kubectl create namespace team-b

kubectl run app-server --image=centos --namespace=team-a -- sleep infinity && \
kubectl run app-server --image=centos --namespace=team-b -- sleep infinity

kubectl get pods -A

kubectl describe pod app-server --namespace=team-a

kubectl config set-context --current --namespace=team-a

kubectl describe pod app-server