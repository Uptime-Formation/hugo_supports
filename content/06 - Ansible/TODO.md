---
title: "TODO formation Ansible" 
draft: true
---

TODO: refaire un bel histoirque git ansible-tp-solutions

TODO:
- exo clair avec le vault
- passer à webhookd (nécessite ubnutu 22)

TODO: Répartir la biblio par section

FIXME: ajout de liens vers module ynh créé et vers doc officielle "quand doit-on créer un module ?"
TODO: ajout de liens vers jinja filter custom

TODO:
    - connection à une machine windows avec winRM et installation d'un truc?
    - installer un serveur AWX dans un cluster kubernetes
    - coder un module custom basique
    - créer un orchestration avancée avec un rollback utilisant block et rescue
    
TODO: tuto du debug Ansible avec le debugger normal 
<!-- et https://gist.github.com/Deepakkothandan/daeb1ba8dc5b73d85ded03cb2a614e85 -->


TODO:
- virer loop var loop control ou simplifier

- faire que dans une 2nde partie le loop sur le yaml non ?
 rôles dans ex

- isntall git de base

- instructions en français dans playbook

- parler de l'ext vscode YAML et git graph avec des screens

- faire un vrai tp avec variables, conds, changed_when, etc.


- exo avec register

- exo avec conditions


---
A integrer :

    ansible_connection définit le mode de connexion aux hôtes cibles. Cette directive est essentielle pour déterminer comment Ansible établit une connexion avec les machines distantes, que ce soit via SSH, WinRM, Docker...

    register permet de capturer les résultats d'une tâche dans une variable.
    Les conditions dans Ansible permettent d'adapter l'exécution des tâches en fonction de critères spécifiques.

    Les directives include_* et import_* (comme include_tasks, import_tasks, include_role, import_role, include_playbook et import_playbook) sont utilisées pour inclure des fichiers, des rôles ou des playbooks dans un playbook Ansible, offrant ainsi une modularité et une réutilisabilité accrues.

    Les tags, limites et patterns d'hôtes permettent de contrôler sélectivement quelles tâches s'exécutent et sur quels hôtes, offrant une plus grande flexibilité dans la gestion des déploiements avec Ansible.

    Directive no_log:
        La directive no_log permet de masquer les informations sensibles dans les résultats des tâches exécutées par Ansible. Elle est utilisée pour éviter que des données confidentielles ne soient exposées dans les logs.

    Variable {{ ansible_managed }}:
        La variable ansible_managed est utilisée pour marquer les fichiers générés par Ansible. Elle peut être ajoutée en en-tête des fichiers de configuration pour indiquer qu'ils ont été créés ou modifiés par Ansible.

    Option async:
        L'option async permet d'exécuter des tâches de manière asynchrone, ce qui est utile pour les tâches prenant du temps ou nécessitant une exécution en arrière-plan.

    Utilisation de Vault:
        Vault est un outil intégré à Ansible permettant de gérer les secrets de manière sécurisée. Il chiffre les données sensibles avant de les stocker, garantissant ainsi leur confidentialité.

    Directive become_user:
        La directive become_user est utilisée pour exécuter des tâches en tant qu'utilisateur différent. Cela est souvent nécessaire pour effectuer des actions qui requièrent des privilèges élevés.

    Directive delegate:
        La directive delegate permet de déléguer l'exécution d'une tâche à une autre machine. Cela est utile dans les scénarios où une tâche doit être exécutée sur un hôte spécifique.

    Collections dans Ansible:
        Les collections sont des ensembles de contenus, tels que des rôles, des modules et des plugins, qui peuvent être distribués et installés de manière indépendante dans Ansible. 

    Débogage Ansible:
     Il existe plusieurs techniques et outils disponibles, y compris le debugger intégré à Ansible et des outils tiers.

    Directives comme changed_when, ignore_errors, check_mode:
        Ces directives offrent un contrôle plus précis sur le comportement des tâches Ansible. changed_when permet de définir les conditions dans lesquelles une tâche est considérée comme ayant modifié l'état du système, ignore_errors permet d'ignorer les erreurs lors de l'exécution des tâches, et check_mode permet de simuler l'exécution des tâches sans effectuer de modifications réelles sur le système.


TODO: ajouter liens vers pages de docs

TODO: register

TODO: FIXME: passer infra en ubuntu 22 pouyr ansible-lint

TODO: conds j2, conds tasks pour ansible_family

TODO: rescue