pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/singh-pranjal/terraform-jenkins-setup-with-docker.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t cicd-app:latest .'
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                  docker rm -f cicd || true
                  docker run -d -p 80:80 --name cicd cicd-app:latest
                '''
            }
        }
    }
}
