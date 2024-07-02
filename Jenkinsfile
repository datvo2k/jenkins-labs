pipeline {
    agent {
        node {
            label 'jenkins-python'
        }
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Code checkout.'
                git branch: 'main', url: 'https://github.com/datvo2k/flask-demo-devops.git'
            }
        }

        stage('Prepare') {
            steps {
                echo 'Installing required packages...'
                sh 'venv/bin/python -m pip install -r requirements.txt'
            }
        }

        stage('Unit Tests') {
            steps {             
                echo 'Running tests...'
                sh 'nosetests -v test'
            }
        }

        stage('Integration tests') {
            steps {
                echo "execute integration tests"
                sh "nosetests -v int_test"
            }
        }

    }
}