# Jenkins deployment pipeline

This is an exercise from sevf education as part of cource in [SkillFactory.ru - DEVOPS](https://lms.skillfactory.ru/)

## How To deploy Jenkins in Yandec Cloud

  terraform apply

### 12.5 

#### 1.to launch docker with Wordpress via Jenkins Job (shell) on production Node


    ssh jenkins@178.154.207.107 docker run -d -p 80:80 tutum/wordpress /run.sh


#### 2 to launch docker with Wordpress via Jenkins Job (shell) on stating Node

    ssh jenkins@178.154.207.107 docker run -d -p 80:80 tutum/wordpress /run.sh

#### 3 to get Ping DOWN of Production and Stating Nodes via Jenkins Job (shell) every 5 min
  
```shell
ping -c 1 178.154.203.182
if [ $? -eq 1 ];  then
    echo "stating PING DOWN"  >> /home/jenkins/myping_sh.log
fi

ping -c 1 178.154.207.107
if [ $? -eq 1 ];  then
    echo "production PING DOWN" >> /home/jenkins/myping_sh.log
fi

```
#### 4 to get UPtime from Production and Stating Nodes via Jenkins Job (shell) every 5 min

```shell
sh '''ssh jenkins@178.154.203.182 uptime >> /home/jenkins/statingUTime.log
ssh jenkins@178.154.207.107 uptime >> /home/jenkins/productionUTime.log'''
```


### how to lauch 

Prepare system with installed kubectl : [Install and setup kubectl](https://kubernetes.io/ru/docs/tasks/tools/install-kubectl/#%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-kubectl-%D0%B2-linux)
```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl
kubectl version
```
Also [VirtualBox](https://kubernetes.io/ru/docs/setup/learning-environment/minikube/#%D1%83%D0%BA%D0%B0%D0%B7%D0%B0%D0%BD%D0%B8%D0%B5-%D0%B4%D1%80%D0%B0%D0%B9%D0%B2%D0%B5%D1%80%D0%B0-%D0%B2%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D1%8C%D0%BD%D0%BE%D0%B9-%D0%BC%D0%B0%D1%88%D0%B8%D0%BD%D1%8B) should be installed

[Install minikube](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)
Use [git hub releases](https://github.com/kubernetes/minikube/releases)

or use :
```shell
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
Чтобы исполняемый файл Minikube был доступен из любой директории выполните следующие команды:

sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/

# For Checking >minikube start --vm-driver=<driver_name> 
#driver_name = virtualbox ,vmwarefusion , docker , kvm2 , hyperkit , hyperv 

#to start
minikube start --vm-driver=virtualbox

minikube status
#to stop

minikube stop
#before new start it need to clear local status
minikube delete

```
## Operation with K8s 
[k8s cheatcheet](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/)
```shell
>kubectl get pods --all-namespaces
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-74ff55c5b-wbssc            1/1     Running   0          17m
kube-system   etcd-minikube                      1/1     Running   0          17m
kube-system   kube-apiserver-minikube            1/1     Running   0          17m
kube-system   kube-controller-manager-minikube   1/1     Running   0          17m
kube-system   kube-proxy-4lkwq                   1/1     Running   0          17m
kube-system   kube-scheduler-minikube            1/1     Running   0          17m
kube-system   storage-provisioner                1/1     Running   1          18m
```
### Creating some resouce with minikube

```shell
>kubectl create deployment hello-app --image=k8s.gcr.io/echoserver:1.4
deployment.apps/hello-app created

>kubectl get deployments --all-namespaces
NAMESPACE     NAME        READY   UP-TO-DATE   AVAILABLE   AGE
default       hello-app   0/1     1            0           14s
kube-system   coredns     1/1     1            1           21m

```
### Publishing resoгrce to outside

```shell
# requred the service type= NodePort :

>kubectl expose deployment hello-app --type=NodePort --port=8080
service/hello-app exposed
# to check
>kubectl get services hello-app
NAME        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-app   NodePort   10.98.149.162   <none>        8080:31044/TCP   58s

# to porward port of the service to localhost 
>kubectl port-forward service/hello-app 7080:8080
Forwarding from 127.0.0.1:7080 -> 8080
Forwarding from [::1]:7080 -> 8080
```
From now we can open link http://localhost:7080 and get in the browser responce :
```
CLIENT VALUES:
client_address=127.0.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://localhost:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
accept-encoding=gzip, deflate, br
accept-language=ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,pt;q=0.6
connection=keep-alive
host=localhost:7080
sec-ch-ua="Chromium";v="88", "Google Chrome";v="88", ";Not A Brand";v="99"
sec-ch-ua-mobile=?0
sec-fetch-dest=document
sec-fetch-mode=navigate
sec-fetch-site=cross-site
sec-fetch-user=?1
upgrade-insecure-requests=1
user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36
BODY:
-no body in request-
```
## To deploy nginx into cluster using yaml file

Create deployment.yaml which describes this deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # мы создадим 2 реплики nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
