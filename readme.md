# Environnement de Dev - WeFund

Ce projet git a pour but la création d'un environnement de dev commun à tous les projets pour qu'ils puissent profiter de la même infra au besoin

## Prémières étapes
Si c'est votre prémière fois configurant l'environnement de dev, lancez la commande suivante:

```bash
make clone-projects
```

Ça clonera tous les projets git disponibles pour la première fois et les rajoutera sur les dossiers dépendants pour les lancer ensemble

## Mise à jour
Pour mettre à jour les repos git disponibles sur l'environnement, vous pouvez lancer la commande suivante:

```bash
make pull-projects
```

ATTENTION!
Cette commmande va changer automatiquement tous les branches du projet vers la main et fera un pull des repos git, si vous avez fait des changements, pensez à les commit sur une nouvelle branche ou faire un stash avant de le lancer

## Lancement des projets ensemble

### Dev
La commande suivante permet le lancement de tous les projets clonés dans son état actuel d'un seul coup:
```bash
docker compose up
```

Comme ça, on a une émulation sur l'environnement de Dev de comment ça devait marcher

### Dry Run
Pour simuler le comportement sur un environnement de Prod, la commande suivante est disponible
```bash
make dry-run-projects
```

Cette commande clone la dernière version de tous les projets puis les relance.

### Configs à Faire:
- Ajouter les variables d'environnement sur DevEnv (À voir ensemble comment faire)

## Dashboard avec Metabase

Metabase est maintenant intégré au `docker-compose.yaml` de l'environnement.

### Démarrage

```bash
docker compose up -d metabase
```

Si la base PostgreSQL n'est pas démarrée, lance plutôt:

```bash
docker compose up -d postgres metabase
```

### Accès

- Metabase: http://localhost:3001
- PostgreSQL (source de données):
	- Host: `postgres`
	- Port: `5432`
	- Database: `wefund_db`
	- User: `postgres`
	- Password: `password`

### Requêtes SQL prêtes à l'emploi

Les 6 stories sont prêtes dans:

- `metabase/queries.sql`

Variables à créer dans Metabase (Native query):

- `from_date` (Date)
- `to_date` (Date)

Conseil: créer 6 "Questions" SQL puis un dashboard unique avec un filtre global de période mappé à `from_date` et `to_date`.