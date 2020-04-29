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
            ossImage = docker.build(ossRegistry + ":latest", "--force-rm --no-cache ./hazelcast-jet-oss" )
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
            enterpriseImage = docker.build(enterpriseRegistry + ":latest", "--force-rm --no-cache ./hazelcast-jet-enterprise" )
          }
        }
      }
    stage('‘Deploying Enterprise image') {
        steps{
          script {
            docker.withRegistry('', 'devopshazelcast-dockerhub') {
              enterpriseImage.push()
            } 
          }
        }
      }
  }
}  
