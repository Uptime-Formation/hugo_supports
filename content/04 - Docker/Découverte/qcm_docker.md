---
title: "QCM Docker"
draft: true
---

<!-- #### Pour répondre au questionnaire: -->

<!-- - Objet: `QCM Docker Janvier2020 <votre_prénom> <votre_nom>`
- Copier collez le texte des questions ci-dessous dans le mail
- Ajoutez un `V` ou un `X` ou autre devant la ou les réponses que vous pensez être valides -->

- Pour ce QCM il y a une seule bonne réponse par question

**Question 1**

Quelle est la principale différence entre une machine virtuelle (VM) et un conteneur ?

1. Un conteneur est une boîte qui contient un logiciel windows alors qu'une VM fonctionne généralement sous Linux.
1. Un conteneur permet de faire des applications distribuées dans le cloud contrairement aux machines virtuelles.
1. Un conteneur partage le noyau du système hôte alors qu'une machine virtuelle virtualise son propre noyau indépendant.

**Question 2**

En quoi Docker permet de faire de l'infrastructure as code ?

1. Comme Ansible docker se connecte en ssh à un Linux pour décrire des configurations.
1. Docker permet avec les Dockerfiles et les compose files de décrire l'installation d'un logiciel et sa configuration.
1. Docker permet de coder un Paas (plateforme as a service) et de remplacer les infrastructures traditionnelles.

**Question 3**

Quel sont les principaux atouts de Docker

1. Il permet de rendre compatible tous les logiciels avec le cloud (aws etc.) et facilite l'IOT.
1. Il utilise le langage go qui est de plus en plus populaire et accélère les logiciels qui l'utilise.
1. Il permet d'uniformiser les déploiement logiciels, il est léger en ressources, et facilite la construction d'application distribuées.

**Question 4**

Pour créer un conteneur Docker à partir du code d'un logiciel il faut d'abord :

1. Écrire un Dockerfile qui explique comment empaqueter le code puis construire l'image Docker avec docker build.
1. Créer un dossier de projet d'infrastructure et décrire le déploiement puis appliquer la configuration.
1. Créer un cluster avec docker-machine puis compiler le logiciel avec docker stack.

**Question 5**

Un volume docker est :

1. Un espace de stockage connecté à un ou plusieurs conteneurs docker.
1. Une sorte de snapshot à partir duquel créer des conteneurs identiques.
1. Une instance fonctionnante de l'application que l'on déploie dans un cluster comme swarm.

**Question 6**

Comment configurer de préférence un conteneur à sa création (lancement avec docker run) ?

1. Reconstruire l'image à chaque fois à partir du Dockerfile.
1. Utiliser des variables d'environnement pour définir les paramètre à la volée.
1. Utiliser des fichiers de configuration dans serveur de stockage de fichier.

**Question 7**

Un compose file permet :

1. D'installer docker facilement sur des VPS et de contrôler un cluster.
1. Alléger les images et détecter les failles de sécurités dans le packaging d'une application.
1. De décrire une application multiconteneurs et sa configuration réseau et stockage.

<!-- **Question 8**

La philosophie de Docker à la différence d'Ansible est basé sur :

1. L'immutabilité c'est à dire le fait de jeter et recréer un conteneur pour le changer plutôt que d'aller modifier l'intérieur.
1. L'idempotence c'est à dire la possibilité de répéter les modifications sans casser la configuration.
1. Le cloud c'est à dire la vente de plateforme et de logiciel "as a service". -->

**Question 9**

Indiquez la ou les affirmations vraies:

1. Docker est très pratique pour distribuer un logiciel mais le réseau est très pénible à configurer.
2. Docker propose un répertoire officiel pour gérer et distribuer facilement des logiciels dans de nombreuses versions.
3. Docker est une catastrophe en terme de sécurité car les conteneurs sont peu isolés.

**Question 10**

Docker Swarm est:

1. Un cloud ou pousser et récupérer les images docker de la terre entière.
1. Un réseau overlay qui permet de rassembler plusieurs machines en un cloud.
1. Une solution de clustering et d'orchestration intégrée directement avec Docker.
