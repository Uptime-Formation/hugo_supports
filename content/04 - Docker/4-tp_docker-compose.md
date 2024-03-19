---
title: "TP 4 - Créer une application multiconteneur"
draft: false
weight: 1045
---

## Articuler trois images avec Docker Compose


<!-- ### Dans une VM -->

<!-- - Si Docker n'est pas déjà installé, installez Docker par la méthode officielle accélérée et moins sécurisée (un _one-liner™_) avec `curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh`. Que fait cette commande ? Pourquoi est-ce moins sécurisé ? -->
<!-- - Installez VSCode avec la commande `sudo snap install --classic code` -->
{{% expand  Si Docker Compose n'est pas installé %}}

- Installez le plugin `docker compose` avec `sudo apt install docker-compose-plugin`.
- Si ça ne marche pas, il faudra ajouter le repo officiel de Docker :
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
{{% /expand %}}
<!-- - Pour vous faciliter la vie et si ce n'est pas déjà le cas, ajoutez le plugin _autocomplete_ pour Docker Compose à `bash` en copiant les commandes suivantes :

```bash
sudo apt update
sudo apt install bash-completion curl
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.24.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose 
``` -->

  <!-- - S'il y a un bug  -->
  <!-- - S'ajouter au groupe `docker`avec `usermod -a -G docker stagiaire` et actualiser avec `newgrp docker stagiaire` -->

<!-- ### Avec Gitpod

`brew update` (si ça reste bloqué plus de 5min, arrêtez avec Ctrl+C)
`brew install docker-compose`
Si la dernière commande ne marche pas, installez `docker-compose` de la façon suivante :

````bash
mkdir bin
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o bin/docker-compose
chmod +x bin/docker-compose
export PATH="./bin:$PATH"
``` -->

### `identidock` : une application Flask qui se connecte à `redis`

- Démarrez un nouveau projet dans VSCode (créez un dossier appelé `identidock` et chargez-le avec la fonction _Add folder to workspace_)
- Dans un sous-dossier `app`, ajoutez une petite application python en créant ce fichier `identidock.py` :

```python
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
                <p>Tu ressembles a ca :
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
            logging.info("Image trouvee dans le cache")
    except:
        redis_unreachable = True
        logging.warning("Cache redis injoignable")

    if not found_in_cache:
        logging.info("Image non trouvee dans le cache")
        try:
            r = requests.get('http://dnmonster:8080/monster/' + name + '?size=80')
            image = r.content
            logging.info("Image generee grace au service dnmonster")

            if not redis_unreachable:
                cache.set(name, image)
                logging.info("Image enregistree dans le cache redis")
        except:
            logging.critical("Le service dnmonster est injoignable !")
            abort(503)

    return Response(image, mimetype='image/png')

if __name__ == '__main__':
  app.run(debug=True, host='0.0.0.0', port=5000)
```

- `uWSGI` est un serveur python de production très adapté pour servir notre serveur intégré Flask, nous allons l'utiliser.

- Dockerisons maintenant cette nouvelle application avec le Dockerfile suivant :

```Dockerfile
FROM python:3.7

RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip3 install Flask uWSGI requests redis
WORKDIR /app
COPY app/identidock.py /app
ENV FLASK_APP identidock.py

EXPOSE 5000 9191
USER uwsgi
CMD ["uwsgi", "--http", "0.0.0.0:5000", "--wsgi-file", "/app/identidock.py", \
"--callable", "app", "--stats", "0.0.0.0:9191"]
```

- Observons le code du Dockerfile ensemble s'il n'est pas clair pour vous. Juste avant de lancer l'application, nous avons changé d'utilisateur avec l'instruction `USER`, pourquoi ?.

<!-- - Construire l'application, pour l'instant avec `docker build`, la lancer et vérifier avec `docker exec`, `whoami` et `id` l'utilisateur avec lequel tourne le conteneur.

{{% expand "Réponse  :" %}}

- `docker build -t identidock .`
- `docker run --detach --name identidock -p 5000:5000 identidock`
- `docker exec -it identidock /bin/bash`

Une fois dans le conteneur lancez:

- `whoami` et `id`
- vérifiez aussi avec `ps aux` que le serveur est bien lancé.

{{% /expand %}} -->

<!-- - Validez la version actuelle du code avec Git en faisant : `git init && git add -A && git commit -m "Code initial pour le TP Docker Compose"` -->

<!-- ### Pousser notre image sur un registry (le Docker Hub)

- Si ce n'est pas déjà fait, créez un compte sur `hub.docker.com`.
- Lancez `docker login` pour vous identifier en CLI.
- Donnons un tag avec votre login Docker Hub à notre image pour pouvoir la pousser sur le registry : `docker tag identidock <votre_hub_login>/identidock:0.1`
- Puis poussons l'image sur le Docker Hub avec : `docker push <votre_hub_login>/identidock:0.1` -->

### Le fichier Docker Compose

- A la racine de notre projet `identidock` (à côté du Dockerfile), créez un fichier de déclaration de notre application appelé `docker-compose.yml` avec à l'intérieur :

```yml
services:
  identidock:
    build: .
    ports:
      - "5000:5000"
```

- Plusieurs remarques :

  - la première ligne après `services` déclare le conteneur de notre application
  - les lignes suivantes permettent de décrire comment lancer notre conteneur
  - `build: .` indique que l'image d'origine de notre conteneur est le résultat de la construction d'une image à partir du répertoire courant (équivaut à `docker build -t identidock .`)
  - la ligne suivante décrit le mapping de ports entre l'extérieur du conteneur et l'intérieur.

- Lancez le service (pour le moment mono-conteneur) avec `docker compose up` (cette commande sous-entend `docker compose build`)
- Visitez la page web de l'app.

- Ajoutons maintenant un deuxième conteneur. Nous allons tirer parti d'une image déjà créée qui permet de récupérer une "identicon". Ajoutez à la suite du fichier Compose **_(attention aux indentations !)_** un service `dnmonster` utilisant l'image `amouat/dnmonster:1.0`.

{{% expand "Solution :" %}}


```yml
dnmonster:
  image: amouat/dnmonster:1.0
```

Le `docker-compose.yml` doit pour l'instant ressembler à ça :

```yml
services:
  identidock:
    build: .
    ports:
      - "5000:5000"

  dnmonster:
    image: amouat/dnmonster:1.0
```
{{% /expand %}}

- Enfin, nous déclarons aussi un réseau appelé `identinet` pour y mettre les deux conteneurs de notre application.

{{% expand "Solution :" %}}

- Il faut déclarer ce réseau à la fin du fichier (notez que l'on peut spécifier le driver réseau) :

```yaml
networks:
  identinet:
    driver: bridge
```

{{% /expand %}}

- Il faut aussi mettre nos deux services `identidock` et `dnmonster` sur le même réseau en ajoutant **deux fois** ce bout de code où c'est nécessaire **_(attention aux indentations !)_** :

```yaml
  networks:
    - identinet
```

- Ajoutons également un conteneur `redis` **_(attention aux indentations !)_**. Cette base de données sert à mettre en cache les images et à ne pas les recalculer à chaque fois.

{{% expand "Solution :" %}}

```yml
redis:
  image: redis
  networks:
    - identinet
```

{{% /expand %}}

{{% expand "`docker-compose.yml` final :" %}}


```yaml
services:
  identidock:
    build: .
    ports:
      - "5000:5000"
      - "9191:9191" # port pour les stats
    networks:
      - identinet

  dnmonster:
    image: amouat/dnmonster:1.0
    networks:
      - identinet

  redis:
    image: redis
    networks:
      - identinet

networks:
  identinet:
    driver: bridge
```

{{% /expand %}}

- Lancez l'application et vérifiez que le cache fonctionne en cherchant les messages dans les logs de l'application.

- N'hésitez pas à passer du temps à explorer les options et commandes de `docker-compose`, ainsi que [la documentation officielle du langage des Compose files](https://docs.docker.com/compose/compose-file/). 


### Le Hot Code Reloading (rechargement du code à chaud)
Modifions le `docker-compose.yml` pour y inclure des instructions pour lancer le serveur python en mode debug.

Notre image est codée pour lancer le serveur de production appelé uWSGI (`CMD ["uwsgi", "--http", "0.0.0.0:5000", "--wsgi-file", "/app/identidock.py", \
"--callable", "app", "--stats", "0.0.0.0:9191"]`). Nous voulons plutôt lancer le serveur de debug qui se lance avec :
- la variable d'environnement `FLASK_ENV=development`
- le processus lancé avec la commande `flask run -h 0.0.0.0`

En réfléchissant à comment utiliser les volumes, le but est de trouver comment la modification du code source devrait immédiatement être répercutée dans les logs d'`identidock` : recharger la page devrait nous montrer la nouvelle version du code de l'application.


{{% expand "Solution :" %}}

```yml
services:
  identidock:
    build: .
    ports:
      - "5000:5000"
    networks:
      - identinet
    # ---
    # Config dev à commenter si prod
    volumes:
    # le dossier app sur l'hôte contient le code source à la dernière version
      - "./app:/app"
    # les variables d'environnement nécessaires
    environment:
      - FLASK_APP=/app/identidock.py
      - FLASK_ENV=development
    # on surcharge la commande de lancement du conteneur
    command: flask run -h 0.0.0.0
    # ---
```

{{% /expand %}}

### (facultatif) Le Docker Compose de `microblog`

Créons un fichier Docker Compose pour faire fonctionner l'application Microblog du TP précédent avec Postgres.

- Quelles étapes faut-il ?
- Trouver comment configurer une base de données Postgres pour une app Flask (c'est une option de SQLAlchemy)

<!-- Refaire plutôt avec un wordpress, un ELK, un nextcloud, et le microblog, et traefik, recentraliser les logs -->

<!-- Nous allons ensuite installer le reverse proxy Traefik pour accéder à ces services. -->

<!-- On se propose ici d'essayer de déployer plusieurs services pré-configurés comme le microblog, et d'installer le reverse proxy Traefik pour accéder à ces services. -->

## D'autres services

### Exercices de _google-fu_

#### ex: un pad HedgeDoc

On se propose ici d'essayer de déployer plusieurs services pré-configurés comme Wordpress, Nextcloud, Sentry ou votre logiciel préféré.

- Récupérez (et adaptez si besoin) à partir d'Internet un fichier `docker-compose.yml` permettant de lancer un pad HedgeDoc ou autre avec sa base de données. Je vous conseille de toujours chercher **dans la documentation officielle** ou le repository officiel (souvent sur Github) en premier.

- Vérifiez que le service est bien accessible sur le port donné.

- Si besoin, lisez les logs en quête bug et adaptez les variables d'environnement.

<!-- Assemblez à partir d'Internet un fichier `docker-compose.yml` permettant de lancer un Wordpress et un Nextcloud **déjà pré-configurés** (pour l'accès à la base de données notamment). Ajoutez-y un pad CodiMD / HackMD (toujours grâce à du code trouvé sur Internet). -->

## Une stack Elastic

### Centraliser les logs

L'utilité d'Elasticsearch est que, grâce à une configuration très simple de son module Filebeat, nous allons pouvoir centraliser les logs de tous nos conteneurs Docker.
Pour ce faire, il suffit d'abord de télécharger une configuration de Filebeat prévue à cet effet :

```bash
curl -L -O https://raw.githubusercontent.com/elastic/beats/7.10/deploy/docker/filebeat.docker.yml
```

Renommons cette configuration et rectifions qui possède ce fichier pour satisfaire une contrainte de sécurité de Filebeat :

```bash
mv filebeat.docker.yml filebeat.yml
sudo chown root filebeat.yml
sudo chmod go-w filebeat.yml
```

Enfin, créons un fichier `docker-compose.yml` pour lancer une stack Elasticsearch :

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.5.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    networks:
      - logging-network

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.5.0
    user: root
    depends_on:
      - elasticsearch
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - logging-network
    environment:
      - -strict.perms=false

  kibana:
    image: docker.elastic.co/kibana/kibana:7.5.0
    depends_on:
      - elasticsearch
    ports:
      - 5601:5601
    networks:
      - logging-network

networks:
  logging-network:
    driver: bridge
```

Il suffit ensuite de :
- se rendre sur Kibana (port `5601`)
- de configurer l'index en tapant `*` dans le champ indiqué, de valider
- et de sélectionner le champ `@timestamp`, puis de valider.

L'index nécessaire à Kibana est créé, vous pouvez vous rendre dans la partie Discover à gauche (l'icône boussole 🧭) pour lire vos logs.

Il est temps de faire un petit `docker stats` pour découvrir l'utilisation du CPU et de la RAM de vos conteneurs !

#### Avec WSL
Avec WSL, l'emplacement des logs est assez difficile à trouver ! Vous pouvez vous aider de cette page pour ce TP : <https://gist.github.com/Bert-R/e5bb77b9ce9c94fdb1a90e4e615ee518>

### _Facultatif :_ Ajouter un nœud Elasticsearch

Puis, à l'aide de la documentation Elasticsearch et/ou en adaptant de bouts de code Docker Compose trouvés sur internet, ajoutez et configurez un nœud Elastic. Toujours à l'aide de la documentation Elasticsearch, vérifiez que ce nouveau nœud communique bien avec le premier.

### _Facultatif_ : ajouter une stack ELK à `microblog`

<!-- TODO: Fiare avec ma version de l'app et du docker compose -->

Dans la dernière version de l'app `microblog`, Elasticsearch est utilisé pour fournir une fonctionnalité de recherche puissante dans les posts de l'app.
Avec l'aide du [tutoriel de Miguel Grinberg](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xix-deployment-on-docker-containers), écrivez le `docker-compose.yml` qui permet de lancer une stack entière pour `microblog`. Elle devra contenir un conteneur `microblog`, un conteneur `mysql`, un conteneur `elasticsearch` et un conteneur `kibana`.

<!-- ### _Facultatif / avancé_ : centraliser les logs de microblog sur ELK

Avec la [documentation de Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-autodiscover.html) et des [hints Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-autodiscover-hints.html) ainsi que grâce à [cette page](https://discuss.elastic.co/t/nginx-filebeat-elk-docker-swarm-help/130512/2), trouvez comment centraliser les logs Flask de l'app `microblog` grâce au système de labels Docker de Filebeat.

Tentons de centraliser les logs de
de ces services dans ELK. -->

<!-- ### Un `docker-compose.prod.yml` pour `identicon`

#### Faire varier la configuration en fonction de l'environnement

Finalement le serveur de développement flask est bien pratique pour debugger en situation de développement, mais il n'est pas adapté à la production.
Nous pourrions créer deux images pour les deux situations mais ce serait aller contre l'imperatif DevOps de rapprochement du dév et de la production.

- Créons un script bash `boot.sh` pour adapter le lancement de l'application au contexte:

```bash
#!/bin/bash
set -e
if [ "$CONTEXT" = 'DEV' ]; then
    echo "Running Development Server"
    exec python3 "/app/identidock.py"
else
    echo "Running Production Server"
    exec uwsgi --http 0.0.0.0:5000 --wsgi-file /app/identidock.py --callable app --stats 0.0.0.0:9191
fi
```

- Ajoutez au Dockerfile une deuxième instruction `COPY` en dessous de la précédente pour mettre le script dans le conteneur.
- Ajoutez un `RUN chmod a+x /boot.sh` pour le rendre executable.
- Modifiez l'instruction `CMD` pour lancer le script de boot plutôt que `uwsgi` directement.
- Modifiez l'instruction expose pour déclarer le port 5000 en plus.
- Ajoutez au dessus une instruction `ENV CONTEXT PROD` pour définir la variable d'environnement `ENV` à la valeur `PROD` par défaut.

- Testez votre conteneur en mode DEV avec `docker run --env CONTEXT=DEV -p 5000:5000 identidock`, visitez localhost:5000
- Et en mode `PROD` avec `docker run --env CONTEXT=PROD -p 5000:5000 identidock`. Visitez localhost:5000.

{{% expand "Solution `Dockerfile`:" %}}

```Dockerfile
FROM python:3.7
RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask uWSGI requests redis
WORKDIR /app
COPY app /app
COPY boot.sh /
RUN chmod a+x /boot.sh
ENV CONTEXT PROD
EXPOSE 9191 5000
USER uwsgi
CMD ["/boot.sh"]
```

{{% /expand %}}

Conclusions:

- On peut faire des images multicontextes qui s'adaptent au contexte.
- Les variables d'environnement sont souvent utilisée pour configurer les conteneurs au moment de leur lancement. (plus dynamique qu'un fichier de configuration)

#### Un `docker-compose.prod.yml` pour `identicon`

- Créez un deuxième fichier Compose `docker-compose.prod.yml` (à compléter) pour lancer l'application `identicon` en configuration de production. Que doit-on penser à adapter ?

{{% expand "Solution `docker-compose.prod.yml` :" %}}

```yaml
version: "3"
services:
  identidock:
    image: <votre_hub_login>/identidock:0.1
    ports:
      - "5000:5000"
      - "9191:9191"
    environment:
      - CONTEXT=PROD
    networks:
      - identinet

  dnmonster:
    image: amouat/dnmonster:1.0
    networks:
      - identinet

  redis:
    image: redis
    networks:
      - identinet
    volumes:
      - identiredis_volume:/data

  redis-commander:
    image: rediscommander/redis-commander:latest
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - "8081:8081"
    networks:
      - identinet

networks:
  identinet:
    driver: bridge

volumes:
  identiredis_volume:
    driver: local
```


{{% /expand %}}


Commentons ce code:

- plus de volume `/app` pour `identidock` car nous sommes en prod
- on ouvre le port de l'app `5000` mais aussi le port de stat du serveur uWSGI `9191`
- `CONTEXT=PROD` pour lancer l'application avec le serveur uWSGI
- On a mis un volume nommé à `redis` pour conserver les données sur le long terme
- on a ajouté un GUI web Redis accessible sur `localhost:8081` pour voir le conteneur de la base de données Redis
- le tout dans le même réseau

Le dépôt avec les solutions : <https://github.com/Uptime-Formation/tp4_docker_compose_correction_202001>

--- -->

<!-- Galera automagic docker-compose : https://gist.github.com/lucidfrontier45/497341c4b848dfbd6dfb -->


### _Facultatif :_ Utiliser Traefik

Vous pouvez désormais faire [l'exercice 1 du TP7](../7-tp-traefik) pour configurer un serveur web qui permet d'accéder à vos services via des domaines.

<!-- ### *Facultatif :* du monitoring avec *cAdvisor* et *Prometheus*

Suivre ce tutoriel pour du monitoring des conteneurs Docker : <https://prometheus.io/docs/guides/cadvisor/> -->
