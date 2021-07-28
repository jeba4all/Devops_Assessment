# Devops_Assessment
# MEDIAWIKI PROBLEM STATEMENT:
•	Create any kubernetes cluster through infra as code 
•	Build your own images using jenkins
•	Install or configure all cluster related and helm. 
•	Helm install of mediawiki in kubernetes with a chart using your own images 
•	Figure out how you scale when there is high traffic 
•	Perform all the processes both Ci and Cd though a jenkins pipeline.

## REQUIREMENT:
Ubuntu machine with Jenkins, Git, Terraform, Kubectl, Docker. Else Can use Cloud based slave in Jenkins with container configurations of required software’s.

## INSTRUCTION:
```
1.Clone the Git Url
2.Move to Terraform_AKS folder perform terraform opperation on RG and then with AKS 
3.With the help of Config file from the output set the .Kube file and install all required cluster configuration and helm.
4.Move to the mediawiki dev folder build the docker image with the docker file and push to the docker hub with versions
5.Helm install with the chart available in the git by changing the value file with the docker image created in the earlier step.
6.Add Autoscale.yaml with HPA on CPU 75% to scale up during the high traffic.
```

## Sample Jenkins Pipeline:

Provided with the Jenkins script to execute the complete above process in stages using jenkins pipeline.

```
node{
  stage('Checkout'){
      sh ''' git config --global http.sslVerify false '''   
     checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'poc']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'XXXXXXXXXXXXXX-XXXXXXXXXXX', url: 'https://github.com/jeba4all/Devops_Assessment.git']]])
  } 
  
  stage('Start terraform RG'){
      sh'''
        cd poc/terraform/rg
        terraform init
        terraform plan 
     ( sleep 5 && while [ 1 ]; do sleep 1; echo yes; done ) | terraform apply 
      '''
    }

  stage('Start terraform AKS'){
      sh'''
        #!/bin/bash
        cd poc/terraform/aks
        terraform init
        terraform plan -out run.plan  
        ( sleep 5 && while [ 1 ]; do sleep 1; echo yes; done ) | terraform apply "run.plan"
        ls -al
        mkdir ~/.kube
        echo "$(terraform output kube_config)" > ~/.kube/config
        cp ~/.kube/config $WORKSPACE/poc/terraform/rg/ 
        export KUBECONFIG=~/.kube/config
      '''
  }
  
  stage('Environemnt setup'){
      sh'''
        #!/bin/bash

        apt update
        ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | apt install jq
        ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | apt install curl
        
        apt update 
        ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | apt install apt-transport-https gnupg2
        apt update
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" |  tee -a /etc/apt/sources.list.d/kubernetes.list
        apt update
        ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | apt install kubectl
        curl -s https://baltocdn.com/helm/signing.asc | apt-key add -
        ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | apt install apt-transport-https
        echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee -a /etc/apt/sources.list.d/helm-stable-debian.list
        apt update
        ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | apt install helm
             
        mkdir ~/.kube
        cd $WORKSPACE/poc/terraform/rg
        ls -al 
        cp config ~/.kube/
        
	    kubectl --kubeconfig=$WORKSPACE/poc/terraform/rg/config get nodes
	    kubectl --kubeconfig=$WORKSPACE/poc/terraform/rg/config create clusterrolebinding kubernetes-dashboard -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
	    sleep 10
	    kubectl --kubeconfig=$WORKSPACE/poc/terraform/rg/config create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts
 	    sleep 10
	    kubectl config use-context mytestaks-k8s-poc
  }
    
  stage('create mediawiki docker image'){

         sh '''
            cd $WORKSPACE/poc/MediaWIKI_Dev
            docker build  -t mediawiki:$BUILD_ID .
            docker tag mediawiki:$BUILD_ID ajai_poc/mediawiki:$BUILD_ID
            docker push ajai_poc/mediawiki:$BUILD_ID
           '''
        }  

  Stage('Helm Deployment'){
      sh '''
            cd $WORKSPACE/poc/Helm_Deployment
            helm upgrade --install mediawiki mediawiki/ --set image.tag=$BUILD_ID
      '''

  }
  
}
```
