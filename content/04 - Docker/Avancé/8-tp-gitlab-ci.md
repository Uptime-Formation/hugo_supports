---
title: TP 8 - Intégration continue avec Gitlab
draft: false
weight: 1065
---

## Créer une pipeline de build d'image Docker avec les outils CI/CD Gitlab
1. Si vous n'en avez pas déjà un, créez un compte sur Gitlab.com : <https://gitlab.com/users/sign_in#register-pane>
2. Créez un nouveau projet et avec Git, le Web IDE Gitlab, ou bien en forkant une app existante depuis l'interface Gitlab, poussez-y l'app de votre choix (par exemple [`microblog`](https://github.com/Uptime-Formation/microblog/), [`dnmonster`](https://github.com/amouat/dnmonster/) ou l'app `healthcheck` vue au TP2).
3. Ajoutez un Dockerfile à votre repository ou vérifiez qu'il en existe bien un.
4. Créez un fichier `.gitlab-ci.yml` depuis l'interface web de Gitlab et choisissez "Docker" comme template. Observons-le ensemble attentivement.
5. Faites un commit de ce fichier.
6. Vérifiez votre CI : il faut vérifier sur le portail de Gitlab comment s'est exécutée la pipeline.
7. Vérifiez dans la section Container Registry que votre image a bien été push.

### Ressources
* La [section Quick Start de la documentation Gitlab-CI](https://docs.gitlab.com/ee/ci/quick_start/README.html)
* Vous pouvez trouver [des exemples de CI dans la documentation Gitlab](https://docs.gitlab.com/ee/ci/examples/README.html).
* La [section dédiée à `docker build` de la documentation Gitlab](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)
* La [section de la documentation dédiée au Container Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)


## Avec BitBucket

BitBucket propose aussi son outil de pipeline, à la différence qu'il n'a pas de registry intégré, le template par défaut propose donc de pousser son image sur le registry Docker Hub.
- Il suffit de créer un repo BitBucket puis d'y ajouter le template de CI Docker proposé (le template est caché derrière un bouton *See more*).
- Ensuite, il faut ajouter des *Repository variables* avec ses identifiants Docker Hub. Dans le template, ce sont les variables `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD` et `DOCKERHUB_NAMESPACE` (identique à l'username ici).

### Ressources
- https://support.atlassian.com/bitbucket-cloud/docs/run-docker-commands-in-bitbucket-pipelines/


## Conclusion
### Déployer notre container ou notre projet Docker Compose
Nous avons fait la partie CI (intégration continue). Une étape supplémentaire est nécessaire pour ajouter le déploiement continu de l'app (CD) : si aucune étape précédente n'a échoué, la nouvelle version de l'app devra être déployée sur votre serveur, via une connexion SSH et `rsync` par exemple.
Il faudra ajouter des variables secrètes au projet (clé SSH privée par exemple), cela se fait dans les options de Gitlab ou de BitBucket.