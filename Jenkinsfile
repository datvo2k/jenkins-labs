pipeline {
    agent none
    environment {
        // def scannerHome = tool name: 'sonar_scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation';
        DIRECTORY = './jenkins-labs'
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credential')
        APP_NAME = "brianvo/flaskdemodevops"
    }
    stages {
        stage('Checkout') {
            agent {
                label 'python'
                reuseNode true
            }
            steps {
                container('python') {
                    echo 'Code checkout.'
                    git branch: 'main', url: 'https://github.com/datvo2k/flask-demo-devops.git'
                }
            }
        }

        stage('Prepare') {
            agent {
                label 'python'
                reuseNode true
            }
            steps {
                container('python') {
                    echo 'Installing required packages...'
                    sh 'pip3 install -r requirements.txt'
                }
            }
        }

        stage('Unit Tests') {
            agent {
                label 'python'
                reuseNode true
            }
            steps {
                container('python'){
                    echo 'Running tests...'
                    sh 'nosetests -v test'
                }
            }
        }

        stage('Integration tests') {
            agent {
                label 'python'
                reuseNode true
            }
            steps {
                echo 'Executing integration tests...'
                sh 'nosetests -v int_test'
            }
        }

        stage('Build image') {
            agent { 
                label 'docker-agent' 
            }
            steps {
                script { 
                    dockerImage = docker.build APP_NAME + ":$BUILD_NUMBER"
                }
            }
        }
    }
}
