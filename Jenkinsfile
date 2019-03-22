pipeline {
  agent {
    kubernetes {
      label 'jenkins-slave'
      yamlFile 'k8s-jenkins-pod.yaml'
    }
  }
  stages {

    stage('Get sources'){
       container('jnlp'){
            git branch: 'master', url: 'https://github.com/seblaporte/hello-nginx.git'
       }
    }

    stage('Build image and push to registry'){
        container(name: 'kaniko', shell: '/busybox/sh') {
           withEnv(['PATH+EXTRA=/busybox:/kaniko']) {
             sh '''#!/busybox/sh
             /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --cache=true --destination=registry.demo-pic.techlead-top.ovh/hello-nginx:latest
             '''
           }
         }
      }

    stage('Deploy'){
        container('kubectl'){
            sh '''
            kubectl patch deployment hello-nginx -p \
              '{"spec":{"template":{"metadata":{"labels":{"date":"'`date +'%s'`'"}}}}}'
            '''
        }
    }

  }
}
