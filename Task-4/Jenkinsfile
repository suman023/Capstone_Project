pipeline {
    agent any

    environment {
        AWS_IP = '107.23.4.68'
        AZURE_IP = '20.127.104.55'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/suman023/Capstone_Project.git'
            }
        }

        stage('Deploy to AWS') {
            steps {
                sh '''
                    scp -i ~/capstone-key.pem -o StrictHostKeyChecking=no index-aws.html ubuntu@${AWS_IP}:/var/www/html/index-aws.html
                    ssh -i ~/capstone-key.pem -o StrictHostKeyChecking=no ubuntu@${AWS_IP} "sudo systemctl restart nginx"
                '''
            }
        }

        stage('Deploy to Azure') {
            steps {
                sh '''
                    scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no index-azure.html azureuser@${AZURE_IP}:/var/www/html/index-azure.html
                    ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no azureuser@${AZURE_IP} "sudo systemctl restart nginx"
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
