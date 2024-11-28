pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/gopal-py07/CI-CD-Python-Django-Poll-App-Docker-Kubernet-minikube-.git'
       //DOCKER_IMAGE = "gopalghule05/lnx_poll_prj_jenkins:${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "gopalghule05/lnx_poll_prj_argocd:g1"
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
        stage('SonarQube Quality Gate') {
            steps {
                echo "Checking SonarQube Quality Gate..."
                script {
                    def qualityGate = waitForQualityGate()
                    if (qualityGate.status != 'OK') {
                        error "Pipeline failed due to SonarQube Quality Gate failure: ${qualityGate.status}"
                    }
                    else {
                                echo "Quality Gate passed: ${qualityGate.status}"
                            }    
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh "docker-compose -f ${DOCKER_COMPOSE_FILE} build --no-cache"
            }
        }
        stage('Scan Docker Image') {
            steps {
                echo "Scanning Docker image for vulnerabilities..."
                sh """
                ${TRIVY_IMAGE_SCANNER} image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_IMAGE} || echo 'Vulnerabilities detected!'
                """
            }
        }

        stage('Push Docker Images to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'DOCKERHUB_TOKEN', variable: 'DOCKERHUB_TOKEN')]) {
                    sh """
                    echo $DOCKERHUB_TOKEN | docker login -u gopalghule05 --password-stdin
                    docker push ${DOCKER_IMAGE}
                    """
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
