---
title: "TP7 - Serveur de contrôle AWX + Ansible Vault" 
draft: false
weight: 60
---
## Installer AWX ou Semaphore

- AWX : <https://ansible.readthedocs.io/projects/awx-operator/en/latest/installation/basic-install.html>
Sur Kubernetes avec minikube ou k3s

<!-- - Rundeck : <https://docs.rundeck.com/docs/administration/install/>
`docker run -it -p 4440:4440 rundeckpro/enterprise:5.1.1` -->

- Semaphore : <https://github.com/ansible-semaphore/semaphore>
```bash
sudo snap install semaphore
sudo semaphore user add --admin --name "Your Name" --login your_login --email your-email@examaple.com --password your_password
```
puis se connecter sur le port 3000

## Installer Docker
Nécessaire pour Minikube ou Rundeck.

`curl https://get.docker.com | sh`

## Installer AWX

- Installer k3s :
```bash
curl -sfL https://get.k3s.io | sh
alias kubectl="sudo k3s kubectl"
```

- Puis suivre ces instructions :
(inspiré de <https://ansible.readthedocs.io/projects/awx-operator/en/latest/installation/basic-install.html>)

```bash
git clone https://github.com/ansible/awx-operator.git
cd awx-operator
git checkout tags/2.7.2

sudo make deploy
```

Créer un fichier `awx-demo.yml` :
```yaml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: nodeport
```

Puis :
```
kubectl apply -f awx-demo.yml -n awx

kubectl get secret -n awx awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode ; echo

echo "Se connecter en localhost à ce port :"
kubectl get svc -n awx awx-demo -o=jsonpath='{.spec.ports[?(@.nodePort)].nodePort}'
```

## Explorer AWX

- Identifiez vous sur awx avec le login `admin` et le mot de passe précédemment configuré.

- Dans la section Modèle de projet, importez votre projet. Un job d'import se lance. Si vous avez mis le fichier `requirements.yml` dans  `roles` les roles devraient être automatiquement installés.

- Dans la section credentials, créez un credential de type machine. Dans la section clé privée copiez le contenu du fichier `~/.ssh/id_ssh_tp` (ou autre nom) que nous avons configuré comme clé SSH de nos machines. Ajoutez également la passphrase si vous l'avez configuré au moment de la création de cette clé.

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

## Bonus : réimplémentons le load balancing du TP5 via AWX

Dans un template de tâche ou un workflow AWX, manipulez `playbooks/manually_exclude_backend.yml` et/ou d'autres playbooks pour réimplementer le scénario du TP5 dans AWX.
