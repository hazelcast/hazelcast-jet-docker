pipeline {
  environment {
    ossRegistry = "hazelcast/hazelcast-jet"
    ossImage = ''
  }
  agent { label 'lab' }
  stages {
	stage('Building image') {
      steps{
        script {
          ossImage = docker.build(ossRegistry + ":latest-snapshot", "--force-rm --no-cache --build-arg JET_VERSION=$JET_VERSION ./hazelcast-jet-oss" )
        }
      }
    }
	stage('‘Deploying image') {
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
