
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "naveen04jan/my-python-app3"
        DOCKER_TAG = "latest"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .'
            }
        }

      stage('Login to DockerHub') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'dockerhub-creds',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_TOKEN'
            )
        ]) {
            bat '''
                powershell -NoProfile -NonInteractive -Command "$env:DOCKER_TOKEN | docker login -u $env:DOCKER_USER --password-stdin"

                if errorlevel 1 exit /b 1
            '''
        }
    }
}

        stage('Push Image') {
            steps {
                bat 'docker push %DOCKER_IMAGE%:%DOCKER_TAG%'
            }
        }

        stage('Deploy Container') {
            steps {
                bat '''
                docker stop myapp-container 2>NUL || exit /b 0
                docker rm myapp-container 2>NUL || exit /b 0
                docker run -d -p 5000:5000 --name myapp-container %DOCKER_IMAGE%:%DOCKER_TAG%
                '''
            }
        }
    }
}

