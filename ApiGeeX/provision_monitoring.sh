export INSTANCE_NAME=eval-instance
export ENV_NAME=eval
export PREV_INSTANCE_STATE=
echo "waiting for runtime instance ${INSTANCE_NAME} to be active"
while :; do
    export INSTANCE_STATE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}" | jq "select(.state != null) | .state" --raw-output)
    [[ "${INSTANCE_STATE}" == "${PREV_INSTANCE_STATE}" ]] || (
        echo
        echo "INSTANCE_STATE=${INSTANCE_STATE}"
    )
    export PREV_INSTANCE_STATE=${INSTANCE_STATE}
    [[ "${INSTANCE_STATE}" != "ACTIVE" ]] || break
    echo -n "."
    sleep 5
done
echo
echo "instance created, waiting for environment ${ENV_NAME} to be attached to instance"
while :; do
    export ATTACHMENT_DONE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" | jq "select(.attachments != null) | .attachments[] | select(.environment == \"${ENV_NAME}\") | .environment" --join-output)
    [[ "${ATTACHMENT_DONE}" != "${ENV_NAME}" ]] || break
    echo -n "."
    sleep 5
done
echo
echo "${ENV_NAME} environment attached"
echo "***ORG IS READY TO USE***"
