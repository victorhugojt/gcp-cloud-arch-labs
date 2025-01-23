# Calls

export PROJECT_NAME=$(gcloud config get-value project)
export ORG=${PROJECT_NAME}
export INSTANCE_NAME=eval-instance
export INTERNAL_LB_IP=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${ORG}/instances/${INSTANCE_NAME}" | jq ".host" --raw-output)
export EVAL_ENVGROUP_HOSTNAME=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${ORG}/envgroups/eval-group" | jq ".hostnames[0]" --raw-output)
echo "INTERNAL_LB_IP=${INTERNAL_LB_IP}"
echo "EVAL_ENVGROUP_HOSTNAME=${EVAL_ENVGROUP_HOSTNAME}"

The EVAL_ENVGROUP_HOSTNAME contains the hostname that is associated with the eval-group environment group. A DNS entry for this hostname has been
automatically created. It specifies the private IP address for an internal load balancer.

curl -k "https://${EVAL_ENVGROUP_HOSTNAME}/test-nat"

The origin field response shows multiple IP addresses. The last IP address is from the final server that called the httpbin.org server. The first 3 IP addresses shown here are all internal IP addresses, and they document the other hops that the request took from the instance to httpbin.org.

If you repeat the call multiple times, you may see the same final IP address each time. However, unless you add a NAT address to your instance, the final IP address may change over time, making it difficult to allow-list.


Public API

https://cloud.google.com/apigee/docs/reference/apis/apigee/rest
organizations.instances.natAddresses
