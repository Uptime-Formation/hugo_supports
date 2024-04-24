---
title: "TP 5 - Logging et monitoring"
draft: false
weight: 1045
---

## Les drivers de logs

Dans Docker, le driver de logs par défaut est `json-file`.
Son inconvénient majeur est que les logs avec ce driver sont supprimés dès que le conteneur est supprimé.

### Utiliser le driver `journald`

- [A l'aide de la documentation](https://docs.docker.com/config/containers/logging/journald/), changeons le driver dans `/etc/docker/daemon.json` pour utiliser le driver `journald`. 
- Relancez le service `docker.service`
- Consultez les logs d'un conteneur grâce à `journalctl -f` et le bon label.

Ce driver est utile car les logs sont désormais archivés dès leur création, tout en permettant d'utiliser les features de filtrage et de rotation de `journald`.

- Remettez le driver par défaut (`json-file` ou supprimez le fichier `/etc/docker/daemon.json`), et restartez le service `docker.service` pour ne pas interférer avec la seconde moitié de l'exercice : la config Elastic de l'exercice suivant fonctionne avec le driver `json-file`.

## Une stack Elastic

### Centraliser les logs

L'utilité d'Elasticsearch est que, grâce à une configuration très simple de son module Filebeat, nous allons pouvoir centraliser les logs de tous nos conteneurs Docker.
Pour ce faire, il suffit d'abord de télécharger une configuration de Filebeat prévue à cet effet :

```bash
curl -L -O https://raw.githubusercontent.com/elastic/beats/7.10/deploy/docker/filebeat.docker.yml
```

Renommons cette configuration et rectifions qui possède ce fichier pour satisfaire une contrainte de sécurité de Filebeat :

```bash
mv filebeat.docker.yml filebeat.yml
sudo chown root filebeat.yml
sudo chmod go-w filebeat.yml
```

Enfin, créons un fichier `docker-compose.yml` pour lancer une stack Elasticsearch :

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.5.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    networks:
      - logging-network

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.5.0
    user: root
    depends_on:
      - elasticsearch
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - logging-network
    environment:
      - -strict.perms=false

  kibana:
    image: docker.elastic.co/kibana/kibana:7.5.0
    depends_on:
      - elasticsearch
    ports:
      - 5601:5601
    networks:
      - logging-network

networks:
  logging-network:
    driver: bridge
```

Il suffit ensuite de :
- se rendre sur Kibana (port `5601`)
- de configurer l'index en tapant `*` dans le champ indiqué, de valider
- et de sélectionner le champ `@timestamp`, puis de valider.

L'index nécessaire à Kibana est créé, vous pouvez vous rendre dans la partie Discover à gauche (l'icône boussole 🧭) pour lire vos logs.

Il est temps de faire un petit `docker stats` pour découvrir l'utilisation du CPU et de la RAM de vos conteneurs !

#### Parenthèse : Avec WSL
Avec WSL, l'emplacement des logs est assez difficile à trouver ! Vous pouvez vous aider de cette page pour ce TP : <https://gist.github.com/Bert-R/e5bb77b9ce9c94fdb1a90e4e615ee518>

### _Facultatif :_ Ajouter un nœud Elasticsearch

Puis, à l'aide de la documentation Elasticsearch et/ou en adaptant de bouts de code Docker Compose trouvés sur internet, ajoutez et configurez un nœud Elastic. Toujours à l'aide de la documentation Elasticsearch, vérifiez que ce nouveau nœud communique bien avec le premier.

### _Facultatif_ : ajouter une stack ELK à `microblog`

<!-- TODO: Fiare avec ma version de l'app et du docker compose -->

Dans la dernière version de l'app `microblog`, Elasticsearch est utilisé pour fournir une fonctionnalité de recherche puissante dans les posts de l'app.
Avec l'aide du [tutoriel de Miguel Grinberg](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xix-deployment-on-docker-containers), écrivez le `docker-compose.yml` qui permet de lancer une stack entière pour `microblog`. Elle devra contenir un conteneur `microblog`, un conteneur `mysql`, un conteneur `elasticsearch` et un conteneur `kibana`.

<!-- ### _Facultatif / avancé_ : centraliser les logs de microblog sur ELK

Avec la [documentation de Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-autodiscover.html) et des [hints Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-autodiscover-hints.html) ainsi que grâce à [cette page](https://discuss.elastic.co/t/nginx-filebeat-elk-docker-swarm-help/130512/2), trouvez comment centraliser les logs Flask de l'app `microblog` grâce au système de labels Docker de Filebeat.

Tentons de centraliser les logs de
de ces services dans ELK. -->

### *Facultatif :* du monitoring avec *cAdvisor* et *Prometheus*

Suivre ce tutoriel pour du monitoring des conteneurs Docker : <https://prometheus.io/docs/guides/cadvisor/>

On pourra se servir de cette stack Compose : <https://github.com/vegasbrianc/prometheus/>

#### Ressources supplémentaires

Une alternative est Netdata, joli et configuré pour monitorer des conteneurs _out-of-the-box_ : <https://learn.netdata.cloud/docs/netdata-agent/installation/docker>

On peut aussi regarder du côté de Signoz (logging, monitoring et alerting) : https://github.com/SigNoz/signoz

Ou bien Loki : https://grafana.com/docs/loki/latest/setup/install/docker/


Ressources utiles :
- https://github.com/stefanprodan/dockprom
- https://github.com/vegasbrianc/docker-monitoring
- https://grafana.com/grafana/dashboards/179-docker-prometheus-monitoring/