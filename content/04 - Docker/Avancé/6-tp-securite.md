---
title: "TP 6 - Renforcement de la sécurité avec Docker"
draft: false
weight: 1047
---

## Les options de `dockerd` : le fichier `daemon.json`

On peut spécifier des options plus sécurisées, soit en modifiant le service `docker.service`, soit en modifiant le fichier `/etc/docker/daemon.json` (plus recommandé).

- par exemple, on peut choisir certaines valeurs plus restrictives pour les cgroups, pour éviter qu'un conteneur trop gourmand bloque le host (se référer à la documentation).
<!-- - des _cgroups_ correct : `ulimit -a`
defaults dans le docker daemon.json -->

### Configurer les _user namespaces_
Par défault, et à cause de leur côté contre-intuitif, ils ne sont pas utilisés !

<!-- - exemple de durcissement conseillé : <https://docs.docker.com/engine/security/userns-remap/> -->


Voici la documentation détaillée de leur fonctionnement : 
<https://docs.docker.com/engine/security/userns-remap/#enable-userns-remap-on-the-daemon>

- Activons-les grâce à une option spéciale :

`/etc/docker/driver.json` :
```json
{
    "userns-remap": "default"
}
```

- Relancez le service `docker.service`

- Observez ces fichiers :
    - `/etc/subuid`
    - `/etc/passwd`


- Montez le dossier `/` (racine) dans un conteneur : que s'est-il passé ?
```bash
docker run -it -v /:/dossier-racine-hote ubuntu /bin/bash
```

- Faites un `id` depuis un conteneur

- Avec `docker inspect` et `ps -aux`, trouvez le UID effectif d'un conteneur après l'activation de cette option.


## Lancer un audit sur l'installation Docker

- à l'aide du projet Github suivant, lancez le benchmark Docker CIS : <https://github.com/docker/docker-bench-security/>

- commentons-le ensemble

Le guide le plus récent est disponible en téléchargement ici : https://www.cisecurity.org/benchmark/docker

## Le contenu des images Docker

### Utiliser un scanner d'images Docker 
<!-- - Préciser l'empreintre SHA256 d'une image -->
La sécurité de Docker c'est aussi celle de la chaîne de dépendance, des images, des packages installés dans celles-ci : on fait confiance à trop de petites briques dont on ne vérifie pas la provenance ou la mise à jour

<!-- Avec `docker scout`, analysons les CVE présentes dans une image :

- installation : <https://github.com/docker/scout-cli/tree/main?tab=readme-ov-file#manual-installation> ou <https://www.techrepublic.com/article/how-to-add-docker-scout-feature/>
- mode d'emploi : <https://docs.docker.com/scout/quickstart/> -->

- Avec `docker run --rm aquasec/trivy image monimage:latest`, scannons une image de notre choix

<!-- 
- [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) : protéger la _socket_ Docker quand on a besoin de la partager à des conteneurs comme Traefik ou Portainer 


https://github.com/hectorm/cetusguard
CetusGuard - CetusGuard is a tool that protects the Docker daemon socket by filtering calls to its API endpoints
-->

En production, on peut utiliser [Watchtower](https://github.com/containrrr/watchtower) : un conteneur ayant pour mission de périodiquement récupérer des images et recréer les conteneurs pour qu'ils utilisent la dernière image Docker


## Le renforcement de sécurité

On peut utiliser `bane`, un générateur de profil AppArmor pour Docker :
<https://github.com/genuinetools/bane>


<!-- Clair https://github.com/quay/clair -->

<!-- https://github.com/theupdateframework/notary -->

<!-- https://github.com/aquasecurity/trivy -->

