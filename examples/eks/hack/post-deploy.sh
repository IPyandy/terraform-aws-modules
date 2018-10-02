#!/usr/bin/env bash

# SETUP KUBECONFIG

KUBEDIR="${HOME}/.kube"
KUBECONFIG="${KUBEDIR}/config"
AWSKEY="${AWS_DEVPRIV_SSHKEY}"
SSHUSER="ec2-user" # change to appropriate user
CLUSTER="eks"
CLUSTERNAME="None"
CLOUD="None"

function setKubeConfig() {
	# update kubenconfig variable
	DIRLIST=(${KUBEDIR}/${prefix}*.yaml)

	KUBECONFIG=$(printf ":%s" "${DIRLIST[@]}")
	KUBECONFIG="${KUBEDIR}/config:/${KUBECONFIG:2}"
	export KUBECONFIG

	# merge config files
	kubectl config view --flatten >$KUBEDIR/config

	# set KUBECONFIG back to default
	export KUBECONFIG="${KUBEDIR}/config"
	echo "kubeconfig entry generated for ${CLUSTERNAME}."
}

function postTasks() {
	terraform output -module=eks kubeconfig >"$KUBEDIR/${CLUSTERNAME}.yaml"
	BASTIONIP="$(terraform output -module=eks aws_bastion_pub_ip)"

	# SET KUBECONFIG
	setKubeConfig
	if [ $? == 0 ]; then
		scp -i $AWSKEY -o StrictHostKeyChecking=no "$KUBEDIR/${CLUSTERNAME}.yaml" "${SSHUSER}"@$BASTIONIP:.kube/config
	fi

	kubectl config use-context ${CLUSTERNAME}

	# PATCH STORAGE
	cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
mountOptions:
  - debug
EOF

	kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

	# FINISH SETUP

	# apply configmap to allow nodes to connect to cluster master
	terraform output -module=eks aws-auth >$PWD/aws-auth.yaml
	kubectl apply -f $PWD/aws-auth.yaml
	rm $PWD/aws-auth.yaml
}

function run() {
	postTasks
}

run "$@"
