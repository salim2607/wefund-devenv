-- WeFund Metabase SQL pack
-- Variables expected in Metabase Native Query editor:
--   from_date (Type: Date)
--   to_date   (Type: Date)

-- ============================================================
-- Story 1 - Campagnes actives sur une periode (Projet 1)
-- Result shape: date | count
-- ============================================================
WITH days AS (
  SELECT generate_series(
    COALESCE([[{{from_date}}::date,]] CURRENT_DATE - interval '30 day')::date,
    COALESCE([[{{to_date}}::date,]] CURRENT_DATE)::date,
    interval '1 day'
  )::date AS day
)
SELECT
  to_char(d.day, 'YYYY-MM-DD') AS date,
  COUNT(c.id)::int AS count
FROM days d
LEFT JOIN campagnes c
  ON upper(c.statut::text) IN ('ACTIVE', 'EN_COURS')
  AND c."createdAt"::date <= d.day
  AND c."dateFin"::date >= d.day
GROUP BY d.day
ORDER BY d.day;


-- ============================================================
-- Story 2 - Montant total collecte sur une periode (Projet 2)
-- Result shape: date | amount_eur
-- ============================================================
WITH days AS (
  SELECT generate_series(
    COALESCE([[{{from_date}}::date,]] CURRENT_DATE - interval '30 day')::date,
    COALESCE([[{{to_date}}::date,]] CURRENT_DATE)::date,
    interval '1 day'
  )::date AS day
)
SELECT
  to_char(d.day, 'YYYY-MM-DD') AS date,
  COALESCE(SUM(t.montant), 0)::numeric(12,2) AS amount_eur
FROM days d
LEFT JOIN transaction t
  ON t."createdAt"::date = d.day
  AND t.statut = 'captured'
GROUP BY d.day
ORDER BY d.day;


-- ============================================================
-- Story 3 - Taux de succes global (Projet 1)
-- Result shape: total_campaigns | successful | failed | active | success_rate_percent
-- ============================================================
WITH stats AS (
  SELECT
    COUNT(*)::int AS total_campaigns,
    COUNT(*) FILTER (WHERE upper(statut::text) IN ('REUSSIE', 'SUCCESSFUL'))::int AS successful,
    COUNT(*) FILTER (WHERE upper(statut::text) IN ('ECHOUEE', 'FAILED'))::int AS failed,
    COUNT(*) FILTER (WHERE upper(statut::text) IN ('ACTIVE', 'EN_COURS'))::int AS active
  FROM campagnes
)
SELECT
  total_campaigns,
  successful,
  failed,
  active,
  ROUND(
    CASE
      WHEN (successful + failed) = 0 THEN 0
      ELSE (successful::numeric / (successful + failed)::numeric) * 100
    END,
    2
  ) AS success_rate_percent
FROM stats;


-- ============================================================
-- Story 4 - Nombre total de contributions sur une periode (Projet 2)
-- Result shape: date | count
-- ============================================================
WITH days AS (
  SELECT generate_series(
    COALESCE([[{{from_date}}::date,]] CURRENT_DATE - interval '30 day')::date,
    COALESCE([[{{to_date}}::date,]] CURRENT_DATE)::date,
    interval '1 day'
  )::date AS day
)
SELECT
  to_char(d.day, 'YYYY-MM-DD') AS date,
  COUNT(c.id)::int AS count
FROM days d
LEFT JOIN contribution c
  ON c.timestamp::date = d.day
GROUP BY d.day
ORDER BY d.day;


-- ============================================================
-- Story 5 - Nombre moyen de contributions par campagne (Projet 1 + Projet 2)
-- Result shape: total_contributions | total_campaigns | average
-- ============================================================
WITH params AS (
  SELECT
    COALESCE([[{{from_date}}::date,]] CURRENT_DATE - interval '30 day')::date AS from_date,
    COALESCE([[{{to_date}}::date,]] CURRENT_DATE)::date AS to_date
),
contributions_in_period AS (
  SELECT COUNT(*)::int AS total_contributions
  FROM contribution c
  CROSS JOIN params p
  WHERE c.timestamp::date BETWEEN p.from_date AND p.to_date
),
campaigns_p1_active_in_period AS (
  SELECT COUNT(*)::int AS total_campaigns
  FROM campagnes c
  CROSS JOIN params p
  WHERE upper(c.statut::text) IN ('ACTIVE', 'EN_COURS')
    AND c."createdAt"::date <= p.to_date
    AND c."dateFin"::date >= p.from_date
),
campaigns_p2_active_in_period AS (
  SELECT COUNT(*)::int AS total_campaigns
  FROM campagne c
  CROSS JOIN params p
  WHERE upper(c.statut) IN ('ACTIVE', 'EN_COURS')
    AND c."dateEcheance"::date >= p.from_date
),
campaigns_total AS (
  SELECT (p1.total_campaigns + p2.total_campaigns)::int AS total_campaigns
  FROM campaigns_p1_active_in_period p1
  CROSS JOIN campaigns_p2_active_in_period p2
)
SELECT
  ci.total_contributions,
  ct.total_campaigns,
  ROUND(
    CASE
      WHEN ct.total_campaigns = 0 THEN 0
      ELSE ci.total_contributions::numeric / ct.total_campaigns::numeric
    END,
    2
  ) AS average
FROM contributions_in_period ci
CROSS JOIN campaigns_total ct;


-- ============================================================
-- Story 6 - Montant moyen par contribution (Projet 2)
-- Result shape: total_amount_eur | total_contributions | average_eur
-- ============================================================
WITH base AS (
  SELECT
    COALESCE(SUM(c.montant), 0)::numeric(12,2) AS total_amount_eur,
    COUNT(*)::int AS total_contributions
  FROM contribution c
  WHERE c.timestamp::date BETWEEN
    COALESCE([[{{from_date}}::date,]] CURRENT_DATE - interval '30 day')::date
    AND COALESCE([[{{to_date}}::date,]] CURRENT_DATE)::date
)
SELECT
  total_amount_eur,
  total_contributions,
  ROUND(
    CASE
      WHEN total_contributions = 0 THEN 0
      ELSE total_amount_eur / total_contributions::numeric
    END,
    2
  ) AS average_eur
FROM base;
