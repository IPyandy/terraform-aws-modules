#!/usr/bin/env bash

# aws eks update-kubeconfig --kubeconfig ~/.kube/aws-dev-eks.yaml --name eks-cluster-dev-62829
# SETUP KUBECONFIG

KUBEDIR="${HOME}/.kube"
KUBECONFIG="${KUBEDIR}/config"
AWSKEY="${AWS_DEVPRIV_SSHKEY}"
SSHUSER="ec2-user" # change to appropriate user
CLUSTER="eks"
CLUSTERNAME=""

function resetKubeConfig() {
	# update kubenconfig variable
	DIRLIST=(${KUBEDIR}/${prefix}*.yaml)

	KUBECONFIG=$(printf ":%s" "${DIRLIST[@]}")
	KUBECONFIG="${KUBEDIR}/config:/${KUBECONFIG:2}"
	export KUBECONFIG

	# merge config files
	kubectl config view --flatten >$KUBEDIR/config

	# set KUBECONFIG back to default
	export KUBECONFIG="${KUBEDIR}/config"
}

function postTasks() {

	# SET KUBECONFIG
	CLUSTERNAME="$(terraform output -module=${CLUSTER} ${CLUSTER}-name)"
	# aws eks update-kubeconfig --kubeconfig ~/.kube/${CLUSTERNAME}.yaml --name ${CLUSTERNAME}
	terraform output -module=eks kubeconfig >${HOME}/.kube/${CLUSTERNAME}.yaml
	resetKubeConfig
	kubectl config use-context ${CLUSTERNAME}

	# PREPARE BASTION HOST
	BASTIONIP="$(terraform output -module=eks aws_bastion_pub_ip)"
	if [ $? == 0 ]; then
		scp -i $AWSKEY -o StrictHostKeyChecking=no "$KUBEDIR/${CLUSTERNAME}.yaml" "${SSHUSER}"@$BASTIONIP:.kube/config
	fi

	# PATCH STORAGE
	cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gp2
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
reclaimPolicy: Delete
parameters:
  type: gp2
  fsType: ext4
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: iops
provisioner: kubernetes.io/aws-ebs
reclaimPolicy: Delete
parameters:
  type: io1
  iopsPerGB: "10"
  fsType: ext4
EOF

	kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

	# INSTALL HELM and PATCH
	cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

	helm init
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

	# FINISH SETUP

	# apply configmap to allow nodes to connect to cluster master
	terraform output -module=eks aws-auth >$PWD/aws-auth.yaml
	kubectl apply -f $PWD/aws-auth.yaml
	rm -rfv $PWD/aws-auth.yaml
}

function run() {
	postTasks
}

run "$@"
