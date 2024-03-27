---

title: "TP9 Bonus - Orchestration avancée avec un rollback utilisant block et rescue" 
draft: false
weight: 90
---

## Orchestration avancée avec un rollback en utilisant `block` et `rescue`

A l'aide de ces pages de la documentation, adaptez les playbooks de <https://github.com/Uptime-Formation/exo-ansible-cloud> pour gérer le cas où la mise à jour plante (on pourra par exemple tenter une mise à jour en indiquant une branche qui n'existe pas), en décidant de revenir à l'état précédent de l'app et de réactiver l'appserver dans HAProxy.