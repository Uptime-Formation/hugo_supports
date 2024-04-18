---
title: 1-00 A propos de Terraform
weight: 1
---

![](/img/terraform/terraform-logo.png)
---

## Objectifs
- Avoir une perspective historique sur Terraform 

--- 

### 2014 : Naissance (Terraform v0.1)


**Le projet est né de l'absence d'alternative libre au projet cloudFormation de AWS**

Voici un extrait de l'[article de Mitchell Hashimoto en 2011 sur le sujet](https://gist.github.com/mitchellh/b52314d30ba22bb76f3d6bb9ff098090).

> However, we need an open source, cloud-agnostic solution to this problem. Libraries such as Fog, Boto, libcloud, etc. are not the answer. These libraries are just that... libraries to cloud APIs.  
> Ideally, we would have a declarative language to define infrastructure (incrementally, as well), and tools to consume this language and use the various libraries noted previously to spin up cloud infrastructure, perhaps even across different cloud providers.  
> CloudFormation is a brilliant move by AWS and is a technology worth watching, but at this stage its uses are limited, and it leaves space open for an open source alternative, which I hope will come about.

* La cible d'origine est Amazon AWS : le premier provider, fourni par défaut au départ.
* La licence opensource fait partie du projet de base.

--- 

### 2017 : La phase de croissance (Terraform v0.10)

**Le "year of Terraform" : décollage des usages et premier partenariat officiel avec un fournisseur de cloud : Microsoft Azure.**

* Séparation du core et des providers
* Création du programme pour les providers
* Mise à disposition de la plateforme Registry pour télécharger des providers


* Les partenaires développent le code nécessaire pour utiliser leurs API selon la norme Terraform. 

--- 

### 2021 : la phase de stabilisation (Terraform v1.0.0)

**Le projet est un succès, devenu un standard de l'IAC provisioning avec un millier de providers**

* Le business se développe avec de grandes entreprises qui sont clientes de Hashicorp
* Terraform Enterprise : solution pour gérer l'état de l'infrastructure 
* Terraform Cloud : version SAAS de Enterprise fournie par Terraform 

L'entreprise se prépare à entrer en bourse, avec une estimation à 13 milliards de dollars en novembre 2021.

--- 

### 2023 : la phase de rentabilisation (Terraform v1.5.6)

* juin : L'action décroche en bourse, Hashicorp promet des réductions de poste et une rentabilité à 2025 
* août : Annonce d'un changement de licence avec un passage de la Mozilla Public Licence à la Business Source Licence.
* septembre  : annonce officielle de mise à disposition de OpenTF, le fork de Terraform. 

**Une situation de _Walled Garden_ dans laquelle on enferme des utilisateurs après les avoir fait venir.** 

Par exemple Facebook qui a affiché longtemps “_It’s free and always will be_” jusqu'à ce que la mention disparaisse.

**La clôture se fait notamment face à des projets concurrents :**
* Des projets qui utilisent Terraform pour fournir un langage d'IAC : Pulumi
* Des projets qui pilotent Terraform pour faire de l'IAC en équipe : Spacelift

--- 

## Quel avenir ? dans quel contexte ? 

### Le projet de OpenTF

**Fournir une alternative à Terraform** 
* conservant la licence Mozilla Public Licence
* basée sur la communauté (évolutions selon des RDF)
* fondée légalement et institutionnellement (rattachement à la Linux Foundation ou  CNCF)
* fournissant les outils associés à Terraform et touchés par le changement de licence (Registry)

### Une tendance à la fermeture des licences des projets libres qui marchent

Un mouvement historique qui touche notamment les projets libres de bases de données : 

> https://linuxfr.org/news/virevoltantes-valses-de-licences-libres-et-non-libres-dans-les-bases-de-donnees

Des exemples : 
* IBM / RedHat
* Oracle / MySQL 
* Microsoft / Github

Utilisations de licences (Business Source Licence / Server Side Public License) qui visent à empêcher des concurrents d'utilisar le logiciel.

    > The BSL is not an Open Source license and we do not claim it to be one.

Un précédent intéressant : Docker, dont la normalisation permet de dépasser une éventuelle faillite de l'entreprise ou une clôture du projet.

### Les forks de logiciels libres sont souvent des projets solides

Le projet OpenTF est soutenu par de nombreuses entreprises comme Spacelift.



### L'inertie des projets logiciels est importante

**La quantité de projets utilisant Terraform lui donne une garantie de stabilité.**

La plupart des entreprises ne vont pas changer immédiatement de solution : former les équipes, produire le code, etc.

En revanche une solution "drop-in replacement" est rassurante a priori.

### Un rappel important de l'importance des choix de dépendances logicielles

**Ce virage dont les effets sont encore à venir nous rappelle l'importance des choix d'outils et de plateformes pour les métiers de l'ingénierie informatique.**

De la même manière qu'il faut être vigilant quand on produit du code (dette technique), il faut s'assurer qu'il existe des portes de sortie pour les fournisseurs de solutions qu'on utilise.

En l'occurence, le code sous licence libre offre une forme de garantie avec le fork. 

Les annèes à venir nous diront ce qu'il en est pour Terraform / OpenTF

--- 

## Objectifs
- Avoir une perspective historique sur Terraform 


