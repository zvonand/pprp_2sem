from flask import Flask
import os
import requests


app = Flask(__name__)


@app.route('/facts/<animal_type>/<facts_num>', methods=['GET'])
def get_fact(animal_type, facts_num):
    r = requests.get(f"http://cat-fact.herokuapp.com/facts/random?animal_type={animal_type}&amount={facts_num}")
    return (r.content, r.status_code, r.headers.items())


if __name__ == "__main__":
    port = int(os.environ.get('FLASK_PORT', 8080))
    app.run(host='0.0.0.0', port=port)
