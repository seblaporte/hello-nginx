def label = "demo-pic-worker-${UUID.randomUUID().toString()}"

podTemplate(
    label: label,
    containers: [
        containerTemplate(name: 'jnlp', image: 'jenkins/jnlp-slave:3.10-1', args: '${computer.jnlpmac} ${computer.name}'),
        containerTemplate(name: 'docker', image: 'docker:stable', command:'cat', ttyEnabled:true)
    ],
    volumes: [
      hostPathVolume(mountPath: '/home/maven/.m2', hostPath: '/tmp/jenkins/.m2'),
      hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
      secretVolume(secretName: 'docker-config', mountPath: '/root/.docker')
    ]
)

{
    node(label){
        
        stage('Git'){
           container('jnlp'){
                git branch: 'master', url: 'https://github.com/seblaporte/hello-nginx.git'
           }
        }
        
        stage('Image build'){
            container('docker'){
                sh label: 'Docker build', script: 'docker build -t registry.techlead-top.ovh/hello-nginx:jenkins-v1 .'
            }
        }
        
        stage('Push to registry'){
            container('docker'){
                sh 'docker --config /root/.docker push registry.techlead-top.ovh/hello-nginx:jenkins-v1'
            }
        }
            
    }
   
}