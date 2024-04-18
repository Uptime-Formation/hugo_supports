---
draft: true
---
update ubuntu pour podman https://www.how2shout.com/linux/how-to-install-podman-on-ubuntu-20-04-lts-focal-fossa/#2_Add_Podman_Repository

mettre intertitres dans debut tp2
rendre instructions guac optionnelles
devcontainers
+ docker compose -f
42 layers 
RUn --mount + buildkit advanced cache https://www.augmentedmind.de/2023/11/19/advanced-buildkit-caching/
flask run => boot.sh => entrypoint.sh
dockerignore
docker internal host
astuces network external
https://docs.docker.com/compose/compose-file/
dockerfile version
docker compose version
docker compose override
gitlab reconstruire 

---
Add watchtower et buildx bake

# TODO:

## Suggestions

- Pad CodiMD monté en Docker pour toute la classe ?
- TP2 : microblog ou dnmonster ?
- TP3 : docker-compose avec flask, ajouter ELK ?
- Pour swarm : faire ressortir les intérêts du truc, simuler une montée en charge.
- faire un test de NFS ?
- docker-compose secrets
- Faire un gros docker swarm avec toute la classe ? https://github.com/dockersamples/docker-swarm-visualizer
- Faire les démos compliquées comme des sortes de TP assistés et guidés.
- https://docs.docker.com/engine/reference/commandline/config/
- https://docs.docker.com/engine/context/working-with-contexts/

- Distroless pour **sécurité** : https://github.com/GoogleContainerTools/distroless
- Encrypted overlay network: https://github.com/dockersamples/global-2018-hol/tree/master/security/networking

## Inspirations TD

- basic webapp : https://github.com/docker/labs/blob/master/beginner/chapters/webapps.md
- tuto docker desktop officiel
- https://github.com/dockersamples/global-2018-hol/blob/master/beginner-linux/part-three.md https://github.com/docker-training/docker-paas
- app de paiement avec secrets : https://github.com/dockersamples/atsea-sample-shop-app
- app simple à la con : https://github.com/docker-training/namer
- https://docs.docker.com/compose/rails/
- déployer dokuwiki/mediawiki avec conf toute faite ?
- piquer des trucs du tuto de fergus ?
- same with nextcloud https://hub.docker.com/_/nextcloud or here https://github.com/nextcloud/docker
- tp d'ouverture : tester k8s avec minikube ou k3s et l'app vote example

---

## TODO

### Ajouts cours

- https://github.com/google/gvisor


- Prometheus

* Swarm TLS

- podman / buildah ?

# Pédagogie

Tu crées des boîtes pour que les sysadmins aient "que" à maintenir une infra Swarm ou Kubernetes et que le travail des devs soit le travaild es devs

Remettre intro sur le DevOps : le concept 'd'infra as code, et le concept cattle vs. pet ou autre métaphore

- métaphore du garage utile pour telle véhicule et qu'on aimerait chagner de garage à chaque fois
- pet vs. cattle : du bétail par rapport à un chat qu'on amène au véto etc. Le conteneur amène cette logique
  (- approfondir à l'oral la logique de volume from ? : un conteneur vide, pointeur vers les volumes, du coup il suffit de faire volume from pr un nv conteneur)

Séparer bien les concepts et parties de cours en disant Concept A : Les conteneurs, Concept B : L'infra as code, Concept C : Les dockerfile et les layers

Faire des briques physiques avec des fils et des boites transparentes ou set tout fait

Des schémas explicites

Plus de temps sur les concepts et analogies : garage avec outils spécifiques pour tel type de voiture

<!-- et ne se faire voler qu'un garage à la fois -->

problem-centered rather than content-oriented.

---

- docker in docker on ne fait que lui donner accès à la socket du host : c'est en fait du "sidecar"

- ajouts illustrations réseau NAT de Docker
- **REFAIRE TOUT LE QUIZ**

- expliquer comment on stocke les images et les conteneurs et les volumes concrètement
- s'étendre plus longuement sur la partie comment marchent les hashes et l'overlayfs à coup de copiers collers de linux

- Pour comprendre les images prendre l'extrait des cours Linux qui parlent de tar.gz et décortiquer une image pour comprendre eque c'est qu'un rootfs gzipé, et chercher plus d'illustrations du overlayfs **ou les créer**.

- Faire faire une ci gitlab pour les avancés pour qu'ils comprennent la puissance d'avoir packagé docker. Du coup faire git et framagit forcément (jour 1 pour versionner dockerfile / tp fil rouge ?)

- dire que la ref docker est cool à checker car elle change tout le temps

- ajout correction tp build multi image

- ajouter les "expand" partout

- chapitre cours containers Windows

- tp2 modifier pour pas boot.sh la premiere fois?

- fouiller un peu plus flocker/convoy

- rajouter dans slides + TP sur dockerfile plus d'explications et exemples et manips sur VOLUME et sur EXPOSE.

- séparer cours volume et cours network, td aussi ?

- Virer ou renforcer slide qui parlait de microservices.
- Check pour depends_on : Version 3 no longer supports the condition form of depends_on.
- donner texto les commandes pour fix le docker compose de voting_app ou commit sur mon repo et changer les refs

- acheter livrets containers julia et verif droits images utilisées / refaire schémas

- rajout explications slide exposre un port qu'est-ce que c'est, syntaxe réseau et volume à gauche l'hote a droite le container

- "Some of the major differences between v2 and v3 is that v3 does not support using the volumes_from and extends properties. A whole bunch of the CPU and memory properties have also been moved to a deploy property in v3 instead.
  It’s also worth mentioning if you happen to be using Docker Swarm, you’ll need to use v3+."

- dans docker swarm on peut pas build, (logique : dans k8s non plus)

- Laïus sur infrastructures en conclusion et docker permet pas de simplifier mais des outils pour gérer la complexité de l'informatique quand elle March e pas avec illustration xkcd de dépendances faite par un mec du nevada.

- Bien souligner awesome docker dans les ressources avec gif dockercraft.

- Faire fin moins en queue de poisson pour slide orchestration ou conclusion.

- Revoir comment on fait des variables réutilisables dans le même docker file / dockercompose.

- Updater a v3 et network le docker compose exemple du cours.

- Écrire les commandes possibles de docker swarm dans les slides

- le td5 version elie a l'air d'avoir des scemas et autres trucs cool dedans
- Cool buildah tuto: https://mkdev.me/en/posts/dockerless-part-2-how-to-build-container-image-for-rails-application-without-docker-and-dockerfile
- Cool podman tuto: https://mkdev.me/en/posts/dockerless-part-3-moving-development-environment-to-containers-with-podman
- laïus CRI, CRI-o, containerd, runc ?

* Laïus DB répliquée PostgreSQL

  - http://code4projects.altervista.org/install-postgresql-cluster-docker/
  - https://severalnines.com/database-blog/how-deploy-postgresql-docker-container-using-clustercontrol
  - https://medium.com/@2hamed/replicating-postgres-inside-docker-the-how-to-3244dc2305be
  - https://access.crunchydata.com/documentation/crunchy-postgres-containers/4.2.0/examples/backup-restoration/pgbasebackup/
  - https://access.crunchydata.com/documentation/crunchy-postgres-containers/4.2.0/examples/backup-restoration/pgbackrest/
  - https://access.crunchydata.com/documentation/crunchy-postgres-containers/4.2.0/examples/postgresql/statefulset-cluster/
  - https://github.com/paunin/PostDock#postgres
  - https://info.crunchydata.com/blog/an-easy-recipe-for-creating-a-postgresql-cluster-with-docker-swarm

* imprimer des tas de schémas et de fiches plastifiées sur les concepts de docker (idéalement qui "s'emboîtent" façon puzzle) et les distribuer dès le début, recréer les chémas avec ça au tableau

- faire au début de chaque jour des petites questions / moments d'expression sur ce qui a été vaguement retenu ou compris de la veille

## Swarm monitoring

- Swarmprom : https://dockerswarm.rocks/swarmprom/
- Prometheus w/ Swarm : https://prometheus.io/docs/guides/dockerswarm/
- cadvisor: https://github.com/google/cadvisor

### Swarm blue green

https://www.goetas.com/blog/traps-on-the-way-of-blue-green-deployments/

https://github.com/cecchisandrone/docker-swarm-blue-green (demo avec mysql galera)

## Dockerfile cours

### ENV

Parler des variables :

```Dockerfile
FROM busybox
ENV FOO=/bar
WORKDIR ${FOO}   # WORKDIR /bar
ADD . $FOO       # ADD . /bar
COPY \$FOO /quux # COPY $FOO /quux
```

https://docs.docker.com/engine/reference/builder/#environment-replacement

## TD Dockerfile

Mettre une phase de prebuild et une phase de build là avec `as`, nécessite une app qui build ! Donc pas python mias plutôt search-cards par ex.
Ou quoi que ce soit qui ait du Go ou du build webpack JS.

## Cours 2 Dockerfile

Différence ADD et COPY

- TP2/TP3 : linéariser si /home/app ou /app dans microblog et /data

# Retours IB novembre

COURS 1 : docker collision volume possible !

ajout pour moi command ansible reboot all

- instructions guacamole et shortcults Ctrl+Alt+Shift

* les laisser plus autonomes dans le TP2 quitte à mettre la solution à la fin ou en cachant via des balises spoiler

* repackager tp3 microblog pour que soit dans /app et pas /home/machin et virer la variable

* faire une branceh git microblog par exo de tp et num de tp avec tp_correction

* nommer les exos
* rendre menu intra page plus lisible dans le template hugo
* résoudre bug sur les anchorlinks de la page imprimée

* check le tuto @ https://github.com/docker/getting-started.git
* docker scan

* faire un laïus sur comment fonctionne un hash en informatique pour expliquer ce qu'est cet id unique de l'image, ou au moins expliquer que c'est une fn qui associe un truc presque unique et presque bijectif

---

FROM python:3.6-alpine

RUN addgroup --system microblog && adduser --system microblog -G microblog

WORKDIR /microblog

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# DATABASE_URL by default stores data in a SQLite app.db file in the data folder

# These settings can be overriden at runtime

# e.g. to use MySQL, override this variable with:

# DATABASE_URL=mysql+mysqlconnector://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}/${MYSQL_DB}

---

docker run --name mysql -d -e MYSQL_ROOT_PASSWORD=motdepasseroot -e MYSQL_DATABASE=microblog -e MYSQL_USER=microblog -e MYSQL_PASSWORD=microblog --network microblog mysql:5.7

docker run --name microblog -e DATABASE_URL=mysql+mysqlconnector://microblog:microblog@mysql/microblog -p 5000:5000 --network microblog microblog

---

retours:
- réseaux a l'air plus compliqué, pas assez cadré
- pas adminsys du coup hs reseaux ? bien aimé dockerfile docker compose, yaml pas un pb
- fabien : orchestration en plus
- network trop flou !!! bien aimé identidock, on aurait du travailler avec les volumes ou le transformer en stack

---

volume nommés dans cours !
retaper cours volume reseu, supprimer plugins pourris network et préciser volumes nommés

alleger tp network

bien savoir quand faire pauses

dans tp3 faire que faille rajouter une instruction volume

TP2 microblog pas grinberg
TP3 microblog volume ça va pas + buggé sqlite
dire qu'on peut stocker un volume n'importe où

soit parler des vars docerfile et docker compose bien soit ne pas en parler, quel env pour ces vars ? host ? container ?

---

décrire l'install WSL2 !

Swarm tp avec rollout et rollback car bug,

plus de schémas sur tp réseau et réseau docker

- sur réseau overlay swarm

Expliquer clairement commandes stack et option dans docker compose deploy

---

fix swarm : --publish mode=host,target=80,published=8080

---

traefik security / docker.sock mounting security : https://github.com/Tecnativa/docker-socket-proxy
traefik bis : https://blog.mikesir87.io/2018/07/letting-traefik-run-on-worker-nodes/

- prolonger tuto swarm avec tuto traefik swarm et hardening de swarm, et bdd répliquée :
- https://hub.docker.com/r/bitnami/pgpool/
- https://hub.docker.com/r/citusdata/citus/
- https://hub.docker.com/r/bitnami/mariadb-galera/

- Ajouter cours 6 et 7 avec notions de reverse proxy et de CI/CD : illustrations
- CI/CD : https://www.google.com/search?q=gitlab+ci&client=firefox-b-d&source=lnms&tbm=isch&sa=X&ved=2ahUKEwiam9WOjZftAhUMxoUKHcAqAzEQ_AUoAXoECAwQAw&biw=1568&bih=799
- Traefik : https://www.google.com/search?q=traefik&tbm=isch

- Dasn TP3 à la fin dire : récupérez la config wordpress crée à la fin du TP2 sur le container, montez un nouveau container en bindant bien la config xordpress déjà générée depuis un volume nommé

- Swarm galera ou postrgres ?
- Suis je en capacité de faire l'intro k8s au cas où ?
- Sire que volume dans docker file sert à créer anyway hidden file du coup plutôt data folder alors que volume au runtime est pour plug une config, et solr, et exempli gitlab ci, et minideb.
- Ajout slides de gens qui maintiennent images cool comme bitnami.
- https://github.com/GoogleContainerTools/kaniko

- dire dans tp2 ) quoi srt d'avoir fait copy requirements pip avant de copy toute l'app

- dire de faire passer la commande docker run wordpress à rallonge à la moulinette composerize
- dans tp4 faire faire wordpress docker compose avec config sauvée du tp2

# Notes MSF

Si bien amené, expliquer comment construire une image à partir d'un conteneur modifié "à la main" docker diff et docker commit ou truc du genre, puis expliquer que dockerfile ne fait qu'automatiser tout ça

expliquer plus par écrit cette notion de ligne dockerfile = layer et images = groupe de layers

volume nommé cours dire clairement !

flask lance qd meme en production malgré dev server supposé

backup de volume volumes-from à virer

healthcheck direct dans microblog pas app à part, rajouter param toutes les 10s

rajouter prompt shell dans exemple volume

dire pattern tagger images chaque jour et CI
Dire qu'on s'en fiche cache des images et que des qu'une image étiquetée alors on perd pas les layers. Ex tag avec date

parler du dossier /var/lib/docker et de findmnt

parler du dockerignore et de l'utilité de scinder en deux la partie requirements de la partie install de package et de copie fichiers app

supprimer l'histoire du ip a / tee et faire plutot en demo

fin du tp3 docker network plus de prune

faire d'autre noms que tmp data et data et de la meilleure semantique
v

TP 3 Volume :

- volume DE redis
- creeez volume pas clair

peut ne pas marcher, pas éteindre redis violemment ? plusieurs minutes

wo
rdpress pas mysql port public tp1 et 4

- faire exemple avec conf nginx et mount un seul fichier

- faire tp plus concret sur gestion utilisateurs dans une iamge et mieux parler commande USER

- traefik identidock network marche pas

- restart policy health

- rajoute r lens et rancher et k3s

- dire service kubernetes est pas un service swarm wesh j'ai dit l'inverse

- refaires lides swarm vs k8s parce que pas ouf
- dire qu'essentiel est que k8s vvocab, raj exemple comparaison docker vote, dire que faut faire Lens ou Portainer comme avec Portainer

- parler du script nginx proxy

- pas dire "swarm couple les trucs avec un trux leger comme dns"

- ajouter des screens pour ensuite config elasticsearch

- partie réseau trop dense pour devs !

- - docker stack deploy --orchestrator=kubernetes comme ouverture ?

* CRD K8s avec Docker Stack ? Impossible de retrouver la def

- Istio comme résean network ?

- Parler de weavenet et direqu'en fait vrai bail et puis pareil que du k8s conseillé

- trouver outil en ligne pour faire quick polls qd formation àdistance

- pas dire que swarm moins losen up sur les pods isolated: In k8s, by default, pods are non-isolated; they accept traffic from any source.

- trouver comment évaluer acquis à la fin : QCM par mail ou quiz !!!

## Ressources

- https://medium.com/google-cloud/init-process-for-containers-d03a471fa0cc

## TP

https://github.com/dockersamples/k8s-wordsmith-demo

## Notes

- Dire qu'il y a 2 types de commandes Dockerfile : modif du systeme de fichiers et modifs des metadata
- donner un exemple de script buildah et comparer avec dockerfile

---

crediter docker cours 1 illustrations
sudo usermod et puis pas faire confusion avec le oneliner
docker run debian sans rien s'arrête tout de suite abus de langage cours 1
proposer truc sans guac fermer session
autocompletion docker
ducker run detache syntaxe avant option
docker bibliographie

tp git pas miguelgrinberg après y a déjà un dockerfile :'(

docker stop kille au bout d'un moment et c'est pas dit

MEssage running dev server et prod relou + pas de diff avec docker ps

AJOUT d'UN DOCKERIGNORE sur flask au cas où avec app.db et pycache recursif

pas interroger 127.0.0.11

docker volume create exemple manquin

comment mettre de la musique

docker volume prune

virer speech bind mounting

tp3bis "qu'au prune de conteneurs" : faux, d'images

docker swarm crediter schema

heakthcheck

faire autre chose que cache miss, cahce used

wordpress volume nommé pas utile (sauf si theme) mais celui de la db oui

farie que failover si pas redis,

docker compose timeout 600s
