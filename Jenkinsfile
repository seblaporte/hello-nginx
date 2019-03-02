def label = "demo-pic-worker-${UUID.randomUUID().toString()}"

podTemplate(
    label: label,
    containers: [
        containerTemplate(
                name: 'jnlp',
                image: 'jenkins/jnlp-slave:3.10-1',
                args: '${computer.jnlpmac} ${computer.name}',
                resourceRequestCpu: '50m',
                resourceLimitCpu: '100m',
                resourceRequestMemory: '100Mi',
                resourceLimitMemory: '200Mi'
            ),
        containerTemplate(
                name: 'docker',
                image: 'docker:stable',
                command:'cat',
                ttyEnabled:true,
                resourceRequestCpu: '50m',
                resourceLimitCpu: '100m',
                resourceRequestMemory: '100Mi',
                resourceLimitMemory: '200Mi',
                envVars: [
                    envVar(key: 'DOCKER_CONFIG', value: '/root/.docker')
                ]
            ),
        containerTemplate(
                name: 'kubectl',
                image: 'dtzar/helm-kubectl:2.13.0',
                command:'cat',
                ttyEnabled:true,
                resourceRequestCpu: '50m',
                resourceLimitCpu: '100m',
                resourceRequestMemory: '100Mi',
                resourceLimitMemory: '200Mi',
                envVars: [
                    envVar(key: 'KUBECONFIG', value: '/root/.kube/config')
                ]
            )
    ],
    volumes: [
      persistentVolumeClaim(mountPath: '/home/maven/.m2', claimName: 'jenkins-maven')
      hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
      secretVolume(secretName: 'docker-config', mountPath: '/root/.docker'),
      secretVolume(secretName: 'kube-config', mountPath: '/root/.kube')
    ]
)

{
    node(label){
        
        stage('Git clone'){
           container('jnlp'){
                git branch: 'master', url: 'https://github.com/seblaporte/hello-nginx.git'
           }
        }
        
        stage('Build Docker image'){
            container('docker'){
                sh label: 'Docker build', script: 'docker build -t registry.techlead-top.ovh/hello-nginx:jenkins-v1 .'
            }
        }
        
        stage('Push to private registry'){
            container('docker'){
                sh 'docker push registry.techlead-top.ovh/hello-nginx:jenkins-v2'
            }
        }

        stage('Deploy with Kubernetes'){
            container('kubectl'){
                sh 'kubectl -n demo-pic get pods'
            }
        }
            
    }
   
}