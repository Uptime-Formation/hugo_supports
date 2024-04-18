from flask import Flask, Response, request, abort
import requests
import hashlib
import redis
import os
import logging

LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO').upper()
logging.basicConfig(level=LOGLEVEL)

app = Flask(__name__)
cache = redis.StrictRedis(host='redis', port=6379, db=0)
salt = "UNIQUE_SALT"
default_name = 'toi'

@app.route('/', methods=['GET', 'POST'])
def mainpage():

    name = default_name
    if request.method == 'POST':
        name = request.form['name']

    salted_name = salt + name
    name_hash = hashlib.sha256(salted_name.encode()).hexdigest()
    header = '<html><head><title>Identidock</title></head><body>'
    body = '''<form method="POST">
                Salut <input type="text" name="name" value="{0}"> !
                <input type="submit" value="submit">
                </form>
                <p>Tu ressembles à ça :
                <img src="/monster/{1}"/>
            '''.format(name, name_hash)
    footer = '</body></html>'
    return header + body + footer


@app.route('/monster/<name>')
def get_identicon(name):
    found_in_cache = False

    try:
        image = cache.get(name)
        redis_unreachable = False
        if image is not None:
            found_in_cache = True
            logging.info("Image trouvée dans le cache")
    except:
        redis_unreachable = True
        logging.warning("Cache redis injoignable")

    if not found_in_cache:
        logging.info("Image non trouvée dans le cache")
        try:
            r = requests.get('http://dnmonster:8080/monster/' + name + '?size=80')
            image = r.content
            logging.info("Image générée grâce au service dnmonster")

            if not redis_unreachable:
                cache.set(name, image)
                logging.info("Image enregistrée dans le cache redis")
        except:
            logging.critical("Le service dnmonster est injoignable !")
            abort(503)

    return Response(image, mimetype='image/png')

if __name__ == '__main__':
  app.run(debug=True, host='0.0.0.0', port=5000)
