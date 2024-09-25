gcloud beta container clusters update scaling-demo --enable-autoscaling --min-nodes 1 --max-nodes 5

# Balanced: The default profile.
# Optimize-utilization: Prioritize optimizing utilization over keeping spare resources in the cluster. 
# When selected, the cluster autoscaler scales down the cluster more aggressively. It can remove more nodes, 
# and remove nodes faster. This profile has been optimized for use with batch workloads that are not sensitive to start-up latency.

gcloud beta container clusters update scaling-demo \
--autoscaling-profile optimize-utilization

gcloud container clusters update scaling-demo \
    --enable-autoprovisioning \
    --min-cpu 1 \
    --min-memory 2 \
    --max-cpu 45 \
    --max-memory 160