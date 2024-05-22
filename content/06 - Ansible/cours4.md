---
title: 'Cours 4 - Organiser un projet'
draft: false
weight: 31
---

## Organisation d'un dépôt de code Ansible

Voici, extrait de la documentation Ansible sur les "Best Practices", l'une des organisations de référence d'un projet ansible de configuration d'une infrastructure :

```
production                # inventory file for production servers
staging                   # inventory file for staging environment

group_vars/
   group1.yml             # here we assign variables to particular groups
   group2.yml
host_vars/
   hostname1.yml          # here we assign variables to particular systems
   hostname2.yml

library/                  # if any custom modules, put them here (optional)
module_utils/             # if any custom module_utils to support modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yml                  # master playbook
webservers.yml            # playbook for webserver tier
dbservers.yml             # playbook for dbserver tier

roles/
    common/               # this hierarchy represents a "role"
        ...               # role code

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/               # ""

```

Plusieurs remarques:

- Chaque environnement (staging, production) dispose d'un inventaire ce qui permet de préciser à runtime quel environnement cibler avec l'option `--inventory production`.
- Chaque groupe de serveurs (tier) dispose de son playbook
  - qui s'applique sur le groupe en question.
  - éventuellement définit quelques variables spécifiques (mais il vaut mieux les mettre dans l'inventaire ou les dossiers cf suite).
  - Idéalement contient un minimum de tâches et plutôt des roles (ie des tâches rangées dans une sorte de module)
- Pour limiter la taille de l'inventaire principal on range les variables communes dans des dossiers `group_vars` et `host_vars`. On met à l'intérieur un fichier `<nom_du_groupe>.yml` qui contient un dictionnaire de variables. 
- On cherche à modulariser au maximum la configuration dans des roles c'est à dire des modules rendus génériques et specifique à un objectif de configuration.
- Ce modèle d'organisation correspond plutôt à la **configuration** de base d'une infrastructure (playbooks à exécuter régulièrement) qu'à l'usage de playbooks ponctuels comme pour le déploiement. Mais, bien sur, on peut ajouter un dossier `playbooks` ou `operations` pour certaines opérations ponctuelles. (cf cours 4)
- Si les modules de Ansible (complétés par les commandes bash) ne suffisent pas on peut développer ses propre modules ansible.
  - Il s'agit de programmes python plus ou moins complexes
  - On les range alors dans le dossier `library` du projet ou d'un role et on le précise éventuellement dans `ansible.cfg`.
- Observons le role `Common` :  il est utilisé ici pour rassembler les taches de base des communes à toutes les machines. Par exemple s'assurer que les clés ssh de l'équipe sont présentes, que les dépots spécifiques sont présents etc. 

![](../../images/devops/ansible2.png)

## Roles Ansible

### Objectif:

- Découper les tâches de configuration en sous ensembles réutilisables (une suite d'étapes de configuration).

- Ansible est une sorte de langage de programmation et l'intéret du code est de pouvoir créer des fonction regroupées en librairies et les composer. Les roles sont les "librairies/fonction" ansible en quelque sorte.

- Comme une fonction un role prend généralement des paramètres qui permettent de personnaliser son comportement.

- Tout le nécessaire doit y être (fichiers de configurations, archives et binaires à déployer, modules personnels dans `library` etc.)

- Remarque ne pas confondre **modules** et **roles** : `file` est un module `geerlingguy.docker` est un role. On **doit** écrire des roles pour coder correctement en Ansible, on **peut** écrire des modules mais c'est largement facultatif car la plupart des actions existent déjà.

- Présentation d'un exemple de role : [https://github.com/geerlingguy/ansible-role-docker](https://github.com/geerlingguy/ansible-role-docker)
    - Dans la philosophie Ansible on recherche la généricité des roles. On cherche à ajouter des paramètres pour que le rôle s'adapte à différents cas (comme notre playbook flask app).
    - Une bonne pratique: préfixer le nom des paramètres par le nom du rôle exemple `docker_edition`.
    - Cependant la généricité est nécessaire quand on veut distribuer le role ou construire des outils spécifiques qui serve à plus endroit de l'infrastructure mais elle augmente la complexité.
    - Donc pour les roles internes on privilégie la simplicité.
    - Les roles contiennent idéalement un fichier `README` en décrire l'usage et un fichier `meta/main.yml` qui décrit la compatibilité et les dépendanice en plus de la licence et l'auteur.
    - Il peuvent idéalement être versionnés dans des dépots à part et installé avec `ansible-galaxy`


### Structure d'un rôle

Un rôle est un dossier avec des sous dossiers qui répondent à une convention de nommage précise (contrairement à l'organisation d'un projet Ansible, qui peut être plus chaotique), généralement quelque chose comme :

![](../../images/ansible/simple_hierarchy.jpg)

ou encore :

```
roles/
    mediawiki/            # le nom du rôle
        tasks/            #
            main.yml      #  <-- fichier de tasks principal
            autre.yml     #  <-- fichier(s) de tasks en plus
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            foo.sh        #  <-- script files for use with the script resource
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
```

Voici la version exhaustive :
```
roles/
    requirements.yml      # la liste des rôles nécessaires et comment les récupérer
    mediawiki/            # le nom du rôle
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies
        molecule/         # pour le test du rôle
            check.yml
            converge.yml
            idempotent.yml
            verify.yml
        # Plus rare :
        library/          # roles can also include custom modules
        module_utils/     # roles can also include custom module_utils
        lookup_plugins/
```

On constate que les noms des sous dossiers correspondent souvent à des sections du playbook. En fait le principe de base est d'extraire les différentes listes de taches ou de variables dans des sous-dossier

- Remarque : les fichier de liste **doivent nécessairement** s'appeler **main.yml**" (pas très intuitif)
- Remarque2 : `main.yml` peut en revanche importer d'autre fichiers aux noms personnalisés (exp role docker de geerlingguy)

- Le dossier `defaults` contient les valeurs par défaut des paramètres du role. Ces valeurs ne sont jamais prioritaires (elles sont écrasées par n'importe quelle redéfinition)
- Le fichier `meta/main.yml` est facultatif mais conseillé et contient des informations sur le role
  - auteur
  - license
  - compatibilité
  - version
  - dépendances à d'autres roles.
- Le dossier `files` contient les fichiers qui ne sont pas des templates (pour les module `copy` ou `sync`, `script` etc).

### Ansible Galaxy

C'est le store de roles officiel d'Ansible : [https://galaxy.ansible.com/](https://galaxy.ansible.com/)

C'est également le nom d'une commande `ansible-galaxy` qui permet d'installer des roles et leurs dépendances depuis internet. Un sorte de gestionnaire de paquet pour ansible.

Elle est utilisée généralement sour la forme `ansible-galaxy install -r roles/requirements.yml -p roles` ou plus simplement `ansible-galaxy install <role>` mais installe dans `/etc/ansible/roles`.

Tous les rôles ansible sont communautaires (pas de roles officiels) et généralement stockés sur github.

Mais on peut voir la popularité la qualité et les tests qui garantissement la plus ou moins grande fiabilité du role

{{% notice note %}}
Il existe des roles pour installer un peu n'importe quelle application serveur courante aujourd'hui. Passez du temps à explorer le web avant de développer quelque chose avec Ansible
{{% /notice %}}

### Installer des roles avec `requirements.yml`

Conventionnellement on utilise un fichier `requirements.yml` situé dans `roles` pour décrire la liste des roles nécessaires à un projet.

```yaml
- src: geerlingguy.repo-epel
- src: geerlingguy.haproxy
- src: geerlingguy.docke
# from GitHub, overriding the name and specifying a specific tag
- src: https://github.com/bennojoy/nginx
  version: master
  name: nginx_role
```

- Ensuite pour les installer on lance: `ansible-galaxy install -r roles/requirements.yml -p roles`.


#### Dépendances entre rôles

Même si cela a un coût quant à la clarté d'exécution, chaque fois avec un playbook on peut laisser la cascade de dépendances mettre nos serveurs dans un état complexe désiré
Si un role dépend d'autres roles, les dépendances sont décrite dans le fichier `meta/main.yml` comme suit

```yaml
---
dependencies:
  - role: common
    vars:
      some_parameter: 3
  - role: apache
    vars:
      apache_port: 80
  - role: postgres
    vars:
      dbname: blarg
      other_parameter: 12
``` 

Les dépendances sont exécutées automatiquement avant l'execution du role en question. Ce méchanisme permet de créer des automatisation bien organisées avec une forme de composition de roles simple pour créer des roles plus complexe : plutôt que de lancer les rôles à chaque fois avec un playbook on peut laisser la cascade de dépendances mettre nos serveurs dans un état complexe désiré.


## Tester les roles avec Molecule et le Test Driven Development

Pour des rôles fiables il est conseillé d'utiliser l'outil de testing molecule dès la création d'un nouveau rôle pour effectuer des tests unitaire dessus dans un environnement virtuel comme Docker.

On crée différents types de scénarios, même si celui par défaut par Molecule permet déjà d'avoir un bon test du fonctionnement de notre rôle, en couvrant differents cas dès le début :

- `check.yml`
- `converge.yml`
- `idempotent.yml`
- `verify.yml`

<!-- TODO: -  tu peux l'écrire avec ansible qui vérifie tout tâche par tâche écrite originalement
- Ou alors avec testinfra la lib python spécialisée en collecte de facts os -->


<!-- Et du coup ça fait du tdd des le début -->

<!-- Y a un template
Et il faut commencer par la -->

<!-- Plein de drivers pas fonctionnels sauf docker -->
<!-- Pour des cas compliqués genre wireguard ou ynh ça marche pas du coup driver hcloud est le meilleur driver vps -->
