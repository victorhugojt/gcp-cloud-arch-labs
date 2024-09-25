# Create nodePools

gcloud container node-pools create POOL_NAME \
    --cluster CLUSTER_NAME \
    --service-account SERVICE_ACCOUNT

# To check the status of all node pools

gcloud container node-pools list --cluster CLUSTER_NAME

# To view details about a specific node pool

gcloud container node-pools describe POOL_NAME \
    --cluster CLUSTER_NAME

# Scale horizontally

gcloud container clusters resize CLUSTER_NAME \
    --node-pool POOL_NAME \
    --num-nodes NUM_NODES

# Scale vertically

gcloud container node-pools update POOL_NAME \
    --cluster CLUSTER_NAME \
    --machine-type MACHINE_TYPE \
    --disk-type DISK_TYPE \
    --disk-size DISK_SIZE