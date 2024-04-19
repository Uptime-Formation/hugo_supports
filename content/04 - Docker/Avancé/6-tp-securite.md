---
title: "TP 6 - Renforcement de la sécurité avec Docker"
draft: false
weight: 1047
---

## Découverte de Podman

Avec l'aide du mode d'emploi rootless de Podman, découvrons ensemble les choix d'architecture de Podman et son mode rootless par défaut : 
<https://podman.io/docs/installation>

Note : il est aussi possible d'utiliser docker-compose avec Podman grâce à l'activation de son API.

Ressources pour le debugging si nécessaire :
- <https://github.com/containers/podman/blob/main/troubleshooting.md>
- <https://wiki.archlinux.org/title/Podman>
- <https://github.com/containers/podman/blob/main/rootless.md>

## Les options de `dockerd` : le fichier `daemon.json`

Revenons à Docker.
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

- commentons-le ensemble à l'aide du guide suivant : [CIS_Docker_Benchmark_V1.6.0.PDF](../../../pdfs/CIS_Docker_Benchmark_V1.6.0.PDF)

<!-- Le guide le plus récent est disponible en téléchargement ici : https://www.cisecurity.org/benchmark/docker -->
<!-- 
### Facultatif : SELinux

Activez SELinux dans le fichier `daemon.json` et relancez l'audit. -->

### Facultatif : inter-container communication on default network
Désactivez l'options `icc` dans le fichier `daemon.json` et relancez l'audit.
Tentez de pinger un conteneur depuis un autre (voir TP3 sur le réseau pour un exemple).

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

### Un registry avancé avec Harbor

Un registry avancé, par exemple avec Harbor, permet d'activer le scanning d'images, de gérer les droits d'usage d'images, et de potentiellement restreindre les images utilisables dans des contextes d'organisation sécurisés.

Voir la démo : https://goharbor.io/docs/2.10.0/install-config/demo-server/

## Le renforcement de sécurité : les profils AppArmor

- On peut utiliser `bane`, un générateur de profil AppArmor pour Docker, en suivant l'exemple d'un profil Nginx :
<https://github.com/genuinetools/bane>

AppArmor est plus haut niveau que SELinux (qui s'active dans `daemon.json` mais que sur les systèmes RedHat).

- Dans l'écrasante majorité des cas, on peut se concentrer sur les *capabilities* (pour des conteneurs non privilégiés) pour avoir un cluster Docker déjà très sécurisé.

<!-- - SELinux peut s'activer sur les systèmes RedHat : plusieurs règles liées à la conteneurisation sont ajoutées au système hôte pour rendre plus difficile une exploitation via un conteneur. Cela s'active dans les options du daemon Docker : <https://www.arhea.net/posts/2020-04-28-selinux-for-containers/> -->
<!-- - les profils *seccomp* ont une logique similaire : ils désactivent certains appels kernel (syscall) pour rendre plus difficile une exploitation (voir https://docs.docker.com/engine/security/seccomp/). En général on utilise un profil par défaut. -->

<!-- capabilities -->

<!-- wtf is seccomp -->

<!-- selinux enabled:  -->

<!-- Clair https://github.com/quay/clair -->

<!-- https://github.com/theupdateframework/notary -->

<!-- https://github.com/aquasecurity/trivy -->

