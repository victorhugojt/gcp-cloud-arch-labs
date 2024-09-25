
gcloud container clusters list

gcloud container clusters describe CLUSTER_NAME

gcloud config set container/cluster CLUSTER_NAME

gcloud container clusters update CLUSTER_NAME \
  --zone COMPUTE_ZONE \
  --node-locations COMPUTE_ZONE,COMPUTE_ZONE1