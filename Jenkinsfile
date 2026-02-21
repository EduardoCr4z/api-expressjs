// Jenkinsfile
pipeline {
  agent any
  parameters {
    string(name: 'INSTANCE_NAME', defaultValue: '', description: 'Nombre para la instancia (ej: inst1)')
    string(name: 'EMAIL', defaultValue: '', description: 'Correo donde enviar la URL (destino Mailtrap)')
  }
  environment {
    // IDs de credenciales en Jenkins - crear estos en Jenkins Credentials
    SSH_KEY_ID = 'deploy-ssh-key'         // ssh private key credential (type: SSH Username with private key OR secret file)
    MAILTRAP_CRED_ID = 'mailtrap-creds'  // username/password credential in Jenkins
    ANSIBLE_INVENTORY = 'inventory.ini'  // si tienes inventory en repo, lo usaremos; si no, lo generamos.
    REMOTE_BASE_DIR = "/opt/instances"   // base path remoto donde se crearán las instancias
    REMOTE_HOST = "5.189.179.95"
    REMOTE_USER = "eduardo"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate params') {
      steps {
        script {
          if (!params.INSTANCE_NAME?.trim()) {
            error "INSTANCE_NAME is required"
          }
          if (!params.EMAIL?.trim()) {
            error "EMAIL is required"
          }
        }
      }
    }

    stage('Compute ports & names') {
      steps {
        script {
          def name = params.INSTANCE_NAME ?: "default"

          def crc = new java.util.zip.CRC32()
          crc.update(name.getBytes("UTF-8"))

          def mod = (crc.getValue() % 1000) as int

          env.BACKEND_PORT = (4000 + mod).toString()
          env.MYSQL_PORT = (6000 + mod).toString()
          env.CONTAINER_SUFFIX = name.replaceAll("[^a-zA-Z0-9_-]", "_")

          echo "Instance: ${name} -> backend host port ${env.BACKEND_PORT}, mysql host port ${env.MYSQL_PORT}"
        }
      }
    }

    stage('Render templates') {
      steps {
        script {
          // We will fill Jinja2 templates using envsubst (or simple sed). We'll do it via Jenkins shell.
          writeFile file: 'render_vars.sh', text: """#!/bin/bash
                                                        INSTANCE_NAME='${params.INSTANCE_NAME}'
                                                        CONTAINER_SUFFIX='${env.CONTAINER_SUFFIX}'
                                                        BACKEND_PORT='${env.BACKEND_PORT}'
                                                        MYSQL_PORT='${env.MYSQL_PORT}'
                                                        REMOTE_BASE_DIR='${env.REMOTE_BASE_DIR}'
                                                        """ 
          sh 'chmod +x render_vars.sh'
          // Render docker-compose.j2 to docker-compose.yml using envsubst approach
         writeFile file: 'render.py', text: '''
import os
from jinja2 import Template

with open('deploy/docker-compose.j2') as f:
    tpl = Template(f.read())

with open('docker-compose.yml','w') as out:
    out.write(tpl.render(
        instance_name=os.environ['INSTANCE_NAME'],
        container_suffix=os.environ['CONTAINER_SUFFIX'],
        backend_port=os.environ['BACKEND_PORT'],
        mysql_port=os.environ['MYSQL_PORT']
    ))

with open('deploy/.env.j2') as f:
    tpl = Template(f.read())

with open('.env','w') as out:
    out.write(tpl.render(
        instance_name=os.environ['INSTANCE_NAME']
    ))

print("Rendered docker-compose.yml and .env")
'''

sh '''
source ./render_vars.sh
python3 render.py
'''
        }
      }
    }

    stage('Run Ansible deploy') {
      steps {
        // Use SSH key stored in Jenkins. We assume ansible is installed on the agent.
        sshagent (credentials: [env.SSH_KEY_ID]) {
          sh """
            # copy inventory if exists in repo or create a dynamic inventory
            cat > inventory.ini <<EOF
            [webservers]
            ${env.REMOTE_HOST} ansible_user=${env.REMOTE_USER}
            EOF

            ansible-playbook -i inventory.ini deploy.yml --extra-vars "instance_name=${params.INSTANCE_NAME} backend_port=${env.BACKEND_PORT} mysql_port=${env.MYSQL_PORT} remote_base_dir=${env.REMOTE_BASE_DIR}"
          """
        }
      }
    }

    stage('Verify & notify') {
      steps {
        script {
          // Verify status on remote host via ssh. We use sshagent again.
          sshagent (credentials: [env.SSH_KEY_ID]) {
            sh """
              echo "Checking containers on remote..."
              ssh -o StrictHostKeyChecking=no ${env.REMOTE_USER}@${env.REMOTE_HOST} "docker ps --filter name=${env.CONTAINER_SUFFIX} --format '{{.Names}} {{.Status}}'"
            """
          }

          // Send email via Mailtrap using stored Jenkins creds (username/password)
          withCredentials([usernamePassword(credentialsId: env.MAILTRAP_CRED_ID, usernameVariable: 'MAILTRAP_USER', passwordVariable: 'MAILTRAP_PASS')]) {
            sh """
              python3 - <<PY
                import smtplib, os
                from email.message import EmailMessage
                msg = EmailMessage()
                msg['Subject'] = 'API desplegada: ${params.INSTANCE_NAME}'
                msg['From'] = 'no-reply@example.com'
                msg['To'] = '${params.EMAIL}'
                body = f\"La API está disponible en: http://{env.REMOTE_HOST}:{env.BACKEND_PORT}/\\nInstancia: ${params.INSTANCE_NAME}\"
                msg.set_content(body)
                # Mailtrap SMTP (default port 2525)
                smtp_user = os.environ['MAILTRAP_USER']
                smtp_pass = os.environ['MAILTRAP_PASS']
                s = smtplib.SMTP('smtp.mailtrap.io', 2525)
                s.login(smtp_user, smtp_pass)
                s.send_message(msg)
                s.quit()
                print('Email sent to ${params.EMAIL}')
                PY
                """
          }
        }
      }
    }
  } // stages

  post {
    failure {
      echo "Deployment failed"
    }
  }
}