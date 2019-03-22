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
                name: 'kaniko',
                image: 'gcr.io/kaniko-project/executor:debug',
                command:'/busybox/cat',
                ttyEnabled:true,
                envVars: [
                    envVar(key: 'PATH+EXTRA', value: '/busybox:/kaniko')
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
        secretVolume(secretName: 'docker-config', mountPath: '/kaniko/.docker/'),
        secretVolume(secretName: 'kube-config', mountPath: '/root/.kube'),
        persistentVolumeClaim(mountPath: '/share', claimName: 'jenkins-slave-share'),
        configMapVolume(mountPath: '/config', configMapName: 'job-jenkins-config')
    ]
)

{
    node(label){

        stage('Git clone'){
           container('jnlp'){
                git branch: 'master', url: 'https://github.com/seblaporte/hello-nginx.git'
           }
        }

        stage('Build image and push to registry'){
            container(name: 'kaniko', shell: '/busybox/sh') {
               sh '''#!/busybox/sh
               /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --cache=true --destination=registry.demo-pic.techlead-top.ovh/hello-nginx:latest
               '''
             }
          }

        stage('Deploy with Kubernetes'){
            container('kubectl'){
                sh 'kubectl apply -n demo-pic -f k8s-deployment.yaml'
            }
        }
            
    }
   
}