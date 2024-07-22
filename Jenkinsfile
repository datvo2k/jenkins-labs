pipeline {
    agent {kubernetes {label "python && docker-agent"}}
    environment {
        // def scannerHome = tool name: 'sonar_scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation';
        DIRECTORY = './jenkins-labs'
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credential')
        APP_NAME = "brianvo/flaskdemodevops"
    }
    stages {
        stage('Checkout') {
            steps {
                container('python') {
                    echo 'Code checkout.'
                    git branch: 'main', url: 'https://github.com/datvo2k/flask-demo-devops.git'
                }
            }
        }

        stage('Prepare') {
            steps {
                container('python') {
                    echo 'Installing required packages...'
                    sh 'pip3 install -r requirements.txt'
                    reuseNode true
                }
            }
        }

        stage('Unit Tests') {
            steps {
                container('python') {
                    echo 'Running tests...'
                    sh 'nosetests -v test'
                    reuseNode true
                }
            }
        }

        stage('Integration tests') {
            steps {
                container('python') {
                    echo 'Executing integration tests...'
                    sh 'nosetests -v int_test'
                    reuseNode true
                }
            }
        }

        stage('Build image') {
            steps {
                container('python') {
                    script { 
                        withDockerRegistry(credentialsId: ${DOCKERHUB_CREDENTIALS}, toolName: 'docker') {
                            sh 'dockerd & > /dev/null'
                            sh "docker build  -t $APP_NAME:$BUILD_NUMBER ."
                            reuseNode true
                        }
                    }
                }
            }
        }

        // stage('SonarQube Code Analysis') {
        //     steps {
        //         container('python') {
        //             script {
        //                 withSonarQubeEnv('SonarQube-server') {
        //                     def sonarqubeScannerHome = tool 'SonarQube-Scanner-1'
        //                     sh "echo $pwd"
        //                     sh "${sonarqubeScannerHome}/bin/sonar-scanner"
        //                 }
        //             }
        //         }
        //     }
        // }
    }
}
