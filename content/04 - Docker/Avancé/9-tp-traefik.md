---
title: TP 9 - Docker et les reverse proxies
draft: false
weight: 1075
---

## Exercice 1a - Utiliser Traefik pour le routage

Traefik est un reverse proxy très bien intégré à Docker. Il permet de configurer un routage entre un point d'entrée (ports `80` et `443` de l'hôte) et des containers Docker, grâce aux informations du daemon Docker et aux `labels` sur chaque containers.
Nous allons nous baser sur le guide d'introduction [Traefik - Getting started](https://doc.traefik.io/traefik/getting-started/quick-start/).

- Avec l'aide de la documentation Traefik, ajoutez une section pour le reverse proxy Traefik pour dans un fichier Docker Compose de votre choix.

{{% expand "Exemple de Docker Compose :" %}}
```yml
services:
  identidock:
    image: uptimeformation/monstericon
    ports:
      - "5000:5000"
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

{{% expand "Solution :" %}}
 <!-- {linenos=table,hl_lines=[8,"15-17"],linenostart=199} -->

```yaml
services:
  reverse-proxy:
    # The official v2 Traefik docker image
    image: traefik:v2.3
    # Enables the web UI and tells Traefik to listen to docker
    command: --api.insecure=true --providers.docker
    ports:
      # The HTTP port
      - "80:80"
      # The HTTPS port
      - "443:443"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
```

{{% /expand %}}

- Explorez le dashboard Traefik accessible sur le port indiqué dans le fichier Docker Compose.

Pour que Traefik fonctionne, 2 étapes :
- faire en sorte que Traefik reçoive la requête quand on s'adresse à l'URL voulue (DNS + routage)
- faire en sorte que Traefik sache vers quel conteneur rediriger le trafic reçu (et qu'il puisse le faire) 

- Ajouter des labels à l'app web que vous souhaitez desservir grâce à Traefik à partir de l'exemple de la doc Traefik, grâce aux labels ajoutés dans le `docker-compose.yml` (attention à l'indentation).
  {{% expand "Solution :" %}}

```yaml
# ...
whoami:
  # A container that exposes an API to show its IP address
  image: traefik/whoami
  labels:
    - "traefik.http.routers.whoami.rule=Host(`whoami.docker.localhost`)"
```

{{% /expand %}}

## Exercice 1b - un certificat Let's Encrypt (ou autosigné)

Utilisons le nom de domaine public de votre VM, normalement communiqué par le formateur.

- Avec l'aide de la [documentation Traefik sur Let's Encrypt et Docker Compose](https://doc.traefik.io/traefik/user-guides/docker-compose/acme-http/), configurez Traefik pour qu'il crée un certificat Let's Encrypt pour votre container.
<!-- - Si vous avez une IP publique mais pas de domaine, vous pouvez utiliser le service gratuit [netlib.re] qui vous fournira un domaine en `*.netlib.re`. -->
<!-- - Vous aurez aussi besoin de configurer des DNS via `netlib.re` si vous voulez vérifier des sous-domaines (et non votre domaine principal) auprès de Let's Encrypt (de plus, si vous voulez un certificat avec *wildcard* pour tous vos sous-domaines, il faudra [résoudre le `dnsChallenge` de Let's Encrypt de manière manuelle](https://doc.traefik.io/traefik/https/acme/#dnschallenge)). -->

{{% expand "Solution :" %}}

Remplacer le service `reverse-proxy` précédent par :
 <!-- {linenos=table,hl_lines=[8,"15-17"],linenostart=199} -->

```yaml
reverse-proxy:
  image: "traefik:v2.3"
  container_name: "traefik"
  command:
    #- "--log.level=DEBUG"
    - "--api.insecure=true"
    - "--providers.docker=true"
    - "--entrypoints.web.address=:80"
    - "--entrypoints.web-securise.address=:443"

    #  Pour faire un test d'abord, utiliser le serveur Let's Encrypt de staging :
    #- "--certificatesresolvers.letsencrypt-staging.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
    # - "--certificatesresolvers.letsencrypt-staging.acme.httpchallenge=true"
    # - "--certificatesresolvers.letsencrypt-staging.acme.httpchallenge.entrypoint=web"
    # - "--certificatesresolvers.letsencrypt-staging.acme.email=postmaster@example.com"
    # - "--certificatesresolvers.letsencrypt-staging.acme.storage=/letsencrypt/acme.json"
    - "--certificatesresolvers.letsencrypt-certifgratuit.acme.httpchallenge=true"
    - "--certificatesresolvers.letsencrypt-certifgratuit.acme.httpchallenge.entrypoint=web"
    - "--certificatesresolvers.letsencrypt-certifgratuit.acme.email=postmaster@example.com"
    - "--certificatesresolvers.letsencrypt-certifgratuit.acme.storage=/letsencrypt/acme.json"

    # Ces deux lignes permettent de désactiver le HTTP et de rediriger vers du HTTPS
    - "--entrypoints.web.http.redirections.entryPoint.to=web-securise"
    - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
  ports:
    - "80:80"
    - "443:443"
    # On devrait changer pour ne pas exposer le dashboard à l'extérieur
    # - "127.0.0.1:8080:8080"
    - "8080:8080"
  volumes:
    - "./letsencrypt:/letsencrypt"
    - "/var/run/docker.sock:/var/run/docker.sock"
```

(il faut remplacer l'e-mail `postmaster@example.com` par un autre ne terminant pas par `example.com`).

Ensuite, en remplaçant le nom de domaine `example.com`<!-- (utilisez votre nom de domaine principal si vous ne voulez pas vous soucier du DNS et des limitations de Let's Encrypt, voir plus haut)-->, ajoutez des labels à vos containers ainsi :
```yaml
  whoami:
    image: "traefik/whoami"
    labels:
      - "traefik.http.routers.whoami.rule=Host(`example.com`)"
      - "traefik.http.routers.whoami.entrypoints=web-securise"
      - "traefik.http.routers.whoami.tls.certresolver=letsencrypt-certifgratuit"
```

{{% /expand %}}


### **Note pour utiliser un certificat autosigné :**
Pour utiliser un certificat autosigné, il n'y a pas besoin de configurer de "cert resolver", il suffit de bien exposer le port 443 de Traefik et d'adapter la ligne suivante pour chaque service exposé :
`- "traefik.http.routers.whoami.tls=true"`


## Exercice 2 - Router vers notre stack identidock

Ajoutons des labels dans notre stack identidock pour l'exposer via Traefik sur l'adresse `monster.localhost`.

{{% expand "Indice 1 :" %}}
Attention : il faudra bien faire attention aux réseaux dans lesquels se trouvent les conteneurs !
{{% /expand %}}

{{% expand "Indice 2 :" %}}
Il va falloir utiliser le mot-clé `external` dans `networks:` (il y a aussi le mot-clé `name` qui peut être utile ici)
{{% /expand %}}

**Attention :** il y a un problème assez difficile à comprendre et à résoudre avec Traefik, il n'est pas explicite ! Cette page vous aidera à le résoudre (à rajouter dans le paramètre `command:` du conteneur Traefik) : https://community.traefik.io/t/docker-provider-how-does-traefik-choose-which-service-ip-address-to-proxy-to-when-container-is-on-multiple-networks/16852/2

## Exercice 3 - Swarm avec Traefik

- Avec l'aide de la [documentation Traefik sur Docker Swarm](https://doc.traefik.io/traefik/routing/providers/docker/#configuration-examples), configurez Traefik avec Swarm.

{{% expand "Solution :" %}}
 <!-- {linenos=table,hl_lines=[8,"15-17"],linenostart=199} -->

```yaml
services:
      reverse-proxy:
            image: "traefik:v2.3"
            container_name: "traefik"
            command:
            # - "--log.level=DEBUG"

            - "--api.insecure=true"
            - "--providers.docker=true"

            # Config pour Docker Swarm
            - "--providers.docker.swarmMode=true"

            - "--entrypoints.web.address=:80"

            #     Config pour Let's Encrypt
            #     - "--entrypoints.websecure.address=:443"
            #     - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
            #     - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
            #     #- "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
            #     - "--certificatesresolvers.myresolver.acme.email=postmaster@example.com"
            #     - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"

            ports:
            -     target: 80
                  published: 80
                  mode: host
            -     target: 8080
                  published: 8080
                  mode: host
            # -     target: 443
            #       published: 443
            #       mode: host

            deploy:
                  mode: global
                  placement:
                        constraints:
                        - node.role == manager
                  restart_policy:
                        condition: on-failure

            volumes:
            - "/var/run/docker.sock:/var/run/docker.sock"
            #     - "./letsencrypt:/letsencrypt"
```


Ensuite, en adaptant le nom de domaine, ajoutez des labels  **à la section `deploy`** (nécessaire dans Swarm) de vos containers ainsi :

 <!-- {linenos=table,hl_lines=[8,"15-17"],linenostart=199} -->
```yaml
      whoami:
            image: "traefik/whoami"
            deploy:
                  replicas: 5
                  labels:
                        - traefik.http.routers.whoami-service.rule=Host(`example.com`)
                        - traefik.http.services.whoami-service.loadbalancer.server.port=80
      #   Config TLS
      #     - "traefik.http.routers.whoami-service.entrypoints=websecure"
      #     - "traefik.http.routers.whoami-service.tls.certresolver=myresolver"
```

{{% /expand %}}


<!-- Note pour le DNS :
- Si vous avez une IP publique mais pas de domaine, vous pouvez utiliser le service gratuit [netlib.re] qui vous fournira un domaine en `*.netlib.re`.
- Vous aurez aussi besoin de configurer des DNS via `netlib.re` si vous voulez vérifier des sous-domaines (et non votre domaine principal) auprès de Let's Encrypt (de plus, si vous voulez un certificat avec *wildcard* pour tous vos sous-domaines, il faudra [résoudre le `dnsChallenge` de Let's Encrypt de manière manuelle](https://doc.traefik.io/traefik/https/acme/#dnschallenge)). -->
