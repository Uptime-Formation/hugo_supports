---
title: TP opt. - CI/CD avec Gitlab et ArgoCD 
draft: false
weight: 2100
---

<!-- ## Tester en local (TP3 k8s)

Avant de pouvoir déployer notre application automatiquement (Continuous Delivery) il faut s'assurer de pouvoir bien déployer l'application dans K8S en version développement.

- Assurez-vous d'avoir bien suivi le TP3 Kubernetes de cette formation. Nous allons réutiliser cette application pour la déployer automatiquement dans un cluster de production Kubernetes (K3S).

- Une fois le TP3 terminé pensez à arrêter minikube (si vous installez k3s sur la même machine il n'y aura peut-être pas assez de RAM) avec `minikube stop`. -->

<!-- ## Une vue d'ensemble (Schéma) -->

## Installation d'un cluster avec argoCD

ArgoCD est un outil de GitOps extrêment pratique et puissant mais il nécessite d'être installé dans un cluster public (avec un IP publique) et avec un certificat HTTPS pour être utilisé correctement.

Qu'est-ce que le GitOps: https://www.objectif-libre.com/fr/blog/2019/12/17/gitops-tour-horizon-pratiques-outils/

Vos serveurs VNC qui sont aussi désormais des clusters k3s ont déjà plusieurs sous-domaines configurés: `<votrelogin>.<sousdomaine>.dopl.uk` et `*.<votrelogin>.<sousdomaine>.dopl.uk`. Le sous domaine `argocd.<login>.<sousdomaine>.dopl.uk` pointe donc déjà sur le serveur (Wildcard DNS).

Ce nom de domaine va nous permettre de générer un certificat HTTPS pour notre application web argoCD grâce à un ingress nginx, le cert-manager de k8s et letsencrypt (challenge HTTP101).

#### Installer le ingress NGINX dans k3s

- Installer l'ingress nginx avec la commande: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml` (pour autres méthodes ou problèmes voir : https://kubernetes.github.io/ingress-nginx/deploy/)

- Vérifiez l'installation avec `kubectl get svc -n ingress-nginx ingress-nginx-controller` : le service `ingress-nginx-controller` devrait avoir une IP externe.

#### Installer Cert-manager dans k3s

- Pour installer cert-manager lancez : `kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml`

- Il faut maintenant créer une ressource de type `ClusterIssuer` pour pourvoir émettre (to issue) des certificats.

- Créez une ressource comme suit (soit dans Lens avec `+` soit dans un fichier à appliquer ensuite avec `kubectl apply -f`):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: cto@doxx.fr
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-prod-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
```

#### Installer Argocd

- Effectuer l'installation avec la première méthode du getting started : https://argo-cd.readthedocs.io/en/stable/getting_started/

- Il faut maintenant créer l'ingress (reverse proxy) avec une configuration particulière que nous allons expliquer.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    # If you encounter a redirect loop or are getting a 307 response code 
    # then you need to force the nginx ingress to connect to the backend using HTTPS.
    #
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  tls:
  - hosts:
    - argocd.<yoursubdomain>
    secretName: argocd-secret # do not change, this is provided by Argo CD
  rules:
  - host: argocd.<yoursubdomain>
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
```

- Créez et appliquez cette ressource Ingress.

- Vérifiez dans Lens que l'ingress a bien généré un certificat (cela peut prendre jusqu'à 2 minutes)

- Chargez la page `argocd.<votre sous domaine>` dans un navigateur. exp `argocd.stagiaire1.docker.dopl.uk`

- Pour se connecter utilisez le login admin et récupérez le mot de passe admin en allant chercher le secret `argocd-initial-admin-secret` dans Lens (Config > Secrets avec le namespace argocd activé).

## Récupérer le corrigé du TP et le pousser sur Gitlab

- Récupérer le corrigé à compléter du TP CICD gitlab argocd avec `git clone -b k8s_gitlab_argocd_correction https://github.com/Uptime-Formation/corrections_tp.git k8s_gitlab_argocd_correction`

- Ouvrez le projet dans VSCode

- Créer un nouveau projet vide sur gitlab

- Remplacez dans tout le projet, les occurences de `<sousdomain>.dopl.uk` par votre sous domaine par exemple `stagiaire1.docker.dopl.uk`

- Remplacez également partout `gitlab.com/e-lie/cicd_gitlab_argocd_corrections` par l'url de votre dépot Gitlab (sans le https:// ou git@).

- Poussez ce projet dans la branche `k8s_gitlab_argocd_correction` du dépot créé précédement: 

```bash
git remote add gitlab <votre dépot gitlab>
git push gitlab
```
- Observons le fichier `.gitlab-ci.yml`.

- Allons voir le pipeline dans l'interface CI/CD de gitlab. Les deux premier stages du pipeline devraient s'être bien déroulés.

## Déploiement de l'application dans argoCD

Expliquons un peu le reste du projet projet.

- Créez un token de déploiement dans `Gitlab > Settings > Repository > Deploy Tokens`. Ce token va nous permettre de donner l'authorisation à ArgoCD de lire le dépôt gitlab (facultatif si le dépôt est public cela ne devrait pas être nécessaire). Complétez ensuite **2 fois** le token dans le fichier k8s/argocd-apps.yaml comme suit : `https://<nom_token>:<motdepasse_token>@gitlab.com/<votre depo>.git` dans les deux sections `repoURL:` des deux applications.

- Créer les deux applications `monstericon-dev` et `monstericon-prod` dans argocd avec `kubectl apply -f k8s/argocd-apps.yaml`.

- Allons voir dans l'interface d'ArgoCD pour vérifier que les applications se déploient bien sauf le conteneur monstericon dont l'image n'a pas encore été buildée avec le bon tag. Pour cela il va falloir que notre pipeline s'execute complètement.

Les deux étapes de déploiement (dev et prod) du pipeline nécessitent de pousser automatiquement le code du projet à nouveau pour déclencher le redéploiement automatique dans ArgoCD (en mode pull depuis gitlab). Pour cela nous avons besoin de créer également un token utilisateur:

- Allez dans `Gitlab > User Settings (en haut à droite dans votre profil) > Access Tokens` et créer un token avec `read_repository write_repository read_registry write_registry` activés. Sauvegardez le token dans un fichier.

- Allez dans `Gitlab > Settings > CI/CD > Variables` pour créer deux variables de pipelines: `CI_USERNAME` contenant votre nom d'utilisateur gitlab et `CI_PUSH_TOKEN` contenant le token précédent. Ces variables de pipelines nous permettent de garder le token secret dans gitlab et de l'ajouter automatiquement aux pipeline pour pouvoir autoriser la connexion au dépot depuis le pipeline (git push).

- Nous allons maintenant tester si le pipeline s'exécute correctement en commitant et poussant à nouveau le code avec `git push gitlab`.

- Debuggons les pipelines s'ils sont en échec.

- Allons voir dans ArgoCD pour voir si l'application dev a été déployée correctement. Regardez la section `events` et `logs` des pods si nécessaire.

- Une fois l'application dev complètement healthy (des coeurs verts partout). On peut visiter l'application en mode dev à l'adresse `https://monster-dev.<votre_sous_domaine>`.

- On peut ensuite déclencer le stage `deploy-prod` manuellement dans le pipeline, vérifier que l'application est healthy dans ArgoCD (debugger sinon) puis visiter `https://monster.<votre_sous_domaine>`.


### Idées d'amélioration

- Déplacer le code de déploiement dans un autre dépôt que le code d'infrastructure. Le pipeline de devra cloner le dépôt d'infrastructure, templater avec kustomize la bonne version de l'image dans le bon environnement. Pousser le code d'infrastructure sur le dépôt d'infrastructure. Corriger l'application ArgoCD pour monitorer le dépôt d'infrastructure.

- Mutualiser le code de déploiement k8s avec des overlays kustomize

- Utiliser une stragégie de blue/green ou A/B déploiement avec Argo Rollouts ou Istio avec vérification de réussite du déploiement et rollback en cas d'échec.

- Ajouter plus d'étapes réalistes de CI/CD en se basant par exemple sur le livre GitOps suivant.

- Gérer la création des ressources gitlab automatiquement avec Terraform et gérer les secrets (tokens gitlab) consciencieusement.

### Bibliographie

- 2021 - GitOps and Kubernetes Continuous Deployment with Argo CD, Jenkins X, and Flux

- Billy Yuen, Alexander Matyushentsev, Todd Ekenstam, Jesse Suen (z-lib.org)
