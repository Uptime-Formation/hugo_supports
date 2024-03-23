---
title: "07 - TP 3 - Déployer des conteneurs de A à Z"
draft: false
weight: 2050
---

Récupérez le projet de base : `git clone -b exercice https://github.com/Uptime-Formation/tp3-k8s.git tp3`. On peut ouvrir une fenêtre VSCode directement dans le dossier qui nous intéresse avec : `code tp3`.

Ce TP va consister à créer des objets Kubernetes pour déployer une application microservices (plutôt simple) : `monsterstack`.
Elle est composée :

- d'un front-end en Flask (Python) appelé `monstericon`,
- d'un service de backend qui génère des images (un avatar de monstre correspondant à une chaîne de caractères) appelé `dnmonster`
- et d'un datastore `redis` servant de cache pour les images de monstericon

Nous allons également utiliser le builder kubernetes `skaffold` pour déployer l'application en mode développement : l'image du frontend `monstericon` sera construite à partir du code source présent dans le dossier `app` et automatiquement déployée dans `minikube`.

# Etudions le code et testons avec `docker compose`

- Monstericon est une application web python (flask) qui propose un petit formulaire et lance une requete sur le backend pour chercher une image et l'afficher.
- Monstericon est construit à partir du `Dockerfile` présent dans le dossier `TP3`.
- Le fichier `docker-compose.yml` est utile pour faire tourner les trois services de l'application dans docker rapidement (plus simple que kubernetes)

Pour lancer l'application il suffit :
1. d'installer Docker avec : `curl https://get.docker.com | sudo sh -`
2. puis d'exécuter : `sudo docker compose up -d`
3. on peut afficher l'install avec `sudo docker compose ps` et les logs avec `sudo docker compose logs -f`

Passons maintenant à Kubernetes.

## Utiliser Kompose (facultatif)

Explorer avec Kompose comment on peut traduire un fichier `docker-compose.yml` en ressources Kubernetes (ce sont les instructions à la page suivante : https://kubernetes.io/fr/docs/tasks/configure-pod-container/translate-compose-kubernetes/).

D'abord, installons Kompose :

```bash
# Linux
curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.1/kompose-linux-amd64 -o kompose

chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose
```

Puis, utilisons la commande `kompose convert` et observons les fichiers générés. 
Ces fichiers ne sont pas très complets, supprimons-les.


## Déploiements pour le backend d'image `dnmonster` et le datastore `redis`

Maintenant nous allons également créer un déploiement pour `dnmonster`:

- créez `dnmonster.yaml` dans le dossier `k8s-deploy-dev` et collez-y le code suivant :

`dnmonster.yaml` :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dnmonster
  labels:
    app: monsterstack
spec:
  selector:
    matchLabels:
      app: monsterstack
      partie: dnmonster
  strategy:
    type: Recreate
  replicas: 5
  template:
    metadata:
      labels:
        app: monsterstack
        partie: dnmonster
    spec:
      containers:
        - image: amouat/dnmonster:1.0
          name: dnmonster
          ports:
            - containerPort: 8080
              name: dnmonster
```

- Ensuite, configurons un deuxième deployment `redis.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: monsterstack
spec:
  selector:
    matchLabels:
      app: monsterstack
      partie: redis
  strategy:
    type: Recreate
  replicas: 1
  template:
    metadata:
      labels:
        app: monsterstack
        partie: redis
    spec:
      containers:
        - image: redis:latest
          name: redis
          ports:
            - containerPort: 6379
              name: redis
```


- Appliquez ces ressources avec `kubectl apply -f k8s-deploy-dev/` et vérifiez dans `Lens` que les 5 + 1 réplicats sont bien lancés.

## Déploiement du frontend `monstericon`

Ajoutez au fichier `monstericon.yml` du dossier `k8s-deploy-dev` le code suivant:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monstericon
  labels:
    app: monsterstack
spec:
  selector:
    matchLabels:
      app: monsterstack
      partie: monstericon
  strategy:
    type: Recreate
  replicas: 3
  template:
    metadata:
      labels:
        app: monsterstack
        partie: monstericon
    spec:
      containers:
        - name: monstericon
          image: monstericon
          ports:
            - containerPort: 5000
```

### Skaffold (optionnel)
- Installez `skaffold` en suivant les indications ici: [https://skaffold.dev/docs/install/](https://skaffold.dev/docs/install/)

L'image `monstericon` de ce déploiement n'existe pas sur le Docker Hub, et notre Kubernetes doit pouvoir accéder à la nouvelle version de l'image construite à partir du `Dockerfile`. Nous allons utiliser `skaffold` pour cela.
Il y a plusieurs possibilités :
- utiliser **minikube** : minikube a la capacité de se connecter au registry de notre installation Docker locale
- **sur k3s ou sur un cluster cloud** : pousser à chaque itération notre image sur un registry distant (Docker Hub)
  - pour ce faire, il faut éditer le fichier `skaffold.yaml` et le fichier de **Deployment** correspondant pour remplacer le nom de l'image `monstericon` pour faire référence à l'adresse à laquelle on souhaite pousser l'image sur le registry distant (ex: `docker.io/MON_COMPTE_DOCKER_HUB/monstericon`)
  - il est possible qu'il faille ajouter au même niveau que `artifacts:` dans le fichier `skaffold.yaml` ceci :
```yaml
  local:
    push: true
```
  - heureusement le mécanisme de layers des images Docker ne nous oblige à uploader que les layers modifiés de notre image à chaque build
- (plus long) configurer un registry local (en Docker ou en Kubernetes) auquel Skaffold et Kubernetes peuvent accéder
  - c'est plus long car il faut simplement configurer les certificats HTTPS ou expliciter que l'on peut utiliser un registry non sécurisé (HTTP)
  - ensuite il suffit de déployer un registry tout simple (l'image officielle `registry:2`) ou plus avancé ([Harbour](https://goharbor.io/) par exemple)
- (plus avancé) utiliser Kaniko, un programme de Google qui permet de builder directement dans le cluster Kubernetes : https://skaffold.dev/docs/pipeline-stages/builders/docker/#dockerfile-in-cluster-with-kaniko


- Observons le fichier `skaffold.yaml`
- Lancez `skaffold run` pour construire et déployer l'application automatiquement (skaffold utilise ici le registry docker local et `kubectl`)

### Une image pour `monstericon`


L'image `monstericon` de ce déploiement n'existe pas sur le Docker Hub, et notre Kubernetes doit pouvoir accéder à la nouvelle version de l'image construite à partir du `Dockerfile`.

**Sans un outil comme Skaffold**, nous sommes bloqué·es : il faut construire l'image à la main et la pousser dans un registry joignable par notre install.

Voici l'image déjà poussée par le formateur :
`docker.io/uptimeformation/monstericon`

#### Santé du service avec les `Probes`

- Ajoutons des healthchecks au conteneur dans le pod avec la syntaxe suivante (le mot-clé `livenessProbe` doit être à la hauteur du `i` de `image:`) :

```yaml
livenessProbe:
  tcpSocket: # si le socket est ouvert c'est que l'application est démarrée
    port: 5000
  initialDelaySeconds: 5 # wait before firt probe
  timeoutSeconds: 1 # timeout for the request
  periodSeconds: 10 # probe every 10 sec
  failureThreshold: 3 # fail maximum 3 times
readinessProbe:
  httpGet:
    path: /healthz # si l'application répond positivement sur sa route /healthz c'est qu'elle est prête pour le traffic
    port: 5000
    httpHeaders:
      - name: Accept
        value: application/json
  initialDelaySeconds: 5
  timeoutSeconds: 1
  periodSeconds: 10
  failureThreshold: 3
```

La **livenessProbe** est un test qui s'assure que l'application est bien en train de tourner. S'il n'est pas rempli le pod est automatiquement supprimé et recréé en attendant que le test fonctionne.

Ainsi, k8s sera capable de savoir si notre conteneur applicatif fonctionne bien, quand le redémarrer. C'est une bonne pratique pour que le `replicaset` Kubernetes sache quand redémarrer un pod et garantir que notre application se répare elle même (self-healing).

Cependant une application peut être en train de tourner mais indisponible pour cause de surcharge ou de mise à jour par exemple. Dans ce cas on voudrait que le pod ne soit pas détruit mais que le traffic évite l'instance indisponible pour être renvoyé vers un autre backend `ready`.

La **readinessProbe** est un test qui s'assure que l'application est prête à répondre aux requêtes en train de tourner. S'il n'est pas rempli le pod est marqué comme non prêt à recevoir des requêtes et le `service` évitera de lui en envoyer.

#### Configuration d'une application avec des variables d'environnement simples

- Notre application monstericon peut être configurée en mode DEV ou PROD. Pour cela elle attend une variable d'environnement `CONTEXT` pour lui indiquer si elle doit se lancer en mode `PROD` ou en mode `DEV`. Ici nous mettons l'environnement `DEV` en ajoutant (aligné avec la livenessProbe):

```yaml
env:
  - name: CONTEXT
    value: DEV
```

#### Ajouter des indications de ressource nécessaires pour garantir la qualité de service

- Ajoutons aussi des contraintes sur l'usage du CPU et de la RAM, en ajoutant à la même hauteur que `env:` :

```yaml
resources:
  requests:
    cpu: "100m" # 10% de proc
    memory: "50Mi"
  limits:
    cpu: "300m" # 30% de proc
    memory: "200Mi"
```

Nos pods auront alors **la garantie** de disposer d'un dixième de CPU (100/1000) et de 50 mégaoctets de RAM. Ce type d'indications permet de remplir au maximum les ressources de notre cluster tout en garantissant qu'aucune application ne prend toute les ressources à cause d'un fuite mémoire etc.

- Relancer `skaffold run` pour appliquer les modifications.
- Avec `kubectl describe deployment monstericon`, lisons les résultats de notre `readinessProbe`, ainsi que comment s'est passée la stratégie de déploiement `type: Recreate`.

#### Exposer notre stack avec des services

Les services K8s sont des endpoints réseaux qui balancent le trafic automatiquement vers un ensemble de pods désignés par certains labels. Ils sont un peu la pierre angulaire des applications microservices qui sont composées de plusieurs sous parties elles même répliquées.

Pour créer un objet `Service`, utilisons le code suivant, à compléter :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <nom_service>
  labels:
    app: monsterstack
spec:
  ports:
    - port: <port>
  selector:
    app: <app_selector>
    partie: <tier_selector>
  type: <type>
---
```

Ajoutez le code précédent au début de chaque fichier déploiement. Complétez pour chaque partie de notre application :

- le nom du service (`name:` dans `metadata:`) par le nom de notre programme. En particulier, il faudra forcément appeler les services `redis` et `dnmonster` comme ça car cela permet à Kubernetes de créer les entrées DNS correspondantes. Le pod `monstericon` pourra ainsi les joindre en demandant à Kubernetes l'IP derrière `dnmonster` et `redis`.
- nom de la `partie` par le nom de notre programme (`monstericon`, `dnmonster` et `redis`)
- le port par le port du service
- les selectors `app` et `partie` par ceux du pod correspondant.

Le type sera : `ClusterIP` pour `dnmonster` et `redis`, car ce sont des services qui n'ont à être accédés qu'en interne, et `LoadBalancer` pour `monstericon`.

- Appliquez à nouveau avec `skaffold run`.
- Listez les services avec `kubectl get services`.
- Visitez votre application dans le navigateur avec `minikube service monstericon`.
- Supprimez l'application avec `skaffold delete`.

### Ajoutons un ingress (~ reverse proxy) pour exposer notre application en http


- Pour **Minikube** : Installons le contrôleur Ingress Nginx avec `minikube addons enable ingress`.
- Pour les autres types de cluster (**cloud** ou **k3s**), lire la documentation sur les prérequis pour les objets Ingress et installez l'ingress controller appelé `ingress-nginx` : <https://kubernetes.io/docs/concepts/services-networking/ingress/#prerequisites>. Si besoin, aidez-vous du TP suivant sur l'utilisation de Helm.

- Avant de continuer, vérifiez l'installation du contrôleur Ingress Nginx avec `kubectl get svc -n ingress-nginx ingress-nginx-controller` : le service `ingress-nginx-controller` devrait avoir une IP externe.

Il s'agit d'une implémentation de reverse proxy dynamique (car ciblant et s'adaptant directement aux objets services k8s) basée sur nginx configurée pour s'interfacer avec un cluster k8s.

- Repassez le service `monstericon` en mode `ClusterIP`. Le service n'est plus accessible sur un port. Nous allons utiliser l'ingress à la place pour afficher la page.

- Ajoutez également l'objet `Ingress` suivant dans le fichier `monster-ingress.yaml` :

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monster-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: monsterstack.local # à changer si envie/besoin
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: monstericon
                port:
                  number: 5000
```

- Ajoutez ce fichier avec `skaffold run`.

- Récupérez l'ip de minikube avec `minikube ip`, (ou alors allez observer l'objet `Ingress` dans `Lens` dans la section `Networking`. Sur cette ligne, récupérez l'ip de minikube en `192.x.x.x.`).

- Ajoutez la ligne `<ip-minikube> monsterstack.local` au fichier `/etc/hosts` avec `sudo nano /etc/hosts` puis CRTL+S et CTRL+X pour sauver et quitter.

- Visitez la page `http://monsterstack.local` pour constater que notre Ingress (reverse proxy) est bien fonctionnel.
<!-- Pour le moment l'image de monstre ne s'affiche pas car la sous route de récup d'image /monster de notre application ne colle pas avec l'ingress que nous avons défini. TODO trouver la syntaxe d'ingress pour la faire marcher -->

### Solution

Le dépôt Git de la correction de ce TP est accessible ici : `git clone -b tp3 https://github.com/Uptime-Formation/corrections_tp.git`
