#!/usr/bin/env sh

################################################################################
## SCRIPT MUST BE RUN INSIDE OF THE DIRECTORY CONTIANING THE TERRAFORM FILES
################################################################################

KUBEDIR="${HOME}/.kube"
DEPLOY="no"
DESTROY="no"
CLUSTERNAME=""
CLUSTER="eks"

function getClusterName() {
	CLUSTERNAME="$(terraform output -module=${CLUSTER} ${CLUSTER}-name)"
}

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

function postDeploy() {
	echo "Running post ${CLUSTER} deployment"
	"hack/post-deploy.sh"
}

function deployCluster() {
	echo "Deploying to ${CLUSTER} -> $PWD"
	terraform init

	terraform plan -out plan.tfplan >plan.txt
	if [ "$?" != 0 ]; then
		echo "removing .terraform"
		rm -rfv ".terraform"
		terraform init
		if [ "$?" == 0 ]; then
			terraform plan -out "plan.tfplan"
		else
			echo "There was an error deploying ${CLUSTER}."
			echo "Exiting"
			exit 1
		fi
	fi
	cat plan.txt | egrep --color "No changes\. Infrastructure is" >>/dev/null
	if [ "${?}" == 0 ]; then
		echo 'NO CHANGES FOUND TO APPLY'
		echo 'TERRAFORM WILL NOW QUIT'
		exit 0
	else
		echo "########################################"
		echo ''
		cat plan.txt
		echo ''
		echo "########################################"
		echo ''
		echo 'THE ABOVE CHANGES WILL BE APPLIED'
		echo ''
		echo "########################################"
		echo ''
		printf 'CONTINUE (Y/N)?: '
		read -r RESPONSE
		case "${RESPONSE}" in
		N | n | NO | no | No)
			echo 'QUITTING'
			exit 0
			;;
		Y | y | YES | yes | Yes)
			terraform apply "plan.tfplan"
			;;
		esac
	fi
}

# Create Cluster(s)
function deployClusters() {
	deployCluster

	# Run post deployment script only if success
	if [ "$?" == 0 ]; then
		postDeploy
	fi
}

function destroyCluster() {
	echo "Destroying -> $PWD"
	getClusterName
	kubectl config use-context $CLUSTERNAME

	rm "${KUBEDIR}/config"
	rm "${KUBEDIR}/${CLUSTERNAME}.yaml"
	terraform destroy -force

	resetKubeConfig
}

function run() {
	while [[ $# -gt 0 ]]; do
		key="$1"
		case $key in
		deploy | create | up)
			DEPLOY="yes"
			shift
			deployClusters
			if [ "${?}" == 0 ]; then
				exit 0
			else
				exit 1
			fi
			;;
		remove | delete | destroy | down)
			DESTROY="yes"
			shift
			destroyCluster
			if [ "${?}" == 0 ]; then
				exit 0
			else
				exit 1
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
