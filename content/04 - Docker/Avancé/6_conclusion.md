---
title: Conclusion
weight: 1060
---

<!-- # Docker en production -->

---

# Conclusions sur l'écosystème Docker

## Configurer de la CI/CD

- La nature facile à déployer des conteneurs et l'intégration du principe d'Infrastructure-as-Code les rend indispensable dans de la CI/CD (intégration continue et déploiement continu).
- Les principaux outils de CI sont Gitlab, Jenkins, Github Actions, Travis CI…
  - Gitlab propose par défaut des runners préconfigurés qui utilisent des conteneurs Docker et tournent en général dans un cluster Kubernetes.
  - Gitlab propose aussi un registry d'images Docker, privé ou public, par projet.
- Les tests à l'intérieur des conteneurs peuvent aussi être faits de façon plus poussée, avec par exemple Ansible comme source de healthcheck ou comme suite pour les tests.
- Dans une autre catégorie, Gitpod base son workflow sur des images Docker permettant de configurer un environnement de développement

![](../../images/devops/gitlab_workflow_example.png)
![](../../images/devops/pipeline_status.png)

## Gérer les logs des conteneurs

Avec Elasticsearch, Filebeat et Kibana… grâce aux labels sur les conteneurs Docker

## Gérer le reverse proxy

Avec Traefik, aussi grâce aux labels sur les conteneurs Docker

![](../../images/docker/traefik-architecture.png)

Ou avec Nginx, avec deux projets :

- https://github.com/nginx-proxy/nginx-proxy
- https://github.com/nginx-proxy/acme-companion

## Monitorer des conteneurs

- Avec Prometheus pour Docker et Docker Swarm
- Ou bien Netdata, un peu plus joli et configuré pour monitorer des conteneurs _out-of-the-box_

## Tests sur des conteneurs

- Ansible ou un autre outil comme source de healthcheck

---

<!-- # Exemples de cas pratiques :

Présentation d'un workflow Docker, du développement à la production -->

## Bonnes pratiques et outils

### Sécurité / durcissement

- **un conteneur privilégié est _root_ sur la machine !**

- des _cgroups_ correct : `ulimit -a`

- par défaut les _user namespaces_ ne sont pas utilisés !
  - exemple de faille : <https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b>
  - exemple de durcissement conseillé : <https://docs.docker.com/engine/security/userns-remap/>

<!-- Exemple de renforcement :
```bash
vim /etc/docker/daemon.json
adduser docker-userns -s /bin/false
service docker restart
cat /etc/subuid
cat /etc/passwd
docker run -d -it alpine sh
docker ps
htop
``` -->

- le benchmark Docker CIS : <https://github.com/docker/docker-bench-security/>

- La sécurité de Docker c'est aussi celle de la chaîne de dépendance, des images, des packages installés dans celles-ci : on fait confiance à trop de petites briques dont on ne vérifie pas la provenance ou la mise à jour

  - [Clair](https://github.com/quay/clair) : l'analyse statique d'images Docker

- [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) : protéger la _socket_ Docker quand on a besoin de la partager à des conteneurs comme Traefik ou Portainer

    <!-- - alpine par exemple c'est uclibc donc un glibc recodé par un seul mec : y a des erreurs de compilation sur par exemple compilation d'une JVAPP java et on sait pas pourquoi : du coup l'argument de dire "c'est le même binaire de A à Z", à relativiser car alpine a pas du tout les mêmes binaires par exemplee t donc plus fragile -->

<!-- - Chroot : To be clear, this is NOT a vulnerability. The **root user is supposed to be able to change the root directory for the current process and for child processes**. Chroot only jails non-root processes. Wikipedia clearly summarises the limitations of chroot." Wikipédia : "On most systems, chroot contexts do not stack properly and chrooted programs with sufficient privileges may perform a second chroot to break out. To mitigate the risk of this security weakness, chrooted programs should relinquish root privileges as soon as practical after chrooting, or other mechanisms – such as FreeBSD jails – should be used instead. "
  > En gros chroot fait que changer le root, si on peut rechroot on peut rechroot. Aussi, pb. d'isolation network et IPC. si privilégié pour le faire (du coup tempérer le "filesystem-based" d'Unix)
  > http://pentestmonkey.net/blog/chroot-breakout-perl -->

<!-- - différence en sécurité des VM c'est qu'on s'appuie pour les VM sur un sandboxing au niveau matériel (failles dans IOMMU/VT-X/instrctions x84) (si l'on oublie qu'un soft comme virtualbox a une surface d'attaque plus grade, par exemple exploit sur driver carte réseau) et dans l'autre faille de kernel -->

<!-- - Exemple avec option profil seccomp -->

## Limites de Docker

## Stateful

- les conteneurs stateless c'est bien beau mais avec une base de données, ça ne se gère pas magiquement du tout
  - quelques ressources sur le stateful avec Docker : <https://container.training/swarm-selfpaced.yml.html#450>

### Configurer le réseau de façon plus complexe avec des plugins réseau

- Réseaux "overlay": IP in IP, VXLAN…
- …mais on a rapidement besoin de plugins exclusifs à Kubernetes : [Calico](https://github.com/projectcalico/calico), [Flannel](https://github.com/coreos/flannel/), Canal (Calico + Flannel), [Cilium](https://github.com/cilium/cilium) (qui utilise eBPF)

<!-- (parenthèse systemd : docker daemon et systemd en cocurrence pour être tous les deux des process d'init : pas possible de lancer un conteneur depuis systemd) (2e parenthèse : pid 1) -->

## Volumes distribués

- problème des volumes partagés / répliqués
  - domaine à part entière
  - **Solution 1** : solutions applicatives robustes
    - pour MySQL/MariaDB : [Galera](https://mariadb.com/kb/en/what-is-mariadb-galera-cluster/)
    - pour Postgres : on peut citer [Citus](https://hub.docker.com/r/citusdata/citus/) ou [pgpool](https://hub.docker.com/r/bitnami/pgpool/), voir la [comparaison de différentes solutions](https://wiki.postgresql.org/wiki/Replication,_Clustering,_and_Connection_Pooling)
    - Elasticsearch est distribué _out-of-the-box_
  - **Solution 2** : volume drivers avec Docker
    - [Flocker](https://flocker.readthedocs.io/en/latest/docker-integration/tutorial-swarm-compose.html), [Convoy](https://github.com/rancher/convoy), visent à intégrer une technologie de réplication
    - c'est un moyen, pas une solution : reste un outil pour configurer ce que l'on souhaite

## DataOps
- Doit se baser sur une solution applicative complète comme Kafka
- avec Compose pour les différents services et Swarm pour le scaling
- Solutions actuelles peut-être plus orientées Kubernetes
- Ressources :
    - Pas-à-pas très détaillé d'une pipeline "ETL" https://medium.com/sfu-cspmp/building-data-pipeline-kafka-docker-4d2a6cfc92ca
      - dépôt lié : https://github.com/salcaino/sfucmpt733
    - Exemple avec Kafka : https://github.com/rogaha/data-processing-pipeline/blob/master/docker-compose.yml

## Aller plus loin

- Le livre _Mastering Docker_, de Russ McKendrick et Scott Gallagher
- les ressources présentes dans la [bibliographie](../../bibliographie)
- la liste de [Awesome Docker](https://github.com/veggiemonk/awesome-docker)

![](../../images/dockercraft.gif)
_[Dockercraft](https://github.com/docker/dockercraft) : administrez vos containers dans Minecraft_

## Retours

- Comment ça s'est passé ?
  - Difficulté : trop facile ? trop dur ? quoi en particulier ?
  - Vitesse : trop rapide ? trop lent ? lors de quoi en particulier ?
  - Attentes sur le contenu ? Les manipulations ?
  - Questions restées ouvertes ? Nouvelles questions ?
  - Envie d'utiliser Docker ? ou de le jeter à la poubelle ?
