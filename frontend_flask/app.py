from flask import Flask, render_template, request
import requests
from requests.auth import HTTPBasicAuth
import smtplib
from email.mime.text import MIMEText

app = Flask(__name__)

# ---------------------------
# CONFIGURACIÓN JENKINS
# ---------------------------

JENKINS_URL = "http://localhost:8080"
JOB_NAME = "deploy-backend"
JENKINS_USER = "admin"
JENKINS_TOKEN = "1171b9756c17f161957cbeaa3556a1b32a"

# ---------------------------
# CONFIGURACIÓN CORREO (Mailtrap)
# ---------------------------

SMTP_SERVER = "sandbox.smtp.mailtrap.io"
SMTP_PORT = 2525
SMTP_USER = "a6d8d3fd454e60"
SMTP_PASS = "70ce65ef699dd8"


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/solicitar', methods=['POST'])
def solicitar():
    instancia = request.form['instancia']
    correo_destino = request.form['correo']

    try:
        # ---------------------------
        # 1️⃣ ENVIAR CORREO
        # ---------------------------

        mensaje = f"""
Hola,

Tu solicitud fue recibida correctamente.

Instancia solicitada: {instancia}

Gracias por usar nuestro sistema.
        """

        msg = MIMEText(mensaje)
        msg['Subject'] = "Solicitud de instancia"
        msg['From'] = "no-reply@miapp.com"
        msg['To'] = correo_destino

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.login(SMTP_USER, SMTP_PASS)
            server.send_message(msg)

        # ---------------------------
        # 2️⃣ OBTENER CRUMB DE JENKINS
        # ---------------------------

        crumb_response = requests.get(
            f"{JENKINS_URL}/crumbIssuer/api/json",
            auth=HTTPBasicAuth(JENKINS_USER, JENKINS_TOKEN)
        )

        if crumb_response.status_code != 200:
            return f"Error obteniendo crumb: {crumb_response.status_code}"

        crumb_data = crumb_response.json()
        crumb = crumb_data['crumb']
        crumb_field = crumb_data['crumbRequestField']

        headers = {
            crumb_field: crumb
        }

        # ---------------------------
        # 3️⃣ DISPARAR JOB EN JENKINS
        # ---------------------------

        job_url = f"{JENKINS_URL}/job/{JOB_NAME}/buildWithParameters"

        params = {
            "INSTANCE_NAME": instancia,
            "EMAIL": correo_destino
        }

        response = requests.post(
            job_url,
            params=params,
            headers=headers,
            auth=HTTPBasicAuth(JENKINS_USER, JENKINS_TOKEN)
        )

        return f"""
Solicitud enviada correctamente<br>
Correo enviado a: {correo_destino}<br>
Jenkins status: {response.status_code}
        """

    except Exception as e:
        return f"Error: {str(e)}"


if __name__ == '__main__':
    app.run(debug=True)