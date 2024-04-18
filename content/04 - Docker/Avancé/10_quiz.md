---
title: "QCM Docker"
draft: false
weight: 1100
---

### Entourez la bonne réponse

## Question 1

Quelle est la principale différence entre une machine virtuelle (VM) et un conteneur ?

1. Un conteneur est une boîte qui contient un logiciel Windows alors qu'une VM fonctionne généralement sous Linux.
1. Un conteneur permet de faire des applications distribuées dans le cloud contrairement aux machines virtuelles.
1. Un conteneur partage le noyau du système hôte alors qu'une machine virtuelle virtualise son propre noyau indépendant.

## Question 2

En quoi Docker permet de faire de l'_Infrastructure as Code_ ?

1. Comme Ansible, Docker se connecte en SSH à un Linux pour décrire des configurations.
2. Docker permet avec les Dockerfiles et les fichiers Compose de décrire l'installation d'un logiciel et sa configuration.

## Question 3

Quels sont les principaux atouts de Docker ?

1. Il permet de rendre compatible tous les logiciels avec le cloud (AWS, etc.) et facilite l'IoT.
2. Il utilise le langage Go qui est de plus en plus populaire et accélère les logiciels qui l'utilise.
3. Il permet d'uniformiser les déploiements logiciels et facilite la construction d'application distribuées.

## Question 4

Pour créer un conteneur Docker à partir du code d'un logiciel il faut d'abord :

1. Écrire un Dockerfile qui explique comment empaqueter le code puis construire l'image Docker avec docker build.
2. Créer un cluster avec docker-machine puis compiler le logiciel avec Docker Stack.

## Question 5

Un volume Docker est :

1. Un espace de stockage connecté à un ou plusieurs conteneurs docker.
2. Une image fonctionnelle à partir de laquelle on crée des conteneurs identiques.
3. Un snapshot de l'application que l'on déploie dans un cluster comme Swarm.

## Question 6

Indiquez la ou les affirmations vraies :

Comment configurer de préférence un conteneur à sa création (lancement avec `docker run`) ?

1. Reconstruire l'image à chaque fois à partir du Dockerfile avant.
1. Utiliser des variables d'environnement pour définir les paramètres à la volée.
1. Faire `docker exec` puis aller modifier les fichiers de configuration à l'intérieur
1. Associer le conteneur à un volume qui rassemble des fichiers de configuration

## Question 7

Un _Compose file_ ou fichier Compose permet :

1. D'installer Docker facilement sur des VPS et de contrôler un cluster.
2. D'alléger les images et de détecter les failles de sécurité dans le packaging d'une application.
3. De décrire une application multiconteneurs, sa configuration réseau et son stockage.

## Question 8

Indiquez la ou les affirmations vraies :

La philosophie de Docker est basée sur :

1. L'immutabilité, c'est-à-dire le fait de jeter et recréer un conteneur pour le changer plutôt que d'aller modifier l'intérieur.
2. Le cloud, c'est-à-dire la vente de plateforme et de logiciel "as a service".
3. L'infrastructure-as-code, c'est-à-dire la description d'un état souhaité de l'infrastructure hébergeant application

## Question 9

Indiquez la ou les affirmations vraies :

1. Docker est très pratique pour distribuer un logiciel mais tous les conteneurs doivent obligatoirement être exposés à Internet.
2. Docker utilise un cloud pour distribuer facilement des logiciels dans de nombreuses versions.
3. Docker est une catastrophe en terme de sécurité car les conteneurs sont peu isolés.

## Question 10

Docker Swarm est :

1. Un cloud où pousser et récupérer les images Docker de la terre entière.
2. Une solution de clustering et d'orchestration intégrée directement avec Docker.
3. Un logiciel qui complète ce qu'offre Kubernetes en y ajoutant des fonctionnalités manquantes
