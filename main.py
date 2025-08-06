from flask import Flask, jsonify
import os

# Api de teste
# Atualiza as informações retornadas de forma imediata

app = Flask(__name__)

APP_NAME = os.getenv('APP_NAME', 'null')
APP_URL = os.getenv('APP_URL', 'null')
APP_PORT = os.getenv('APP_PORT', 'null')

@app.route('/', methods=['GET'])
def hello():
    return 'Hello, world!!'

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'UP'}), 200

if __name__ == '__main__':
    app.run(host=APP_URL, port=APP_PORT, debug=True)
