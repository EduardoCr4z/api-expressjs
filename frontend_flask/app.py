from flask import Flask, render_template, request, redirect, url_for, flash
import requests
import os
from requests.auth import HTTPBasicAuth

app = Flask(__name__)
app.secret_key = "supersecretkey" 

JENKINS_URL = os.getenv("JENKINS_URL", "http://localhost:8080")
JOB_NAME = os.getenv("JOB_NAME", "deploy-backend")
JENKINS_TRIGGER_TOKEN = os.getenv("JENKINS_TRIGGER_TOKEN", "deploytoken123")

JENKINS_USER = os.getenv("JENKINS_USER", "admin")
JENKINS_API_TOKEN = os.getenv("JENKINS_API_TOKEN", "1171b9756c17f161957cbeaa3556a1b32a")


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/solicitar', methods=['POST'])
def solicitar():
    instancia = request.form.get('instancia')
    correo_destino = request.form.get('correo')

    if not instancia or not correo_destino:
        flash("Todos los campos son obligatorios.")
        return redirect(url_for('index'))

    try:
        job_url = f"{JENKINS_URL}/job/{JOB_NAME}/buildWithParameters"

        params = {
            "INSTANCE_NAME": instancia,
            "EMAIL": correo_destino,
        }

        response = requests.post(
            f"{JENKINS_URL}/job/{JOB_NAME}/buildWithParameters",
            params={
                "INSTANCE_NAME": instancia,
                "EMAIL": correo_destino
            },
            auth=HTTPBasicAuth(JENKINS_USER, JENKINS_API_TOKEN)
        )

        if response.status_code not in [200, 201]:
            return f"Error al disparar Jenkins: {response.status_code}"

        return f"""
        <h3>Solicitud enviada correctamente</h3>
        <p>Instancia: {instancia}</p>
        <p>Correo destino: {correo_destino}</p>
        <p>Jenkins status: {response.status_code}</p>
        """

    except Exception as e:
        return f"Error inesperado: {str(e)}"


if __name__ == '__main__':
    app.run(debug=True)