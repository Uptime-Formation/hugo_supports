---
title: 3 - Volumes et réseaux
weight: 1030
---

## Cycle de vie d'un conteneur

- Un conteneur a un cycle de vie très court: il doit pouvoir être créé et supprimé rapidement même en contexte de production.

Conséquences :

- On a besoin de mécanismes d'autoconfiguration, en particuler réseau car les IP des différents conteneur changent tout le temps.
- On ne peut pas garder les données persistantes dans le conteneur.

Solutions :

- Des réseaux dynamiques par défaut automatiques (DHCP mais surtout DNS automatiques)
- Des volumes (partagés ou non, distribués ou non) montés dans les conteneurs

---

## Réseau

### Gestion des ports réseaux (_port mapping_)

<!-- Schéma -->

- L'instruction `EXPOSE` dans le Dockerfile informe Docker que le conteneur écoute sur les ports réseau au lancement. L'instruction `EXPOSE` **ne publie pas les ports**. C'est une sorte de **documentation entre la personne qui construit les images et la personne qui lance le conteneur à propos des ports que l'on souhaite publier**.

- Par défaut les conteneurs n'ouvrent donc pas de port même s'ils sont déclarés avec `EXPOSE` dans le Dockerfile.

- Pour publier un port au lancement d'un conteneur, c'est l'option `-p <port_host>:<port_guest>` de `docker run`.

- Instruction `port:` d'un compose file.

---

### Bridge et overlay

<!-- Schéma réseau classique bridge -->

- Un réseau bridge est une façon de créer un pont entre deux carte réseaux pour construire un réseau à partir de deux.

- Par défaut les réseaux docker fonctionne en bridge (le réseau de chaque conteneur est bridgé à un réseau virtuel docker)

- par défaut les adresses sont en 172.0.0.0/8, typiquement chaque hôte définit le bloc d'IP 172.17.0.0/16 configuré avec DHCP.

<!-- Schéma réseau overlay -->

- Un réseau overlay est un réseau virtuel privé déployé par dessus un réseau existant (typiquement public). Pour par exemple faire un cloud multi-datacenters.

---

#### Le réseau Docker est très automatique

<!-- Schéma DNS et DHCP -->

- Serveur DNS et DHCP intégré dans le "user-defined network" (c'est une solution IPAM)

- Donne un nom de domaine automatique à chaque conteneur.

- Mais ne pas avoir peur d'aller voir comment on perçoit le réseau de l'intérieur. Nécessaire pour bien contrôler le réseau.

- `ingress` : un loadbalancer automatiquement connecté aux nœuds d'un Swarm. Voir la [doc sur les réseaux overlay](https://docs.docker.com/network/overlay/).
<!-- schéma ingress -->

### Lier des conteneurs

- Aujourd'hui il faut utiliser un réseau dédié créé par l'utilisateur ("user-defined bridge network")

  - avec l'option `--network` de `docker run`
  - avec l'instruction `networks:` dans un docker composer

- On peut aussi créer un lien entre des conteneurs
  - avec l'option `--link` de `docker run`
  - avec l'instruction `link:` dans un docker composer
  - MAIS cette fonctionnalité est **obsolète** et déconseillée

### Plugins réseaux

Il existe :

- les réseaux par défaut de Docker
- plusieurs autres solutions spécifiques de réseau disponibles pour des questions de performance et de sécurité
  - Ex. : **Weave Net** pour un cluster Docker Swarm
    - fournit une autoconfiguration très simple
    - de la sécurité
    - un DNS qui permet de simuler de la découverte de service
    - Du multicast UDP
    <!-- Donner un autre exemple -->

---

## Volumes

<!-- Ajout schéma -->
<!-- Ajout raisonnement tout ce qui est stateful sur un volume : fichiers de config, certifs, fichiers de base de données -->

## Les volumes Docker via la sous-commande `volume`

- `docker volume ls`
- `docker volume inspect`
- `docker volume prune`
- `docker volume create`
- `docker volume rm`

<!-- ## Volumes nommés -->
<!-- Où sont ils stockés -->

## Bind mounting

Lorsqu'un répertoire hôte spécifique est utilisé dans un volume (la syntaxe `-v HOST_DIR:CONTAINER_DIR`), elle est souvent appelée **bind mounting** ("montage lié").
C'est quelque peu trompeur, car tous les volumes sont techniquement "bind mounted". La particularité, c'est que le point de montage sur l'hôte est explicite plutôt que caché dans un répertoire appartenant à Docker.

Exemple :

```bash
# Sur l'hôte
docker run -it -v /home/user/app/config.conf:/config/main.conf:ro -v /home/user/app/data:/data ubuntu /bin/bash

# Dans le conteneur
cd /data/
touch testfile
exit

# Sur l'hôte
ls /home/user/app/data:
```

## Volumes nommés

- L'autre technique est de créer d'abord un volume nommé avec :
  `docker volume create mon_volume`
  `docker run -d -v mon_volume:/data redis`

---

### L'instruction `VOLUME` dans un `Dockerfile`

L'instruction `VOLUME` dans un `Dockerfile` permet de désigner les volumes qui devront être créés lors du lancement du conteneur. On précise ensuite avec l'option `-v` de `docker run` à quoi connecter ces volumes. Si on ne le précise pas, Docker crée quand même un volume Docker au nom généré aléatoirement, un volume "caché".

### Partager des données avec un volume

- Pour partager des données on peut monter le même volume dans plusieurs conteneurs.

- Pour lancer un conteneur avec les volumes d'un autre conteneur déjà montés on peut utiliser `--volumes-from <container>`

- On peut aussi créer le volume à l'avance et l'attacher après coup à un conteneur.

- Par défaut le driver de volume est `local` c'est-à-dire qu'un dossier est créé sur le disque de l'hôte.

```bash
docker volume create --driver local \
    --opt type=btrfs \
    --opt device=/dev/sda2 \
    monVolume
```

---

### Plugins de volumes

On peut utiliser d'autres systèmes de stockage en installant de nouveau plugins de driver de volume. Par exemple, le plugin `vieux/sshfs` permet de piloter un volume distant via SSH.

Exemples:

- SSHFS (utilisation d'un dossier distant via SSH)
- NFS (protocole NFS)
- BeeGFS (système de fichier distribué générique)
- Amazon EBS (vendor specific)
- etc.

```bash
docker volume create -d vieux/sshfs -o sshcmd=<sshcmd> -o allow_other sshvolume
docker run -p 8080:8080 -v sshvolume:/path/to/folder --name test someimage
```

---

Ou via docker-compose :

```yaml
volumes:
  sshfsdata:
    driver: vieux/sshfs:latest
    driver_opts:
      sshcmd: "username@server:/location/on/the/server"
      allow_other: ""
```

---

### Permissions

- Un volume est créé avec les permissions du dossier préexistant.

```Dockerfile
FROM debian
RUN groupadd -r graphite && useradd -r -g graphite graphite
RUN mkdir -p /data/graphite && chown -R graphite:graphite /data/graphite
VOLUME /data/graphite
USER graphite
CMD ["echo", "Data container for graphite"]
```

---

### Backups de volumes

- Pour effectuer un backup la méthode recommandée est d'utiliser un conteneur suplémentaire dédié
- qui accède au volume avec `--volume-from`
- qui est identique aux autres et donc normalement avec les mêmes UID/GID/permissions.
<!-- - permet de ne pas perdre bêtement le volume lors d'un `prune` car il reste un conteneur qui y est lié -->
