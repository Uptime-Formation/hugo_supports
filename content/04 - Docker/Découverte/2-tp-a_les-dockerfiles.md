---
title: TP 2a - Images et Dockerfile
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


## Améliorer le Dockerfile

### Une image plus simple

- A l'aide de l'image `python:3.9-alpine` et en remplaçant les instructions nécessaires<!-- (pas besoin d'installer `python3-pip` car ce programme est désormais inclus dans l'image de base)-->, repackagez l'app microblog en une image taggée `microblog:slim` ou `microblog:light`. Comparez la taille entre les deux images ainsi construites.

### Ne pas faire tourner l'app en root
- Avec l'aide du [manuel de référence sur les Dockerfiles](https://docs.docker.com/engine/reference/builder/), faire en sorte que l'app `microblog` soit exécutée par un utilisateur appelé `microblog`.

{{% expand "Solution :" %}}

```Dockerfile
# Ajoute un user et groupe appelés microblog
RUN addgroup microblog && adduser -S microblog -G microblog
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


