#!/bin/bash

#Make sure that VT-x or AMD-v virtualization is enabled in your computer’s BIOS or VM settings if you are doing this on a VM
#Also make sure to sudo chmod +x this script

sudo apt update
sudo apt upgrade
sudo apt install git curl python-pip
sudo apt install virtualbox
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
minikube start
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
helm init
sleep 2m
helm repo add brigade https://azure.github.io/brigade
helm install -n brigade brigade/brigade
helm status brigade
sleep 2m
minikube stop
minikube start
git clone https://github.com/ramhiser/kafka-kubernetes.git
cd kafka-kubernetes
kubectl create -f namespace-kafka.yaml
kubectl config set-context kafka --namespace=kafka-cluster --cluster=${CLUSTER_NAME} --user=${USER_NAME}
kubectl config use-context kafka
kubectl create -f zookeeper-services.yaml
sleep 2m
kubectl create -f zookeeper-cluster.yaml
sleep 2m
#In order to see which zookeeper pod is leading type this command with the appropriate pod name from kubectl get pods: kubectl logs zookeeper-deployment-[pod-name]
kubectl create -f kafka-service.yaml
sleep 2m
kubectl describe service kafka-service
#Script ends here but process doesn't
#Grab the ip of the load balancer from the previous command, then copy it into kafka-cluser.yaml in the KAFKA_ADVERTISED_HOST_NAME value
#After adding the load-balancer DNS IP, copy this env name and value pair to name your topic 
#- name: KAFKA_CREATE_TOPICS
#value: ramhiser:2:1
#End of installing virtualbox, minikube, kubectl, helm, brigade, zookeeper, and Kafka
#UPCOMING: Add installing the kafkacat client to this script
