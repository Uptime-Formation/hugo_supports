# TODO
- https://www.youtube.com/@TheLearningChannel-Tech
- https://medium.com/@.anders/learnings-from-our-8-years-of-kubernetes-in-production-two-major-cluster-crashes-ditching-self-0257c09d36cd
- ajouter secrets and configmaps!!!

- On pourrait faire : je donne les ressources pour se co avec Azure CLI, pendant ce temps, cours sur les Dockerfiles, et après pendant leur tp dockerfile je les aide sur la azure cli pour apply le rôle helm et creer un azure container registry et azure file ?

- panachage entre TP et cours

# 2 TP de plus sur K8S pur : secrets + RBAC non ? PVC et storage classes, daemonset... (postgres avec helm ?), HPA ?

# 1 TP sur Azure (registries ? l'app cheloue ? Terraform ?) + les TP prémâchés de la doc Azure

# 1 TP plus dev ? TP Docker surtout

- imprimer des tas de schémas et de fiches plastifiées sur les concepts de k8s (idéalement qui "s'emboîtent" façon puzzle) et les distribuer dès le début, recréer les chémas avec ça au tableau

# TP registry : https://www.linuxtechi.com/setup-private-docker-registry-kubernetes/

- Faire du docker ?
- Faire une intro à K8S en commençant par Docker swarm ?
- Intro DevOps
- Rappels YAML

## Idées TP

- rbac
- multinode avec terraform (ou k3sup ?), ou simplement https://microk8s.io/docs/clustering ?
- gestion des secrets
- gestion des configmaps
- storageclasses
- ingresses
- horizontal pod autoscaling avec montée en charge
- daemonsets
- statefulsets (chart postgres ?)
- ***

# Notes en vrac

<!-- - imprimer des awesome-* surlignés et commentés
https://github.com/veggiemonk/awesome-docker#security -->
<!--
## Un netlify commun sur lequel on itère
- dépasser la juxtaposition de modules :
  - intro au cursus : le but est de faire un PaaS (ex. : pbmatique cloud hybride, multi cluster), et non seulement "une CI/CD correcte"
  - on part sur du ansible : infra as code et déploiement, l'approche bas niveau, pour saisir l'idempotence, infra as code, versioning (git), plutôt pet que cattle
  - sur les bases de docker : concepts "devops" : conteneurisation, cattle, immutabilité
  - k8s+rancher :
    - concepts k8s : théorie, liste de concepts, petites manips avec docker run rancher et rancher utilisé comme IDE pour du déploiement k8s, GUI k8s
    - rancher : problématiques de PaaS, cloud hybride / multi cluster et workloads + multi cluster apps (enhanced helm w/ rancher), auth et multiuser (RBAC), ouverture vers pbmatiques réseau distribués (canal/flannel/calico/istio) et volume distribué (ceph/gluster), debug des accès disque et réseau avec truc de tracing poussé par rancher jaeger -->

<!-- ## Scénarios TP fil rouge :

- Ansible : (Elie)
  - LXD (à la main) : lab Ansible ok
  - Ansible ad-hoc ok
  - Application Flask avec playbook (+ playbook LXD donné) ok : v0 hello world
  - Reprendre le playbook pour faire un rôle
    - déployer MySQL et intégrer flask v1 MySQL
  - Déploiement orchestré avec LXD Haproxy, lxc mysql et lxc flask : loadbalancer et backends (LXD)

- Docker : (Hadrien)
  - tp1 existant à améliorer (pas debian sleep) et à la fin portainer
  - TP2 : partir d'un dockerfile du projet knowledge/search d'hadrien qui utiliserait mysql (flask v1) : améliorer TP 2 d'Elie existant et changer l'app, et gestion volumes et réseau en CLI pou rlancer mysql
  -  TP3 : docker-compose avec flask v1 + mysql, puis la passer en elk (flask v2)
  -  TP4 : Swarm vite fait (app web qui loadbalance où tu sais quel nœud t'a servi ou voting app) et intro à K8s en montrant les limites de swarm -->

- Kubernetes + Rancher
  - Concepts K8S
  - petites manips avec docker run rancher et rancher utilisé comme IDE pour du déploiement k8s, GUI k8s
  - chart helm
  - déployer une CI en mettant non seulement gitlab dans k8s mais aussi utiliser un node comme CI
  - rancher intro à la logique :
    problématiques de PaaS, cloud hybride / multi cluster et workloads + multi cluster apps (enhanced helm w/ rancher), auth et multiuser (RBAC)
  - ouverture vers pbmatiques réseau distribués (canal/flannel/calico/istio) et volume distribué (ceph/gluster), debug des accès disque et réseau avec truc de tracing poussé par rancher jaeger

<!-- TP wordpress simple : https://github.com/kubernetes/examples/tree/master/mysql-wordpress-pd -->

# Ressources K8S

## Cours

Bouquin Learn openshift très cool

## TP

https://github.com/GoogleCloudPlatform/kubernetes-workshops

<!-- ### Gitlab
* https://rancher.com/blog/2019/connecting-gitlab-autodevops-authorized-cluster-endpoints/
* https://docs.gitlab.com/12.8/runner/install/kubernetes.html
* https://docs.gitlab.com/charts/installation/index.html
* https://blog.kubernauts.io/ci-cd-with-rancher-pipelines-and-self-hosted-gitlab-b17248294fda

https://medium.com/@abenahmed1/pipeline-de-ci-cd-simplifi%C3%A9-dans-un-cluster-kubernetes-avec-gitlab-et-rancher-602a01029bae

Il y a aussi Rancher's own CI/CD pipeline: https://rancher.com/docs/rancher/v2.x/en/project-admin/pipelines/


NOTE: Gitlab operator? https://docs.gitlab.com/charts/installation/operator.html


  - TP : Gitlab-CI runner + gitlab ? https://rancher.com/blog/2019/connecting-gitlab-autodevops-authorized-cluster-endpoints/
  - https://docs.gitlab.com/12.8/runner/install/kubernetes.html
  - https://docs.gitlab.com/charts/installation/index.html

-->

## General

- https://kubernetes.io/blog/2018/07/18/11-ways-not-to-get-hacked/
- https://coreos.com/operators/
- https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
<!-- ## Kubernetes avec DB répliquée PostgreSQL
- https://github.com/CrunchyData/postgres-operator
- https://access.crunchydata.com/documentation/postgres-operator/latest/run-ha-postgresql-rancher-kubernetes-engine/
- https://portworx.com/
- https://portworx.com/ha-postgresql-kubernetes/
- https://hackernoon.com/postgresql-cluster-into-kubernetes-cluster-f353cde212de
- https://info.crunchydata.com/blog/crunchy-postgresql-operator-with-rook-ceph-storage
- https://rook.io/docs/rook/v1.2/quickstart.html -->

- https://vitess.io/

<!-- ## TODO: à étudier

https://github.com/kubernetes/kubernetes/blob/master/cluster/kube-up.sh
https://rexray.readthedocs.io/en/stable/user-guide/storage-providers/ceph/#ceph-rbd

* https://linkerd.io/ -->

## Sécurité K8S

super tp pour sécuriser la stack elastic sur k8s avec cilium : http://docs.cilium.io/en/stable/gettingstarted/elasticsearch/

- https://github.com/falcosecurity/falco
- vidéos youtube + ressources rootme
- APT the future of k8s attacks
- favs github

# Ressources K8S

https://codelabs.developers.google.com/codelabs/cloud-orchestrate-with-kubernetes/#0

## TP

### Gitlab

- https://rancher.com/blog/2019/connecting-gitlab-autodevops-authorized-cluster-endpoints/
- https://docs.gitlab.com/12.8/runner/install/kubernetes.html
- https://docs.gitlab.com/charts/installation/index.html
- https://blog.kubernauts.io/ci-cd-with-rancher-pipelines-and-self-hosted-gitlab-b17248294fda

https://medium.com/@abenahmed1/pipeline-de-ci-cd-simplifi%C3%A9-dans-un-cluster-kubernetes-avec-gitlab-et-rancher-602a01029bae

Il y a aussi Rancher's own CI/CD pipeline: https://rancher.com/docs/rancher/v2.x/en/project-admin/pipelines/

NOTE: Gitlab operator? https://docs.gitlab.com/charts/installation/operator.html

# Rancher

- a project is a group of namespaces: https://rancher.com/docs/rancher/v2.x/en/cluster-admin/projects-and-namespaces/

* Ajout part sécurité avec le TP de rootme en mode simplifié : guider la partie reverse shell ou faire en mode démo

* Faire une partie des slides qu'il y a dans ressources

* AJouts schemas networks avec appui sur cours lexsi

* me faire kubernetes the hard way

* parler de Autoscaling des pods et des clusters

* smoketest : https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md

* check https://github.com/projectcontour/contour

* mettre la bd d'initiation à K8s de Google ?

* comprendre différentes CNI et cce qui est mis en prod

* ajouter un tuto CRD

## Idées TD :

- https://github.com/dockersamples/k8s-wordsmith-demo
- https://github.com/microservices-demo/microservices-demo
- https://docs.microsoft.com/fr-fr/azure/aks/tutorial-kubernetes-app-update
- https://docs.microsoft.com/fr-fr/azure/aks/tutorial-kubernetes-scale
- reprendre éléments de tutos katakoda officiels : https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-interactive/
- https://kubernetes.io/docs/tutorials/configuration/configure-redis-using-configmap/
- https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/
- k8s elastic + petclinic : https://www.elastic.co/fr/blog/kubernetes-observability-tutorial-k8s-cluster-setup-demo-app-deployment
- https://github.com/michaelhyatt/k8s-o11y-workshop (voir ci dessus)
- istio + bookinfo : https://istio.io/latest/docs/examples/bookinfo/ https://www.digitalocean.com/community/tutorials/an-introduction-to-service-meshes

---

- schémas pods et nodes : https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/

- parler des PersistentVolumeClaims et des plugins

- tuto rolling update

- tuto rancher

- kustomization

- on fait un docker stack deploy --orchestrator=kubernetes de transition ?

- INSTALL LA VERSION DE HOBBYKUBE + KBPR avec Terraform automatique

- weavenet par "défaut" donc ?

- trouver outil en ligne pour faire quick polls qd formation àdistance
- donner olein d'apps d'exemple pour toutes les propriétés intéressantes + parler des CRD via ELasticsearches par exemple ? ou des prometheuses ou etcd operators

- Idée TP HPA : https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

<!-- - trouver comment évaluer acquis à la fin : QCM par mail ou quiz !!! -->

- https://github.com/hobby-kube/guide

- network policy tp : https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/

  - à combne avec calico / cilium / weavenet tuto : https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/
  - avec les example policies à copier coller (dont schema) : https://github.com/ahmetb/kubernetes-network-policy-recipes

- Ne pas arrêter de répéter que tout est alpha dans k8s et les third party stuff et que l'écosystème change tout le temps. par contre bcp d'entreprises dedans et ne sera pas abandonné, et c'est en fait si on trouve l'expression déclarative des objets + les API CRD qui fait qu'on trouve un intérêt à K8s fondamentalement.

- Se baser sur https://victorops.com/blog/how-to-use-vanilla-kubernetes

- https://www.youtube.com/watch?v=iqVt5mbvlJ0 + github

- CronJobs!

- faire un truc avec secrets

- RBAC : https://kubernetes.io/docs/reference/access-authn-authz/rbac/

## TD idées

https://github.com/GoogleCloudPlatform/kubernetes-workshops/tree/master/state
https://github.com/GoogleCloudPlatform/kubernetes-workshops/tree/master/advanced et https://github.com/GoogleCloudPlatform/kubernetes-workshops/blob/master/advanced/local.md

---

- https://12factor.net/fr/

## Apps de demo

https://github.com/oskapt/rancher-demo

## Ressources

(https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/).

https://github.com/cyberark/KubiScan

https://github.com/ramitsurana/awesome-kubernetes/blob/master/docs/managed-kubernetes/managed-kubernetes.md

## Azure Terraform

az ad sp create-for-rbac --skip-assignment

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
https://docs.microsoft.com/fr-fr/azure/developer/terraform/get-started-cloud-shell#authenticate-via-azure-service-principal

## TP

### Un tp dockerfile to registry to running?

https://www.katacoda.com/courses/kubernetes/deploy-service-from-source

## Demo app

https://github.com/instana/robot-shop
https://github.com/microservices-demo/microservices-demo/tree/master/deploy/kubernetes/helm-chart/templates

## Notes

- Prler de Hobbykube et BKPR
- https://toolkit.fluxcd.io/get-started/
- https://github.com/stefanprodan/podinfo

## Todo: parler de ce que devrait fait une CD de Gitlab : se connecter à un bastion, git pull, puis kubectl apply

TODO: add commandes pour basculer de namespace, le créer et l'ajouter dans son kubeconfig

TODO: Inglressa vec dns ou joli minikube (jour 2)

TODO: Jour 1 kustomization + secrets + liveness et eventuellement configmaps

TODO: --watch

TODO/ livenessprobe mysql
TODO: readinessprobe avec podinfo ou l'app python qui se kill + readiness probe type exec + initcontainer

clusterip: none?

TODO: Ressource et cours should u microservices (et bonnes pratiquesde dockernetrypoint qui reboot) et should u crd +

TODO: paradigme k8s de pas orchestrer mais chaos, a ses limites (ajotus statefulsets)

TODO: Purge sensible tp from git

TODO: Ajout initcontainers : https://kubernetes.io/fr/docs/concepts/workloads/pods/init-containers/

TODO: clarifier specs pods et deployments, clarifier accès aux specs

TODO: artifacthub

TODO: gros tp de helm avec postgres ha, wiki, blog, registry, monstersstack et even gitlab avec runner ??, et les ingresses qui vont bien

TODO: tuto bkpr

TODO: tuto registry as helm: harbour, docker-registry, else?

TODO: tuto helm cert manager / lego / let's encrypt

TODO: parler des retours d'expérience de mise en place de k8s grâce aux pages là dessus dans la doc de k8s

Ajouter dans kubeconfig Parler des namespaces dans les contexts

ne pas parler de réseau 2 fois

strategy: recreate bof pour demo, mais sinon rollingupdate est default

---

- istio et networkpolicies ?
- k3s multi node ?
- argocd ?
- chart Helm ?
- rancher ?
- depuis Pod jusqu'à Deployment ? oui !
- metalLB ou au moins TP d'ingress avec HTTPS (cert-manager) jusqu'au bout ? oui
- package docker à k8s avec machin ? skaffoold

- partie réseau

- solution de volume décentralisé ? contrainte à nndoe -> stockage ici ? bases de storageclasses
- réseau vidéo
- bien comprendre bases


---

- rancher demo avec vaches rouges et bleues en 2 deployments mais un seul service