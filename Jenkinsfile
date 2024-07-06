pipeline {
    agent {
        kubernetes { label 'python' }
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
                }
            }
        }

        stage('Unit Tests') {
            steps {
                container('python') {
                    echo 'Running tests...'
                    sh 'nosetests -v test'
                }
            }
        }

        stage('Integration tests') {
            steps {
                container('python') {
                    echo 'Executing integration tests...'
                    sh 'nosetests -v int_test'
                }
            }
        }

        stage('Static Code Analysis') {
            environment {
                SONAR_URL = 'http://54.212.5.74:9000'
            }
        }
    }
}
