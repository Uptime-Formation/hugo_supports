---
title: "TP8 Bonus - Cloud via Incus et générer un inventaire dynamique" 
draft: false
weight: 80
---
## Ajouter un provisionneur d'infra maison pour créer les machines automatiquement

<!-- FIXME: verif https://github.com/ansible/ansible/issues/82546 -->

Dans notre infra virtuelle, nous avons trois machines dans deux groupes. Quand notre lab d'infra grossit il devient laborieux de créer les machines et affecter les ip à la main. En particulier détruire le lab et le reconstruire est pénible. Nous allons pour cela introduire un playbook de provisionning qui va créer les conteneurs lxd en définissant leur ip à partir de l'inventaire.

- modifiez l'inventaire comme suit:

```ini
[all:vars]
ansible_user=<votre_user>

[appservers]
app1 ansible_host=10.x.y.121 container_image=ubuntu_ansible node_state=started
app2 ansible_host=10.x.y.122 container_image=ubuntu_ansible node_state=started

[dbservers]
db1 ansible_host=10.x.y.131 container_image=ubuntu_ansible node_state=started
```

- Remplacez `x` et `y` dans l'adresse IP par celle fournies par votre réseau virtuel lxd (faites `incus list` et copier simple les deux chiffre du milieu des adresses IP)

- Ajoutez un playbook `lxd.yml` dans un dossier `provisioners/lxd` contenant:

```yaml
- hosts: localhost
  connection: local

  tasks:
    - name: Setup linux containers for the infrastructure simulation
      lxd_container:
        name: "{{ item }}"
        state: "{{ hostvars[item]['node_state'] }}"
        source:
          type: image
          alias: "{{ hostvars[item]['container_image'] }}"
        profiles: ["default"]
        config:
          security.nesting: 'true' 
          security.privileged: 'false' 
        devices:
          # configure network interface
          eth0:
            type: nic
            nictype: bridged
            parent: lxdbr0
            # get ip address from inventory
            ipv4.address: "{{ hostvars[item].ansible_host }}"

        # Comment following line if you installed lxd using apt
        # url: unix:/var/snap/lxd/common/lxd/unix.socket
        wait_for_ipv4_addresses: true
        timeout: 600

      register: containers
      loop: "{{ groups['all'] }}"
    

    # Uncomment following if you want to populate hosts file pour container local hostnames
    # AND launch playbook with --ask-become-pass option

    - name: Config /etc/hosts file accordingly
      become: yes
      lineinfile:
        path: /etc/hosts
        regexp: ".*{{ item }}$"
        line: "{{ hostvars[item].ansible_host }}    {{ item }}"
        state: "present"
      loop: "{{ groups['all'] }}"
```

- Etudions le playbook (explication démo).

<!-- - Lancez le playbook avec `sudo` car `incus` se contrôle en root sur localhost: `sudo ansible-playbook provision_incus_infra` (c'est le seul cas exceptionnel ou ansible-playbook doit être lancé avec sudo, pour les autre playbooks ce n'est pas le cas) -->

- Lancez `incus list` pour afficher les nouvelles machines de notre infra et vérifier que le serveur de base de données a bien été créé.
