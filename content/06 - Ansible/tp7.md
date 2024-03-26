---
title: "TP7 - Serveur de contrôle AWX et Ansible Vault" 
draft: false
weight: 60
---
## Installer AWX, Rundeck ou Semaphore

- AWX : sur Kubernetes avec k3s


- Rundeck : <https://docs.rundeck.com/docs/administration/install/>
`docker run -it -p 4440:4440 rundeckpro/enterprise:5.1.1`

- Semaphore : <https://github.com/ansible-semaphore/semaphore>
`docker run -p 3000:3000 -d semaphoreui/semaphore`

## Explorer AWX

- Identifiez vous sur awx avec le login `admin` et le mot de passe précédemment configuré.

- Dans la section Modèle de projet, importez votre projet. Un job d'import se lance. Si vous avez mis le fichier `requirements.yml` dans  `roles` les roles devraient être automatiquement installés.

- Dans la section credentials, créez un credential de type machine. Dans la section clé privée copiez le contenu du fichier `~/.ssh/id_ssh_tp` que nous avons configuré comme clé SSH de nos machines. Ajoutez également la passphrase que vous avez configuré au moment de la création de cette clé.

- Créez une ressource inventaire. Créez simplement l'inventaire avec un nom au départ. Une fois créé vous pouvez aller dans la section `source` et choisir de l'importer depuis le `projet`, sélectionnez `inventory.cfg` que nous avons configuré précédemment.
<!-- Bien que nous utilisions AWX les ip n'ont pas changé car AWX est en local et peut donc se connecter au reste de notre infrastructure LXD. -->

- Pour tester tout cela vous pouvez lancez une tâche ad-hoc `ping` depuis la section inventaire en sélectionnant une machine et en cliquant sur le bouton `executer`.

- Allez dans la section modèle de job et créez un job en sélectionnant le playbook `site.yml`.

- Exécutez ensuite le job en cliquant sur la fusée. Vous vous retrouvez sur la page de job de AWX. La sortie ressemble à celle de la commande mais vous pouvez en plus explorer les taches exécutées en cliquant dessus.

- Modifiez votre job, dans la section `Planifier` configurer l'exécution du playbook `site.yml` toutes les 5 minutes.

- Allez dans la section planification. Puis visitez l'historique des Jobs.

- Créons maintenant un workflow qui lance d'abord les playbooks `dbservers.yml` et `appservers.yml` puis en cas de réussite le playbook `upgrade_apps.yml`

- Voyons ensemble comment configurer un vault Ansible, d'abord dans notre projet Ansible normal en chiffrant le mot de passe utilisé pour le rôle MySQL. Il est d'usage de préfixer ces variables par `secret_`.

- Voyons comment déverrouiller ce Vault pour l'utiliser dans AWX en ajoutant des *Credentials*.