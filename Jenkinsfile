
pipeline {
    agent any

    stages {

        stage('Docker Environment Check') {
    steps {
        powershell '''
            Write-Host "Windows User:"
            whoami

            Write-Host "Docker Executable:"
            (Get-Command docker).Source

            Write-Host "Docker Version:"
            docker --version

            Write-Host "User Profile:"
            Write-Host $env:USERPROFILE

            Write-Host "Proxy Configuration:"
            Write-Host "HTTP_PROXY present: $([bool]$env:HTTP_PROXY)"
            Write-Host "HTTPS_PROXY present: $([bool]$env:HTTPS_PROXY)"
        '''
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
                $ErrorActionPreference = "Stop"

                $psi = New-Object System.Diagnostics.ProcessStartInfo
                $psi.FileName = "docker.exe"
                $psi.Arguments = "login -u $env:DOCKER_USER --password-stdin"
                $psi.UseShellExecute = $false
                $psi.RedirectStandardInput = $true
                $psi.RedirectStandardOutput = $true
                $psi.RedirectStandardError = $true
                $psi.CreateNoWindow = $true

                $process = New-Object System.Diagnostics.Process
                $process.StartInfo = $psi

                [void]$process.Start()

                $bytes = [System.Text.Encoding]::UTF8.GetBytes(
                    $env:DOCKER_TOKEN + "`n"
                )

                $process.StandardInput.BaseStream.Write(
                    $bytes, 0, $bytes.Length
                )

                $process.StandardInput.Close()

                $output = $process.StandardOutput.ReadToEnd()
                $errorOutput = $process.StandardError.ReadToEnd()

                $process.WaitForExit()

                Write-Host $output

                if ($process.ExitCode -ne 0) {
                    Write-Host $errorOutput
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
