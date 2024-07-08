pipeline {
    agent {
        kubernetes { label 'python' }
    }
    environment {
        // def scannerHome = tool name: 'sonar_scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation';
        DIRECTORY = './jenkins-labs'
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

        stage('SonarQube Code Analysis') {
            steps {
                container("python") {
                    withSonarQubeEnv("jenkins-python") {
                        sh '-Dsonar.projectKey=jenkins-python && -Dsonar.sources=. '
                    }
                }
            }
        }
        // stage('Quality Gate') {
        //     steps {
        //         container("python"){
        //             timeout(time: 1, unit: 'HOURS') {
        //                 script {
        //                     def qg = waitForQualityGate()
        //                     if (qg.status != 'OK') {
        //                         error "Pipeline aborted due to quality gate failure: ${qg.status}"
        //                     }
        //                     echo 'Quality Gate Passed'
        //                 }
        //             }
        //         }
        //     }
        // }
    }
}
