pipeline {
  environment {
    ossRegistry = "hazelcast/hazelcast-jet"
    enterpriseRegistry = "hazelcast/hazelcast-jet-enterprise"
    ossImage = ''
    enterpriseImage = ''
  }
  agent { label 'multi-arch-docker-release' }
  stages {
    stage('Building the OSS image') {
        steps{
          script {
            ossImage = docker.build(ossRegistry + ":latest-snapshot", "--force-rm --no-cache --build-arg JET_VERSION=$JET_VERSION ./hazelcast-jet-oss" )
          }
        }
      }
    stage('‘Deploying OSS image') {
        steps{
          script {
            docker.withRegistry('', 'devopshazelcast-dockerhub') {
              if (params.JET_VERSION.contains("SNAPSHOT")) {
                // Pushes latest-snapshot
                ossImage.push()
              } else {
                // Both version and latest tags point to same image
                ossImage.push(ossRegistry + ":" + params.JET_VERSION)
                if (params.UPDATE_LATEST) {
                  ossImage.push(ossRegistry + ":latest")
                }
              }
            } 
          }
        }
      }
    stage('Building the Enterprise image') {
        steps{
          script {
            enterpriseImage = docker.build(enterpriseRegistry + ":latest-snapshot", "--force-rm --no-cache --build-arg JET_VERSION=$JET_VERSION ./hazelcast-jet-enterprise" )
          }
        }
      }
    stage('‘Deploying Enterprise image') {
        steps{
          script {
            docker.withRegistry('', 'devopshazelcast-dockerhub') {
              if (params.JET_VERSION.contains("SNAPSHOT")) {
                // Pushes latest-snapshot
                enterpriseImage.push()
              } else {
                // Both version and latest tags point to same image
                enterpriseImage.push(enterpriseRegistry + ":" + params.JET_VERSION)
                if (params.UPDATE_LATEST) {
                  enterpriseImage.push(enterpriseRegistry + ":latest")
                }
              }
            }
          }
        }
      }
  }
}  
