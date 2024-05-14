---
title: "Git 2 - Exercices"
draft: false
weight: 210
---

Durant cette partie nous allons explorer un dépôt git existant grâce aux commandes git de base mais également grâce au GUI (interface graphique) de VSCode.

## Récupérer un dépôt de code

- Récupérez le dépôt https://github.com/miguelgrinberg/microblog/ sur votre **Bureau** à l'aide de la commande `git clone`.
- Ouvrez le projet dans VSCode.

Il s'agit d'un dépôt exemple d'une application de microblogging (comme Twitter) codée en Python avec le framework Flask.

## Explorer le dépôt

<!-- - Installez ce qui est nécessaire pour l'application avec les commandes :

```bash
sudo apt install python3-pip
pip3 install -r requirements.txt
echo "PATH=~/.local/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
flask db init
flask db upgrade
```

- Lancez l'application avec la commande `flask run`.

- Utilisez l'application en visitant l'adresse `http://localhost:5000/`, puis créez-vous un compte et postez un message.

- Tentez d'exporter vos posts
- Tenter de faire une recherche sur un post -->

- Plutôt que d'utiliser la version finale de l'application, remontons l'historique du dépôt pour retrouver un état plus simple de l'application.

- Quel est le premier commit du dépôt ? A quoi sert-il ?

- Utilisez la commande `git blame` sur le fichier `app/main/routes.py`. Cette commande est très utile quand on travaille à plusieurs car elle permet de savoir à qui s'adresser lorsqu'on cherche à comprendre le code ou qu'on a trouvé un bug.

<!-- - Installez `tig` qui est un utilitaire pour explorer un dépôt depuis le terminal. -->
- Installez les extensions VSCode suivantes pour explorer le dépôt depuis VSCode :

  - [**GitLens**](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
  - [**Git Graph**](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph).

- À l'aide de `tig` ou des extensions VSCode cherchez le premier commit de l'historique **qui ne fasse pas référence à Redis** : c'est le commit de la version v0.21 avant la version v0.22
<!-- - À l'aide de `tig` cherchez le premier commit de l'historique sans référence à Elasticsearch : c'est le commit de la version v0.15 avant la version v0.16 -->

- Déplacez vous au niveau de ce commit avec `git checkout <num_commit>`. Votre dépôt est en mode "_HEAD détaché_" c'est à dire que le pointeur HEAD se balade le long de l'historique.
  C'est un état anormal dans lequel il ne faut généralement pas modifier le code. Il est très facile de se perdre dans un dépôt git (le cas échéant utilisez `git reflog` pour bien comprendre les opérations qui vous ont amené dans l'état courant).

<!-- - Cherchez les fichiers de code java et la fonction `sum` dans cette application. -->

- Lancez à nouveau l'application avec la commande `flask run`

- Utilisez l'application en visitant l'adresse `http://localhost:5000/`
- On observe que la fonctionnalité d'export de posts qui était cassée n'existe plus

- Utilisez `git reflog` pour observer les déplacement de votre pointeur HEAD.

## Créer une branche pour étendre l'application

Nous allons maintenant créer une branche en repartant du début du projet pour étendre l'application avec une page supplémentaire "A propos".

- Installez dans VSCode l'extension `GitLens`.

- Retournez à la fin de l'historique du projet comme précédemment (`master`).

- Nous allons expérimenter de réinitialiser (violemment) le projet au début de son historique avec `git reset --hard`. Réinitialisez au niveau du commit identifié précédemment. Constatez sur GitLens ou Git Graph que les commits on été effacés et les fichiers également (sans le `--hard` les commits auraient disparu mais les fichiers et leur contenus auraient été gardés et désindexés comme dans la partie 1).

- La commande précédente a effacé toutes les modifications du dépôt des 106 derniers commits. Faites bien attention avec cette commande `git reset --hard` ! Dans notre cas ce n'est pas un problème car ces commits sont disponibles sur le serveur. Pour récupérer les commits effacés utilisez `git pull`. `pull` va récupérer les modifications depuis le serveur.

<!-- FIXME: -->
<!-- - Pour créer une branche plus "doucement" nous allons a nouveau déplacer HEAD au niveau du commit d'introduction du `Jenkinsfile`. -->

- Créez une nouvelle branche avec `git checkout -b <nom branche>` appelez-la **`about-page`**.

- Trouvez comment ajouter une page _A propos_ à l'application Flask (indice : il faut ajouter une route, un template et un lien dans le menu).

{{% expand "Solution :" %}}

`app/templates/base.html` :

```python
<li><a href="{{ url_for('main.about_page') }}">{{ _('About') }}</a></li>
```

`app/main/routes.py` :

```python
@bp.route('/about')
def about_page():
    return render_template('about.html', title=_('About me'))
```

`app/templates/about.html` :

```html
{% extends "base.html" %} {% block app_content %}

<h1>A propos</h1>
<p>
  Bonjour, je m'appelle Hadrien et j'ai modifié
  <a href="https://github.com/miguelgrinberg/microblog">l'application Microblog de Miguel Grinberg pour ce TP</a>.
</p>
{% endblock %}
```

{{% /expand %}}

- Une fois vos modifications ajoutées, faites simplement `git diff`. Cette fonction affiche en vert le code que vous venez d'ajouter, et en rouge celui que vous avez retiré, si jamais.

- Ajoutez les fichiers modifiés (`git add`) et committez toutes ces nouvelles modifications.

- Maintenant que les modifications sont engagées (commitées) refaites `git diff`. Que se passe-t-il ?

- Trouvez comment faire pour comparer avec un autre commit pris au hasard en utilisant `git diff`.

- Avec `git diff` toujours, comparez maintenant deux branches.

- Utilisez `git reset HEAD~1` pour annuler le dernier commit puis refaites-le en utilisant l'interface graphique de VSCode.

## Exercices supplémentaires

- ["Déplacer le travail + Un assortiment + Sujets avancés" sur _Learn Git branching_](https://learngitbranching.js.org/?locale=fr_FR)

### gitexercises.fracz.com

https://gitexercises.fracz.com/exercise/fix-typo
https://gitexercises.fracz.com/exercise/commit-lost
