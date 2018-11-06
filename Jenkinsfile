pipeline {
  environment {
    registry = "hazelcast/hazelcast-jet"
    dockerImage = ''
  }
  agent { label 'lab' }
  stages {
	stage('Building image') {
      steps{
        script {
          dockerImage = docker.build(registry + ":latest-snapshot", "--build-arg JET_VERSION=$JET_VERSION ." )
        }
      }
    }
	stage('‘Deploy image') {
      steps{
        script {
	        docker.withRegistry('', '73f14c4e-5562-4e19-9a06-0873e83ade24') {
		        dockerImage.push()
        	} 
        }
      }
    }
  }
}  
