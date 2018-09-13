#!/usr/bin/env bash

# SETUP KUBECONFIG

KUBEDIR="${HOME}/.kube"
KUBECONFIG="${KUBEDIR}/config"
AWSKEY="/Users/yandy/.aws-keys/aws-dev-key"
SSHUSER="ec2-user" # change to appropriate user
CLUSTER="None"
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

function postAWS() {
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

function postAzure() {
	terraform output -module=aks kube_config >"$KUBEDIR/${CLUSTERNAME}.yaml"

	# SET KUBECONFIG
	setKubeConfig
}

function postGCP() {
	gcloud container clusters get-credentials "${CLUSTERNAME}"

	export KUBECONFIG
}

function run() {
	while [[ $# -gt 0 ]]; do
		key="$1"
		case $key in
		--cluster)
			if ! [ -z "${2}" ]; then
				CLUSTER="${2}"
				CLUSTERNAME="$(terraform output -module="${CLUSTER}" "${CLUSTER}"-name)"
			else
				echo "Please enter cluster to use first."
				exit 1
			fi
			shift
			shift
			;;
		--cloud)
			if [ -z "${2}" ]; then
				echo "Enter a cloud provider"
				exit 1
			fi
			CLOUD="${2}"
			if [ "${CLOUD}" == "aws" ]; then
				postAWS
			elif [ "${CLOUD}" == "azure" ]; then
				postAzure
			elif [ "${CLOUD}" == "gcp" ]; then
				postGCP
			else
				echo "Not a valid cloud provider."
				exit 1
			fi
			if [ "${?}" == 0 ]; then
				echo 'EXITING'
				exit 0
			fi
			;;
		*)
			echo "Enter a valid option."
			exit 1
			;;
		esac
	done
	run
}

run "$@"
