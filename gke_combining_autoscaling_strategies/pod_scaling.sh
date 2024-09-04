gcloud config set compute/zone zone

gcloud container clusters create scaling-demo --num-nodes=3 --enable-vertical-pod-autoscaling


kubectl get deployment

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

kubectl get hpa

gcloud container clusters describe scaling-demo | grep ^verticalPodAutoscaling -A 1

kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0

kubectl get deployment hello-server

kubectl set resources deployment hello-server --requests=cpu=450m

kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"

cat << EOF > hello-vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: hello-server-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       hello-server
  updatePolicy:
    updateMode: "Off"
EOF

kubectl apply -f hello-vpa.yaml

# Off: this policy means VPA will generate recommendations based on historical data which you can manually apply.
# Initial: VPA recommendations will be used to create new pods once and then won't change the pod size after.
# Auto: pods will regularly be deleted and recreated to match the size of the recommendations.


kubectl describe vpa hello-server-vpa

# Lower Bound: this is the lower bound number VPA looks at for triggering a resize. If your pod utilization goes below this, VPA will delete the pod and scale it down.
# Target: this is the value VPA will use when resizing the pod.
# Uncapped Target: if no minimum or maximum capacity is assigned to the VPA, this will be the target utilization for VPA.
# Upper Bound: this is the upper bound number VPA looks at for triggering a resize. If your pod utilization goes above this, VPA will delete the pod and scale it up.

sed -i 's/Off/Auto/g' hello-vpa.yaml

kubectl apply -f hello-vpa.yaml

kubectl scale deployment hello-server --replicas=2

kubectl get pods -w