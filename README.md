# Jenkins deployment pipeline

This is an exercise from sevf education as part of cource in [SkillFactory.ru - DEVOPS](https://lms.skillfactory.ru/)

## How To deploy Jenkins in Yandec Cloud

  terraform apply

### 12.5 

#### 1.   to launch docker with Wordpress via Jenkins Job (shell) on production Node


    ssh jenkins@178.154.207.107 docker run -d -p 80:80 tutum/wordpress /run.sh


#### 2.   to launch docker with Wordpress via Jenkins Job (shell) on stating Node

    ssh jenkins@178.154.207.107 docker run -d -p 80:80 tutum/wordpress /run.sh

#### 3.   to get Ping DOWN of Production and Stating Nodes via Jenkins Job (shell) every 5 min
  
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
#### 4.  to get UPtime from Production and Stating Nodes via Jenkins Job (shell) every 5 min

```shell
sh '''ssh jenkins@178.154.203.182 uptime >> /home/jenkins/statingUTime.log
ssh jenkins@178.154.207.107 uptime >> /home/jenkins/productionUTime.log'''
```
also via pipeline file  (12.6)

```shell
pipeline {
    agent any
    stages {
        stage('Ping') {
            steps {
               sh '''ping -c 1 178.154.203.182
                    if [ $? -eq 1 ];  then
                    echo "stating PING DOWN"  >> /home/jenkins/myping_sh.log
                    fi

                    ping -c 1 178.154.207.107
                    if [ $? -eq 1 ];  then
                    echo "production PING DOWN" >> /home/jenkins/myping_sh.log
                    fi 
                '''
            }
        }
        stage('Uptime') {
            steps {
                sh '''ssh jenkins@178.154.203.182 uptime >> /home/jenkins/statingUTime.log
                ssh jenkins@178.154.207.107 uptime >> /home/jenkins/productionUTime.log'''
            }
        }
        stage('Docker') {
            steps {
                echo 'Hello World'
            }
        }
    }
}

```

#### 5.   to reboot Production or Stating or both Nodes via Jenkins Pipeline (12.6)

```shell
pipeline {
    agent any
    parameters{ choice(choices: ['All', 'production', 'stating'], description: 'which of server (s)',  name: 'ServerName') }    
    stages {
        stage('reboot Production') {
            agent { 
                label 'stating'
            }
            when {
                expression { 
                   return params.ServerName == 'production'
                }
            }
            steps {
                    sh """
                   reboot now
                    """
            }
        }
        stage('reboot staging') {
            when {
                expression { 
                   return params.ServerName == 'stating'
                }
            }
            steps {
                    sh """
                    ssh jenkins@178.154.203.182 reboot now
                    """
            }
        }
        stage('reboot all') {
            when {
                expression { 
                   return params.ServerName == 'stating'
                }
            }
            steps {
                    sh """
                    ssh jenkins@178.154.203.182 reboot now
                    ssh jenkins@178.154.207.107 reboot now
                    """
            }
        }
    }
}
```
