pipeline {
  agent any

  environment {
   SONAR_TOKEN = 'squ_1ff12c102b3b9c50acdd91aa28d76ba11515b23c'
    SONAR_HOST_URL = 'http://localhost:9000'
  } 

  stages {
    stage('Checkout') {
      steps {
        echo "🛎 Checkout du dépôt"
        git url: 'https://github.com/Marouanne13/projet-symfony-devops.git', branch: 'main'
        sh 'ls -la'
      }
    }

    stage('Docker Compose Start') {
      steps {
        echo "🚀 Démarrage des services Docker"
        sh '''
          docker-compose down || true
          docker-compose up -d
          sleep 5
          docker-compose ps
          docker-compose ps | grep php || (echo "❌ Conteneur PHP absent !" && exit 1)
        '''
      }
    }

    stage('Composer Install') {
      steps {
        echo "📦 Installation des dépendances Symfony"
        sh 'docker-compose exec php composer install --no-interaction --optimize-autoloader'
      }
    }

    stage('SonarQube: Start Analysis') {
      steps {
        echo "📊 Début de l’analyse SonarQube"
        withSonarQubeEnv('MySonarQube') {
          sh """
            sonar-scanner \
              -Dsonar.projectKey=symfony-devops \
              -Dsonar.projectName=\"Symfony DevOps\" \
              -Dsonar.sources=./app \
              -Dsonar.host.url=\$SONAR_HOST_URL \
              -Dsonar.login=\$SONAR_TOKEN
          """
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "🐳 Construction de l'image Docker de l'application"
        sh 'docker build -t symfony-devops-app .'
      }
    }

    stage('DockerHub Login & Push') {
      steps {
        echo "🔐 Connexion à Docker Hub et push"
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker tag symfony-devops-app $DOCKER_USER/symfony-devops-app:latest
            docker push $DOCKER_USER/symfony-devops-app:latest
          '''
        }
      }
    }

    stage('Ansible Deploy') {
      steps {
        echo "🎯 Déploiement avec Ansible"
        sh '''
       ansible-playbook -i ansible/inventory ansible/playbook-local.yml

        '''
      }
    }
  }

  post {
    always {
      echo '📋 Pipeline terminée (succès ou échec)'
    }
    success {
      echo '✅ Tout s’est bien passé !'
    }
    failure {
      echo '❌ Échec de la pipeline, consulte les logs.'
    }
  }
}
