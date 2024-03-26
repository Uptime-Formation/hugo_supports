---
title: "TP5 - Simuler un load balancer" 
draft: false
weight: 50
---

## Infrastructure multi-tier avec load balancer

Pour configurer notre infrastructure:

- Installez les roles avec `ansible-galaxy install -r roles/requirements.yml -p roles`.

- Si vous n'avez pas fait la partie Terraform :
{{% expand "Facultatif  :" %}}

  - complétez l'inventaire statique (`inventory.cfg`)
  - changer dans `ansible.cfg` l'inventaire en `./inventory.cfg` comme pour les TP précédents

- Lancez le playbook global `site.yml`

- Utilisez la commande `ansible-inventory --graph` pour afficher l'arbre des groupes et machines de votre inventaire
- Utilisez la de même pour récupérer l'ip du `balancer0` (ou `balancer1`) avec : `ansible-inventory --host=balancer0`
- Ajoutez `hello.test` et `hello2.test` dans `/etc/hosts` pointant vers l'ip de `balancer0`.

- Chargez les pages `hello.test` et `hello2.test`.

- Observons ensemble l'organisation du code Ansible de notre projet.
  - Nous avons rajouté à notre infrastructure un loadbalancer installé à l'aide du fichier `balancers.yml`
  - Le playbook `upgrade_apps.yml` permet de mettre à jour l'application en respectant sa haute disponibilité. Il s'agit d'une opération d'orchestration simple en utilisant les 3 serveurs de notre infrastructure.
  - Cette opération utilise en particulier `serial` qui permet de d'exécuter séquentiellement un play sur une fraction des serveurs d'un groupe (ici 1 à la fois parmis les 2).
  - Notez également l'usage de `delegate` qui permet d'exécuter une tache sur une autre machine que le groupe initialement ciblé. Cette directive est au coeur des possibilités d'orchestration Ansible en ce qu'elle permet de contacter un autre serveur (déplacement latéral et non pas *master -> node* ) pour récupérer son état ou effectuer une modification avant de continuer l'exécution et donc de coordonner des opérations.
  - notez également le playbook `exclude_backend.yml` qui permet de sortir un backend applicatif du pool. Il s'utilise avec des variables en ligne de commande.
<!-- TODO: faire des vars_prompts ? -->

- Désactivez le noeud qui vient de vous servir la page en utilisant le playbook `exclude_backend.yml` dans une tâche AWX avec `backend_name=<noeud à désactiver> backend_state=disabled` et `playbooks/exclude_backend.yml`.

- Rechargez la page: vous constatez que c'est l'autre backend qui a pris le relai.

- Nous allons maintenant mettre à jour.
