# api_dispositivos.py
from flask import Flask, jsonify
import subprocess, re

app = Flask(__name__)

@app.route('/api/devices')
def dispositivos():
    try:
        # Executa o comando arp para pegar dispositivos conectados
        resultado = subprocess.check_output(['arp', '-a']).decode()
        dispositivos = []

        for linha in resultado.splitlines():
            match = re.search(r'(\d+\.\d+\.\d+\.\d+).*?([a-f0-9:]{17})', linha, re.IGNORECASE)
            if match:
                ip = match.group(1)
                mac = match.group(2)
                dispositivos.append({
                    'ip': ip,
                    'mac': mac,
                    'status': 'Conectado'
                })

        return jsonify(dispositivos)

    except Exception as e:
        return jsonify({'erro': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)