
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'naveen04jan/my-python-app3'
        IMAGE_TAG = 'latest'
        CONTAINER_NAME = 'my-python-container'
        APP_PORT = '5000'
    }

    stages {

        // Stage 1: Build Docker Image
        stage('Build Docker Image') {
            steps {
                bat '''
                    docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% .
                '''
            }
        }

        // Stage 2: Docker Environment Check
        stage('Docker Environment Check') {
            steps {
                powershell '''
                    Write-Host "Windows User:"
                    whoami

                    Write-Host "Docker Version:"
                    docker --version

                    Write-Host "Docker Engine:"
                    docker info --format "{{.ServerVersion}}"
                '''
            }
        }

        // Stage 3: Login to Docker Hub
        stage('Login to DockerHub') {
            steps {
                withEnv(["DOCKER_CONFIG=${env.WORKSPACE}\\.docker"]) {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-creds',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_TOKEN'
                        )
                    ]) {
                        powershell '''
                            $ErrorActionPreference = "Stop"

                            New-Item -ItemType Directory `
                                -Force -Path $env:DOCKER_CONFIG | Out-Null

                            $psi = New-Object System.Diagnostics.ProcessStartInfo
                            $psi.FileName = "docker.exe"
                            $psi.Arguments = "--config `"$env:DOCKER_CONFIG`" login -u `"$env:DOCKER_USER`" --password-stdin"
                            $psi.UseShellExecute = $false
                            $psi.RedirectStandardInput = $true
                            $psi.RedirectStandardOutput = $true
                            $psi.RedirectStandardError = $true
                            $psi.CreateNoWindow = $true

                            $p = New-Object System.Diagnostics.Process
                            $p.StartInfo = $psi

                            [void]$p.Start()

                            $bytes = [System.Text.Encoding]::UTF8.GetBytes(
                                $env:DOCKER_TOKEN + "`n"
                            )

                            $p.StandardInput.BaseStream.Write(
                                $bytes, 0, $bytes.Length
                            )

                            $p.StandardInput.Close()

                            $output = $p.StandardOutput.ReadToEnd()
                            $errorOutput = $p.StandardError.ReadToEnd()

                            $p.WaitForExit()

                            Write-Host $output

                            if ($p.ExitCode -ne 0) {
                                Write-Host $errorOutput
                                throw "DockerHub login failed"
                            }

                            Write-Host "DockerHub login successful"
                        '''
                    }
                }
            }
        }

        // Stage 4: Push Docker Image
        stage('Push Image') {
            steps {
                withEnv(["DOCKER_CONFIG=${env.WORKSPACE}\\.docker"]) {
                    bat '''
                        docker push %DOCKER_IMAGE%:%IMAGE_TAG%
                    '''
                }
            }
        }

        // Stage 5: Deploy Container
        stage('Deploy Container') {
            steps {
                withEnv(["DOCKER_CONFIG=${env.WORKSPACE}\\.docker"]) {
                    bat '''
                        docker stop %CONTAINER_NAME% 2>NUL
                        docker rm %CONTAINER_NAME% 2>NUL

                        docker run -d ^
                            --name %CONTAINER_NAME% ^
                            -p %APP_PORT%:%APP_PORT% ^
                            %DOCKER_IMAGE%:%IMAGE_TAG%

                        docker ps
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
            echo 'Docker image pushed and application deployed.'
        }

        failure {
            echo 'CI/CD Pipeline failed. Check the Console Output.'
        }

        always {
            bat '''
                if exist "%WORKSPACE%\\.docker" (
                    rmdir /s /q "%WORKSPACE%\\.docker"
                )
            '''
            echo 'Pipeline execution completed.'
        }
    }
}
