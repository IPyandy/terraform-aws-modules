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

function deleteIstio() {
	echo "Removing istio install from: $(kubectl config current-context)"

	helm ls --all | grep istio
	if [ $? == 0 ]; then
		# delete helm install
		helm delete --debug --purge istio

		# delete customresourcedefs
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "adapters.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "apikeys.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "attributemanifests.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "authorizations.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "bypasses.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "checknothings.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "circonuses.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "deniers.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "destinationrules.networking.istio.i"o
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "edges.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "envoyfilters.networking.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "fluentds.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "gateways.networking.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "handlers.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "httpapispecbindings.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "httpapispecs.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "instances.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "kubernetesenvs.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "kuberneteses.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "listcheckers.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "listentries.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "logentries.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "memquotas.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "metrics.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "noops.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "opas.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "prometheuses.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "quotas.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "quotaspecbindings.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "quotaspecs.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "rbacconfigs.rbac.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "rbacs.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "redisquotas.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "reportnothings.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "rules.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "servicecontrolreports.config.istio."io
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "servicecontrols.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "serviceentries.networking.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "servicerolebindings.rbac.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "serviceroles.rbac.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "signalfxs.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "solarwindses.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "stackdrivers.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "statsds.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "stdios.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "templates.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "tracespans.config.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "virtualservices.networking.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "clusterissuers.certmanager.k8s.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "issuers.certmanager.k8s.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "certificates.certmanager.k8s.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "meshpolicies.authentication.istio.io"
		kubectl delete customresourcedefinitions.apiextensions.k8s.io "policies.authentication.istio.io"
		kubectl delete namespace istio-system
	else
		echo "Istio not installed, nothing to delete"
	fi
}

function destroyCluster() {
	echo "Destroying -> $PWD"
	getClusterName
	kubectl config use-context $CLUSTERNAME

	if [ "$?" == 0 ]; then
		deleteIstio
	fi
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
