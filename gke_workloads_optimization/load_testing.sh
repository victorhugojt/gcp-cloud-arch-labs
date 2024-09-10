gsutil -m cp -r gs://spls/gsp769/locust-image .

gcloud builds submit \
    --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/locust-tasks:latest locust-image

gcloud container images list


gsutil cp gs://spls/gsp769/locust_deploy_v2.yaml .
sed 's/${GOOGLE_CLOUD_PROJECT}/'$GOOGLE_CLOUD_PROJECT'/g' locust_deploy_v2.yaml | kubectl apply -f -


kubectl get service locust-main


[EXTERNAL_IP_ADDRESS]:8089

