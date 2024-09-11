# Set your default zone to "us-central1-f":

gcloud config set compute/zone us-central1-f

# The --enable-ip-alias flag is included in order to enable the use of alias IPs for pods which will be required for container-native load balancing through an ingress.

gcloud container clusters create test-cluster --num-nodes=3  --enable-ip-alias

ClusterIP Service

cat << EOF > gb_frontend_cluster_ip.yaml
apiVersion: v1
kind: Service
metadata:
  name: gb-frontend-svc
  annotations:
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: ClusterIP
  selector:
    app: gb-frontend
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
EOF

App Ingress

Container-native load balancing allows pods to become the core objects for load balancing, potentially reducing the number of network hops:
In order to take advantage of container-native load balancing, the VPC-native setting must be enabled on the cluster. 
his was indicated when you created the cluster and included the --enable-ip-alias flag.



cat << EOF > gb_frontend_ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gb-frontend-ingress
spec:
  defaultBackend:
    service:
      name: gb-frontend-svc
      port:
        number: 80
EOF

The manifest includes an annotations field where the annotation for cloud.google.com/neg will enable container-native load balancing on for your application when an ingress is created.

BACKEND_SERVICE=$(gcloud compute backend-services list | grep NAME | cut -d ' ' -f2)

gcloud compute backend-services get-health $BACKEND_SERVICE --global

kubectl get ingress gb-frontend-ingress # 34.54.64.145