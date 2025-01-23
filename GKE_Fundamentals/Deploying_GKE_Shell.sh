export my_region=Region
export my_cluster=autopilot-cluster-1

gcloud container clusters create-auto $my_cluster --region $my_region

gcloud container clusters get-credentials $my_cluster --region $my_region

nano ~/.kube/config

kubectl config view

kubectl cluster-info

kubectl config current-context

kubectl config get-contexts

kubectl config use-context gke_${DEVSHELL_PROJECT_ID}_Region_autopilot-cluster-1

source <(kubectl completion bash)

kubectl create deployment --image nginx nginx-1

kubectl get pods

kubectl top nodes

export my_nginx_pod=nginx-1-59c757669d-hhwx5

echo $my_nginx_pod

kubectl describe pod $my_nginx_pod

nano ~/test.html

kubectl cp ~/test.html $my_nginx_pod:/usr/share/nginx/html/test.html

kubectl expose pod $my_nginx_pod --port 80 --type LoadBalancer

kubectl get services

curl http://34.75.205.81/test.html

kubectl top pods

git clone https://github.com/GoogleCloudPlatform/training-data-analyst

ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s

cd ~/ak8s/GKE_Shell/

kubectl apply -f ./new-nginx-pod.yaml

kubectl get pods

kubectl exec -it new-nginx -- /bin/bash

apt-get update
apt-get install nano

cd /usr/share/nginx/html
nano test.html