def label = "jenkins-worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, yaml: """
kind: Pod
metadata:
  name: jnlp-kaniko-kubectl
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/

  - name: jnlp
    image: jenkins/jnlp-slave:3.10-1
    imagePullPolicy: Always

  - name: kubectl
    image: dtzar/helm-kubectl:2.13.0
    imagePullPolicy: Always
    tty: true
    volumeMounts:
      - name: kube-config
        mountPath: /root/.kube
    env:
    - name: KUBECONFIG
      value: "/root/.kube/config"

  imagePullSecrets:
  - name: docker-registry-config

  volumes:
  - name: docker-config
    secret:
      secretName: docker-config
  - name: kube-config-demo
    secret:
      secretName: kube-config
""")
{
    node(label){

        stage('Get sources'){
           container('jnlp'){
                git branch: BRANCH_NAME, url: 'https://github.com/seblaporte/hello-nginx.git'
           }
        }

        stage('Build image and push to registry'){
            container(name: 'kaniko', shell: '/busybox/sh') {
               withEnv(['PATH+EXTRA=/busybox:/kaniko']) {
                 sh '''#!/busybox/sh
                 /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --cache=true \
                     --destination=cf1n92at.gra5.container-registry.ovh.net/hello-nginx:$BRANCH_NAME
                 '''
               }
            }
         }

        stage('Deploy'){
            container('kubectl'){
                sh '''
                sed "s/BRANCH_NAME/$BRANCH_NAME/g" k8s.yaml | kubectl apply -n demo -f -
                kubectl patch deployment hello-nginx-$BRANCH_NAME -p \
                    '{"spec":{"template":{"metadata":{"labels":{"date":"'`date +'%s'`'"}}}}}'
                '''
            }
        }

    }

}
