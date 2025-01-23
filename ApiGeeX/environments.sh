export INSTANCE_NAME=eval-instance
curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" -X POST "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" -d '{ "environment": "prod" }' | jq

export ATTACHING_ENV=prod; export INSTANCE_NAME=eval-instance; echo "waiting for ${ATTACHING_ENV} attachment"; while : ; do export ATTACHMENT_DONE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" | jq "select(.attachments != null) | .attachments[] | select(.environment == \"${ATTACHING_ENV}\") | .environment" --join-output); [[ "${ATTACHMENT_DONE}" != "${ATTACHING_ENV}" ]] || break; echo -n "."; sleep 5; done; echo; echo "***${ATTACHING_ENV} ENVIRONMENT ATTACHED***";

TEST_VM_ZONE=$(gcloud compute instances list --filter="name=('apigeex-test-vm')" --format "value(zone)")
gcloud compute ssh apigeex-test-vm --zone=${TEST_VM_ZONE} --force-key-file-overwrite

export PROJECT_NAME=$(gcloud config get-value project)
export ORG=${PROJECT_NAME}
export INSTANCE_NAME=eval-instance
export INTERNAL_LB_IP=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${ORG}/instances/${INSTANCE_NAME}" | jq ".host" --raw-output)
export EVAL_ENVGROUP_HOSTNAME=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${ORG}/envgroups/eval-group" | jq ".hostnames[0]" --raw-output)
export PROD_ENVGROUP_HOSTNAME=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${ORG}/envgroups/prod-group" | jq ".hostnames[0]" --raw-output)
echo "INTERNAL_LB_IP=${INTERNAL_LB_IP}"
echo "EVAL_ENVGROUP_HOSTNAME=${EVAL_ENVGROUP_HOSTNAME}"
echo "PROD_ENVGROUP_HOSTNAME=${PROD_ENVGROUP_HOSTNAME}"


curl -i -k --resolve "${EVAL_ENVGROUP_HOSTNAME}:443:${INTERNAL_LB_IP}" \
  "https://${EVAL_ENVGROUP_HOSTNAME}/test-env"