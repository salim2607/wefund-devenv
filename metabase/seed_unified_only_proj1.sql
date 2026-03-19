-- Seed script : modèle unifié (Projet 1 = source de vérité)
-- Remplit uniquement : projects, campagnes, news, user, auth, role, contribution, transaction
-- Toutes les FK pointent vers les UUID de Projet 1
-- Usage :
--   docker exec -i we-fund-db psql -U postgres -d wefund_db < metabase/seed_unified_only_proj1.sql

BEGIN;

TRUNCATE TABLE
  news,
  campagnes,
  projects,
  contribution,
  "transaction",
  "auth",
  "role",
  "user"
RESTART IDENTITY CASCADE;

-- =========================
-- Projet 1 (source de vérité)
-- =========================

INSERT INTO projects (id, titre, description, photo, "porteurId", "createdAt", "updatedAt") VALUES
  ('11111111-1111-1111-1111-111111111001', 'Projet Eau Solidaire', 'Acces a l eau potable', 'p1.jpg', 'porteur_p1', '2026-03-01 09:00:00', '2026-03-01 09:00:00'),
  ('11111111-1111-1111-1111-111111111002', 'Projet Ecole Connectee', 'Materiel numerique pour ecoles', 'p2.jpg', 'porteur_p2', '2026-03-03 10:00:00', '2026-03-03 10:00:00'),
  ('11111111-1111-1111-1111-111111111003', 'Projet Sante Mobile', 'Clinique mobile rurale', 'p3.jpg', 'porteur_p3', '2026-03-06 11:00:00', '2026-03-06 11:00:00'),
  ('11111111-1111-1111-1111-111111111004', 'Projet Reboisement', 'Planter 10 000 arbres', 'p4.jpg', 'porteur_p4', '2026-03-09 14:00:00', '2026-03-09 14:00:00'),
  ('11111111-1111-1111-1111-111111111005', 'Projet Formation Pro', 'Ateliers de formation', 'p5.jpg', 'porteur_p5', '2026-03-12 16:00:00', '2026-03-12 16:00:00');

INSERT INTO campagnes (id, titre, description, objectif, "montantCollecte", "dateFin", statut, "porteurId", "projetId", "createdAt", "updatedAt") VALUES
  ('22222222-2222-2222-2222-222222222001', 'Campagne Eau Mars', 'Collecte mensuelle eau', 5000.00, 2400.00, '2026-03-19 23:00:00', 'ACTIVE', 'porteur_p1', '11111111-1111-1111-1111-111111111001', '2026-03-01 09:30:00', '2026-03-10 09:30:00'),
  ('22222222-2222-2222-2222-222222222002', 'Campagne Ecole 2026', 'Tablettes et routeurs', 12000.00, 12000.00, '2026-03-14 18:00:00', 'REUSSIE', 'porteur_p2', '11111111-1111-1111-1111-111111111002', '2026-03-02 10:30:00', '2026-03-14 18:00:00'),
  ('22222222-2222-2222-2222-222222222003', 'Campagne Sante Printemps', 'Medicaments essentiels', 8000.00, 3500.00, '2026-03-18 20:00:00', 'ACTIVE', 'porteur_p3', '11111111-1111-1111-1111-111111111003', '2026-03-05 11:30:00', '2026-03-11 11:30:00'),
  ('22222222-2222-2222-2222-222222222004', 'Campagne Reboisement', 'Pepiniere et logistique', 7000.00, 1200.00, '2026-03-12 17:00:00', 'ECHOUEE', 'porteur_p4', '11111111-1111-1111-1111-111111111004', '2026-03-04 14:30:00', '2026-03-12 17:00:00'),
  ('22222222-2222-2222-2222-222222222005', 'Campagne Formation', 'Formateurs et kits', 6000.00, 0.00, '2026-03-17 19:00:00', 'EN_ATTENTE', 'porteur_p5', '11111111-1111-1111-1111-111111111005', '2026-03-08 16:30:00', '2026-03-09 16:30:00');

INSERT INTO news (id, titre, contenu, "campagneId", "createdAt") VALUES
  ('33333333-3333-3333-3333-333333333001', 'Point semaine 1', 'Lancement officiel de la campagne.', '22222222-2222-2222-2222-222222222001', '2026-03-02 08:00:00'),
  ('33333333-3333-3333-3333-333333333002', 'Objectif atteint', 'Merci a tous les contributeurs.', '22222222-2222-2222-2222-222222222002', '2026-03-14 09:00:00'),
  ('33333333-3333-3333-3333-333333333003', 'Nouveau partenaire', 'Un partenaire local rejoint le projet.', '22222222-2222-2222-2222-222222222003', '2026-03-08 10:00:00'),
  ('33333333-3333-3333-3333-333333333004', 'Mise a jour budget', 'Reallocation des ressources terrain.', '22222222-2222-2222-2222-222222222004', '2026-03-12 11:00:00'),
  ('33333333-3333-3333-3333-333333333005', 'Preparation lancement', 'Calendrier et objectifs publies.', '22222222-2222-2222-2222-222222222005', '2026-03-09 12:00:00');

-- =========================
-- Utilisateurs et contributions (liés à Projet 1)
-- =========================

INSERT INTO "user" (id, nom, prenom, username) VALUES
  ('44444444-4444-4444-4444-444444444001', 'Dupont', 'Alice', 'alice.dupont'),
  ('44444444-4444-4444-4444-444444444002', 'Martin', 'Benoit', 'benoit.martin'),
  ('44444444-4444-4444-4444-444444444003', 'Nguyen', 'Camille', 'camille.nguyen'),
  ('44444444-4444-4444-4444-444444444004', 'Diallo', 'David', 'david.diallo'),
  ('44444444-4444-4444-4444-444444444005', 'Lopez', 'Emma', 'emma.lopez');

INSERT INTO "auth" (id, password, "userId") VALUES
  (1, 'hash_pwd_1', '44444444-4444-4444-4444-444444444001'),
  (2, 'hash_pwd_2', '44444444-4444-4444-4444-444444444002'),
  (3, 'hash_pwd_3', '44444444-4444-4444-4444-444444444003'),
  (4, 'hash_pwd_4', '44444444-4444-4444-4444-444444444004'),
  (5, 'hash_pwd_5', '44444444-4444-4444-4444-444444444005');

INSERT INTO "role" (id, role, "userId") VALUES
  (1, 'ADMINISTRATEUR', '44444444-4444-4444-4444-444444444001'),
  (2, 'USER', '44444444-4444-4444-4444-444444444002'),
  (3, 'USER', '44444444-4444-4444-4444-444444444003'),
  (4, 'USER', '44444444-4444-4444-4444-444444444004'),
  (5, 'USER', '44444444-4444-4444-4444-444444444005');

INSERT INTO contribution (id, montant, "timestamp", "campagneId", "contributeurId") VALUES
  (1, 40, '2026-03-01 13:00:00', '22222222-2222-2222-2222-222222222001', '44444444-4444-4444-4444-444444444001'),
  (2, 25, '2026-03-05 15:30:00', '22222222-2222-2222-2222-222222222002', '44444444-4444-4444-4444-444444444002'),
  (3, 60, '2026-03-09 09:45:00', '22222222-2222-2222-2222-222222222003', '44444444-4444-4444-4444-444444444003'),
  (4, 80, '2026-03-14 17:10:00', '22222222-2222-2222-2222-222222222004', '44444444-4444-4444-4444-444444444004'),
  (5, 35, '2026-03-19 20:25:00', '22222222-2222-2222-2222-222222222005', '44444444-4444-4444-4444-444444444005');

INSERT INTO "transaction" (id, "paymentIntentId", montant, statut, "contributionId", "contributeurId", "createdAt", "updatedAt") VALUES
  ('55555555-5555-5555-5555-555555555001', 'pi_demo_001', 40, 'captured', 1, '44444444-4444-4444-4444-444444444001', '2026-03-01 13:02:00', '2026-03-01 13:03:00'),
  ('55555555-5555-5555-5555-555555555002', 'pi_demo_002', 25, 'captured', 2, '44444444-4444-4444-4444-444444444002', '2026-03-05 15:31:00', '2026-03-05 15:32:00'),
  ('55555555-5555-5555-5555-555555555003', 'pi_demo_003', 60, 'authorized', 3, '44444444-4444-4444-4444-444444444003', '2026-03-09 09:46:00', '2026-03-09 09:47:00'),
  ('55555555-5555-5555-5555-555555555004', 'pi_demo_004', 80, 'captured', 4, '44444444-4444-4444-4444-444444444004', '2026-03-14 17:11:00', '2026-03-14 17:12:00'),
  ('55555555-5555-5555-5555-555555555005', 'pi_demo_005', 35, 'failed', 5, '44444444-4444-4444-4444-444444444005', '2026-03-19 20:26:00', '2026-03-19 20:27:00');

-- Keep sequences aligned after explicit IDs
SELECT setval(pg_get_serial_sequence('"auth"', 'id'), COALESCE((SELECT MAX(id) FROM "auth"), 1), true);
SELECT setval(pg_get_serial_sequence('contribution', 'id'), COALESCE((SELECT MAX(id) FROM contribution), 1), true);

COMMIT;
