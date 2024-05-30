---
title: "TP2 - Créer un playbook de déploiement d'application flask" 
draft: false
weight: 21
---

## Création du projet

- Créez un nouveau dossier `tp2_flask_deployment`.
- Créez le fichier `ansible.cfg` comme précédemment.

```ini
[defaults]
inventory = ./inventory.cfg
roles_path = ./roles
host_key_checking = false
```

- Créez deux machines ubuntu `ubu1` et `ubu2`.

```
incus launch ubuntu_ansible ubu1
incus launch ubuntu_ansible ubu2
```

- Créez l'inventaire statique `inventory.cfg`.

```
$ incus list # pour récupérer l'adresse ip puis
```

```

[all:vars]
ansible_user=stagiaire

[appservers]
ubu1 ansible_host=10.x.y.z
ubu2 ansible_host=10.x.y.z
```

- Ajoutez à l'intérieur les deux machines dans un groupe `appservers`.
- Pinguez les machines.

```
ansible all -m ping
```

{{% expand "Facultatif  :" %}}
- Configurez git et initialisez un dépôt git dans ce dossier.

```
git init   # à executer à la racine du projet
```

- Ajoutez un fichier `.gitignore` avec à l'intérieur:

```bash
*.retry   # Fichiers retry produits lors des execution en echec de ansible-playbook
```

- Committez vos modifications avec git.

```
git add -A
git commit -m "démarrage tp2"
```
{{% /expand %}}

## Créer le playbook : installer les dépendances

Le but de ce projet est de déployer une application flask, c'est a dire une application web python.
Le code (très minimal) de cette application se trouve sur github à l'adresse: [https://github.com/e-lie/flask_hello_ansible.git](https://github.com/e-lie/flask_hello_ansible.git).

- N'hésitez pas consulter extensivement la documentation des modules avec leur exemple ou d'utiliser la commande de doc `ansible-doc <module>`

- Créons un playbook : ajoutez un fichier `flask_deploy.yml` avec à l'intérieur:

```yaml
- hosts: hotes_cible
  
  tasks:
    - name: ping
      ping:
```

- Lancez ce playbook avec la commande `ansible-playbook <nom_playbook>`.

- Commençons par installer les dépendances de cette application. Tous nos serveurs d'application sont sur ubuntu. Nous pouvons donc utiliser le module `apt` pour installer les dépendances. Il fournit plus d'options que le module `package`.

{{% expand "Si vous avez créé une app3 sur CentOS :" %}}
Pour faire varier les tasks que l'on exécute, il faudrait jouer sur la variable `ansible_os_family` avec la ligne `when: ansible_os_family == "RedHat"` (ou `Debian`) (au niveau du nom du module dans la task).
Il faudra aussi trouver les bons noms de packages et installer `epel-release`

{{% /expand %}}

- Avec le module `apt` installez les applications: `python3-dev`, `python3-pip`, `python3-virtualenv`, `virtualenv`, `nginx`, `git`. Donnez à cette tache le nom: `ensure basic dependencies are present`. ajoutez pour cela la directive `become: yes` au début du playbook.

En utilisant une `loop` (et en accédant aux différentes valeurs qu'elle prend avec `{{ item }}`), on va pouvoir exécuter plusieurs fois cette tâche :

```yaml
    - name: Ensure basic dependencies are present
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - python3-dev
        - python3-pip
        - python3-virtualenv
        - virtualenv
        - nginx
        - git
```

- Relancez bien votre playbook à chaque tâche : comme Ansible est idempotent il n'est pas grave en situation de développement d'interrompre l'exécution du playbook et de reprendre l'exécution après un échec.

- Ajoutez une tâche `systemd` pour s'assurer que le service `nginx` est démarré.

```yaml
    - name: Ensure nginx service started
      systemd:
        name: nginx
        state: started
```

- Ajoutez une tâche pour créer un utilisateur `flask` et l'ajouter au groupe `www-data`. Utilisez bien le paramètre `append: yes` pour éviter de supprimer des groupes à l'utilisateur.

```yaml
    - name: Add the user running webapp
      user:
        name: "flask"
        state: present
        append: yes # important pour ne pas supprimer les groupes d'un utilisateur existant
        groups:
          - "www-data"
```

{{% expand "Si vous avez créé une app3 sur CentOS (facultatif), cliquez ici" %}}
Ici, le fonctionnement le plus concis serait d'utiliser les conditions Jinja2 (et non le mot-clé `when:`) avec une section de playbook appelée `vars:` et quelque chose comme `nginx_user: "{{ 'www-data' if ansible_os_family == "RedHat" else 'www-data'`
{{% /expand %}}

N'hésitez pas à tester l'option `--diff -v` avec vos commandes pour voir l'avant-après.

## Récupérer le code de l'application

- Pour déployer le code de l'application deux options sont possibles.
  - Télécharger le code dans notre projet et le copier sur chaque serveur avec le module `sync` qui fait une copie rsync.
  - Utiliser le module `git`.

- Nous allons utiliser la deuxième option (`git`) qui est plus cohérente pour le déploiement et la gestion des versions logicielles. Allez voir la documentation pour voir comment utiliser ce module.
  
- Utilisez-le pour télécharger le code source de l'application (branche `master`) dans le dossier `/home/flask/hello` mais en désactivant la mise à jour (au cas où le code change).

```yaml
    - name: Git clone/update python hello webapp in user home
      git:
        repo: "https://github.com/e-lie/flask_hello_ansible.git"
        dest: /home/flask/hello
        clone: yes
        update: no
```
<!-- TODO: expliquer qu'il faudrait p'tet utiliser become_user ou pas faire ces trucs en root car corriger les permissions en recurse après c'est bourrin -->
<!-- become_user: "{{ app.user }}" -->

- Lancez votre playbook et allez vérifier sur une machine en ssh que le code est bien téléchargé.

## Installez les dépendances python de l'application

Le langage python a son propre gestionnaire de dépendances `pip` qui permet d'installer facilement les librairies d'un projet. Il propose également un méchanisme d'isolation des paquets installés appelé `virtualenv`. Normalement installer les dépendances python nécessite 4 ou 5 commandes shell.

- nos dépendances sont indiquées dans le fichier `requirements.txt` à la racine du dossier d'application. **`pip` a une option spéciale pour gérer ces fichiers.**

- Nous voulons installer ces dépendances dans un dossier `venv` également à la racine de l'application.

- Nous voulons installer ces dépendances en version python3 avec l'argument `virtualenv_python: python3`.

- même si nous pourrions demander à Ansible de lire ce fichier, créer une variable qui liste ces dépendances et les installer une par une, **nous n'allons pas utiliser `loop`**. Le but est de toujours trouver le meilleur module pour une tâche.

Avec ces informations et la documentation du module `pip` installez les dépendances de l'application.

{{% expand "Cliquez pour voir la solution :" %}}

```yaml
    - name: Install python dependencies for the webapp in a virtualenv
      pip:
        requirements: /home/flask/hello/requirements.txt
        virtualenv: /home/flask/hello/venv
        virtualenv_python: python3
        state: present
```

{{% /expand %}}

## Changer les permissions sur le dossier application

Notre application sera exécutée en tant qu'utilisateur flask pour des raisons de sécurité. Pour cela le dossier doit appartenir à cet utilisateur or il a été créé en tant que root (à cause du `become: yes` de notre playbook).

- Créez une tache `file` qui change le propriétaire du dossier de façon récursive. N'hésitez pas à tester l'option `--diff -v` avec vos commandes pour voir l'avant-après.


```yaml
    - name: Change permissions of app directory
      file:
        path: /home/flask/hello
        state: directory
        owner: "flask"
        group: www-data
        recurse: true
```

## Module Template : configurer le service qui fera tourner l'application

Notre application doit tourner comme c'est souvent le cas en tant que service (systemd). Pour cela nous devons créer un fichier service adapté `hello.service` **et le copier dans le dossier `/etc/systemd/system/`**.

Ce fichier est un fichier de configuration qui doit contenir le texte suivant:

```ini
[Unit]
Description=Gunicorn instance to serve hello
After=network.target

[Service]
User=flask
Group=www-data
WorkingDirectory=/home/flask/hello
Environment="PATH=/home/flask/hello/venv/bin"
ExecStart=/home/flask/hello/venv/bin/gunicorn --workers 3 --bind unix:hello.sock -m 007 app:app

[Install]
WantedBy=multi-user.target
```

Pour gérer les fichier de configuration on utilise généralement le module `template` qui permet à partir d'un fichier modèle situé dans le projet  ansible de créer dynamiquement un fichier de configuration adapté sur la machine distante.

- Créez un dossier `templates`, avec à l'intérieur le fichier `app.service.j2` contenant le texte précédent.
- Utilisez le module `template` pour le copier au bon endroit avec le nom `hello.service`.

- Utilisez ensuite `systemd` pour démarrer ce service (avec `state: restarted` dans le cas où le fichier a changé).

## Configurer nginx

- Comme précédemment créez un fichier de configuration `hello.test.conf` dans le dossier `/etc/nginx/sites-available` à partir du fichier modèle:

`nginx.conf.j2`

```
# {{ ansible_managed }}
# La variable du dessus indique qu'il ne faut pas modifier ce fichier directement, on peut l'écraser dans notre config Ansible pour écrire un message plus explicite à ses collègues

server {
    listen 80;

    server_name hello.test;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/flask/hello/hello.sock;
    }
}
```

<!-- - Remplacez `hello.test` par `hello.test.votrenom.formation.doxx.fr` le cas échéant si vous avez accès à un nom de domaine public -->

- Utilisez `file` pour créer un lien symbolique de ce fichier dans `/etc/nginx/sites-enabled` (avec l'option `force: yes` pour écraser le cas échéant). C'est une bonne pratique Nginx que nous allons respecter dans notre playbook Ansible.

- Ajoutez une tache pour supprimer le site `/etc/nginx/sites-enabled/default`.

- Ajouter une tâche de redémarrage de nginx.

- Ajoutez l'IP de la VM puis `hello.test` séparé par un espace dans votre fichier `/etc/hosts`, pour que le domaine `hello.test` soit résolu par l'IP d'un des serveurs d'application.

- Visitez l'application dans un navigateur et debugger le cas échéant.


## Solution intermédiaire

`flask_deploy.yml`


{{% expand "Code de solution :" %}}
```yaml
- hosts: appservers
  become: yes

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Ensure basic dependencies are present
      apt:
        name:
          - python3-dev
          - python3-pip
          - python3-virtualenv
          - virtualenv
          - nginx
          - git
        state: present

    - name: Ensure nginx service started
      systemd:
        name: nginx
        state: started

    - name: Add the user running webapp
      user:
        name: "flask"
        state: present
        append: yes # important pour ne pas supprimer les groupes d'un utilisateur existant
        groups:
        - "www-data"

    - name: Git clone/update python hello webapp in user home
      git:
        repo: "https://github.com/e-lie/flask_hello_ansible.git"
        dest: /home/flask/hello
        clone: yes
        update: no

    - name: Install python dependencies for the webapp in a virtualenv
      pip:
        requirements: /home/flask/hello/requirements.txt
        virtualenv: /home/flask/hello/venv
        virtualenv_python: python3

    - name: Change permissions of app directory recursively if needed
      file:
        path: /home/flask/hello
        state: directory
        owner: "flask"
        group: www-data
        recurse: true
    
    - name: Template systemd service config
      template:
        src: templates/app.service.j2
        dest: /etc/systemd/system/hello.service
    
    - name: Start systemd app service
      systemd:
        name: "hello.service"
        state: restarted
        enabled: yes
    
    - name: Template nginx site config
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/hello.test.conf
    
    - name: Remove default nginx site config
      file:
        path: /etc/nginx/sites-enabled/default
        state: absent
    
    - name: Enable nginx site for hello webapp
      file:
        src: /etc/nginx/sites-available/hello.test.conf
        dest: /etc/nginx/sites-enabled/hello.test.conf
        state: link
        force: yes
    
    - name: Restart nginx service
      systemd:
        name: "nginx"
        state: restarted
        enabled: yes
```

- Renommez votre fichier `flask_deploy.yml` en `flask_deploy_precorrection.yml`.
- Copiez la solution dans un nouveau fichier `flask_deploy.yml`.
- Lancez le playbook de solution `ansible-playbook flask_deploy.yml`.
- Ajoutez `hello.test` dans votre fichier `/etc/hosts`
- enfin, testez votre application en visitant la page `hello.test`. 
{{% /expand %}}


{{% expand "Facultatif  :" %}}
- Validez/Commitez votre version corrigée:
  
```
git add -A
git commit -m "tp2 solution intermediaire"
```

- Installez l'extension `git graph` dans vscode.
- Cliquez sur le bouton `Git Graph` en bas à gauche de la fenêtre puis cliquez sur le dernier point (commit) avec la légende **tp2 solution intermédiaire**. Vous pouvez voir les fichiers et modifications ajoutées depuis le dernier commit.

!!! Nous constatons que git a mémorisé les versions successives du code et permet de revenir à une version antérieure de votre déploiement.

{{% /expand %}}

## Ajouter un handler pour nginx et le service

Pour le moment dans notre playbook, les deux tâches de redémarrage de service sont en mode `restarted` c'est à dire qu'elles redémarrent le service à chaque exécution (résultat: `changed`) et ne sont donc pas idempotentes. En imaginant qu'on lance ce playbook toutes les 15 minutes dans un cron pour stabiliser la configuration, on aurait un redémarrage de nginx 4 fois par heure sans raison.

On désire plutôt ne relancer/recharger le service que lorsque la configuration conrespondante a été modifiée. c'est l'objet des tâches spéciales nommées `handlers`.

Ajoutez une section `handlers:` à la suite

- Déplacez la tâche de redémarrage/reload de `nginx` dans cette section et mettez comme nom `reload nginx`.
- Ajoutez aux deux tâches de modification de la configuration la directive `notify: <nom_du_handler>`.

- Testez votre playbook. il devrait être idempotent sauf le restart de `hello.service`.
- Testez le handler en ajoutant un commentaire dans le fichier de configuration `nginx.conf.j2`.

```yaml
    - name: template nginx site config
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/{{ app.domain }}.conf
      notify: reload nginx

      ...

  handlers:
    - name: reload nginx
      systemd:
        name: "nginx"
        state: reloaded

# => penser aussi à supprimer la tâche maintenant inutile de restart de nginx précédente
```

## Solution

- Pour la solution complète, clonons le dépôt via cette commande :
```bash
cd # Pour revenir dans notre dossier home
git clone https://github.com/Uptime-Formation/ansible-tp-solutions -b tp2_correction tp2_before_handlers
```

Vous pouvez également consulter la solution directement sur le site de Github : <https://github.com/Uptime-Formation/ansible-tp-solutions/tree/tp2_correction>

## Amélioration A : Les conditions : faire varier le playbook selon une variable

Nous allons tenter de faire que notre playbook puisse lancer une tâche en plus selon la valeur de la variable `ajoute_config_nginx` (on pourra la mettre dans la section `vars:` du playbook). 
Pour cela, utilisez la variable `when: mavariable == 'valeur'` où c'est nécessaire.

<!-- 
Note :
Dans un template Jinja2, pour écrire un bloc de texte en fonction d'une variable, la syntaxe est la suivante :
```jinja2
{% if ansible_os_family == "Debian" %}
# ma config spécial Debian
# ...
{% endif %}
``` -->

## Amélioration B : un handler en deux parties en testant la config de Nginx avant de reload
On peut utiliser l'attribut `listen` dans le handler pour décomposer un handler en plusieurs étapes.
Avec `nginx -t`, testons la config de Nginx dans le handler avant de reload.
Documentation : <https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html#naming-handlers>

## Amélioration C : faire fonctionner le playbook en check mode
Certaines tâches ne peuvent fonctionner sur une nouvelle machine en check mode.
Pour tester, créons une nouvelle machine et exécutons le playbook avec `--check`.
Avec `ignore_errors:` et `{{ ansible_check_mode }}`, résolvons le problème.

## Amélioration D : modifier le `/etc/hosts` via le playbook

A l'aide de la documentation de l'option `delegate:` et du module `lineinfile`, trouvez comment ajouter une tâche qui modifie automatiquement votre `/etc/hosts` pour ajouter une entrée liant le nom de domaine de votre app à l'IP du conteneur (il faudra utiliser la variable `ansible_host` et celle du nom de domaine).
Idéalement, on utiliserait la regex `.* {{ app.domain }}` pour gérer les variations d'adresse IP

Dans le cas de plusieurs hosts hébergeant nos apps, on pourrait même ajouter une autre entrée DNS pour préciser à quelle instance de notre app nous voulons accéder. Sans cela, nous sommes en train de faire une sorte de loadbalancing via le DNS.

Pour info : la variable `{{ inventory_hostname }}` permet d'accéder au nom que l'on a donné à une machine dans l'inventaire.


## Amélioration E : faire varier le playbook selon les OS

Nous allons tenter de créer une nouvelle version de votre playbook pour qu'il soit portable entre CentOS et Ubuntu.

- Pour cela, utilisez la directive `when: ansible_os_family == 'Debian'` ou `RedHat` (on pourra aussi utiliser des modules génériques comme `package:` au lieu de `apt:`, ou `service:` au lieu de `systemd:`). Cette directive peut s'utiliser sur toutes les tâches.

- N'oubliez pas d'installer `epel-release` qui est nécessaire à CentOS.

- Il va falloir adapter le nom des packages à CentOS.

- Pour le nom du user Nginx, on pourrait ajouter une section de playbook appelée `vars:` et définir quelque chose comme `nginx_user: "{{ 'nginx' if ansible_os_family == "RedHat" else 'www-data' }}`

- De même, les fichiers Nginx ne sont pas forcément au même endroit dans CentOS : il n'y a pas de notion de `sites-enabled` dans Nginx, il suffit de copier un fichier de config dans `/etc/nginx/conf.d` à la place (pas de lien symbolique).

<!-- - Il faudra peut-être penser à l'installation de Python 3 dans CentOS, et dire à Ansible d'utiliser Python 3 en indiquant dans l'inventaire `ansible_python_interpreter=/usr/bin/python3`. -->

### Amélioration F : l'attribut `register:`

- Avec le module `command`, listez les configs activées dans Nginx, utilisez la directive `register:` pour la mettre dans une variable.

- Ajoutez une tâche de `debug:` qui affiche le contenu de cette variable (avec `{{ }}`)

## Réorganisation : rendre le playbook dynamique avec des variables, puis une boucle, pour se préparer aux rôles

### Améliorer notre playbook avec des variables

Ajoutons des variables pour gérer dynamiquement les paramètres de notre déploiement:

- Ajoutez une section `vars:` avant la section `tasks:` du playbook.

- Mettez dans cette section la variable suivante (dictionnaire):

```yaml
  app:
    name: hello
    user: flask
    domain: hello.test
```

(il faudra modifier votre fichier `/etc/hosts` pour faire pointer le domaine `hello.test` vers l'IP de votre conteneur)
<!-- remplacez `hello.test` par `hello.test.votrenom.formation.doxx.fr` le cas échéant si vous avez accès à un nom de domaine public,  -->
- ajoutons une petite task dans la section `pre_tasks:` pour afficher cette variable au début du playbook, c'est le module `debug` :

```yaml
  pre_tasks:
    - debug:
        msg: "{{ app }}"
```

- Remplacez dans le playbook précédent et les deux fichiers de template:
  - toutes les occurences de la chaine `hello` par `{{ app.name }}`
  - toutes les occurences de la chaine `flask` par `{{ app.user }}`
  - toutes les occurences de la chaine `hello.test` par `{{ app.domain }}`

- Relancez le playbook : toutes les tâches devraient renvoyer `ok` à part les "restart" car les valeurs sont identiques.

{{% expand "Facultatif  :" %}}
- Ajoutez deux variables `repository` et `version` pour l'adresse du dépôt git et la version de l'application `master` par défaut. Il faudra modifier la tâche `git` pour utiliser ces nouvelles variables.

- Remplacez les valeurs correspondante dans le playbook par ces nouvelles variables.


```yaml
app:
  name: hello
  user: flask
  domain: hello.test
  repository: https://github.com/e-lie/flask_hello_ansible.git
  version: master
```

{{% /expand %}}

- Pour la solution intermédiaire, clonons le dépôt via cette commande :
```bash
cd # Pour revenir dans notre dossier home
git clone https://github.com/Uptime-Formation/ansible-tp-solutions -b tp2_before_handlers_correction tp2_before_handlers
```

Vous pouvez également consulter la solution directement sur le site de Github : <https://github.com/Uptime-Formation/ansible-tp-solutions/tree/tp2_before_handlers_correction>


### Rendre le playbook dynamique avec une boucle

Nous allons nous préparer à transformer ce playbook en rôle, plus général.

Plutôt qu'une variable `app` unique on voudrait fournir au playbook une liste d'application à installer (liste potentiellement définie durant l'exécution).

- Identifiez dans le playbook précédent les tâches qui sont exactement communes à l'installation des deux apps.
{{% expand "Réponse  :" %}}

> Il s'agit des tâches d'installation des dépendances `apt` et de vérification de l'état de nginx (démarré)

{{% /expand %}}

- Créez un nouveau fichier `deploy_app_tasks.yml` et copier à l'intérieur la liste de toutes les autres tâches mais sans les handlers que vous laisserez à la fin du playbook.

{{% expand "Réponse  :" %}}

> Il reste donc dans le playbook seulement les deux premières tâches et les handlers, les autres tâches (toutes celles qui contiennent des parties variables) sont dans `deploy_app_tasks.yml`.

{{% /expand %}}

Ce nouveau fichier n'est pas à proprement parler un `playbook` mais une **liste de tâches**.
- Utilisez `include_tasks:` (cela se configure comme une task un peu spéciale) pour importer cette liste de tâches à l'endroit où vous les avez supprimées.
- Vérifiez que le playbook fonctionne et est toujours idempotent. _Note: si vous avez récupéré une solution, il va falloir récupérer le fichier d'inventaire d'un autre projet et adapter la section `hosts:` du playbook._

- Ajoutez une tâche `debug: msg={{ app }}` (c'est une syntaxe abrégée appelée *free-form* ) au début du playbook pour visualiser le contenu de la variable.
*Note :* La version non-*free-form* (version longue) de cette tâche est :
```yaml
debug:
  msg: {{ app }}
```

- Ensuite remplacez la variable `app` par une liste `flask_apps` de deux dictionnaires (avec `name`, `domain`, `user` différents les deux dictionnaires et `repository` et `version` identiques).

```yaml
flask_apps:
  - name: hello
    domain: "hello.test"
    user: "flask"
    version: master
    repository: https://github.com/e-lie/flask_hello_ansible.git

  - name: hello2
    domain: "hello2.test"
    user: "flask2"
    version: master
    repository: https://github.com/e-lie/flask_hello_ansible.git
```

Il faudra modifier la tâche de debug par `debug: msg={{ flask_apps }}`. Observons le contenu de cette variable.

- A la task `debug:`, ajoutez la directive `loop: "{{ flask_apps }}` (elle se situe à la hauteur du nom de la task et du module) et remplacez le `msg={{ flask_apps }}` par `msg={{ item }}`. Que se passe-t-il ? *note: il est normal que le playbook échoue désormais à l'étape `include_tasks`*

La directive `loop_var` permet de renommer la variable sur laquelle on boucle par un nom de variable de notre choix. A quoi sert-elle ? Rappelons-nous : sans elle, on accéderait à chaque item de notre liste `flask_apps` avec la variable `item`. **Cela nous permet donc de ne pas modifier toutes nos tasks utilisant la variable `app` et de ne pas avoir à utiliser `item` à la place.**

- Utilisez la directive `loop` et `loop_control`+`loop_var` sur la tâche `include_tasks` pour inclure les tâches pour chacune des deux applications, en complétant comme suit :

```yaml
- include_tasks: deploy_app_tasks.yml
  loop: "{{ A_COMPLETER }}"
  loop_control:
    loop_var: A_COMPLETER
```

- Créez le dossier `group_vars` et déplacez le dictionnaire `flask_apps` dans un fichier `group_vars/appservers.yml`. Comme son nom l'indique ce dossier permet de définir les variables pour un groupe de serveurs dans un fichier externe.

- Testez en relançant le playbook que le déplacement des variables est pris en compte correctement.

- Pour la solution : activez la branche `tp2_correction` avec `git checkout tp2_correction`.



## Bonus : pour pratiquer

Essayez de déployer une version plus complexe d'application flask avec une base de donnée mysql : [https://github.com/miguelgrinberg/microblog/tree/v0.17](https://github.com/miguelgrinberg/microblog/tree/v0.17)

Il s'agit de l'application construite au fur et à mesure dans un [magnifique tutoriel python](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xvii-deployment-on-linux). Ce chapitre indique comment déployer l'application sur linux.
