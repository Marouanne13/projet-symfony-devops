pipeline {
    agent any

    stages {
        stage('Composer Install') {
            steps {
                sh 'docker-compose up -d'
                sh 'docker-compose exec php composer install || true'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarQube') {
                    sh 'docker-compose exec php ./vendor/bin/phpunit || true'
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=symfony \
                        -Dsonar.sources=./app \
                        -Dsonar.php.coverage.reportPaths=coverage.xml
                    '''
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
                    sh '''
                        echo $PASS | docker login -u $USER --password-stdin
                        docker tag myapp/symfony $USER/myapp-symfony
                        docker push $USER/myapp-symfony
                    '''
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                sh 'ansible-playbook -i ansible/inventory ansible/playbook.yml || true'
            }
        }
    }
}
