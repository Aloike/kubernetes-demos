#!/bin/bash

##  @brief  Script to automatically install Microk8s on Ubuntu.
##  @see    Instructions from https://ubuntu.com/tutorials/install-a-local-kubernetes-with-microk8s#1-overview


#
# 2. Deploying MicroK8s
#

sudo snap install microk8s --classic

# You may need to configure your firewall to allow pod-to-pod and
# pod-to-internet communication:
	sudo ufw allow in on cni0	\
&&	sudo ufw allow out on cni0	\
&&	sudo ufw default allow routed

# Wait until the cluster is ready
microk8s.status --wait-ready


#
# 3. Enable addons
#

# Deploy DNS. This addon may be required by others, thus we recommend you always
# enable it.
MICROK8S_ADDONS_ENABLE+=("dns")

# Deploy kubernetes dashboard.
MICROK8S_ADDONS_ENABLE+=("dashboard")

# Expose GPU(s) to MicroK8s by enabling the nvidia-docker runtime and
# nvidia-device-plugin-daemonset. Requires NVIDIA drivers to be already
# installed on the host system.
#MICROK8S_ADDONS_ENABLE+=("gpu")

# Create an ingress controller.
#MICROK8S_ADDONS_ENABLE+=("ingress")

# Deploy the core Istio services. You can use the microk8s istioctl command to
# manage your deployments.
#MICROK8S_ADDONS_ENABLE+=("istio")

# Deploy a docker private registry and expose it on localhost:32000. The
# storage addon will be enabled as part of this addon.
#MICROK8S_ADDONS_ENABLE+=("registry")

# Create a default storage class. This storage class makes use of the
# hostpath-provisioner pointing to a directory on the host.
MICROK8S_ADDONS_ENABLE+=("storage")


for lAddon in "${MICROK8S_ADDONS_ENABLE[@]}"
do
	microk8s enable ${lAddon}
done


#
# 4. Accessing the Kubernetes dashboard
#

# Have a look at [the documentation](https://ubuntu.com/tutorials/install-a-local-kubernetes-with-microk8s#4-accessing-the-kubernetes-dashboard)

# The following lines help us retrieve the token to access the dashboard:
echo -e "\n\nToken to access the Kubernetes dashboard:\n"

token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
sudo microk8s kubectl -n kube-system describe secret $token


#
# Misc.: Access for local user without using 'sudo'
#
SUDO_USER_HOME=$(eval echo ~${SUDO_USER})
echo "SUDO_USER_HOME=${SUDO_USER_HOME}"
echo "Adding user ${SUDO_USER} to group 'microk8s'"
sudo usermod -a -G microk8s ${SUDO_USER}
echo "Change owner of '${SUDO_USER_HOME}/.kube/' directory"
sudo chown -f -R ${SUDO_USER} ${SUDO_USER_HOME}/.kube

# echo "Add a 'kubectl' alias in bashrc if it doesn't exist..."
#
# echo -en "\n\n"	>> ${SUDO_USER_HOME}/.bashrc
# cat << EOT >> ${SUDO_USER_HOME}/.bashrc
# if ! command -v kubectl &> /dev/null
# then
#     echo "kubectl could not be found - Create an alias for 'microk8s.kubectl'..."
#
#     # Create the alias
#     alias kubectl='microk8s.kubectl'
#
#     # Source the completion script in your ~/.bashrc file
#     source <(kubectl completion bash)
#
#     # extend shell completion to work with that alias
#     complete -F __start_kubectl kubectl
# fi
#
# EOT

echo "Create snap command alias for 'microk8s.kubectl'..."
snap alias	\
	microk8s.kubectl	\
	kubectl


#
# Optional: Do a cluster inspection to detect any trouble.
# It might show configuration error that shall be solved.
#

microk8s inspect


echo -e "# ######################################"
echo -e "#"
echo -e "# Please note: for user add to group to take effect, you shall restart your computer."
echo -e "# On newer Ubuntu (>18.04?) closing your session won't be sufficient,"
echo -e "# as some processes remain for a while after your logout."
echo -e "#"
echo -e "# ######################################"

