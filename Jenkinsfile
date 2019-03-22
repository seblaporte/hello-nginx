def label = "demo-pic-worker-${UUID.randomUUID().toString()}"

podTemplate(
    label: label,
    containers: [
        containerTemplate(
                name: 'jnlp',
                image: 'jenkins/jnlp-slave:3.10-1',
                args: '${computer.jnlpmac} ${computer.name}'
            ),
        containerTemplate(
                name: 'kaniko',
                image: 'gcr.io/kaniko-project/executor:latest',
                command:'/busybox/cat',
                ttyEnabled:true,
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
        persistentVolumeClaim(mountPath: '/share', claimName: 'jenkins-hello-nginx-share'),
        configMapVolume(mountPath: '/config', configMapName: 'hello-nginx-job-config')
    ]
)

{
    node(label){

        stage('Git clone'){
           container('jnlp'){
                git branch: 'master', url: 'https://github.com/seblaporte/hello-nginx.git'
           }
        }

        stage('Create image name'){
            container('jnlp'){
                sh  '''
                git rev-parse --short HEAD > /share/buildVersion
                echo "`cat /config/registryHost`/`cat /config/applicationName`:`cat /share/buildVersion`" > /share/imageName
                sed -ie s@IMAGE@`cat /share/imageName`@g k8s-deployment.yaml
                '''
            }
        }
        
        stage('Build Docker image and push to private registry'){
            container(name: 'kaniko', shell: '/busybox/sh') {
                withEnv(['PATH+EXTRA=/busybox:/kaniko']) {
                sh '''
                #!/busybox/sh
                /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=registry.demo-pic.techlead-top.ovh/myorg/myimage
                '''
                }
            }
        }

        stage('Deploy with Kubernetes'){
            container('kubectl'){
                sh 'kubectl apply -n demo-pic -f k8s-deployment.yaml'
            }
        }
            
    }
   
}