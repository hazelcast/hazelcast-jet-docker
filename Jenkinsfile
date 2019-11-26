pipeline {
  environment {
    ossRegistry = "hazelcast/hazelcast-jet"
    ossImage = ''
  }
  agent { label 'lab' }
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
              ossImage.push()
            } 
          }
        }
      }
    stage('Building the Enterprise image') {
        steps{
          script {
            ossImage = docker.build(ossRegistry + ":latest-snapshot", "--force-rm --no-cache --build-arg JET_VERSION=$JET_VERSION ./hazelcast-jet-enterprise" )
          }
        }
      }
    stage('‘Deploying Enterprise image') {
        steps{
          script {
            docker.withRegistry('', 'devopshazelcast-dockerhub') {
              ossImage.push()
            } 
          }
        }
      }
  }
}  
