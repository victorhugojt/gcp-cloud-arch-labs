gcloud config set compute/zone zone

gcloud container clusters create scaling-demo --num-nodes=3 --enable-vertical-pod-autoscaling