pipeline {
  agent any

  parameters {
    string(name: 'INSTANCE_NAME', trim: true)
    string(name: 'EMAIL', trim: true)
  }

  environment {
    SSH_KEY_ID = 'deploy-ssh-key'
    MAILTRAP_CRED_ID = 'mailtrap-creds'
    REMOTE_HOST = "181.209.203.138:1722"
    REMOTE_USER = "jcruz"
    REMOTE_BASE_DIR = "/home/jcruz"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validacion de parámetros') {
      steps {
        script {
          if (!params.INSTANCE_NAME) {
            error "Se requiere INSTANCE_NAME"
          }
          if (!params.EMAIL) {
            error "Se requiere EMAIL"
          }
        }
      }
    }

    stage('Despliegue con Ansible') {
      steps {
        sshagent(credentials: [env.SSH_KEY_ID]) {
          sh """
            ansible-playbook deploy/deploy.yml \
              -i deploy/inventory.ini \
              --extra-vars "
                instance_name=${params.INSTANCE_NAME}
                email=${params.EMAIL}
                remote_base_dir=${env.REMOTE_BASE_DIR}
              "
          """
        }
      }
    }

  }

  post {
    success {
      echo "Despliegue exitoso"
    }
    failure {
      echo "Fallo despliegue"
    }
  }
}