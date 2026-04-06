pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "your-dockerhub-username/myapp-image"
        DOCKER_TAG = "latest"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git 'https://github.com/your-username/my-python-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image') {
            steps {
                sh 'docker push $DOCKER_IMAGE:$DOCKER_TAG'
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker stop myapp-container || true
                docker rm myapp-container || true
                docker run -d -p 5000:5000 --name myapp-container $DOCKER_IMAGE:$DOCKER_TAG
                '''
            }
        }
    }
}
