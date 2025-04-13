pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'MySonarServer' // Must match Jenkins' SonarQube config name
    }

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t demo-app .'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh './gradlew test' // or `python -m unittest` if you're using Python
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                    sh './gradlew sonarqube -Dsonar.projectKey=demo' // or sonar-scanner for non-Gradle projects
                }
            }
        }
    }
}
