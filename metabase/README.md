# Problème d'unification des modèles de données (Projet 1 / Projet 2)

## Contexte

Le script `seed_unified_only_proj1.sql` vise à peupler la base uniquement avec les entités du Projet 1 (projects, campagnes, news, etc.) et à lier toutes les contributions/transactions à ces campagnes/projets (UUID).

## Problème rencontré

Lors de l'exécution du script sur une base fraîche, l'insertion dans la table `contribution` échoue avec l'erreur suivante :

```
ERROR:  invalid input syntax for type integer: "22222222-2222-2222-2222-222222222001"
LINE 2:   (1, 40, '2026-03-01 13:00:00', '22222222-2222-2222-2222-22...
```

Cela signifie que la colonne `campagneId` de la table `contribution` attend un entier (clé primaire auto-incrémentée de la table `campagne` du Projet 2), alors que le script insère des UUID (liés aux campagnes du Projet 1).

## Origine

- **Projet 1** : Les campagnes et projets utilisent des UUID comme identifiants.
- **Projet 2** : Les entités `contribution` et `campagne` utilisent des entiers auto-incrémentés comme identifiants et clés étrangères.
- Le script de seed tente d'unifier les modèles en liant les contributions aux campagnes du Projet 1 (UUID), mais la structure de la table `contribution` ne le permet pas.

## Solutions possibles

1. **Adapter le script de seed** pour insérer des entiers factices dans `campagneId` (mais cela ne pointera pas vers les vraies campagnes du Projet 1).
2. **Faire migrer la structure de la table `contribution`** pour accepter des UUID en clé étrangère, et ainsi permettre une vraie unification des modèles.

## Recommandation

Pour une unification réelle et exploitable (Metabase, analytics, etc.), il est recommandé de migrer la structure de la table `contribution` (et toutes les FKs concernées) vers des UUID, afin de référencer directement les campagnes du Projet 1.

---

Contactez l'équipe technique pour valider la stratégie de migration et adapter les entités TypeORM + migrations SQL en conséquence.
