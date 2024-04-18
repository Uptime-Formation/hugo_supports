---
title: "6 - Considérations de sécurité dans Docker"
draft: false
weight: 1046
---

### Sécurité / durcissement

- **un conteneur privilégié est _root_ sur la machine !**
  - et l'usage des capabilities Linux dès que possible pour éviter d'utiliser `--privileged`
  - on peut utiliser [`bane`](https://github.com/genuinetools/bane), un générateur de profil AppArmor pour Docker
  - AppArmor est plus haut niveau que SELinux, très (trop) complexe à utiliser
  - dans l'écrasante majorité des cas, on peut se concentrer sur les *capabilities* (pour des conteneurs non privilégiés) pour avoir un cluster Docker déjà très sécurisé.

- des _cgroups_ corrects par défaut dans la config Docker : `ulimit -a` et `docker stats`

- par défaut les _user namespaces_ ne sont pas utilisés !
  - exemple de faille : <https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b>
  - exemple de durcissement conseillé : <https://docs.docker.com/engine/security/userns-remap/>

- le benchmark Docker CIS : <https://github.com/docker/docker-bench-security/>

- La sécurité de Docker c'est aussi celle de la chaîne de dépendance, des images, des packages installés dans celles-ci : on fait confiance à trop de petites briques dont on ne vérifie pas la provenance ou la mise à jour

  - Docker Scout, Clair ou Trivy : l'analyse statique d'images Docker grâce aux bases de données de CVEs

  - [Watchtower](https://github.com/containrrr/watchtower) : un conteneur ayant pour mission de périodiquement recréer les conteneurs pour qu'ils utilisent la dernière image Docker

- [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) : protéger la _socket_ Docker quand on a besoin de la partager à des conteneurs comme Traefik ou Portainer

    <!-- - alpine par exemple c'est uclibc donc un glibc recodé par un seul mec : y a des erreurs de compilation sur par exemple compilation d'une JVAPP java et on sait pas pourquoi : du coup l'argument de dire "c'est le même binaire de A à Z", à relativiser car alpine a pas du tout les mêmes binaires par exemplee t donc plus fragile -->

<!-- - Chroot : To be clear, this is NOT a vulnerability. The **root user is supposed to be able to change the root directory for the current process and for child processes**. Chroot only jails non-root processes. Wikipedia clearly summarises the limitations of chroot." Wikipédia : "On most systems, chroot contexts do not stack properly and chrooted programs with sufficient privileges may perform a second chroot to break out. To mitigate the risk of this security weakness, chrooted programs should relinquish root privileges as soon as practical after chrooting, or other mechanisms – such as FreeBSD jails – should be used instead. "
  > En gros chroot fait que changer le root, si on peut rechroot on peut rechroot. Aussi, pb. d'isolation network et IPC. si privilégié pour le faire (du coup tempérer le "filesystem-based" d'Unix)
  > http://pentestmonkey.net/blog/chroot-breakout-perl -->

<!-- - différence en sécurité des VM c'est qu'on s'appuie pour les VM sur un sandboxing au niveau matériel (failles dans IOMMU/VT-X/instrctions x84) (si l'on oublie qu'un soft comme virtualbox a une surface d'attaque plus grade, par exemple exploit sur driver carte réseau) et dans l'autre faille de kernel -->

<!-- - Exemple avec option profil seccomp -->

- intégration des événements suspects à un SIEM avec Falco :
https://github.com/falcosecurity/falco

## Les registries privés
Un registry avancé, par exemple avec [Harbor](https://goharbor.io/docs/2.10.0/install-config/demo-server/), permet d'activer le scanning d'images, de gérer les droits d'usage d'images, et de potentiellement restreindre les images utilisables dans des contextes d'organisation sécurisés.
