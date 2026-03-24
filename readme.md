# Environnement de Dev - WeFund

Ce projet git a pour but la création d'un environnement de dev commun à tous les projets pour qu'ils puissent profiter de la même infra au besoin

## Premières étapes
Si c'est votre première fois configurant l'environnement de dev, lancez la commande suivante:

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
Cette commande va changer automatiquement tous les branches du projet vers la main et fera un pull des repos git, si vous avez fait des changements, pensez à les commit sur une nouvelle branche ou faire un stash avant de le lancer

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

---

## Architecture

| Service | Port Docker | Port local | Description |
|---------|-------------|------------|-------------|
| `wefund-projects-service-api` | 3000 | **1001** | Projets & campagnes (Projet 1) |
| `wefund-contributions-paiements-utilisateurs-api` | 3000 | **1002** | Contributions, paiements, utilisateurs (Projet 2) |
| `postgres` | 5432 | 5432 | PostgreSQL 16 (base partagée `wefund_db`) |
| `redpanda` | 9092 | 19092 (ext) | Broker Kafka/Redpanda |
| `pgadmin` | 80 | 5050 | Interface d'administration PostgreSQL |

### URLs Swagger

- Projet 1 : <http://localhost:1001/api/docs>
- Projet 2 : <http://localhost:1002/api/docs>

### Broker Kafka
Le broker Redpanda remplace Kafka/Zookeeper. Les deux services communiquent via `redpanda:9092` en interne.

Topics publiés par Projet 1 :
| Topic | Déclencheur |
|-------|-------------|
| `campaign.submitted` | POST `/campagnes/:id/soumettre` |
| `campaign.closed.success` | Cron `closeExpiredCampaigns` → REUSSIE |
| `campaign.closed.failed` | Cron `closeExpiredCampaigns` → ECHOUEE |

Topics consommés par Projet 2 :
| Topic | Action |
|-------|--------|
| `campaign.closed.success` | Capture de toutes les transactions `authorized` |
| `campaign.closed.failed` | Remboursement de toutes les transactions `authorized` |
| `campaign.moderated` | Log (implémentation Projet 1 à venir) |

---

## Projet 2 — Contributions, Paiements & Utilisateurs

### User Stories couvertes

| # | Story | Endpoint | Statut |
|---|-------|----------|--------|
| 1 | Financer une campagne | `POST /api/contribution` | ✅ |
| 2 | Consulter ses contributions | `GET /api/contribution` | ✅ |
| 3 | Remboursement auto (campagne échouée) | Kafka `campaign.closed.failed` | ✅ |
| 4 | Remboursement manuel / annulation | `DELETE /api/contribution/:id` | ✅ |
| 5 | Modifier le montant | `PATCH /api/contribution/:id` | ✅ |
| 6 | Créer un compte | `POST /api/auth/signup` | ✅ |
| 7 | Authentification | `POST /api/auth/login` | ✅ |
| 8 | Modération admin | `PATCH /api/campagnes/:id/moderer` | ✅ |

### Règles de gestion respectées

- **RG1** : Contribution liée à un utilisateur, une campagne active et un montant positif
- **RG2** : Toute contribution est horodatée (`createdAt`)
- **RG3** : Modification et annulation uniquement si la campagne est ACTIVE
- **RG4** : Paiements tracés en DB (`transactions`) avec statut (pending → authorized → captured/refunded)
- **RG5** : Fonds en séquestre Stripe (`capture_method: 'manual'`) jusqu'à clôture de campagne
- **RG6** : Seul un ADMINISTRATEUR peut accepter (`ACTIVE`) ou refuser (`REFUSEE`) une campagne EN_ATTENTE

### Variables d'environnement Projet 2

| Variable | Valeur par défaut | Description |
|----------|-------------------|-------------|
| `JWT_SECRET` | `cle-demo-123` | Clé de signature JWT |
| `DATABASE_HOST` | `postgres` | Hôte PostgreSQL |
| `DATABASE_PORT` | `5432` | Port PostgreSQL |
| `DATABASE_USER` | `postgres` | Utilisateur PostgreSQL |
| `DATABASE_PASSWORD` | `password` | Mot de passe PostgreSQL |
| `DATABASE_NAME` | `wefund_db` | Nom de la base de données |
| `KAFKA_BROKERS` | `redpanda:9092` | Broker Redpanda |
| `STRIPE_SECRET_KEY` | *(vide)* | Clé secrète Stripe (sandbox) |
| `STRIPE_WEBHOOK_SECRET` | *(vide)* | Secret webhook Stripe |
| `CORS_ORIGIN` | `http://localhost:5173` | Origine CORS autorisée |
| `PORT` | `3000` | Port HTTP |

### Tests

```bash
cd wefund-contributions-paiements-utilisateurs/utilisateurs
npm install
npm test
```

28 tests unitaires couvrent :

- `ContributionService` (create, update, remove, findAllByUser)
- `PaymentService` (createPaymentIntent, captureAllForCampaign, refundAllForCampaign)
- `CampaignEventsConsumer` (handleCampaignSuccess, handleCampaignFailed, handleCampaignModerated)

### Collection Postman

La collection Postman est disponible dans :
`wefund-contributions-paiements-utilisateurs/utilisateurs/postman/WeFund-Utilisateurs.postman_collection.json`

Importer aussi l'environnement :
`wefund-contributions-paiements-utilisateurs/utilisateurs/postman/WeFund-Local.postman_environment.json`

---

## Configs à faire

- Renseigner `STRIPE_SECRET_KEY` et `STRIPE_WEBHOOK_SECRET` pour les paiements Stripe sandbox
- Renseigner `JWT_SECRET` avec une valeur complexe en production
