---
title: "Fil rouge DevOps"
weight: 350
# pre: "<i class='fab fa-git'></i> - "
pre: "<i class='fas fa-infinity'></i> "
# chapter: true
draft: false
---

<!-- pas facultatif le shell -->
<!-- facultatif mysql grinberg -->
<!-- tous prendre flask microblog ? ou le flask qu'ils ont pris -->

## Introduction

L'objectif de ce TP est de faire la démonstration pratique de la plupart des éléments techniques appris durant le cursus DevOps.

L'activité de DevOps dans une équipe est une activité de support au développement et d'automatisation des divers éléments pratiques nécessaire au bon fonctionnement d'une application. Elle est par nature intégrative.

Ce TP consiste donc logiquement à rassembler les aspects pratiques (éléments vus en TP) découverts dans les modules du cursus et de les combiner autour d'une infrastrure Kubernetes pour réaliser en particulier une CI/CD de notre application utilisant Jenkins.

Attention :

- Toutes les parties ne sont pas forcément obligatoire. L'appréciation sera globale. Les bonus sont des idées de personnalisation à réaliser si vous avez le temps et le courage.

- Ce sujet de TP est loin d'être simple :
  - N'hésitez pas à demander de l'aide aux formateurs.
  - Collaborez et partagez la compréhension des enjeux dans le groupe.
- Le sujet est succeptible d'évoluer au fur et à mesure en fonction de vos retours et demandes d'information.
- Les parties de la fin du cursus (Jenkins et peut-être le Monitoring et/ou AWS et/ou Ansible) seront ajoutées par la suite.
- N'oubliez pas de vous reposer pendant les vacances !!

## Rendu

Le rendu du TP est à effectuer par groupe.

Pour chaque groupe les éléments suivant devront être présentés lors de la présentation finale du cursus:

- Une présentation décrivant les différents élements de l'infrastructure et leurs objectifs ainsi que les choix réalisés lors de la réalisation.

- On peut se servir de diapositives afin d’avoir un support oral. L’idée est de voir la gestion du temps, l’expression orale et évidemment le côté technique. Et attention, à la répartition de parole dans le groupe, chacun doit occuper sa place.

- La qualité des diapositives est notée également.

- La présentation dure 20mn, 10mn de plus de questions du jury, 5 mn de délibération du jury sans les stagiaires et 5 mn de compte rendu au groupe de la part du jury.

- Pas de rapport écrit à part les diapositives.

## Objectifs

- Mettre en œuvre un système d’intégration continue et de déploiement DevOps
- Construire une image capable de servir à l’application
- Automatiser la construction d’images
- Mettre à jour et déployer automatiquement des images

- Une installation fonctionnelle de l'infrastructure et de l'application du TP installé sur cette infrastructure telle que décrite dans l'énoncé suivant.
- Deux dépots de code sur Github ou Gitlab contenant pour le premier le code d'infrastructure et pour le second l'application à déployer sur l'infrastructure.

## 0 - Vagrant et Virtualbox: créer une machine virtuelle avec du code

Une infrastructure est généralement composée de machines virtuelles pour la flexibilité, qu'elles soient louées chez un provider de cloud comme Amazon Web Service ou créées à l'aide d'un hyperviseur comme Virtualbox (ou VMWare ou Proxmox etc).

Dans ce TP nous allons utiliser Virtualbox pour créer un ou plusieurs serveurs (selon vos préférences, voir bonus kubernetes installation dans la suite). Pour respecter les bonnes pratiques de l'infrastructure as code et pouvoir partager et reproduire l'installation nous aimerions créer ces machines virtuelles à l'aide de **code descriptif**. L'outil adapté pour cela s'appelle `Vagrant`.

- Installez Vagrant en ajoutant le dépôt ubuntu et utilisant apt (voir https://www.vagrantup.com/downloads pour d'autres installation):

```sh
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vagrant
```

- Créez un dossier pour votre code d'infrastructure par exemple `tp_fil_rouge_infra` et ajoutez à l'intérieur un fichier `Vagrantfile` contenant le code suivant:

```ruby
Vagrant.configure("2") do |config|
    config.vm.provider :virtualbox do |v|
      v.memory = 2048
      v.cpus = 2
    end

    config.vm.define :master do |master|
      # Vagrant va récupérer une machine de base ubuntu 20.04 (focal) depuis cette plateforme https://app.vagrantup.com/boxes/search
      master.vm.box = "ubuntu/focal64"
      master.vm.hostname = "master"
      master.vm.network :private_network, ip: "10.10.0.1"
    end
  end
```

- Entrainez vous à allumer, éteindre, détruire la machine et vous y connecter en ssh en suivant ce tutoriel: https://les-enovateurs.com/vagrant-creation-machines-virtuelles/. (pensez également à utiliser `vagrant --help` ou `vagrant <commande> --help` pour découvrir les possibilités de la ligne de commande vagrant).

Remarques pratiques sur Vagrant :

- Toutes les machines vagrant ont automatiquement un utilisateur vagrant.
- Vagrant partage automatiquement le dossier dans lequel est le `Vagrantfile` à l'intérieur de la VM dans le dossier `/vagrant`. Les scripts et autres fichiers sont donc directement accessibles dans la VM.

## 1 - Application Web Python et Linux

En vous aidant du tutorial suivant (jusqu'à la partie 5, avant la partie certbot): https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-20-04-fr

- Installez dans la machine virtuelle Vagrant précédente une application web flask (par exemple celle proposée dans le tutoriel).

- Rassemblez les étapes d'installation dans un script shell (à ajouter dans le dossier d'infra).

- Vérifiez que votre script d'installation fonctionne en détruisant et recréant la machine virtuelle (`vagrant destroy`) puis en lançant le script en ssh.

- (facultatif) Vous pouvez même ajouter le script directement au `Vagrantfile`, après la ligne `master.vm.network :private_network, ip: "10.10.0.1"` avec la syntaxe suivante ([cf. la documentation](https://www.vagrantup.com/docs/provisioning/basic_usage)):

```rb
      master.vm.provision :shell, privileged: false, inline: <<-SHELL
      commande1
      commande2
      etc
  SHELL
```

#### Idée de bonus

- Sur votre serveur, installez/scriptez en plus de la précédente, l'application flask `microblog` du Flask Mega Tutorial avec une base de donnée MySQL. Voir ce lien tutoriel : https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xvii-deployment-on-linux.

- Personnalisez votre application Flask / Python avec une ou des pages en plus ou une fonctionnalité en plus

## 2 - Git

Versionner le code de l'application précédente avec Git. Créer un dépôt sur Github ou Gitlab.

- Un-e membre du groupe crée le dépôt et ajoute ses collègues à l'application en leur donnant le status de `maintainer`.
- Poussez le code avec une branche `develop`, une branche `main` (production).
- Chaque membre du groupe créé une branche à son nom et s'efforce de ne plus pousser sur `develop` ou `main` dans le futur mais en utilisant sa branche.
- Le code sera ensuite mergé dans la branche `develop` et/ou `main`.

Répétez les étapes précédentes en créant un dépôt pour le code d'infrastructure.

Ces deux dépôts serviront pour la présentation finale de votre code.

#### Idées de bonus

- Écrire à l'avance des issues (au fur et a mesure plutôt que toutes au départ) pour décrire les prochaines étapes à réaliser.

- Utilisez pour la suite du TP des branches pour les issues.

  - Les merger dans `main` sans passer par `develop` (les feature branches remplacent la branche `develop`) en effectuant des pull request Github ou merge requests Gitlab.

- Utilisez le wiki Github ou Gitlab du dépôt d'infrastructure pour documenter votre infrastructure et servir de support à la présentation finale.

## 3 - Docker

En s'aidant du TP2 et TP4 du module Docker, et de votre script d'installation existant :

- Dockeriser une application flask simple (par exemple celle de la partie précédent ou celle du TP Docker à la place) en écrivant un Dockerfile.
- (facultatif) Ajoutez un fichier `docker-compose.yml`. pour lancer l'application.
- Ajoutez les fichiers créées à votre dépôt d'application.

#### Idée de bonus

- Dockeriser l'application microblog avec une base de données MySQL à mettre dans un conteneur à part (voir [le chapitre 19 du Flask Mega Tutorial](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xix-deployment-on-docker-containers) et les différentes branches du dépôt <https://github.com/Uptime-Formation/microblog/>).
- (facultatif) Comme vu dans les TP, rajoutez une instruction `HEALTHCHECK` au Dockerfile pour tester si votre app va bien.

## 4 - Kubernetes installation

En suivant/vous inspirant des TP kubernetes et de la partie 0.

- En repartant du Vagrantfile de la partie 0 : utilisez la commande `master.vm.provision` comme indiqué dans la partie 0 ci-dessus pour installer k3s avec la commande `curl -sfL https://get.k3s.io | sh -`.

- (facultatif) Trouvez comment supprimer l'ingress Traefik de k3s et installez à la place un ingress nginx plus classique (pour pouvoir exposer l'application web à l'extérieur).

- (facultatif) Installez cert-manager comme dans le TP avec un générateur de certificat auto-signé : https://cert-manager.io/docs/configuration/selfsigned/

<!-- - Installez ArgoCD comme dans le TP -->

- Versionnez le Vagrantfile et les fichiers d'installation Kubernetes dans le dépôt d'infrastructure.

#### Idées de bonus

- Installez un repository d'image docker simple en vous aidant de tutoriels sur Internet et de l'image registry:2, ou bien de solutions plus avancées
- Créez un cluster de 3 noeuds k3s avec Vagrant et k3sup.
<!-- - Très avancé! : installer un cluster Kubernetes dans 3 machines virtuelles Vagrant avec Kubespray (solution de référence d'installation kubernetes utilisant Ansible). -->

## 5 - Kubernetes déploiement de l'application

- Déployez une application flask dans le cluster en vous inspirant du TP déployer une application de A à Z.
- Versionnez les fichiers d'installation dans un dossier `k8s` du dépôt d'application.

#### Idée de bonus

- Déployer en plus l'application flask avec une base de donnée externe (voir [chapitre 19 du mega tutorial](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xix-deployment-on-docker-containers)). Installez MySQL à l'aide d'un chart Helm.

<!--
## Ansible et Amazon Web Service

#### Simple

Écrire un playbook Ansible de provisionning de DNS avec AWS (pour pointer sur le cluster Kubernetes)

#### Bonus

Écrire un déploiement Ansible de l'application web (simple ou avec mysql) sur un VPS Amazon Web Service.

## Testing

#### Simple

Ecrire quelques tests unitaires et d'intégration

#### Bonus

Bootstrapper la base de données pour les tests d'intégration

#### Bonus avancé

Écrire des tests pour l'application GRPC

## Jenkins

#### Simple

Installer Jenkins avec un chart Helm
Créer un Pipeline as Code pour lancer les tests
Créer un Stage pour construire, pousser l'image docker et effectuer le déploiement dans Kubernetes si les tests sont concluants.

#### Bonus

Lancer et bootstrapper une BDD de test pour les tests d'intégration
Gérer Jenkins à l'aide de ArgoCD

#### Bonus Avancé

Adapter la CI et la CD à l'application GRPC

## Monitoring

#### Simple

Installer ELK dans le cluster.
Envoyer les logs des conteneurs Docker dans la suite ELK.

#### Bonus
Personnaliser un dashboard de monitoring de l'application dans Kibana -->
