gcloud config set compute/zone us-central1-a

gcloud container clusters create scaling-demo --num-nodes=3 --enable-vertical-pod-autoscaling

cat << EOF > php-apache.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 3
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
EOF

kubectl get deployment

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

kubectl get hpa

#VPA

gcloud container clusters update scaling-demo --enable-vertical-pod-autoscaling

gcloud container clusters describe scaling-demo | grep ^verticalPodAutoscaling -A 1

kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0

kubectl get deployment hello-server

kubectl set resources deployment hello-server --requests=cpu=450m

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

# Off: this policy means VPA will generate recommendations based on historical data which you can manually apply.
# Initial: VPA recommendations will be used to create new pods once and then won't change the pod size after.
# Auto: pods will regularly be deleted and recreated to match the size of the recommendations.

kubectl describe vpa hello-server-vpa

# Locate the "Container Recommendations" at the end of the output. If you don't see it, wait a little longer and try the previous command again. When it appears, you'll see several different recommendation types, each with values for CPU and memory:

#  Lower Bound: this is the lower bound number VPA looks at for triggering a resize. If your pod utilization goes below this, VPA will delete the pod and scale it down.
# Target: this is the value VPA will use when resizing the pod.
# Uncapped Target: if no minimum or maximum capacity is assigned to the VPA, this will be the target utilization for VPA.
# Upper Bound: this is the upper bound number VPA looks at for triggering a resize. If your pod utilization goes above this, VPA will delete the pod and scale it up.

kubectl apply -f hello-vpa.yaml

kubectl describe vpa hello-server-vpa

sed -i 's/Off/Auto/g' hello-vpa.yaml

kubectl apply -f hello-vpa.yaml

kubectl describe vpa hello-server-vpa

kubectl get pods -w

kubectl set resources deployment hello-server --requests=cpu=25m

#CA

# Balanced: The default profile.
# Optimize-utilization: Prioritize optimizing utilization over keeping spare resources in the cluster. 
# When selected, the cluster autoscaler scales down the cluster more aggressively. It can remove more nodes, and remove nodes faster. 
# This profile has been optimized for use with batch workloads that are not sensitive to start-up latency.

gcloud beta container clusters update scaling-demo \
--autoscaling-profile optimize-utilization

kubectl get deployment -n kube-system

kubectl create poddisruptionbudget kube-dns-pdb --namespace=kube-system --selector k8s-app=kube-dns --max-unavailable 1
kubectl create poddisruptionbudget prometheus-pdb --namespace=kube-system --selector k8s-app=prometheus-to-sd --max-unavailable 1
kubectl create poddisruptionbudget kube-proxy-pdb --namespace=kube-system --selector component=kube-proxy --max-unavailable 1
kubectl create poddisruptionbudget metrics-agent-pdb --namespace=kube-system --selector k8s-app=gke-metrics-agent --max-unavailable 1
kubectl create poddisruptionbudget metrics-server-pdb --namespace=kube-system --selector k8s-app=metrics-server --max-unavailable 1
kubectl create poddisruptionbudget fluentd-pdb --namespace=kube-system --selector k8s-app=fluentd-gke --max-unavailable 1
kubectl create poddisruptionbudget backend-pdb --namespace=kube-system --selector k8s-app=glbc --max-unavailable 1
kubectl create poddisruptionbudget kube-dns-autoscaler-pdb --namespace=kube-system --selector k8s-app=kube-dns-autoscaler --max-unavailable 1
kubectl create poddisruptionbudget stackdriver-pdb --namespace=kube-system --selector app=stackdriver-metadata-agent --max-unavailable 1
kubectl create poddisruptionbudget event-pdb --namespace=kube-system --selector k8s-app=event-exporter --max-unavailable 1

kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

cat << EOF > pause-pod.yaml
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: overprovisioning
value: -1
globalDefault: false
description: "Priority class used by overprovisioning."
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: overprovisioning
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      run: overprovisioning
  template:
    metadata:
      labels:
        run: overprovisioning
    spec:
      priorityClassName: overprovisioning
      containers:
      - name: reserve-resources
        image: k8s.gcr.io/pause
        resources:
          requests:
            cpu: 1
            memory: 4Gi
EOF