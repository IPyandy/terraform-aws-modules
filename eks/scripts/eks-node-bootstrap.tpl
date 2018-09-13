#!/bin/bash -xe

set -o xtrace
/etc/eks/bootstrap.sh \
  --use-max-pods ${MAX_PODS} \
  --b64-cluster-ca ${CLUSTER_CERT} \
  --apiserver-endpoint ${CLUSTER_ENDPOINT} ${CLUSTER_ID}
systemctl daemon-reload
systemctl restart kubelet
