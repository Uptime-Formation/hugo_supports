---
title: 2 - Images et conteneurs
weight: 1020
---

# Créer une image en utilisant un Dockerfile

- Jusqu'ici nous avons utilisé des images toutes prêtes.

- Une des fonctionnalités principales de Docker est de pouvoir facilement construire des images à partir d'un simple fichier texte : **le Dockerfile**.

# Le processus de build Docker

- Un image Docker ressemble un peu à une VM car on peut penser à un Linux "freezé" dans un état.

- En réalité c'est assez différent : il s'agit uniquement d'un système de fichier (par couches ou _layers_) et d'un manifeste JSON (des méta-données).

- Les images sont créés en empilant de nouvelles couches sur une image existante grâce à un système de fichiers qui fait du _union mount_.

---

- Chaque nouveau build génère une nouvelle image dans le répertoire des images (`/var/lib/docker/images`) (attention ça peut vite prendre énormément de place)

- On construit les images à partir d'un fichier `Dockerfile` en décrivant procéduralement (étape par étape) la construction.

![](../../images/ops-images-dockerfile.svg)

### Exemple de Dockerfile :

```Dockerfile
FROM debian:latest

RUN apt update && apt install -y htop

CMD ['sleep 1000']
```

- La commande pour construire l'image est :

```
docker build [-t tag] [-f dockerfile] <build_context>
```

- généralement pour construire une image on se place directement dans le dossier avec le `Dockerfile` et les élements de contexte nécessaire (programme, config, etc), le contexte est donc le caractère **`.`**, il est obligatoire de préciser un contexte.

- exemple : `docker build -t mondebian .`

---

- Le **Dockerfile** est un fichier procédural qui permet de décrire l'installation d'un logiciel (la configuration d'un container) en enchaînant des instructions Dockerfile (en MAJUSCULE).

- Exemple:

```Dockerfile
# our base image
FROM alpine:3.5

# Install python and pip
RUN apk add --update py2-pip

# upgrade pip
RUN pip install --upgrade pip

# install Python modules needed by the Python app
COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt

# copy files required for the app to run
COPY app.py /usr/src/app/
COPY templates/index.html /usr/src/app/templates/

# tell the port number the container should expose
EXPOSE 5000

# run the application
CMD ["python", "/usr/src/app/app.py"]
```
<!-- ```Dockerfile
FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
``` -->

---

## Instruction `FROM`

- L'image de base à partir de laquelle est construite l'image actuelle.

## Instruction `RUN`

- Permet de lancer une commande shell (installation, configuration).

## Instruction `ADD` ou `COPY`

- Permet d'ajouter des fichier depuis le contexte de build à l'intérieur du conteneur.
- Généralement utilisé pour ajouter le code du logiciel en cours de développement et sa configuration au conteneur.
- Ces deux instructions ont des petites différences subtiles : les options de `COPY` sont plus complètes, et `ADD` permet de télécharger et dézipper un fichier disponible à une URL distante.
---

## Instruction `CMD`

- Généralement à la fin du `Dockerfile` : elle permet de préciser la commande par défaut lancée à la création d'une instance du conteneur avec `docker run`. on l'utilise avec une liste de paramètres

```Dockerfile
CMD ["echo 'Conteneur démarré'"]
```

## Instruction `ENTRYPOINT`

- Précise le programme de base avec lequel sera lancé la commande

```Dockerfile
ENTRYPOINT ["/usr/bin/python3"]
```

## `CMD` et `ENTRYPOINT`

* Ne surtout pas confondre avec `RUN` qui exécute une commande Bash uniquement pendant la construction de l'image.

L'instruction `CMD` a trois formes :
* `CMD ["executable","param1","param2"]` (*exec form*, forme à préférer)
* `CMD ["param1","param2"]` (combinée à une instruction `ENTRYPOINT`)
* `CMD command param1 param2` (*shell form*)


Si l'on souhaite que notre container lance le même exécutable à chaque fois, alors on peut opter pour l'usage d'`ENTRYPOINT` en combination avec `CMD`.

---

## Instruction `ENV`

- Une façon recommandée de configurer vos applications Docker est d'utiliser les variables d'environnement UNIX, ce qui permet une configuration "au _runtime_".

---

## Instruction `HEALTHCHECK`

`HEALTHCHECK` permet de vérifier si l'app contenue dans un conteneur est en bonne santé.

```bash
HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1
```

---

## Les variables
On peut utiliser des variables d'environnement dans les Dockerfiles. La syntaxe est `${...}`.
Exemple :
```Dockerfile
FROM busybox
ENV FOO=/bar
WORKDIR ${FOO}   # WORKDIR /bar
ADD . $FOO       # ADD . /bar
COPY \$FOO /quux # COPY $FOO /quux
```

Se référer au [mode d'emploi](https://docs.docker.com/engine/reference/builder/#environment-replacement) pour la logique plus précise de fonctionnement des variables.
## Documentation

- Il existe de nombreuses autres instructions possibles très clairement décrites dans la documentation officielle : [https://docs.docker.com/engine/reference/builder/](https://docs.docker.com/engine/reference/builder/)

---

# Lancer la construction

- La commande pour lancer la construction d'une image est :

```bash
docker build [-t <tag:version>] [-f <chemin_du_dockerfile>] <contexte_de_construction>
```

- Lors de la construction, Docker télécharge l'image de base. On constate plusieurs téléchargements en parallèle.

- Il lance ensuite la séquence des instructions du Dockerfile.

- Observez l'historique de construction de l'image avec `docker image history <image>`

- Il lance ensuite la série d'instructions du Dockerfile et indique un *hash* pour chaque étape.
  - C'est le *hash* correspondant à un *layer* de l'image

---

# Les layers et la mise en cache

- **Docker construit les images comme une série de "couches" de fichiers successives.**

- On parle d'**Union Filesystem** car chaque couche (de fichiers) écrase la précédente.

![](../../images/overlay_constructs.jpg)
<!-- ![](../../images/OverlayFS_Image.png) -->

<!-- In order to understand the relationship between images and containers, we need to explain a key piece of technology that enables Docker—the UFS (sometimes simply called a union mount). Union file systems allow multiple file systems to be overlaid, appearing to the user as a single filesytem. Folders may contain files from multiple filesystems, but if two files have the exact same path, the last mounted file will hide any previous files. Docker supports several different UFS implentations, including AUFS, Overlay, devicemapper, BTRFS, and ZFS. Which implementation is used is system dependent and can be checked by running docker info where it is listed under “Storage Driver.” It is possible to change the filesystem, but this is only recom‐ mended if you know what you are doing and are aware of the advantages and disad‐ vantages.
Docker images are made up of multiple layers. Each of these layers is a read-only fil‐ eystem. A layer is created for each instruction in a Dockerfile and sits on top of the previous layers. When an image is turned into a container (from a docker run or docker create command), the Docker engine takes the image and adds a read-write filesystem on top (as well as initializing various settings such as the IP address, name, ID, and resource limits). -->

- Chaque couche correspond à une instruction du Dockerfile.

- `docker image history <conteneur>` permet d'afficher les layers, leur date de construction et taille respectives.

- Ce principe est au coeur de l'**immutabilité** des images Docker.

- Au lancement d'un container, le Docker Engine rajoute une nouvelle couche de filesystem "normal" read/write par dessus la pile des couches de l'image.

- `docker diff <container>` permet d'observer les changements apportés au conteneur depuis le lancement.

<!-- ![](../../images/overlay.jpeg) -->

---

# Optimiser la création d'images

- Les images Docker ont souvent une taille de plusieurs centaines de **mégaoctets** voire parfois **gigaoctets**. `docker image ls` permet de voir la taille des images.
- Or, on construit souvent plusieurs dizaines de versions d'une application par jour (souvent automatiquement sur les serveurs d'intégration continue).

  - L'espace disque devient alors un sérieux problème.

- Le principe de Docker est justement d'avoir des images légères car on va créer beaucoup de conteneurs (un par instance d'application/service).

- De plus on télécharge souvent les images depuis un registry, ce qui consomme de la bande passante.

> La principale **bonne pratique** dans la construction d'images est de **limiter leur taille au maximum**.

---

# Limiter la taille d'une image

- Choisir une image Linux de base **minimale**:

  - Une image `ubuntu` complète pèse déjà presque une soixantaine de mégaoctets.
  - mais une image trop rudimentaire (`busybox`) est difficile à débugger et peu bloquer pour certaines tâches à cause de binaires ou de bibliothèques logicielles qui manquent (compilation par exemple).
  - Souvent on utilise des images de base construites à partir de `alpine` qui est un bon compromis (6 mégaoctets seulement et un gestionnaire de paquets `apk`).
  - Par exemple `python3` est fourni en version `python:alpine` (99 Mo), `python:3-slim` (179 Mo) et `python:latest` (918 Mo).

<!-- - Limiter le nombre de commandes de modification du conteneur :
  -  -->

---

## Les multi-stage builds

Quand on tente de réduire la taille d'une image, on a recours à un tas de techniques. Avant, on utilisait deux `Dockerfile` différents : un pour la version prod, léger, et un pour la version dev, avec des outils en plus. Ce n'était pas idéal.
Par ailleurs, il existe une limite du nombre de couches maximum par image (42 layers). Souvent on enchaînait les commandes en une seule pour économiser des couches (souvent, les commandes `RUN` et `ADD`), en y perdant en lisibilité.

Maintenant on peut utiliser les multistage builds.

Avec les multi-stage builds, on peut utiliser plusieurs instructions `FROM` dans un Dockerfile. Chaque instruction `FROM` utilise une base différente.
On sélectionne ensuite les fichiers intéressants (des fichiers compilés par exemple) en les copiant d'un stage à un autre.

Exemple de `Dockerfile` utilisant un multi-stage build :

```Dockerfile
FROM golang:1.7.3 AS builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]
```

---

# Créer des conteneurs personnalisés

- Il n'est pas nécessaire de partir d'une image Linux vierge pour construire un conteneur.

- On peut utiliser la directive `FROM` avec n'importe quelle image.

- De nombreuses applications peuvent être configurées en étendant une image officielle
- _Exemple : une image Wordpress déjà adaptée à des besoins spécifiques._

- L'intérêt ensuite est que l'image est disponible préconfigurée pour construire ou mettre à jour une infrastructure, ou lancer plusieurs instances (plusieurs containers) à partir de cette image.

- C'est grâce à cette fonctionnalité que Docker peut être considéré comme un outil d'_infrastructure as code_.

- On peut également prendre une sorte de snapshot du conteneur (de son système de fichiers, pas des processus en train de tourner) sous forme d'image avec `docker commit <image>` et `docker push`.

---

# Publier des images vers un registry privé

- Généralement les images spécifiques produites par une entreprise n'ont pas vocation à finir dans un dépôt public.

- On peut installer des **registries privés**.

- On utilise alors `docker login <adresse_repo>` pour se logger au registry et le nom du registry dans les `tags` de l'image.

- Exemples de registries :
  - **Gitlab** fournit un registry très intéressant car intégré dans leur workflow DevOps.
  <!-- - **Docker Trusted Registry (DTR)** fait partie de **Docker Enterprise** et pratique des tests de sécurité sur les images. -->

---

## Le design pattern de l'architecture "microservice" (multi-conteneurs) : [12factor.net](https://12factor.net)

[12factor.net](https://12factor.net)

- faire en sorte que le conteneur soit agnostique de l'environnement :
  - s'assure qu'il a les services dont il a besoin
  - config dans des volumes ou des variables d'environnement
  - le plus "stateless" possible
  - interagit avec d'autres services via des ports réseau
  - log bien via son process principal
  - se lance vite et s'éteint proprement rapidement
  - basé sur la même image pour la prod et le dev (ou au mieux)
