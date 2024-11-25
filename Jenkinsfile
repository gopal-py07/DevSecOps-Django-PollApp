pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/gopal-py07/CI-CD-Python-Django-Poll-App-Docker-Kubernet-minikube-.git'
        DOCKER_IMAGE = "gopalghule05/lnx_poll_prj_jenkins:${env.BUILD_NUMBER}"
        DOCKER_COMPOSE_FILE = "${env.WORKSPACE}/docker-compose.yml"
        DEPLOYMENT_YML_PATH = "${env.WORKSPACE}/deployment.yml"
        MINIKUBE_PATH = '/usr/local/bin/minikube'
        KUBECTL_PATH = '/usr/local/bin/kubectl'
        SERVICE_NAME = 'django-backend-poll-app-jenkins-service'
        SONARQUBE_SERVER = 'http://172.27.231.128:9000/'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Code Quality Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    sudo sonar-scanner \
                    -Dsonar.projectKey=pollpp \
                    -Dsonar.sources=${env.WORKSPACE} \
                    -Dsonar.host.url=${SONARQUBE_SERVER} \
                    -Dsonar.login=$SONAR_AUTH_TOKEN
                    """
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh "docker-compose -f ${DOCKER_COMPOSE_FILE} build --no-cache"
            }
        }

        stage('Push Docker Images to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh """
                    docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD
                    docker tag django-poll-app ${DOCKER_IMAGE}
                    docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Security Scan') {
            steps {
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh "snyk auth $SNYK_TOKEN"
                    sh "snyk test"
                    sh "snyk monitor"
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                script {
                    sh "${KUBECTL_PATH} apply --dry-run=client -f ${DEPLOYMENT_YML_PATH}"
                    sh "${KUBECTL_PATH} apply -f ${DEPLOYMENT_YML_PATH}"
                }
            }
        }

        stage('Expose Kubernetes Service') {
            steps {
                script {
                    def serviceExists = sh(script: "${KUBECTL_PATH} get service ${SERVICE_NAME}", returnStatus: true)
                    if (serviceExists != 0) {
                        sh "${KUBECTL_PATH} expose deployment ${SERVICE_NAME} --type=LoadBalancer --port=8000"
                    }
                }
            }
        }

        stage('Verify Minikube Service') {
            steps {
                script {
                    sh "${MINIKUBE_PATH} service list"
                    sh "${MINIKUBE_PATH} service ${SERVICE_NAME}"
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up resources..."
            sh "docker-compose -f ${DOCKER_COMPOSE_FILE} down"
        }
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs for details."
        }
    }
}
