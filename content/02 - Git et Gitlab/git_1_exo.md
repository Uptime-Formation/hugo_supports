---
title: "Git 1 - Exercices"
weight: 11
---

# Créer un projet git

Durant ces exercices nous allons utiliser Git en ligne de commande (sans interface graphique) : l'objectif est de pratiquer les différentes commandes de base git

### Installer Git

`git` est souvent déjà installé sur Linux. Mais si ce n'est pas le cas, il suffit d'installer le paquet `git`, par exemple avec `apt install git`.

### Initialiser le dépôt

<!-- - Vous pouvez reprendre du code que vous avez pu utiliser dans une session précédente, par exemple tiré de votre dossier d'exercices Python. -->

- En ligne de commande créez le dossier de code `tp1_git`.

- Chargez ce dossier avec VSCode.

Sur Linux : Si VSCode n'est pas installé : `snap install --classic code`

- Pour lancer VSCode : `code` ou `code mondossier/`

- Créez un nouveau fichier Python dans ce dossier appelé `multiplication.py`. Copiez-y le code suivant :

{{% expand "Cliquer pour afficher `multiplication.py` :" %}}

```python
    # Définit l'opération de multiplication
def multiplie(a, b):
    return a * b

if __name__ == "__main__":
  print("6 * 7 = ")
  print(multiplie(a, b))
```

{{% /expand %}}

- Lancez `git status`. Quel est le problème ?
- Initialisez le dépot de code avec la commande `git init`.
- Utilisez ensuite `git status` pour voir l'état de votre dépôt.

### Dire à Git de suivre un fichier

Pour le moment Git ne versionne aucun fichier du dépôt comme le confirme la commande `git status`.

- Utilisez `git add <nom_fichier>` sur le fichier. Puis faites à nouveau `git status`. Le fichier est passé à l'état suivi (_tracked_).
<!-- FIXME: autre fichier -->
- Créez un nouveau fichier et écrivez quelque chose à l'intérieur (ou copiez un fichier situé en dehors de ce dossier vers ce dossier).
- Faites `git status` à nouveau. Que s'est-il passé ?
<!-- - Lancez le script `multiplication.py` pour vérifier -->

### Faire votre premier commit

- Faites `git status` pour constater que tous les fichiers sont **non suivis** sauf un.
- Un commit est une version du code validée par un·e développeur/développeuse. Il faut donc que git sache qui vous êtes avant de faire un commit. Pour ce faire, utilisez :

```bash
git config --global user.name "<votre nom>"
git config --global user.email "<votre email>"
```

- Pour créer un commit on utilise la commande `git commit -m "<message_de_commit>"` (_commit_ signifie s'engager alors réfléchissez avant de lancer cette commande !). Utilisons le message `"Ceci est mon premier commit"` pour le premier commit d'un dépôt. Valider la version courante.
- Lancez un `git status` pour voir l'état du dépôt. Que constate-t-on ?
- Lancez `git log` pour observer votre premier commit.

### Commit de tous les fichiers

- Si le dossier `__pycache__` n'a pas été créé, créez manuellement juste pour le TP un fichier : `touch __pycache__`

- Utiliser `git add` avec l'option `-A` pour ajouter tous les fichiers actuels de votre projet.
- Qu'affiche `git status` ?
- Lancez à nouveau `git commit` avec un message adéquat.

- A quoi sert le dossier `__pycache__` ? Que faire avec ce dossier ?

### Supprimer un fichier

Oh non ! Vous avez ajouté le dossier `__pycache__` dans votre commit précédent 🙃
Ce ne serait pas correct de pousser sur Internet votre code en l'état !

- Supprimez le suivi du dossier `__pycache__` avec la commande `git rm`:
  - Quelles options sont nécessaires ? utilisez `git rm --help` pour les trouver.

### Ignorer un fichier

Maintenant que nous avons supprimé ce dossier nous voulons éviter de l'ajouter accidentellement à un commit à l'avenir. Nous allons ignorer ce dossier.

- Ajoutez un fichier `.gitignore` et à la première ligne ajoutez `__pycache__`
- Ajoutez ce fichier au suivi.
- Ajoutez un commit avec le message "`ignore __pycache__`"
- Lancez le programme `multiplication.py` à nouveau.
- Lancez `status`. Que constate-t-on ?

### Annuler un ou plusieurs commit

Le problème avec la suppression de `__pycache__` de la partie précédente est qu'elle n'affecte que le dernier commit. Le dossier inutile `__pycache__` encombre encore l'historique de notre dépôt.

- Pour le constater, installez l'extension [`Git Graph` de VSCode](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph).
- Explorer la fenêtre git graph en cliquant sur `Git Graph` en haut à gauche de la fenêtre des fichiers.
- Regardez successivement le contenu des deux commits.

- Pour corriger l'historique du dépôt nous aimerions revenir en arrière.

- Utilisez `git reset` avec `HEAD~2` pour revenir deux commits en arrière (nous parlerons de `HEAD` plus tard).
- Faites `git status`. Normalement vous devriez avoir un seul fichier non suivi `.gitignore`. Git vient de réinitialiser les ajouts des deux commits précédents.
- Constatez dans Git Graph que seul reste le premier commit qui est toujours là.
- Ajouter et _committez_ tous les fichiers non suivis du dépôt.
- Vérifier que **`__pycache__`** n'apparaît pas dans l'historique.

## Exercices supplémentaires

- ["1: Séquence d'introduction et Montée en puissance" sur _Learn Git branching_](https://learngitbranching.js.org/?locale=fr_FR)

### gitexercises.fracz.com

1. <https://gitexercises.fracz.com/exercise/master>
2. <https://gitexercises.fracz.com/exercise/commit-one-file>
3. <https://gitexercises.fracz.com/exercise/commit-one-file-staged>
4. <https://gitexercises.fracz.com/exercise/ignore-them>
5. <https://gitexercises.fracz.com/exercise/remove-ignored>
