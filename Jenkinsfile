def label = "jenkins-worker-${UUID.randomUUID().toString()}"

podTemplate(
    label: label,
    containers: [
        containerTemplate(
                name: 'jnlp',
                image: 'jenkins/jnlp-slave:3.10-1',
                args: '${computer.jnlpmac} ${computer.name}'
            ),
        containerTemplate(
                name: 'docker',
                image: 'docker:stable',
                command:'cat',
                ttyEnabled:true,
                envVars: [
                    envVar(key: 'DOCKER_CONFIG', value: '/root/.docker')
                ]
            ),
        containerTemplate(
                name: 'kubectl',
                image: 'dtzar/helm-kubectl:2.13.0',
                command:'cat',
                ttyEnabled:true,
                envVars: [
                    envVar(key: 'KUBECONFIG', value: '/root/.kube/config')
                ]
            )
    ],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
        secretVolume(secretName: 'docker-config', mountPath: '/root/.docker'),
        secretVolume(secretName: 'kube-config', mountPath: '/root/.kube'),
        persistentVolumeClaim(mountPath: '/share', claimName: 'jenkins-slave-share'),
        configMapVolume(mountPath: '/config', configMapName: 'job-jenkins-config')
    ]
)

{
    node(label){

        stage('Git clone'){
           container('jnlp'){
                git branch: 'ludo', url: 'https://github.com/seblaporte/hello-nginx.git'
           }
        }

        stage('Create image name'){
            container('jnlp'){
                sh  '''
                git rev-parse --short HEAD > /share/buildVersion
                git config --local remote.origin.url|sed -n 's#.*/\\([^.]*\\)\\.git#\\1#p' > /share/applicationName
                echo "`cat /config/registryHost`/`cat /share/applicationName`:`cat /share/buildVersion`" > /share/imageName
                sed -ie s@IMAGE@`cat /share/imageName`@g k8s-deployment.yaml
                '''
            }
        }

        stage('Build Docker image'){
            container('docker'){
                sh 'docker build -t `cat /share/imageName` .'
            }
        }

        stage('Push to private registry'){
            container('docker'){
                sh 'docker push `cat /share/imageName`'
            }
        }

        stage('Deploy with Kubernetes'){
            container('kubectl'){
                sh 'kubectl apply -n demo-pic -f k8s-deployment.yaml'
            }
        }
            
    }
   
}
