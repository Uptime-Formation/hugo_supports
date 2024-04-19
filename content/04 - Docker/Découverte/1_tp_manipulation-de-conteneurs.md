---
title: "TP 1 - Installer Docker et jouer avec"
weight: 1015
---

# Premier TD : on installe Docker et on joue avec
{{% expand Installer Docker sur la VM Ubuntu dans Guacamole %}}


- Accédez à votre VM via l'interface Guacamole

- Pour accéder au copier-coller de Guacamole, il faut appuyer sur **`Ctrl+Alt+Shift`** et utiliser la zone de texte qui s'affiche (réappuyer sur `Ctrl+Alt+Shift` pour revenir à la VM).
{{% /expand %}}

<!-- - Vérifiez l'installation de Docker en lançant `sudo docker info`. -->

- Pour installer Docker, suivez la [documentation officielle pour installer Docker sur Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository), depuis "Install using the repository" jusqu'aux deux commandes `sudo apt-get update` et `sudo apt-get install docker-ce docker-ce-cli containerd.io`.

  - Docker nous propose aussi une installation en une ligne (_one-liner_), moins sécurisée : `curl -sSL https://get.docker.com | sudo sh`

- Lancez `sudo docker run hello-world`. Bien lire le message renvoyé (le traduire sur [Deepl](https://www.deepl.com/translator) si nécessaire). Que s'est-il passé ?

- Il manque les droits pour exécuter Docker sans passer par `sudo` à chaque fois.

  - Le daemon tourne toujours en `root`
  - Un utilisateur ne peut accéder au client que s'il est membre du groupe `docker`
  - Ajoutez-le au groupe avec la commande `sudo usermod -aG docker <user>` (en remplaçant `<user>` par ce qu'il faut)
  - Pour actualiser la liste de groupes auquel appartient l'utilisateur, redémarrez la VM avec `sudo reboot` puis reconnectez-vous avec Guacamole pour que la modification sur les groupes prenne effet.

  <!-- **à l'aide du bouton en haut à droite de l'écran sur Ubuntu (pas simplement le terminal mais bien la session Ubuntu, redémarrer marche aussi)**  -->

<!-- - Relancez la session de terminal (en quittant le terminal puis en le relançant)

- Faites un snapshot de la VM Ubuntu avec VirtualBox -->

Pour les prochaines fois, Docker nous propose aussi une installation en une ligne (_one-liner_) : `curl -sSL https://get.docker.com | sudo sh`

### Autocomplétion

- Pour vous faciliter la vie, ajoutez le plugin _autocomplete_ pour Docker et Docker Compose à `bash` en copiant les commandes suivantes :

```bash
sudo apt update
sudo apt install bash-completion curl
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.24.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
```

**Important:** Vous pouvez désormais appuyer sur la touche <TAB> pour utiliser l'autocomplétion quand vous écrivez des commandes Docker

---

# Pour vérifier l'installation

- Les commandes de base pour connaître l'état de Docker sont :

```bash
docker info  # affiche plein d'information sur l'engine avec lequel vous êtes en contact
docker ps    # affiche les conteneurs en train de tourner
docker ps -a # affiche  également les conteneurs arrêtés
```

## Manipuler un conteneur

- **Commandes utiles :** <https://devhints.io/docker>
- **Documentation `docker run` :** <https://docs.docker.com/engine/reference/run/>

Mentalité :
![](../../../images/changingThings.jpg)
Il faut aussi prendre l'habitude de bien lire ce que la console indique après avoir passé vos commandes.

Avec l'aide du support et de `--help`, et en notant sur une feuille ou dans un fichier texte les commandes utilisées :

- Lancez simplement un conteneur Debian. Que se passe-t-il ?

{{% expand "Résultat :" %}}

```bash
docker run debian
# Il ne se passe rien car comme debian ne contient pas de processus qui continue de tourner le conteneur s'arrête
```

{{% /expand %}}

- Lancez un conteneur Debian (`docker run` puis les arguments nécessaires, cf. l'aide `--help`)n avec l'option "mode détaché" et la commande passée au conteneur `echo "Je suis le conteneur basé sur Debian"`. Rien n'apparaît. En effet en mode détaché la sortie standard n'est pas connectée au terminal.

- Lancez `docker logs` avec le nom ou l'id du conteneur. Vous devriez voir le résultat de la commande `echo` précédente.

{{% expand "Résultat :" %}}

```bash
docker logs <5b91aa9952fa> # n'oubliez pas que l'autocomplétion est activée, il suffit d'appuyer sur TAB !
=> Debian container
```

{{% /expand %}}

<!-- - Réessayez en affichant le résultat cette fois-ci avec le mode *attached* -->

- Affichez la liste des conteneurs en cours d'exécution

{{% expand "Solution :" %}}

```bash
docker ps
```

{{% /expand %}}

- Affichez la liste des conteneurs en cours d'exécution et arrêtés.

{{% expand "Solution :" %}}

```bash
docker ps -a
```

{{% /expand %}}

- Lancez un conteneur debian **en mode détaché** avec la commande `sleep 3600`

- Réaffichez la liste des conteneurs qui tournent

- Tentez de stopper le conteneur, que se passe-t-il ?

```
docker stop <conteneur>
```

**NB:** On peut désigner un conteneur soit par le nom qu'on lui a donné, soit par le nom généré automatiquement, soit par son empreinte (toutes ces informations sont indiquées dans un `docker ps` ou `docker ps -a`). L'autocomplétion fonctionne avec les deux noms.

- Trouvez comment vous débarrasser d'un conteneur récalcitrant (si nécessaire, relancez un conteneur avec la commande `sleep 3600` en mode détaché).

{{% expand "Solution :" %}}

```
docker kill <conteneur>
```

{{% /expand %}}

- Tentez de lancer deux conteneurs avec le nom `debian_container`

{{% expand "Solution :" %}}

```
docker run -d --name debian_container debian sleep 500
docker run -d --name debian_container debian sleep 500
```

{{% /expand %}}

Le nom d'un conteneur doit être unique (à ne pas confondre avec le nom de l'image qui est le modèle utilisé à partir duquel est créé le conteneur).

- Créez un conteneur avec le nom `debian2`

```bash
docker run debian -d --name debian2 sleep 500
```

- Lancez un conteneur debian en mode interactif (options `-i -t`) avec la commande `/bin/bash` et le nom `debian_interactif`.
- Explorer l'intérieur du conteneur : il ressemble à un OS Linux Debian normal.

---

## Chercher sur Docker Hub

- Visitez [hub.docker.com](https://hub.docker.com)
- Cherchez l'image de Nginx (un serveur web), et téléchargez la dernière version (`pull`).

```bash
docker pull nginx
```

- Lancez un conteneur Nginx. Notez que lorsque l'image est déjà téléchargée le lancement d'un conteneur est quasi instantané.

```bash
docker run --name "test_nginx" nginx
```

Ce conteneur n'est pas très utile, car on a oublié de configurer un port exposé sur `localhost`.

- Trouvez un moyen d'accéder quand même au Nginx à partir de l'hôte Docker (indice : quelle adresse IP le conteneur possède-t-il ?).

{{% expand "Solution :" %}}

- Dans un nouveau terminal lancez `docker inspect test_nginx` (c'est le nom de votre conteneur Nginx). Cette commande fournit plein d'informations utiles mais difficiles à lire.

- Lancez la commande à nouveau avec `| grep IPAddress` à la fin. Vous récupérez alors l'adresse du conteneur dans le réseau virtuel Docker.

{{% /expand %}}

- Arrêtez le(s) conteneur(s) `nginx` créé(s).
- Relancez un nouveau conteneur `nginx` avec cette fois-ci le port correctement configuré dès le début pour pouvoir visiter votre Nginx en local.

```bash
docker run -p 8080:80 --name "test2_nginx" nginx # la syntaxe est : port_hote:port_container
```

- En visitant l'adresse et le port associé au conteneur Nginx, on doit voir apparaître des logs Nginx dans son terminal car on a lancé le conteneur en mode _attach_.
- Supprimez ce conteneur. NB : On doit arrêter un conteneur avant de le supprimer, sauf si on utilise l'option "-f".

---

On peut lancer des logiciels plus ambitieux, comme par exemple Funkwhale, une sorte d'iTunes en web qui fait aussi réseau social :

```bash
docker run --name funky_conteneur -p 80:80 funkwhale/all-in-one:1.0.1
```

Vous pouvez visiter ensuite ce conteneur Funkwhale sur le port 80 (après quelques secondes à suivre le lancement de l'application dans les logs) ! Mais il n'y aura hélas pas de musique dedans :(

_Attention à ne jamais lancer deux containers connectés au même port sur l'hôte, sinon cela échouera !_

- Supprimons ce conteneur :

```bash
docker rm -f funky_conteneur
```

### _Facultatif :_ Wordpress, MYSQL et les variables d'environnement

- Lancez un conteneur Wordpress joignable sur le port `8080` à partir de l'image officielle de Wordpress du Docker Hub
- Visitez ce Wordpress dans le navigateur

Nous pouvons accéder au Wordpress, mais il n'a pas encore de base MySQL configurée. Ce serait un peu dommage de configurer cette base de données à la main. Nous allons configurer cela à partir de variables d'environnement et d'un deuxième conteneur créé à partir de l'image `mysql`.

Depuis Ubuntu:

- Il va falloir mettre ces deux conteneurs dans le même réseau (nous verrons plus tarde ce que cela implique), créons ce réseau :

```bash
docker network create wordpress
```

- Cherchez le conteneur `mysql` version 5.7 sur le Docker Hub.

- Utilisons des variables d'environnement pour préciser le mot de passe root, le nom de la base de données et le nom d'utilisateur de la base de données (trouver la documentation sur le Docker Hub).

- Il va aussi falloir définir un nom pour ce conteneur

{{% expand "Résultat :" %}}

```bash
docker run --name mysqlpourwordpress -d -e MYSQL_ROOT_PASSWORD=motdepasseroot -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=monwordpress --network wordpress mysql:5.7
```

{{% /expand %}}

- inspectez le conteneur MySQL avec `docker inspect`

- Faites de même avec la documentation sur le Docker Hub pour préconfigurer l'app Wordpress.
- En plus des variables d'environnement, il va falloir le mettre dans le même réseau, et exposer un port

{{% expand "Solution :" %}}

```bash
docker run --name wordpressavecmysql -d -e WORDPRESS_DB_HOST="mysqlpourwordpress:3306" -e WORDPRESS_DB_PASSWORD=monwordpress -e WORDPRESS_DB_USER=wordpress --network wordpress -p 80:80 wordpress
```

{{% /expand %}}

- regardez les logs du conteneur Wordpress avec `docker logs`

- visitez votre app Wordpress et terminez la configuration de l'application : si les deux conteneurs sont bien configurés, on ne devrait pas avoir à configurer la connexion à la base de données
<!-- - avec `docker exec`, visitez votre conteneur Wordpress. Pouvez-vous localiser le fichier `wp-config.php` ? Une fois localisé, utilisez `docker cp` pour le copier sur l'hôte. -->
<!-- - (facultatif) Détruisez votre conteneur Wordpress, puis recréez-en un et poussez-y votre configuration Wordpress avec `docker cp`. Nous verrons ensuite une meilleure méthode pour fournir un fichier de configuration à un conteneur. -->

## Faire du ménage

Il est temps de faire un petit `docker stats` pour découvrir l'utilisation du CPU et de la RAM de vos conteneurs !

- Lancez la commande `docker ps -aq -f status=exited`. Que fait-elle ?

- Combinez cette commande avec `docker rm` pour supprimer tous les conteneurs arrêtés (indice : en Bash, une commande entre les parenthèses de "`$()`" est exécutée avant et utilisée comme chaîne de caractère dans la commande principale)

{{% expand "Solution :" %}}

```bash
docker rm $(docker ps -aq -f status=exited)
```

{{% /expand %}}

- S'il y a encore des conteneurs qui tournent (`docker ps`), supprimez un des conteneurs restants en utilisant l'autocomplétion et l'option adéquate

- Listez les images
- Supprimez une image
- Que fait la commande `docker image prune -a` ?

## Décortiquer un conteneur

- En utilisant la commande `docker export votre_conteneur -o conteneur.tar`, puis `tar -C conteneur_decompresse -xvf conteneur.tar` pour décompresser un conteneur Docker, explorez (avec l'explorateur de fichiers par exemple) jusqu'à trouver l'exécutable principal contenu dans le conteneur.

### Portainer

Portainer est un portail web pour gérer une installation Docker via une interface graphique. Il va nous faciliter la vie.

- Lancer une instance de Portainer :

```bash
docker volume create portainer_data
docker run --detach --name portainer -p 9000:9000 -v portainer_data:/data -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce
```

- Remarque sur la commande précédente : pour que Portainer puisse fonctionner et contrôler Docker lui-même depuis l'intérieur du conteneur il est nécessaire de lui donner accès au socket de l'API Docker de l'hôte grâce au paramètre `--volume` ci-dessus.

- Visitez ensuite la page [http://localhost:9000](http://localhost:9000) ou l'adresse IP publique de votre serveur Docker sur le port 9000 pour accéder à l'interface.
- il faut choisir l'option "local" lors de la configuration
- Créez votre user admin et choisir un mot de passe avec le formulaire.
- Explorez l'interface de Portainer.
- Créez un conteneur.

<!-- ## Installer Docker Desktop for Windows

- À l'aide des [instructions du site officiel](https://docs.docker.com/docker-for-windows/install/), téléchargez et installez Docker Desktop for Windows.
- après avoir vérifié que Docker fonctionnait avec `docker info` dans une invite de commande Windows, installez Visual Studio Code. Ensemble, explorons son interface. . -->

<!-- - Facultatif : installez l'extension VSCode "Docker" par Microsoft pour vous faciliter la vie. Explorez l'interface. -->

<!-- ## _Facultatif :_ explorer Gitpod

- Se créer un compte sur [github.com](https://github.com)

- Créer un dépôt vide (vous pouvez l'appeler `tp_docker` par exemple) et l'ouvrir avec Gitpod

- Dans Gitpod, lancer la commande suivante pour installer Docker (`brew` est un gestionnaire de packet créé initialement pour MacOS et qui ne nécessite pas de droits `sudo`) :
  `brew install docker`

- Dans Gitpod, copiez-collez la clé privée fournie dans le dossier de partage dans un fichier appelé `ssh.private`, changez ses permissions avec :
  `chmod go-rwx ssh.private`

- Puis (après avoir retrouvé l'IP publique de votre VM Scaleway) lancez le tunnel SSH qui nous permettra d'accéder à notre dæmon Docker comme ceci :

```
export DOCKER_IP=INSEREZ_VOTRE_IP_ICI
ssh -nNT -L localhost:23750:var/run/docker.sock $DOCKER_IP -N -l root -i ssh.private
```

Puis dans un autre terminal :

```
export DOCKER_HOST=localhost:23750

```

- Vérifiez en faisant `docker info` et `docker ps` que vous avez bien accès à la même installation de Docker que sur votre VM Scaleway. -->
