---
title: 'Cours 3 - Les variables, les structures de contrôle et les templates Jinja2'
draft: false
weight: 30
---

## Variables Ansible

Ansible utilise en arrière plan un dictionnaire contenant de nombreuses variables.

Pour s'en rendre compte on peut lancer :
`ansible <hote_ou_groupe> -m debug -a "msg={{ hostvars }}"`

Ce dictionnaire contient en particulier:

- des variables de configuration ansible (`ansible_user` par exemple)
- les `ansible_facts`, c'est à dire des variables dynamiques caractérisant les systèmes cible (par exemple `ansible_os_family`) et récupéré au lancement d'un playbook.
- des variables personnalisées (de l'utilisateur) que vous définissez avec vos propre nom généralement en **snake_case**.

### Définition des variables

On peut définir et modifier la valeur des variables à différents endroits du code ansible:

- La section `vars:` du playbook.
- Un fichier de variables appelé avec `vars_files:`
- L'inventaire : variables pour chaque machine ou pour le groupe.
- Dans des dossier extension de l'inventaire `group_vars`, `host_vars`
- Dans le dossier `defaults` des roles (cf partie sur les roles)
- Dans une tâche avec le module `set_facts`.
- Au runtime au moment d'appeler la CLI ansible avec `--extra-vars "version=1.23.45 other_variable=foo"`

Lorsque définies plusieurs fois, les variables ont des priorités en fonction de l'endroit de définition.
L'ordre de priorité est plutôt complexe: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable>

En résumé la règle peut être exprimée comme suit: les variables de runtime sont prioritaires sur les variables dans un playbook qui sont prioritaires sur les variables de l'inventaire qui sont prioritaires sur les variables par défaut d'un role.

- Bonne pratique: limiter les redéfinitions de variables en cascade (au maximum une valeur par défaut, une valeur contextuelle et une valeur runtime) pour éviter que le playbook soit trop complexe et difficilement compréhensible et donc maintenable.

<!-- ### Remarques de syntaxe -->

<!-- - `groups.all` et `groups['all']` sont deux syntaxes équivalentes pour désigner les éléments d'un dictionnaire. -->

### Variables spéciales

<https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html>

Les plus utiles:

- `ansible_facts`: faits récoltés par Ansible (Ansible Facts) sur l'hôte en cours
- `hostvars`: dictionaire de toute les variables rangées par hôte de l'inventaire.
- `ansible_host`: information utilisée pour la connexion (ip ou domaine).
- `inventory_hostname`: nom de la machine dans l'inventaire.
- `groups`: dictionnaire de tous les groupes avec la liste des machines appartenant à chaque groupe.

Pour explorer chacune de ces variables vous pouvez utiliser le module `debug` en mode adhoc ou dans un playbook :

`ansible <hote_ou_groupe> -m debug -a "msg={{ ansible_host }}" -vvv`

Attention, les facts ne sont pas relevés en mode ad-hoc. Il faut donc utiliser le module `debug`.

Vous pouvez exporter les ansible_facts en JSON pour plus de lisibilité :
`ansible all -m setup --tree ./ansible_facts_export`

Puis les lire avec `cat ./ansible_facts_export/votremachine.json | jq` (il faut que jq soit installé, sinon tout ouvrir dans VSCode avec `code ./ansible_facts_export`).

### Facts

Les facts sont des valeurs de variables récupérées au début de l'exécution durant l'étape **gather_facts** et qui décrivent l'état courant de chaque machine.

- Par exemple, `ansible_os_family` est un fact/variable décrivant le type d'OS installé sur la machine. Elle n'existe qu'une fois les facts récupérés.

Lors d'une **commande adhoc** ansible les **facts** ne sont pas récupérés : la variable `ansible_os_family` ne sera pas disponible.

La liste des facts peut être trouvée dans la documentation et dépend des plugins utilisés pour les récupérés: <https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html>

## Structures de contrôle Ansible

### La directive `when:`

Elle permet de rendre une tâche conditionnelle (une sorte de `if`)

```yaml
- name: start nginx service
  systemd:
    name: nginx
    state: started
  when: ansible_os_family == 'RedHat'
```

Sinon la tâche est sautée (skipped) durant l'exécution.

### La directive `loop:`

Cette directive permet d'exécuter une tâche plusieurs fois basée sur une liste de valeurs :

[https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html)

exemple:

```yaml
- hosts: localhost
  tasks:
    - name: exemple de boucle
      debug:
        msg: "{{ item }}"
      loop:
        - message1
        - message2
        - message3
```

On accéde aux différentes valeurs qu'elle prend avec `{{ item }}`.

On peut également contrôler cette boucle avec quelques paramètres:

```yaml
- hosts: localhost
  vars:
    messages:
      - message1
      - message2
      - message3

  tasks:
    - name: exemple de boucle
      debug:
        msg: "message numero {{ num }} : {{ message }}"
      loop: "{{ messages }}"
      loop_control:
        loop_var: message
        index_var: num
    
```

Cette fonctionnalité de boucle était anciennement accessible avec le mot-clé `with_items:` qui est maintenant déprécié.

## Jinja2 et variables dans les playbooks et rôles (fichiers de code)

La plupart des fichiers Ansible (sauf l'inventaire) sont traités avec le moteur de template python Jinja2.

Ce moteur permet de créer des valeurs dynamiques dans le code des playbooks, des roles, et des fichiers de configuration.

- Les variables écrites au format `{{ mavariable }}` sont remplacées par leur valeur provenant du dictionnaire d'exécution d'Ansible.

- Des filtres (fonctions de transformation) permettent de transformer la valeur des variables: exemple : `{{ hostname | default('localhost') }}` (Voir plus bas)

### Filtres Jinja

Pour transformer la valeur des variables à la volée lors de leur appel on peut utiliser des filtres (jinja2) :

- par exemple on peut fournir une valeur par défaut pour une variable avec filtre default: `{{ hostname | default('localhost') }}`
- Un autre usage courant des filtres est de reformater et filtrer des listes et dictionnaires de paramètre. Ces syntaxes sont peut intuitives. Vous pouvez vous entrainer en regardant ces tutoriels:
  - [https://www.tailored.cloud/devops/how-to-filter-and-map-lists-in-ansible/](https://www.tailored.cloud/devops/how-to-filter-and-map-lists-in-ansible/)
  - [https://www.tailored.cloud/devops/advanced-list-operations-ansible/](https://www.tailored.cloud/devops/advanced-list-operations-ansible/)

La liste complète des filtres ansible se trouve ici : [https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html)
<!-- TODO: ajout de liens vers jinja filter custom -->

### Jinja2 et les variables dans les fichiers de templates

Les fichiers de templates (.j2) utilisés avec le module template, généralement pour créer des fichiers de configuration peuvent **contenir des variables** et des **filtres** comme les fichier de code (voir au dessus) **mais également** d'autres constructions jinja2 comme:

- Des `if` : `{% if nginx_state == 'present' %}...{% endif %}`.
- Des boucles `for` : `{% for host in groups['appserver'] %}...{% endfor %}`.
- Des inclusions de templates `{% include 'autre_fichier_template.j2' %}`

## Imports et includes

Il est possible d'importer le contenu d'autres fichiers dans un playbook:

- `import_tasks`: importe une liste de tâches (atomiques)
- `import_playbook`: importe une liste de play contenus dans un playbook.

Les deux instructions précédentes désignent un import **statique** qui est résolu avant l'exécution.

**En général, on utilise `import_*` pour améliorer la lisibilité de notre dépôt.**

Au contraire, `include_tasks` permet d'intégrer une liste de tâches **dynamiquement** pendant l'exécution.
**En général, on utilise `include_*` pour décider quelles tâches, quelles variables ou quels rôles seront inclus au run d'un playbook.**

Par exemple :

```yaml
vars:
  apps:
    - app1
    - app2
    - app3

tasks:
  - include_tasks: install_app.yml
    loop: "{{ apps }}"
```

Ce code indique à Ansible d'exécuter une série de tâches pour chaque application de la liste. On pourrait remplacer cette liste par une liste dynamique. Comme le nombre d'imports ne peut pas facilement être connu à l'avance on **doit** utiliser `include_tasks`.

Documentation additionnelle :
- <https://docs.ansible.com/ansible/6/user_guide/playbooks_reuse.html#playbooks-reuse>
- <https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html#conditionals-with-imports>
- <https://www.ansiblejunky.com/blog/ansible-101-include-vs-import/>
- <https://serverfault.com/questions/875247/whats-the-difference-between-include-tasks-and-import-tasks>

## Debugger un playbook

Avec Ansible on dispose d'au moins trois manières de debugger un playbook :

- Rendre la sortie verbeuse (mode debug) avec `-vvv`.

- Utiliser une tâche avec le module `debug` : `debug msg="{{ mavariable }}"`.

- Utiliser la directive `debugger: always` ou `on_failed` à ajouter à la fin d'une tâche. L'exécution s'arrête alors après l'exécution de cette tâche et propose un interpreteur de debug.

Les commandes et l'usage du debugger sont décrits dans la documentation: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html>

<!-- TODO: laïus sur register a et a.stdout -->
### Les 7 commandes de debug dans Ansible

| Command                | Shortcut | Action                                    |
|------------------------|----------|-------------------------------------------|
| print                  | p        | Print information about the task          |
| task.args[key] = value |          | Update module arguments                   |
| task_vars[key] = value |          | Update task variables (you must update_task next) |
| update_task            | u        | Recreate a task with updated task variables |
| redo                   | r        | Run the task again                        |
| continue               | c        | Continue executing, starting with the next task |
| quit                   | q        | Quit the debugger                         |
