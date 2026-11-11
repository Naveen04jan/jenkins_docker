
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
                    powershell '''
                        $username = $env:DOCKER_USER.Trim()
                        $token = $env:DOCKER_TOKEN.Trim()

                        $token | docker login `
                            --username $username `
                            --password-stdin

                        if ($LASTEXITCODE -ne 0) {
                            throw "DockerHub login failed"
                        }

                        Write-Host "DockerHub login successful"
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
                    docker stop myapp-container 2>NUL
                    docker rm myapp-container 2>NUL

                    docker run -d -p 5000:5000 --name myapp-container %DOCKER_IMAGE%:%DOCKER_TAG%
                '''
            }
        }
    }
}
