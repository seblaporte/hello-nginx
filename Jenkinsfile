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
      secretVolume(secretName: 'kube-config', mountPath: '/root/.kube')
    ]
)

{
    node(label){

        sh "git rev-parse --short HEAD > commit-id"

        tag = readFile('commit-id').replace("\n", "").replace("\r", "")
        appName = "hello-nginx"
        registryHost = "registry.techlead-top.ovh"

        imageName = "${registryHost}/${appName}:${tag}"
        
        stage('Git clone'){
           container('jnlp'){
                git branch: 'master', url: 'https://github.com/seblaporte/hello-nginx.git'
           }
        }
        
        stage('Build Docker image'){
            container('docker'){
                sh 'docker build -t ${imageName} .'
            }
        }
        
        stage('Push to private registry'){
            container('docker'){
                sh 'docker push ${imageName}'
            }
        }

        stage('Deploy with Kubernetes'){
            container('kubectl'){
                sh 'kubectl apply -n demo-pic -f k8s-deployment.yaml --image=${imageName}'
            }
        }
            
    }
   
}