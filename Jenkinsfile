node {

    checkout scm
    
    sh "git rev-parse --short HEAD > commit-id"

    tag = readFile('commit-id').replace("\n", "").replace("\r", "")
    appName = "hello-nginx"
    registryHost = "registry.techlead-top.ovh/"

    imageName = "${registryHost}${appName}:${tag}"
    
    env.BUILDIMG=imageName

    stage "Build image"
    
        sh "docker build -t ${imageName} ."
    
    stage "Push image"

        sh "docker push ${imageName}"

}