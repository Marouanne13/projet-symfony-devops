pipeline {
  agent any

  environment {
    SONAR_TOKEN = 'squ_1ff12c102b3b9c50acdd91aa28d76ba11515b23c'
    SONAR_HOST_URL = 'http://10.0.2.15:9000'  // IP locale Debian
  }

  stages {

    stage('Checkout') {
      steps {
        echo "🛎 Clonage du dépôt Symfony DevOps"
        git url: 'https://github.com/Marouanne13/projet-symfony-devops.git', branch: 'main'
        sh 'ls -la'
      }
    }

    stage('Install Dependencies') {
      steps {
        echo "📦 Installation des dépendances avec Composer via Docker"
        sh '''
          docker run --rm \
            -v $(pwd):/app \
            -w /app \
            composer:2.5 \
            install --no-interaction --optimize-autoloader
        '''
      }
    }

    stage('Run PHPUnit & Coverage') {
      steps {
        echo "🧪 Lancement des tests avec couverture"
        sh '''
          ./vendor/bin/phpunit --coverage-clover=coverage.xml || echo "❌ PHPUnit a échoué"
          [ -f coverage.xml ] && echo "✅ coverage.xml trouvé" || echo "⚠️ coverage.xml manquant"
        '''
      }
    }

  stage('SonarQube Analysis') {
      steps {
        echo "📊 Analyse SonarQube avec le scanner Docker"
        withSonarQubeEnv('SonarLocal') {
          sh '''
            docker run --rm \
              -v $(pwd):/usr/src \
              -w /usr/src \
              sonarsource/sonar-scanner-cli:latest \
              sonar-scanner -X \
                -Dsonar.projectKey=symfony-devops \
                -Dsonar.projectName="Symfony DevOps" \
                -Dsonar.sources=src \
                -Dsonar.php.coverage.reportPaths=coverage.xml \
                -Dsonar.host.url=http://10.0.2.15:9000 \
                -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }
    

    stage('Start Docker Compose') {
      steps {
        dir('') {
          echo "🚀 Lancement des services Docker : Symfony, Prometheus, Grafana"
          sh '''
           
            docker-compose up -d --build
            docker-compose ps
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
        echo "📤 Push de l’image sur Docker Hub"
        withCredentials([usernamePassword(
          credentialsId: 'docker-hub-credentials',
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
        sh 'ansible-playbook -i ansible/inventory ansible/playbook.yml'
      }
    }


stage('Check Monitoring') {
  steps {
    echo "⏳ Attente du démarrage de Grafana & Prometheus"
    sh 'sleep 30'

    script {
      def prometheusStatus = sh(script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:9090', returnStdout: true).trim()
      def grafanaStatus = sh(script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:3001', returnStdout: true).trim()

      if (prometheusStatus != "200") {
        error "❌ Prometheus ne répond pas (HTTP ${prometheusStatus})"
      } else {
        echo "✅ Prometheus est UP"
      }

      if (grafanaStatus != "200") {
        error "❌ Grafana ne répond pas (HTTP ${grafanaStatus})"
      } else {
        echo "✅ Grafana est UP"
      }
    }
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
