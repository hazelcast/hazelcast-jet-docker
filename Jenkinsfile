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
          ossImage = docker.build(ossRegistry + ":latest-snapshot", "--build-arg JET_VERSION=$JET_VERSION ./hazelcast-jet-oss" )
        }
      }
    }
	stage('‘Deploying image') {
      steps{
        script {
	        docker.withRegistry('', '73f14c4e-5562-4e19-9a06-0873e83ade24') {
		        ossImage.push()
        	} 
        }
      }
    }
  }
}  
