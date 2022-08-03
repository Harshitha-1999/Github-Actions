@Library('jenkins-shared-library') _
#@Library('jenkins-shared-library@feature/AKS-JAR') _

pipeline {

  options {
    ansiColor('xterm')
  }

  environment {
    registry = albUtils.getRegistry(registry_type)
    registryCredential = albUtils.getRegistryCredentials(registry_type)
    dockerfile           = 'Dockerfile'
    registryRepo         = "/${application_name.toLowerCase()}/${git_repo}"
    CommitId             = 'False'
    imageURI             = "${registry}${registryRepo}:${env.BUILD_NUMBER}"
    VeraAppid            = "${git_repo}-${env.BUILD_NUMBER}"
    VeraAppName          = "ME01r"
    AbortOnFail          = true
    CompliancePolicy     = 'warn'
    VulnerabilityPolicy  = 'warn'
    RemoveImageOnPublish = false
    logLevel = 'debug' 
    BRANCH_NAME          = "feature/azure_migration"
  }

  agent { 
    label 'platform-ff'
  }
	
  /*agent { 
    label 'Jenkins_Agent1'
  }*/

  /*triggers {
    pollSCM 'H/5 * * * *'
  }*/
  
   stages { 
    stage('SonarQube Analysis') {
      steps {
        script {
          echo "valiating ${BRANCH_NAME}"    
          withSonarQubeEnv('sonar') {
   def BRANCH_NAME = albUtils.getSonarBranch()
    	  String version = Runtime.class.getPackage().getImplementationVersion()
    	  if(version.contains("1.8")){
	        sh '''export JAVA_HOME=/usr/lib/jvm/jdk11/jdk-11.0.9.1+1   
             mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent install org.jacoco:jacoco-maven-plugin:report 
             export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk'''	
    	    sh '''export JAVA_HOME=/usr/lib/jvm/jdk11/jdk-11.0.9.1+1 
	            mvn sonar:sonar -Dsonar.branch.name=feature/azure_migration
	            export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk'''
    	  }
		         else{
			           sh "mvn sonar:sonar -Dsonar.branch.name=feature/azure_migration"
		      }
    }
        }
      }
    }
	   
    /*stage('Build, Test & SonarQube Analysis') {
    when { allOf { environment name: 'application_type', value: 'java' } }
      steps {
        script {
        echo "${env.imageURI}"
          albBuild.sonarMavenExec()
        }
      }
    } */
	   
     /* stage('Build, Test, Coverage and sonar') {
      when { allOf { environment name: 'application_type', value: 'nodejs' } }
       steps {
        script {  
          albBuild.npmHeadless()
        } 
      }
    } */ 
	   
    stage('SonarQube Quality Gate') {
    when { allOf { environment name: 'application_type', value: 'java' } }
      steps {
        script {
          albBuild.sonarQualityGate(AbortOnFail)
        }
      }
    }
	   
	   
    stage('Veracode Scan') {
    when { allOf { environment name: 'application_type', value: 'java' } }
      steps {
        script {
          albBuild.veraCodeScan(VeraAppid, AbortOnFail, VeraAppName)
        }
      }
    }   
	   
    /*stage('Veracode nodejs Scan') {
    when { allOf { environment name: 'application_type', value: 'nodejs' } }
      steps {
        script {
          sh """tar -czvf node_modules.tar.gz node_modules"""
          albBuild.veraCodeScannj(VeraAppid, AbortOnFail, VeraAppName)
        }
      }
    }*/
	   
    stage('maven build') {
    steps {
       sh 'mvn -B -DskipTests clean package -P Azure'
       sh 'mv target/*SNAPSHOT.jar target/me01r-rest-sprboot.jar'
     }
   }
    


    stage('Docker build image') {
      steps{
        script {
          dockerImage = albBuild.buildDockerTaggedImage(registry, registryRepo, dockerfile)
        }
      }
    }

    stage('Twistlock Analysis') {
      steps {
        script {
          albBuild.twistscanDockerImage(imageURI, logLevel)
        }
      }
    }

    stage('Docker push image to ACR or GCR') {
      steps{
        script {
          albBuild.publishDockerImage(registry, registryCredential, dockerImage, imageURI, removeAfterPublish = RemoveImageOnPublish)
        }
      }
    }

  }

  post {
    failure {
      script {
        albNotify.emailNotify()
      }
    }
    always {
      script {
        albBuild.twistscanPublish()
        addShortText(text: GIT_BRANCH, borderColor: 'BLUE', color: 'GREEN')
      }
    }
    cleanup {
      script {
        albBuild.removeDockerImage(imageURI)
      }
    }
  }

}
