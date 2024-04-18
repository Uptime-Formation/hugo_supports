---
title: TP 2 - Images et conteneurs
weight: 1025
---

## Découverte d'une application web flask

- Récupérez d’abord une application Flask exemple en la clonant :

```bash
git clone https://github.com/uptime-formation/microblog/
```

- Si VSCode n'est pas installé : `sudo snap install --classic code`

- Ouvrez VSCode avec le dossier `microblog` en tapant `code microblog` ou bien en lançant VSCode avec `code` puis en cliquant sur `Open Folder`.

- Dans VSCode, vous pouvez faire `Terminal > New Terminal` pour obtenir un terminal en bas de l'écran.

<!-- - Pour la tester d’abord en local (sans conteneur) nous avons besoin des outils python. Vérifions s'ils sont installés :
    `sudo apt install python-pip python-dev build-essential` -->

<!-- - Créons l’environnement virtuel : `virtualenv -p python3 venv`

- Activons l’environnement : `source venv/bin/activate` -->

<!-- - Installons la librairie `flask` et exportons une variable d’environnement pour déclarer l’application.
    a) `pip install flask`
    b) `export FLASK_APP=microblog.py` -->

<!-- - Maintenant nous pouvons tester l’application en local avec la commande : `flask run` -->

<!-- - Visitez l’application dans le navigateur à l’adresse indiquée. -->

- Observons ensemble le code dans VSCode.
<!-- - Qu’est ce qu’un fichier de template ? Où se trouvent les fichiers de templates dans ce projet ? -->

<!-- - Changez le prénom Miguel par le vôtre dans l’application. -->
<!-- - Relancez l'app flask et testez la modification en rechargeant la page. -->

## Passons à Docker

Déployer une application Flask manuellement à chaque fois est relativement pénible. Pour que les dépendances de deux projets Python ne se perturbent pas, il faut normalement utiliser un environnement virtuel `virtualenv` pour séparer ces deux apps.
Avec Docker, les projets sont déjà isolés dans des conteneurs. Nous allons donc construire une image de conteneur pour empaqueter l’application et la manipuler plus facilement. Assurez-vous que Docker est installé.

Pour connaître la liste des instructions des Dockerfiles et leur usage, se référer au [manuel de référence sur les Dockerfiles](https://docs.docker.com/engine/reference/builder/).

- Dans le dossier du projet ajoutez un fichier nommé `Dockerfile` et sauvegardez-le

- Normalement, VSCode vous propose d'ajouter l'extension Docker. Il va nous faciliter la vie, installez-le. Une nouvelle icône apparaît dans la barre latérale de gauche, vous pouvez y voir les images téléchargées et les conteneurs existants. L'extension ajoute aussi des informations utiles aux instructions Dockerfile quand vous survolez un mot-clé avec la souris.

- Ajoutez en haut du fichier : `FROM python:3.9` Cette commande indique que notre image de base est la version 3.9 de Python. Quel OS est utilisé ? Vérifier en examinant l'image ou via le Docker Hub.
<!-- prendre une autre image ? alpine ? -->

- Nous pouvons déjà contruire un conteneur à partir de ce modèle Ubuntu vide :
  `docker build -t microblog .`

- Une fois la construction terminée lancez le conteneur.
- Le conteneur s’arrête immédiatement. En effet il ne contient aucune commande bloquante et nous n'avons précisé aucune commande au lancement.

<!-- Pour pouvoir observer le conteneur convenablement il fautdrait faire tourner quelque chose à l’intérieur. Ajoutez à la fin du fichier la ligne :
  `CMD ["/bin/sleep", "3600"]` -->

<!-- Cette ligne indique au conteneur d’attendre pendant 3600 secondes comme au TP précédent. -->

<!-- - Reconstruisez l'image et relancez un conteneur -->

<!-- - Affichez la liste des conteneurs en train de fonctionner -->

<!-- - Nous allons maintenant rentrer dans le conteneur en ligne de commande pour observer. Utilisez la commande : `docker exec -it <id_du_conteneur> /bin/bash` -->

<!-- - Vous êtes maintenant dans le conteneur avec une invite de commande. Utilisez quelques commandes Linux pour le visiter rapidement (`ls`, `cd`...). -->

Il s’agit d’un Linux standard, mais il n’est pas conçu pour être utilisé comme un système complet, juste pour une application isolée. Il faut maintenant ajouter notre application Flask à l’intérieur.

<!-- Dans le Dockerfile supprimez la ligne CMD, puis ajoutez :

```Dockerfile
RUN apt-get update -y
RUN apt-get install -y python3-pip
``` -->

  <!-- - `RUN apt-get install -y python3-pip python-dev build-essential` -->

<!-- - Reconstruisez votre image. Si tout se passe bien, poursuivez. -->

- Pour installer les dépendances python et configurer la variable d'environnement Flask, il va falloir :
  - ajouter le fichier `requirements.txt` avec `COPY`
  - lancer `pip3 install -r requirements.txt`
  - initialiser la variable d'environnement `FLASK_APP` à `microblog.py`

{{% expand "Solution :" %}}

```Dockerfile
COPY ./requirements.txt /requirements.txt
RUN pip3 install -r requirements.txt
ENV FLASK_APP microblog.py
```

{{% /expand %}}

- Reconstruisez votre image. Si tout se passe bien, poursuivez.

- Ensuite, copions le code de l’application à l’intérieur du conteneur.

{{% expand "Solution :" %}}

Pour cela ajoutez les lignes :

```Dockerfile
COPY ./ /microblog
```

{{% /expand %}}


Cette ligne indique de copier tout le contenu du dossier courant sur l'hôte dans un dossier `/microblog` à l’intérieur du conteneur.
Nous n'avons pas copié les requirements en même temps pour pouvoir tirer partie des fonctionnalités de cache de Docker, et ne pas avoir à retélécharger les dépendances de l'application à chaque fois que l'on modifie le contenu de l'app.

Puis, faites que le dossier courant dans le conteneur est déplacé à `/microblog`.

{{% expand "Solution :" %}}
```Dockerfile
WORKDIR /microblog
```
{{% /expand %}}

- Reconstruisez votre image. **Observons que le build recommence à partir de l'instruction modifiée. Les layers précédents avaient été mis en cache par le Docker Engine.**
- Si tout se passe bien, poursuivez.


- Enfin, ajoutons la section de démarrage à la fin du Dockerfile, c'est un script appelé `boot.sh` :

{{% expand "Solution :" %}}

```Dockerfile
CMD ["./boot.sh"]
```
{{% /expand %}}

- Reconstruisez l'image et lancez un conteneur basé sur l'image en ouvrant le port `5000` avec la commande : `docker run -p 5000:5000 microblog`

- Naviguez dans le navigateur à l’adresse `localhost:5000` pour admirer le prototype microblog.

- Lancez un deuxième container cette fois avec : `docker run -d -p 5001:5000 microblog`

- Une deuxième instance de l’app est maintenant en fonctionnement et accessible à l’adresse `localhost:5001`

## Docker Hub

- Avec `docker login`, `docker tag` et `docker push`, poussez l'image `microblog` sur le Docker Hub. Créez un compte sur le Docker Hub le cas échéant.

{{% expand "Solution :" %}}

```bash
docker login
docker tag microblog:latest <your-docker-registry-account>/microblog:latest
docker push <your-docker-registry-account>/microblog:latest
```

{{% /expand %}}

## Améliorer le Dockerfile

### Une image plus simple

- A l'aide de l'image `python:3.9-alpine` et en remplaçant les instructions nécessaires<!-- (pas besoin d'installer `python3-pip` car ce programme est désormais inclus dans l'image de base)-->, repackagez l'app microblog en une image taggée `microblog:slim` ou `microblog:light`. Comparez la taille entre les deux images ainsi construites.

### Ne pas faire tourner l'app en root
- Avec l'aide du [manuel de référence sur les Dockerfiles](https://docs.docker.com/engine/reference/builder/), faire en sorte que l'app `microblog` soit exécutée par un utilisateur appelé `microblog`.

{{% expand "Solution :" %}}

```Dockerfile
# Ajoute un user et groupe appelés microblog
RUN addgroup microblog && adduser microblog -G microblog
RUN chown -R microblog:microblog ./
USER microblog
```

{{% /expand %}}

Construire l'application avec `docker build`, la lancer et vérifier avec `docker exec`, `whoami` et `id` l'utilisateur avec lequel tourne le conteneur.

{{% expand "Réponse  :" %}}

- `docker build -t microblog .`
- `docker run --detach --name microblog -p 5000:5000 microblog`
- `docker exec -it microblog /bin/bash`

Une fois dans le conteneur lancez:

- `whoami` et `id`
- vérifiez aussi avec `ps aux` que le serveur est bien lancé.

{{% /expand %}}

<!-- Après avoir ajouté ces instructions, lors du build, que remarque-t-on ?

{{% expand "Réponse :" %}}
La construction reprend depuis la dernière étape modifiée. Sinon, la construction utilise les layers précédents, qui avaient été mis en cache par le Docker Engine.
{{% /expand %}} -->

### Documenter les ports utilisés

- Ajoutons l'instruction `EXPOSE 5000` pour indiquer à Docker que cette app est censée être accédée via son port `5000`.
- NB : Publier le port grâce à l'option `-p port_de_l-hote:port_du_container` reste nécessaire, l'instruction `EXPOSE` n'est là qu'à titre de documentation de l'image.

### Faire varier la configuration en fonction de l'environnement

Le serveur de développement Flask est bien pratique pour debugger en situation de développement, mais n'est pas adapté à la production.
Nous pourrions créer deux images pour les deux situations mais ce serait aller contre l'impératif DevOps de rapprochement du dev et de la prod.

Pour démarrer l’application, nous avons fait appel à un script de boot `boot.sh` avec à l’intérieur :

```bash
#!/bin/bash

# ...

set -e
if [ "$CONTEXT" = 'DEV' ]; then
    echo "Running Development Server"
    FLASK_ENV=development exec flask run -h 0.0.0.0
else
    echo "Running Production Server"
    exec gunicorn -b :5000 --access-logfile - --error-logfile - app_name:app
fi
```

- Déclarez maintenant dans le Dockerfile la variable d'environnement `CONTEXT` avec comme valeur par défaut `PROD`.

- Construisez l'image avec `build`.
- Puis, grâce aux bons arguments allant avec `docker run`, lancez une instance de l'app en configuration `PROD` et une instance en environnement `DEV` (joignables sur deux ports différents).
- Avec `docker ps` ou en lisant les logs, vérifiez qu'il existe bien une différence dans le programme lancé.

### Dockerfile amélioré

{{% expand "`Dockerfile` final :" %}}

```Dockerfile
FROM python:3.9-slim

# Permet à flask de savoir quel fichier exécuter
ENV FLASK_APP microblog.py
# Par défaut, l'image ci-dessus a comme utilisateur courant `root` : c'est une bonne pratique de sécurité de créer un user adéquat pour notre application (la justification détaillée se trouve dans les articles de la bibliographie)
WORKDIR /
COPY requirements.txt requirements.txt
# On fait une étape d'installation des requirements avant pour tirer partie du système de cache de Docker lors de la construction des images
RUN pip3 install -r requirements.txt
RUN useradd --system flask
# On copie des fichiers qui changent moins souvent avant pour le cache
WORKDIR /microblog
COPY microblog.py config.py boot.sh migrations/ app/ ./

RUN chown -R flask /microblog
ENV CONTEXT PROD

# A titre de documentation entre le maintainer de l'image et les gens l'utilisant :
EXPOSE 5000

USER flask
CMD ["./boot.sh"]

```

{{% /expand %}}

## L'instruction HEALTHCHECK

`HEALTHCHECK` permet de vérifier si l'app contenue dans un conteneur est en bonne santé.

- Dans un nouveau dossier ou répertoire, créez un fichier `Dockerfile` dont le contenu est le suivant :

```Dockerfile
FROM python:alpine

RUN apk add curl
RUN pip install flask

ADD /app.py /app/app.py
WORKDIR /app
EXPOSE 5000

HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1

CMD python app.py
```

- Créez aussi un fichier `app.py` avec ce contenu :

```python
from flask import Flask

healthy = True

app = Flask(__name__)

@app.route('/health')
def health():
    global healthy

    if healthy:
        return 'OK', 200
    else:
        return 'NOT OK', 500

@app.route('/kill')
def kill():
    global healthy
    healthy = False
    return 'You have killed your app.', 200


if __name__ == "__main__":
    app.run(host="0.0.0.0")
```

- Observez bien le code Python et la ligne `HEALTHCHECK` du `Dockerfile` puis lancez l'app. A l'aide de `docker ps`, relevez où Docker indique la santé de votre app.
- Visitez l'URL `/kill` de votre app dans un navigateur. Refaites `docker ps`. Que s'est-il passé ?

- _(Facultatif)_ Rajoutez une instruction `HEALTHCHECK` au `Dockerfile` de notre app microblog.

---

##  _Facultatif_ : construire une image "à la main"

Avec `docker commit`, trouvons comment ajouter une couche à une image existante.
La commande `docker diff` peut aussi être utile.

{{% expand "Solution :" %}}

```bash
docker run --name debian-updated -d debian apt-get update
docker diff debian-updated 
docker commit debian-updated debian:updated
docker image history debian:updated 
```

{{% /expand %}}

## _Facultatif_ : Décortiquer une image

Une image est composée de plusieurs layers empilés entre eux par le Docker Engine et de métadonnées.

- Affichez la liste des images présentes dans votre Docker Engine.

- Inspectez la dernière image que vous venez de créez (`docker image --help` pour trouver la commande)

- Observez l'historique de construction de l'image avec `docker image history <image>`

- Visitons **en root** (`sudo su`) le dossier `/var/lib/docker/` sur l'hôte. En particulier, `image/overlay2/layerdb/sha256/` :

  - On y trouve une sorte de base de données de tous les layers d'images avec leurs ancêtres.
  - Il s'agit d'une arborescence.

- Vous pouvez aussi utiliser la commande `docker save votre_image -o image.tar`, et utiliser `tar -C image_decompressee/ -xvf image.tar` pour décompresser une image Docker puis explorer les différents layers de l'image.

- Pour explorer la hiérarchie des images vous pouvez installer <https://github.com/wagoodman/dive>

---

## _Facultatif :_ un Registry privé

- En récupérant [la commande indiquée dans la doc officielle](https://distribution.github.io/distribution/), créez votre propre registry.
- Puis trouvez comment y pousser une image dessus.
- Enfin, supprimez votre image en local et récupérez-la depuis votre registry.

{{% expand "Solution :" %}}

```bash
# Créer le registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Y pousser une image
docker tag ubuntu:16.04 localhost:5000/my-ubuntu
docker push localhost:5000/my-ubuntu

# Supprimer l'image en local
docker image remove ubuntu:16.04
docker image remove localhost:5000/my-ubuntu

# Récupérer l'image depuis le registry
docker pull localhost:5000/my-ubuntu
```

{{% /expand %}}

## _Facultatif :_ Faire parler la vache

Créons un nouveau Dockerfile qui permet de faire dire des choses à une vache grâce à la commande `cowsay`.
Le but est de faire fonctionner notre programme dans un conteneur à partir de commandes de type :

- `docker run --rm cowsay Coucou !`
- `docker run --rm cowsay` doit afficher une vache qui dit "Hello"
- `docker run --rm cowsay -f stegosaurus Yo!`
- `docker run --rm cowsay -f elephant-in-snake Un éléphant dans un boa.`

- Doit-on utiliser la commande `ENTRYPOINT` ou la commande `CMD` ? Se référer au [manuel de référence sur les Dockerfiles](https://docs.docker.com/engine/reference/builder/) si besoin.
- Pour information, `cowsay` s'installe dans `/usr/games/cowsay`.
- La liste des options (incontournables) de `cowsay` se trouve ici : <https://debian-facile.org/doc:jeux:cowsay>

{{% expand "Solution :" %}}

```Dockerfile
FROM ubuntu
RUN apt-get update && apt-get install -y cowsay
ENTRYPOINT ["/usr/games/cowsay"]
CMD ["Hello"]
# les crochets sont nécessaires, car ce n'est pas tout à fait la même instruction qui est exécutée sans
```

{{% /expand %}}

- L'instruction `ENTRYPOINT` et la gestion des entrées-sorties des programmes dans les Dockerfiles peut être un peu capricieuse et il faut parfois avoir de bonnes notions de Bash et de Linux pour comprendre (et bien lire la documentation Docker).
- On utilise parfois des conteneurs juste pour qu'ils s'exécutent une fois (pour récupérer le résultat dans la console, ou générer des fichiers). On utilise alors l'option `--rm` pour les supprimer dès qu'ils s'arrêtent.

## _Facultatif :_ TP avancé : Un multi-stage build avec distroless comme image de base de prod

Chercher la documentation sur les images distroless. 
Quel est l'intérêt ? Quels sont les cas d'usage ? 

Objectif : transformer le `Dockerfile` de l'app nodejs (express) suivante en build multistage : https://github.com/Uptime-Formation/docker-example-nodejs-multistage-distroless.git
 Le builder sera par exemple basé sur l'image `node:20` et le résultat sur `gcr.io/distroless/nodejs20-debian11`.

La doc:
- https://docs.docker.com/build/building/multi-stage/

 Deux exemples simple pour vous aider:
 - https://alphasec.io/dockerize-a-node-js-app-using-a-distroless-image/
 - https://medium.com/@luke_perry_dev/dockerizing-with-distroless-f3b84ae10f3a

 Une correction possible dans la branche correction : `git clone https://github.com/Uptime-Formation/docker-example-nodejs-multistage-distroless/ -b correction`

 L'image résultante fait tout de même environ 170Mo.

 Pour entrer dans les détails de l'image on peut installer et utiliser https://github.com/wagoodman/dive

 <!-- On peut alors constater que pour une application nodejs, même le minimum du minimum dans une image c'est déjà un joyeux bordel difficile à auditer: (confs linux + locales + ssl + autre + votre node_modules avec plein de lib + votre app) -->
