pipeline {
    agent any

    environment {
        // Defines the Docker Compose project name
        COMPOSE_PROJECT_NAME = "devops_resume_analyser"
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                // 'checkout scm' only works if Jenkins pulls this Jenkinsfile directly from Git.
                // Since you pasted it manually, you must explicitly tell Jenkins where the code is:
                git branch: 'master', url: 'https://github.com/Mihit10/devops-resume-analyser.git'
            }
        }

        stage('Code Quality (SonarQube)') {
            steps {
                // Runs the SonarQube Scanner against the codebase
                // Note: Requires SonarQube Scanner plugin installed in Jenkins
                script {
                    // 'sonar-scanner' must be configured in Jenkins Global Tool Configuration
                    def scannerHome = tool 'sonar-scanner'
                    // 'sonar-server' must be configured in Jenkins System Configuration
                    withSonarQubeEnv('sonar-server') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=devops_resume_analyser -Dsonar.sources=."
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Pauses the pipeline until SonarQube finishes its analysis.
                // Aborts the build if the code fails the quality standards.
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build & Start App (Docker)') {
            steps {
                // Uses the host's Docker daemon (via the socket we mounted in Terraform)
                // to build and run the Next.js and Python containers
                sh 'docker compose build'
                sh 'docker compose up -d frontend backend'
            }
        }

        stage('Automated UI Testing (Selenium)') {
            steps {
                // Wait briefly for the Next.js server to fully start
                sh 'sleep 10'
                
                // Spin up a temporary Python container on the same Docker network 
                // to run the Selenium Pytest scripts against the running frontend
                sh '''
                docker run --rm --network ${COMPOSE_PROJECT_NAME}_default \\
                -v ${WORKSPACE}/tests/e2e:/tests -w /tests \\
                python:3.10-slim /bin/bash -c "
                  apt-get update && apt-get install -y wget gnupg && \\
                  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \\
                  sh -c 'echo \\"deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main\\" >> /etc/apt/sources.list.d/google.list' && \\
                  apt-get update && apt-get install -y google-chrome-stable && \\
                  pip install -r requirements.txt && \\
                  pytest test_homepage.py -v
                "
                '''
            }
        }

        stage('Deploy') {
            steps {
                // Placeholder for actual deployment logic (e.g. pushing to AWS ECR)
                echo "All tests passed! Deploying the latest Docker images to Production..."
            }
        }
    }

    post {
        always {
            // Clean up: shut down the app containers so the next build starts fresh
            sh 'docker compose down'
            cleanWs()
        }
        success {
            echo "Pipeline executed successfully! The new version is live."
        }
        failure {
            echo "Pipeline failed! Code did not pass quality gates or tests."
        }
    }
}
