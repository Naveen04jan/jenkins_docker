
pipeline {
    agent any

    stages {

        stage('Build Docker Image') {
            steps {
                bat '''
                    docker build -t naveen04jan/my-python-app3:latest .
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    powershell '''
                        $ErrorActionPreference = "Stop"

                        $env:DOCKER_TOKEN |
                            docker login -u $env:DOCKER_USER --password-stdin

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
                bat '''
                    docker push naveen04jan/my-python-app3:latest
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                bat '''
                    docker stop my-python-container 2>NUL
                    docker rm my-python-container 2>NUL

                    docker run -d ^
                    --name my-python-container ^
                    -p 5000:5000 ^
                    naveen04jan/my-python-app3:latest
                '''
            }
        }
    }
}
