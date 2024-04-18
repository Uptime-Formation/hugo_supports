---
title: TP 2b - Exercices sur les images
weight: 1026
---

## Docker Hub

- Avec `docker login`, `docker tag` et `docker push`, poussez l'image `microblog` sur le Docker Hub. Créez un compte sur le Docker Hub le cas échéant.

{{% expand "Solution :" %}}

```bash
docker login
docker tag microblog:latest <your-docker-registry-account>/microblog:latest
docker push <your-docker-registry-account>/microblog:latest
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
