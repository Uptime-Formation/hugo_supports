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

- instructions en français dans playbook

- parler de l'ext vscode ansible et git graph avec des screens

- faire un vrai tp avec variables, conds, changed_when, etc.

- exo avec register

---
A integrer :

    `register` permet de capturer les résultats d'une tâche dans une variable.
    Les conditions dans Ansible permettent d'adapter l'exécution des tâches en fonction de critères spécifiques.

    Les directives include_* et import_* (comme include_tasks, import_tasks, include_role, import_role, include_playbook et import_playbook) sont utilisées pour inclure des fichiers, des rôles ou des playbooks dans un playbook Ansible.

    Les tags, limites et patterns d'hôtes permettent de contrôler sélectivement quelles tâches s'exécutent et sur quels hôtes, offrant une plus grande flexibilité dans la gestion des déploiements avec Ansible.


    Option `async`:
        L'option async permet d'exécuter des tâches de manière asynchrone, ce qui est utile pour les tâches prenant du temps ou nécessitant une exécution en arrière-plan.
---
Directive become_user:
La directive become_user est utilisée pour exécuter des tâches en tant qu'utilisateur différent. Cela est souvent nécessaire pour effectuer des actions qui requièrent des privilèges élevés.

<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html#risks-and-limitations-of-become>

Pipelining:
<https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ssh_connection.html#parameter-pipelining>
<https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-pipelining>

Mitogen : <https://www.toptechskills.com/ansible-tutorials-courses/speed-up-ansible-playbooks-pipelining-mitogen/>

---

<!-- Collections dans Ansible:
Les collections sont des ensembles de contenus, tels que des rôles, des modules et des plugins, qui peuvent être distribués et installés de manière indépendante dans Ansible.  -->

`changed_when` et `ignore_errors`:
`changed_when` permet de définir les conditions dans lesquelles une tâche est considérée comme ayant modifié l'état du système, `ignore_errors` permet d'ignorer les erreurs lors de l'exécution des tâches.

TODO: register

TODO: FIXME: passer infra en ubuntu 22 pouyr ansible-lint + webhookd

TODO: rescue

TODO: faire des when: - AND - et expliquer

<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_debugger.html>
<https://blog.nicolas-le-borgne.fr/blog/2021/04/03/test-driven-infrastructure-avec-ansible-et-molecule/>
<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_filters.html>
<https://gitlab.com/coopaname/odoo-infra/-/blob/main/roles/coopaname.awx/tasks/main.yml?ref_type=heads>
<https://docs.ansible.com/ansible/2.9/user_guide/playbooks_prompts.html>
<https://docs.ansible.com/ansible/2.9/user_guide/playbooks_lookups.html>
<https://docs.ansible.com/ansible/2.9/user_guide/playbooks_startnstep.html>

TODO: jouer sur la redéfinition des vars à 1000 endroits ET VRAI TP IMPORT VS INCLUDE
<https://docs.ansible.com/ansible/6/user_guide/playbooks_reuse.html#playbooks-reuse>
<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html#conditionals-with-imports>
<https://www.ansiblejunky.com/blog/ansible-101-include-vs-import/>
<https://serverfault.com/questions/875247/whats-the-difference-between-include-tasks-and-import-tasks>
