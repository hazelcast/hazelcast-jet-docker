pipeline {
  environment {
    ossRegistry = "hazelcast/hazelcast-jet"
    enterpriseRegistry = "hazelcast/hazelcast-jet-enterprise"
    ossImage = ''
    enterpriseImage = ''
  }
  agent { label 'lab' }
  stages {
    stage('Building the OSS image') {
        steps{
          script {
            ossImage = docker.build(ossRegistry + ":current", "--force-rm --no-cache --build-arg JET_VERSION=$JET_VERSION ./hazelcast-jet-oss" )
          }
        }
      }
    stage('‘Deploying OSS image') {
        steps{
          script {
            docker.withRegistry('', 'devopshazelcast-dockerhub') {
              if (params.JET_VERSION.contains("SNAPSHOT")) {
                // Pushes latest-snapshot
                ossImage.push("latest-snapshot")
              } else {
                // Both version and latest tags point to same image
                ossImage.push(params.JET_VERSION)
                if (params.UPDATE_LATEST) {
                  ossImage.push("latest")
                }
              }
            } 
          }
        }
      }
    stage('Building the Enterprise image') {
        steps{
          script {
            enterpriseImage = docker.build(enterpriseRegistry + ":current", "--force-rm --no-cache --build-arg JET_VERSION=$JET_VERSION ./hazelcast-jet-enterprise" )
          }
        }
      }
    stage('‘Deploying Enterprise image') {
        steps{
          script {
            docker.withRegistry('', 'devopshazelcast-dockerhub') {
              if (params.JET_VERSION.contains("SNAPSHOT")) {
                // Pushes latest-snapshot
                enterpriseImage.push("latest-snapshot")
              } else {
                // Both version and latest tags point to same image
                enterpriseImage.push(params.JET_VERSION)
                if (params.UPDATE_LATEST) {
                  enterpriseImage.push("latest")
                }
              }
            }
          }
        }
      }
  }
}  
