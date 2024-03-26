---
title: "TP7 - Cloud Terraform" 
draft: false
weight: 53
---

## Cloner le projet modèle

- Pour simplifier le démarrage, clonez le dépôt de base à l'adresse [https://github.com/e-lie/ansible_tp_corrections](https://github.com/e-lie/ansible_tp_corrections).
- Renommez le clone en tp4.
- ouvrez le projet avec VSCode.
- Activez la branche `tp4_correction` avec `git checkout tp4_correction`. 

## Infrastructure dans le cloud avec Terraform et Ansible


### Digitalocean token et clé SSH

- Pour louer les machines dans le cloud pour ce TP vous aurez besoin d'un compte digitalocean : celui du formateur ici mais vous pouvez facilement utiliser le votre. Il faut récupérer les éléments suivant pour utiliser le compte de cloud du formateur:
    - un token d'API digitalocean fourni pour la formation. Cela permet de commander des machines auprès de ce provider.


- Récupérez sur git la paire clé ssh adaptée: [https://github.com/e-lie/id_ssh_shared.git](https://github.com/e-lie/id_ssh_shared.git). Utilisez "clone or download" > "Download as ZIP". Puis décompressez l'archive.
- mettez la paire de clé `id_ssh_shared` et `id_ssh_shared.pub` dans le dossier `~/.ssh/`. La passphrase de cette clé est `trucmuch42`.
- Rétablissez les droits `600` sur la clé privée : `chmod 600 ~/.ssh/id_ssh_shared`.
- faites `ssh-add ~/.ssh/id_ssh_shared` pour vérifier que vous pouvez déverrouiller deux clés (l'ancienne avec votre passphrase et la nouvelle paire que vous venez d'ajouter)

- Si vous utilisez votre propre compte, vous aurez besoin d'un token personnel. Pour en crée allez dans API > Personal access tokens et créez un nouveau token. Copiez bien ce token et collez le dans un fichier par exemple `~/Bureau/compte_digitalocean.txt`. (important détruisez ce token à la fin du TP par sécurité).

- Copiez votre clé ssh (à créer si nécessaire): `cat ~/.ssh/id_ed25519.pub`
- Aller sur digital ocean dans la section `account` en haut à droite puis `security` et ajoutez un nouvelle clé ssh. Notez sa fingerprint dans le fichier précédent.


### Installer Terraform et le provider ansible

Terraform est un outil pour décrire une infrastructure de machines virtuelles et ressources IaaS (infrastructure as a service) et les créer (commander). Il s'intègre en particulier avec AWS, DigitalOcean mais peut également créer des machines dans un cluster VMWare en interne (on premise) pour créer par exemple un cloud mixte.

Terraform est notamment à l'aide d'un dépôt ubuntu/debian. Pour l'installer lancez:

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform
```

- Testez l'installation avec `terraform --version`

Pour pouvoir se connecter à nos VPS, ansible doit connaître les adresses IP et le mode de connexion ssh de chaque VPS. Il a donc besoin d'un inventaire.

Jusqu'ici nous avons créé un inventaire statique c'est à dire un fichier qui contenait la liste des machines. Nous allons maintenant utiliser un inventaire dynamique c'est à dire un programme qui permet de récupérer dynamiquement la liste des machines et leurs adresses en contactant une API.

- L'inventaire dynamique pour terraform est [https://github.com/nbering/terraform-inventory/](https://github.com/nbering/terraform-inventory/). Normalement il est déjà installé avec la correction du TP4.

### Terraform avec DigitalOcean

- Le fichier qui décrit les VPS et ressources à créer avec terraform est `provisionner/terraform/main.tf`. Nous allons commenter ensemble ce fichier:

!! La documentation pour utiliser terraform avec digitalocean se trouve ici [https://www.terraform.io/docs/providers/do/index.html](https://www.terraform.io/docs/providers/do/index.html)

Pour terraform puisse s'identifier auprès de digitalocean nous devons renseigner le token et la fingerprint de clé ssh. Pour cela:

- copiez le fichier `terraform.tfvars.dist` et renommez le en enlevant le `.dist`
- collez le token récupéré précédemment dans le fichier de variables `terraform.tfvars`
- normalement la clé ssh `id_stagiaire` est déjà configuré au niveau de DigitalOcean et précisé dans ce fichier. Elle sera donc automatiquement ajoutée aux VPS que nous allons créer.

- Maintenant que ce fichier est complété nous pouvons lancer la création de nos VPS:
  - `terraform init` permet à terraform de télécharger les "driver" nécessaire pour s'interfacer avec notre provider. Cette commande crée un dossier .terraform
  - `terraform plan` est facultative et permet de calculer et récapituler les créations modifications de ressources à partir de la description de `main.tf`
  - `terraform apply` permet de déclencher la création des ressources.

- La création prend environ 1 minute.

Maintenant que nous avons des machines dans le cloud nous devons fournir leurs IP à Ansible pour pouvoir les configurer. Pour cela nous allons utiliser un inventaire dynamique.

### Terraform dynamic inventory

Une bonne intégration entre Ansible et Terraform permet de décrire précisément les liens entre resource terraform et hote ansible ainsi que les groupes de machines ansible. Pour cela notre binder propose de dupliquer les ressources dans `main.tf` pour créer explicitement les hotes ansible à partir des données dynamiques de terraform.

- Ouvrons à nouveau le fichier `main.tf` pour étudier le mapping entre les ressources digitalocean et leur équivalent Ansible.

- Pour vérifier le fonctionnement de notre inventaire dynamique, allez à la racine du projet et lancez:

```
source .env
./inventory_terraform.py
```

- La seconde appelle l'inventaire dynamique et vous renvoie un résultat en JSON décrivant les groupes, variables et adresses IP des machines créées avec Terraform.

- Complétez le `ansible.cfg` avec le chemin de l'inventaire dynamique: `./inventory_terraform.py`

- Nous pouvons maintenant tester la connexion avec Ansible directement: `ansible all -m ping`.
