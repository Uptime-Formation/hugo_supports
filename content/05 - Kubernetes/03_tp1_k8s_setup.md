---
title: 03 - TP1 - Installation et configuration de Kubernetes
draft: false
weight: 2025
---

Au cours de nos TPs nous allons passer rapidement en revue deux manières de mettre en place Kubernetes :

- Un cluster de développement avec `k3s`
- Un cluster managed loué chez un provider (Scaleway, DigitalOcean, Azure ou Google Cloud)

Nous allons d'abord passer par la première option.

## Découverte de Kubernetes


### Installer le client CLI `kubectl`

kubectl est le point d'entré universel pour contrôler tous les type de cluster kubernetes. 
C'est un client en ligne de commande qui communique en REST avec l'API d'un cluster.

Nous allons explorer kubectl au fur et à mesure des TPs. Cependant à noter que :

- `kubectl` peut gérer plusieurs clusters/configurations et switcher entre ces configurations
- `kubectl` est nécessaire pour le client graphique `Lens` que nous utiliserons plus tard.

La méthode d'installation importe peu. Pour installer kubectl sur Ubuntu nous ferons simplement: `sudo snap install kubectl --classic`.

- Faites `kubectl version` pour afficher la version du client kubectl.
<!-- ### Installer Minikube

**Minikube** est la version de développement de Kubernetes (en local) la plus répendue. Elle est maintenue par la cloud native foundation et très proche de kubernetes upstream. Elle permet de simuler un ou plusieurs noeuds de cluster sous forme de conteneurs docker ou de machines virtuelles.

- Pour installer minikube la méthode recommandée est indiquée ici: https://minikube.sigs.k8s.io/docs/start/

Nous utiliserons classiquement `docker` comme runtime pour minikube (les noeuds k8s seront des conteneurs simulant des serveurs). Ceci est, bien sur, une configuration de développement. Elle se comporte cependant de façon très proche d'un véritable cluster.

- Si Docker n'est pas installé, installer Docker avec la commande en une seule ligne : `curl -fsSL https://get.docker.com | sh`, puis ajoutez-vous au groupe Docker avec `sudo usermod -a -G docker <votrenom>`, et faites `sudo reboot` pour que cela prenne effet.

- Pour lancer le cluster faites simplement: `minikube start` (il est également possible de préciser le nombre de coeurs de calcul, la mémoire et et d'autre paramètre pour adapter le cluster à nos besoins.)

Minikube configure automatiquement kubectl (dans le fichier `~/.kube/config`) pour qu'on puisse se connecter au cluster de développement.

- Testez la connexion avec `kubectl get nodes`.

Affichez à nouveau la version `kubectl version`. Cette fois-ci la version de kubernetes qui tourne sur le cluster actif est également affichée. Idéalement le client et le cluster devrait être dans la même version mineure par exemple `1.20.x`. -->

##### Bash completion

Pour permettre à `kubectl` de compléter le nom des commandes et ressources avec `<Tab>` il est utile d'installer l'autocomplétion pour Bash :

```bash
sudo apt install bash-completion

source <(kubectl completion bash)

echo "source <(kubectl completion bash)" >> ${HOME}/.bashrc
```

**Vous pouvez désormais appuyer sur `<Tab>` pour compléter vos commandes `kubectl`, c'est très utile !**

## Installation de `k3s`

K3s est une distribution de Kubernetes orientée vers la création de petits clusters de production notamment pour l'informatique embarquée et l'Edge computing. Elle a la caractéristique de rassembler les différents composants d'un cluster kubernetes en un seul "binaire" pouvant s'exécuter en mode `master` (noeud du control plane) ou `agent` (noeud de calcul).

Avec K3s, il est possible d'installer un petit cluster d'un seul noeud en une commande ce que nous allons faire ici:

<!-- - Passez votre terminal en root avec la commande `sudo -i` puis: -->
- Lancez dans un terminal la commande suivante: `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh - `

 La configuration kubectl pour notre nouveau cluster k3s est dans le fichier `/etc/rancher/k3s/k3s.yaml` et accessible en lecture uniquement par `root`. Pour se connecter au cluster on peut donc faire (parmis d'autre méthodes pour gérer la kubeconfig):

- Créer le répertoire `~/.kube`
 - Copie de la conf `sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config`
 - Changer les permission `sudo chown $USER ~/.kube/config`
 - activer cette configuration pour kubectl avec une variable d'environnement: `export KUBECONFIG=~/.kube/config` ou rechargez votre terminal
 - Tester la configuration avec `kubectl get nodes` qui devrait renvoyer quelque chose proche de:

 ```
NAME                 STATUS   ROLES                  AGE   VERSION
vnc-stagiaire-...   Ready    control-plane,master   10m   v1.21.7+k3s1
```


### Explorons notre cluster k8s

Notre cluster k8s est plein d'objets divers, organisés entre eux de façon dynamique pour décrire des applications, tâches de calcul, services et droits d'accès. La première étape consiste à explorer un peu le cluster :

- Listez les nodes pour récupérer le nom de l'unique node (`kubectl get nodes`) puis affichez ses caractéristiques avec `kubectl describe node/<nom du node>`.

La commande `get` est générique et peut être utilisée pour récupérer la liste de tous les types de ressources.

De même, la commande `describe` peut s'appliquer à tout objet k8s. On doit cependant préfixer le nom de l'objet par son type (ex : `node/<nom du node>` ou `nodes <nom du node>`) car k8s ne peut pas deviner ce que l'on cherche quand plusieurs ressources ont le même nom.

- Pour afficher tous les types de ressources à la fois que l'on utilise : `kubectl get all`

```
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1   <none>        443/TCP   2m34s
```

Il semble qu'il n'y a qu'une ressource dans notre cluster. Il s'agit du service d'API Kubernetes, pour qu'on puisse communiquer avec le cluster.

En réalité il y en a généralement d'autres cachés dans les autres `namespaces`. En effet les éléments internes de Kubernetes tournent eux-mêmes sous forme de services et de daemons Kubernetes. Les *namespaces* sont des groupes qui servent à isoler les ressources de façon logique et en termes de droits (avec le *Role-Based Access Control* (RBAC) de Kubernetes).

Pour vérifier cela on peut :

- Afficher les namespaces : `kubectl get namespaces`

Un cluster Kubernetes a généralement un namespace appelé `default` dans lequel les commandes sont lancées et les ressources créées si on ne précise rien. Il a également aussi un namespace `kube-system` dans lequel résident les processus et ressources système de k8s. Pour préciser le namespace on peut rajouter l'argument `-n` à la plupart des commandes k8s.

- Pour lister les ressources liées au `kubectl get all -n kube-system`.

- Ou encore : `kubectl get all --all-namespaces` (peut être abrégé en `kubectl get all -A`) qui permet d'afficher le contenu de tous les namespaces en même temps.

- Pour avoir des informations sur un namespace : `kubectl describe namespace/kube-system`

### Déployer une application en CLI

Nous allons maintenant déployer une première application conteneurisée. Le déploiement est un peu plus complexe qu'avec Docker, en particulier car il est séparé en plusieurs objets et plus configurable.

- Pour créer un déploiement en ligne de commande (par opposition au mode déclaratif que nous verrons plus loin), on peut lancer par exemple: `kubectl create deployment demonstration --image=monachus/rancher-demo`.

Cette commande crée un objet de type `deployment`. Nous pourvons étudier ce deployment avec la commande `kubectl describe deployment/demonstration`.

- Notez la liste des événements sur ce déploiement en bas de la description.
- De la même façon que dans la partie précédente, listez les `pods` avec `kubectl`. Combien y en a-t-il ?

- Agrandissons ce déploiement avec `kubectl scale deployment demonstration --replicas=5`
- `kubectl describe deployment/demonstration` permet de constater que le service est bien passé à 5 replicas.
  - Observez à nouveau la liste des évènements, le scaling y est enregistré...
  - Listez les pods pour constater

A ce stade impossible d'afficher l'application : le déploiement n'est pas encore accessible de l'extérieur du cluster. Pour régler cela nous devons l'exposer grace à un service :

- `kubectl expose deployment demonstration --type=NodePort --port=8080 --name=demonstration-service`

- Affichons la liste des services pour voir le résultat: `kubectl get services`

Un service permet de créer un point d'accès unique exposant notre déploiement. Ici nous utilisons le type Nodeport car nous voulons que le service soit accessible de l'extérieur par l'intermédiaire d'un forwarding de port.

Une méthode pour accéder à un service (quel que soit sont type) en mode développement est de forwarder le traffic par l'intermédiaire de kubectl (et des composants kube-proxy installés sur chaque noeuds du cluster).


<!-- - Sauriez-vous expliquer ce que l'app fait ?
- Pour le comprendre ou le confirmer, diminuez le nombre de réplicats à l'aide de la commande utilisée précédement pour passer à 5 réplicats. Qu se passe-t-il ? -->


- Pour cela on peut par exemple lancer: `kubectl port-forward svc/demonstration-service 8080:8080 --address 127.0.0.1`
- Vous pouvez désormais accéder à votre app via via kubectl sur: `http://localhost:8080`. Quelle différence avec l'exposition précédente via minikube ?

=> Un seul conteneur s'affiche. En effet `kubectl port-forward` sert à créer une connexion de developpement/debug qui pointe toujours vers le même pod en arrière plan.

Pour exposer cette application en production sur un véritable cluster, nous devrions plutôt avoir recours à un service de type un LoadBalancer. Nous y reviendrons dans le cours sur les objets kubernetes.

#### Simplifier les lignes de commande k8s

- Pour gagner du temps on dans les commandes Kubernetes on peut définir un alias: `alias kc='kubectl'` (à mettre dans votre `.bash_profile` en faisant `echo "alias kc='kubectl'" >> ~/.bash_profile`, puis en faisant `source ~/.bash_profile`).
- Vous pouvez ensuite remplacer `kubectl` par `kc` dans les commandes.

- Également pour gagner du temps en ligne de commande, la plupart des mots-clés de type Kubernetes peuvent être abrégés :
  - `services` devient `svc`
  - `deployments` devient `deploy`
  - etc.

La liste complète : <https://blog.heptio.com/kubectl-resource-short-names-heptioprotip-c8eff9fb7202>

- Essayez d'afficher les serviceaccounts (users) et les namespaces avec une commande courte.

## Une 2e installation : Mettre en place un cluster K8s managé chez le provider de cloud Scaleway

Je vais louer pour vous montrer un cluster kubernetes managé. Vous pouvez également louez le votre si vous préférez en créant un compte chez ce provider de cloud.

- Créez un compte (ou récupérez un accès) sur [Scaleway](https://console.scaleway.com/).
- Créez un cluster Kubernetes avec [l'interface Scaleway](https://console.scaleway.com/kapsule/clusters/create)

La création prend environ 5 minutes.

- Sur la page décrivant votre cluster, un gros bouton en bas de la page vous incite à télécharger ce même fichier `kubeconfig` (*Download Kubeconfig*).

Ce fichier contient la **configuration kubectl** adaptée pour la connexion à notre cluster.


<!-- ## Merger la configuration kubectl


La/Les configurations de kubectl sont à déclarer dans la variable d'environnement `KUBECONFIG`. Nous allons déclarer deux fichiers de config et les merger automatiquement. 

- Téléchargeons le fichiers de configuration scaleway fourni par le formateur ou à récupérer sur votre espace Scaleway. Enregistrez le par exemple dans `~/.kube/scaleway.yaml`.

- Copiez le fichier de config k3s `/etc/rancher/k3s/k3s.yaml` dans `~/.kube`: `sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/ && sudo chown stagiaire ~/.kube/k3s.yaml`

- Changez la variable d'environnement pour déclarer la config par défaut avec en plus nos deux nouvelles configs: `export KUBECONFIG=~/.kube/config:~/.kube/scaleway.yaml:~/.kube/k3s.yaml`

- Pour afficher la configuration fusionnée des fichiers et l'exporter comme configuration par défaut lancez: `kubectl config view --flatten > ~/.kube/config`.

- Remettons l'env par défaut (vide): `export KUBECONFIG=''`.

- Maintenant que nos trois configs sont fusionnées, observons l'organisation du fichier `~/.kube/config` en particulier les éléments des listes YAML de:
  - `clusters`
  - `contexts`
  - `users` -->

- Listez les contextes avec `kubectl config get-contexts` et affichez les contexte courant avec `kubectl config current-context`.

- Changez de contexte avec `kubectl config use-context <nom_contexte>`.

- Testons quelle connexion nous utilisons avec avec `kubectl get nodes`.

- Observons les derniers évènements arrivés à notre cluster avec `kubectl get events --watch`.


## Au delà de la ligne de commande...

#### Accéder à la dashboard Kubernetes

Le moyen le plus classique pour avoir une vue d'ensemble des ressources d'un cluster est d'utiliser la Dashboard officielle. Cette Dashboard est généralement installée par défaut lorsqu'on loue un cluster chez un provider.

On peut aussi l'installer dans minikube ou k3s.

<!-- => Démonstration -->

#### Installer Lens

Lens est une interface graphique (un client "lourd") pour Kubernetes. Elle se connecte en utilisant kubectl et la configuration `~/.kube/config` par défaut et nous permettra d'accéder à un dashboard puissant et agréable à utiliser.

Vous pouvez l'installer en lançant ces commandes :

```bash
## Ajouter OpenLens
curl -LO https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2-366/OpenLens-6.5.2-366.amd64.deb
sudo dpkg -i OpenLens-6.5.2-366.amd64.deb
```

- Lancez l'application `OpenLens`
<!-- - grâce à `./OpenLens-6.5.2-366.x86_64.AppImage` -->
<!-- - Sélectionnez le cluster Scaleway en cliquant sur le bouton plus au lancement -->
- Explorons ensemble les ressources dans les différentes rubriques et namespaces

<!-- #### Installer `ArgoCD` sur notre cluster k3s

Argocd est une solution de "Continuous Delivery" dédiée au **GitOps** avec Kubernetes. Elle fourni une interface assez géniale pour détecter et monitorer les ressources d'un cluster.

Nous verrons dans le TP5 comment l'installer et l'utiliser. -->
