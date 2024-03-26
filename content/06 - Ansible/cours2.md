---
title: 'Cours 2 - Les playbooks Ansible'
draft: false
weight: 20
---

Les commandes ad-hoc sont des appels directs de modules Ansible qui fonctionnent de façon idempotente mais ne présente pas les avantages du code qui donne tout son intérêt à l'IaC:

- texte descriptif écrit une fois pour toute
- logique lisible et auditable
- versionnable avec git
- reproductible et incrémental

La dimension incrémentale du code rend en particulier plus aisé de construire une infrastructure progressivement en la complexifiant au fur et à mesure plutôt que de devoir tout plannifier à l'avance.

Le `playbook` est une sorte de script ansible, c'est à dire du code.
Le nom provient du football américain : il s'agit d'un ensemble de stratégies qu'une équipe a travaillé pour répondre aux situations du match. Elle insiste sur la versatilité de l'outil.


### La commande `ansible-playbook`

- version minimale : 
`ansible-playbook mon-playbook.yml`

<!-- - `ansible all -m ping`: Permet de tester si les hotes sont joignables et ansible utilisable (SSH et python sont présents et configurés). -->

- version plus complète :
`ansible-playbook <fichier_playbook> --limit <groupe_machine> --inventory <fichier_inventaire> --become -vv --diff` 

#### Le mode `--check` et l'option `--diff`

- Très utile, le mode `--check` sert à vérifier l'état des ressources sur les machines (*dry-run*) mais sans modifier la configuration.

- L'option `--diff` permet d'afficher les différences entre la configuration actuelle et la configuration après les changements effectués par les différentes tasks. 

Une bonne commande est par exemple :
`ansible-playbook --check -vv --diff`

Cette commande permet de lancer une simulation d'exécution de playbook, et d'afficher les différences entre la configuration actuelle et la configuration désirée (qui aurait été atteinte sans le `--check`).

### Les modules Ansible

Ansible fonctionne grâce à des modules python téléversés sur sur l'hôte à configurer puis exécutés. Ces modules sont conçus pour être cohérents et versatiles et rendre les tâches courantes d'administration plus simples.

Il en existe pour un peu toute les tâches raisonnablement courantes : un slogan Ansible "Batteries included" ! Plus de 1300 modules sont intégrés par défaut.


- `ping`: un module de test Ansible (pas seulement réseau comme la commande ping)

- `dnf/apt`: pour gérer les paquets sur les distributions basées respectivement sur Red Hat ou Debian.

<!-- `... -m yum -a "name=openssh-server state=present"`  -->
  
- `systemd` (ou plus générique `service`): gérer les services/daemons d'un système.

<!-- `... -m systemd -a "name=openssh-server state=started"`  -->

- `user`: créer des utilisateurs et gérer leurs options/permission/groupes

- `file`: pour créer, supprimer, modifier, changer les permission de fichiers, dossier et liens.

<!-- - `shell`: pour exécuter des commandes unix grace à un shell -->

### Option et documentation des modules

La documentation des modules Ansible se trouve à l'adresse [https://docs.ansible.com/ansible/latest/modules/file_module.html](https://docs.ansible.com/ansible/latest/modules/file_module.html)

Chaque module propose de nombreux arguments pour personnaliser son comportement:

exemple: le module `file` permet de gérer de nombreuses opérations avec un seul module en variant les arguments.

Il est également à noter que la plupart des arguments sont facultatifs.

- cela permet de garder les appel de modules très succints pour les taches par défaut
- il est également possible de rendre des paramètres par défaut explicites pour augmenter la clarté du code.

Exemple et bonne pratique: toujours préciser `state: present` même si cette valeur est presque toujours le défaut implicite.

<!-- FIXME: ajout de liens vers module ynh créé et "quand doit-on créer un module ? -->

<!-- 
### La commande `ansible`

- version minimale : 
`ansible <groupe_machine> -m <module> -a <arguments_module>`

- `ansible all -m ping`: Permet de tester si les hotes sont joignables et ansible utilisable (SSH et python sont présents et configurés).

- version plus complète :
`ansible <groupe_machine> --inventory <fichier_inventaire> --become -m <module> -a <arguments_module>` -->

<!-- 
### La console `ansible-console`

Pour exécuter des commandes ad-hoc ansible propose aussi un interpréteur spécifique avec la commande `ansible-console`:

```bash
ansible-console --become webservers`

Welcome to the ansible console.
Type help or ? to list commands.

elie@webservers (2)[f:5]# ping
app1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
app2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

- Une fois loggué sur un groupe de serveur, on peut y exécuter les même commandes qu'avec `ansible` an fournissant les arguments à la suite.

- Exemple: `systemd name=nginx state=started` -->

## Syntaxe yaml

Les playbooks ansible sont écrits au format **YAML**.

- YAML est basé sur les identations à base d'espaces (2 espaces par indentation en général). Comme le langage python.
- C'est un format assez lisible et simple à écrire bien que les indentations soient parfois difficiles à lire.
- C'est un format assez flexible avec des types liste et dictionnaires qui peuvent s'imbriquer.
- Le YAML est assez proche du JSON (leur structures arborescentes typées sont isomorphes) mais plus facile à écrire.

A quoi ça ressemble ?

#### Une liste

```yaml
- 1
- Poire
- "Message à caractère informatif"
```

#### Un dictionnaire

```yaml
clé1: valeur1
clé2: valeur2
clé3: 3
```

#### Un exemple imbriqué plus complexe

```yaml
marché: # debut du dictionnaire global "marché"
  lieu: Crimée Curial
  jour: dimanche
  horaire:
    unité: "heure"
    min: 9


    max: 14 # entier
  fruits: #liste de dictionnaires décrivant chaque fruit
    - nom: pomme
      couleur: "verte"
      pesticide: avec #les chaines sont avec ou sans " ou '
            # on peut sauter des lignes dans interrompre la liste ou le dictionnaire en court
    - nom: poires
      couleur: jaune
      pesticide: sans
  légumes: #Liste de 3 éléments
    - courgettes
    - salade

    - potiron
#fin du dictionnaire global
```

Pour mieux visualiser l'imbrication des dictionnaires et des listes en YAML on peut utiliser un convertisseur YAML -> JSON : [https://www.json2yaml.com/](https://www.json2yaml.com/).

Notre marché devient:

```json
{
  "marché": {
    "lieu": "Crimée Curial",
    "jour": "dimanche",
    "horaire": {
      "unité": "heure",
      "min": 9,
      "max": 14
    },
    "fruits": [
      {
        "nom": "pomme",
        "couleur": "verte",
        "pesticide": "avec"
      },
      {
        "nom": "poires",
        "couleur": "jaune",
        "pesticide": "sans"
      }
    ],
    "légumes": [
      "courgettes",
      "salade",
      "potiron"
    ]
  }
}
```

Observez en particulier la syntaxe assez condensée de la liste "fruits" en YAML qui est une liste de dictionnaires.

## Structure d'un playbook

### Version simplifiée

```yaml
--- 
  # (chaque play commence par un tiret)
- hosts: web # une machine ou groupe de machines
  become: yes # lancer le playbook avec "sudo"

  vars:
    logfile_name: "auth.log"

  vars_files:
    - mesvariables.yml

  roles:
    - flaskapp
    
  tasks:

    - name: créer un fichier de log
      file: # syntaxe yaml extensive : conseillée
        path: /var/log/{{ logfile_name }} #guillemets facultatifs
        mode: 755

    - import_tasks: mestaches.yml

  handlers:
    - systemd:
        name: nginx
        state: "reloaded"
```

### Version plus exhaustive
```yaml
--- 
- name: premier play # une liste de play (chaque play commence par un tiret)
  hosts: serveur_web # un premier play
  become: yes
  gather_facts: false # récupérer le dictionnaires d'informations (facts) relatives aux machines

  vars:
    logfile_name: "auth.log"

  vars_files:
    - mesvariables.yml

  pre_tasks:
    - name: dynamic variable
      set_fact:
        mavariable: "{{ inventory_hostname + '_prod' }}" #guillemets obligatoires

  roles:
    - flaskapp
    
  tasks:
    - name: installer le serveur nginx
      apt: name=nginx state=present # syntaxe concise proche des commandes ad hoc mais moins lisible

    - name: créer un fichier de log
      file: # syntaxe yaml extensive : conseillée
        path: /var/log/{{ logfile_name }} #guillemets facultatifs
        mode: 755

    - import_tasks: mestaches.yml

  handlers:
    - systemd:
        name: nginx
        state: "reloaded"

- name: un autre play
  hosts: dbservers
  tasks:
    ... 
```

- Un playbook commence par un tiret car il s'agit d'une liste de plays.

- Un play est un dictionnaire yaml qui décrit un ensemble de tâches ordonnées en plusieurs sections. Un play commence par préciser sur quelles machines il s'applique puis précise quelques paramètres faculatifs d'exécution comme `become: yes` pour l'élévation de privilège (section `hosts`).

- La section `hosts` est obligatoire. Toutes les autres sections sont **facultatives** !

- La section `tasks` est généralement la section principale car elle décrit les tâches de configuration à appliquer.

- La section `tasks` peut être remplacée ou complétée par une section `roles` et des sections `pre_tasks` `post_tasks`

- Les `handlers` sont des tâches conditionnelles qui s'exécutent à la fin (post traitements conditionnels comme le redémarrage d'un service)

### Élévation de privilège

L'élévation de privilège est nécessaire lorsqu'on a besoin d'être `root` pour exécuter une commande ou plus généralement qu'on a besoin d'exécuter une commande avec un utilisateur différent de celui utilisé pour la connexion on peut utiliser:

- Au moment de l'exécution l'argument `--become` en ligne de commande avec `ansible`, `ansible-console` ou `ansible-playbook`.
- La section `become: yes`
  - au début du play (après `hosts`) : toutes les tâches seront executée avec cette élévation par défaut.
  - après n'importe quelle tâche : l'élévation concerne uniquement la tâche cible.

- Pour executer une tâche avec un autre utilisateur que root (become simple) ou celui de connexion (sans become) on le précise en ajoutant à `become: yes`, `become_user: username`

<!--  - Par défaut la méthode d'élévation est `become_method: sudo`. Il n'est donc pas besoin de le préciser à moins de vouloir l'expliciter.
`su` est aussi possible ainsi que d'autre méthodes fournies par les "become plugins" exp `runas`). -->
### Ordre d'exécution

1. `pre_tasks`
2. `roles`
3. `tasks`
4. `post_tasks`
5. `handlers`

Les roles ne sont pas des tâches à proprement parler mais un ensemble de tâches et ressources regroupées dans un module un peu comme une librairie developpement. Cf. cours 3.

### Bonnes pratiques de syntaxe

- Indentation de deux espaces.
- Toujours mettre un `name:` qui décrit lors de l'exécution de la tâche en cours : un des principes de l'IaC est l'intelligibilité des opérations.
- Utiliser les arguments au format yaml (sur plusieurs lignes) pour la lisibilité, sauf s'il y a peu d'arguments

Pour valider la syntaxe il est possible d'installer et utiliser `ansible-lint` sur les fichiers YAML.