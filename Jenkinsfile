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

    stage('Start Docker Compose') {
      steps {
        echo "🚀 Lancement des services Docker"
        sh '''
          docker-compose down || true
          docker-compose up -d --build
          sleep 10
          docker-compose ps
          docker-compose exec -T php php -v || (echo "❌ Le conteneur PHP ne fonctionne pas !" && exit 1)
        '''
      }
    }

    stage('Install Dependencies') {
      steps {
        echo "📦 Installation des dépendances avec Composer"
        sh 'docker-compose exec -T php composer install --no-interaction --optimize-autoloader'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        echo "📊 Analyse de code avec SonarQube"
        withSonarQubeEnv('SONAR_TOKEN') {
          sh '''
            sonar-scanner \
              -Dsonar.projectKey=symfony-devops \
              -Dsonar.projectName="Symfony DevOps" \
              -Dsonar.sources=. \
              -Dsonar.php.coverage.reportPaths=coverage.xml \
              -Dsonar.host.url=$SONAR_HOST_URL \
              -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "🐳 Construction de l’image Docker"
        sh 'docker build -t symfony-devops-app .'
      }
    }

    stage('Push to DockerHub') {
      steps {
        echo "🔐 Connexion et push vers Docker Hub"
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

    stage('Deploy with Ansible') {
      steps {
        echo "🚀 Déploiement via Ansible"
        sh 'ansible-playbook -i ansible/inventory ansible/playbook-local.yml'
      }
    }
  }

  post {
    always {
      echo '📋 Pipeline terminée.'
    }
    success {
      echo '✅ Pipeline exécutée avec succès.'
    }
    failure {
      echo '❌ Une erreur est survenue durant l’exécution de la pipeline.'
    }
  }
}
