pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/ton-repo/symfony-devops.git'
            }
        }
        stage('Composer Install') {
            steps {
                sh 'docker-compose exec php composer install'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarQube') {
                    sh 'docker-compose exec php ./vendor/bin/phpunit'
                    sh 'sonar-scanner -Dsonar.projectKey=symfony -Dsonar.sources=./app -Dsonar.php.coverage.reportPaths=coverage.xml'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t myapp/symfony .'
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker tag myapp/symfony $USER/myapp-symfony'
                    sh 'docker push $USER/myapp-symfony'
                }
            }
        }
        stage('Ansible Deploy') {
            steps {
                sh 'ansible-playbook -i ansible/inventory ansible/playbook.yml'
            }
        }
    }
}
