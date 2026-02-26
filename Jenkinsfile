pipeline {
  agent any

  parameters {
    string(name: 'INSTANCE_NAME', trim: true)
    string(name: 'EMAIL', trim: true)
  }

  environment {
    SSH_KEY_ID = 'deploy-ssh-key'
    MAILTRAP_CRED_ID = 'mailtrap-creds'
    REMOTE_HOST = "192.168.3.22"
    REMOTE_USER = "jcruz"
    REMOTE_BASE_DIR = "/home/jcruz"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate parameters') {
      steps {
        script {
          if (!params.INSTANCE_NAME) {
            error "INSTANCE_NAME is required"
          }
          if (!params.EMAIL) {
            error "EMAIL is required"
          }
        }
      }
    }

    stage('Deploy with Ansible') {
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
      echo "Deployment successful"
    }
    failure {
      echo "Deployment failed"
    }
  }
}