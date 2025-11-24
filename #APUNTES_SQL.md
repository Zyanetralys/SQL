## 1) Objetivo y enfoque

Objetivo: que puedas entender, escribir y optimizar consultas SQL en bases relacionales (PostgreSQL / MySQL) para pentesting, análisis de datos o backends.
Enfoque: minimalismo militar — primero domina lo esencial, luego subes la dificultad. Mucha práctica real sobre un esquema de ejemplo.

## 2) Conceptos básicos

Base de datos (DB): contenedor de tablas.

Tabla: fila(s) = registros; columnas = atributos.

Registro / fila: una entrada.

Columna / campo: tipo de dato (INT, VARCHAR, DATE, BOOLEAN, FLOAT, etc.).

Primary Key (PK): identificador único.

Foreign Key (FK): referencia a otra tabla.

Índice: estructura para acelerar búsquedas.

DDL: Data Definition Language — CREATE, ALTER, DROP.

DML: Data Manipulation Language — SELECT, INSERT, UPDATE, DELETE.

ACID / Transacción: atomicidad, consistencia, aislamiento, durabilidad — BEGIN; COMMIT; ROLLBACK;.

## 3) Esquema de ejemplo

Imagina una DB de operaciones: operaciones con tablas: agents, missions, assets, logs.

DDL (Postgres / MySQL compatible — algunos tipos pueden variar):

-- Tabla agents
CREATE TABLE agents (
  agent_id SERIAL PRIMARY KEY,      -- SERIAL en Postgres; AUTO_INCREMENT en MySQL
  codename VARCHAR(50) NOT NULL,
  real_name VARCHAR(100),
  rank VARCHAR(30),
  active BOOLEAN DEFAULT true,
  recruited_date DATE
);

-- Tabla missions
CREATE TABLE missions (
  mission_id SERIAL PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  status VARCHAR(30) DEFAULT 'planning', -- planning, active, completed, aborted
  start_date DATE,
  end_date DATE
);

-- Tabla assets
CREATE TABLE assets (
  asset_id SERIAL PRIMARY KEY,
  asset_name VARCHAR(100),
  type VARCHAR(50),
  location VARCHAR(100)
);

-- Tabla assignment (many-to-many agent<->mission)
CREATE TABLE assignment (
  agent_id INT NOT NULL,
  mission_id INT NOT NULL,
  role VARCHAR(60),
  PRIMARY KEY (agent_id, mission_id),
  FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
  FOREIGN KEY (mission_id) REFERENCES missions(mission_id)
);

-- Tabla logs
CREATE TABLE logs (
  log_id SERIAL PRIMARY KEY,
  mission_id INT,
  agent_id INT,
  log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  message TEXT,
  FOREIGN KEY (mission_id) REFERENCES missions(mission_id),
  FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

## 4) SELECT: la instrucción más vital

Sintaxis básica:

SELECT columnas
FROM tabla
WHERE condiciones
GROUP BY columnas_agrupadas
HAVING condicion_agrupada
ORDER BY columna [ASC|DESC]
LIMIT n OFFSET m;


Ejemplos y explicación:

Seleccionar todo:

SELECT * FROM agents;


Seleccionar columnas específicas:

SELECT codename, rank FROM agents;


Filtrar (condición booleana):

SELECT codename FROM agents WHERE active = true AND rank = 'senior';


Comparadores: =, <>, !=, >, <, >=, <=, IS NULL, IS NOT NULL

Patrones: LIKE '%hir%' (case-sensitive en algunos motores), ILIKE (Postgres para case-insensitive).

IN y BETWEEN:

SELECT * FROM missions WHERE status IN ('active','planning');
SELECT * FROM missions WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31';

## 5) Funciones agregadas y GROUP BY

COUNT(*), SUM(col), AVG(col), MIN(col), MAX(col).

Ejemplo: contar agentes activos por rango:

SELECT rank, COUNT(*) AS n_agents
FROM agents
WHERE active = true
GROUP BY rank
ORDER BY n_agents DESC;


Regla: todo en SELECT que no es agregación debe estar en GROUP BY.

HAVING filtra después de agrupar:

SELECT rank, COUNT(*) AS n_agents
FROM agents
GROUP BY rank
HAVING COUNT(*) >= 3;

## 6) JOINs — unión entre tablas

Tipos:

INNER JOIN: devuelve filas con match en ambas tablas.

LEFT JOIN / LEFT OUTER JOIN: todas las filas de la izquierda, con match si existe.

RIGHT JOIN: opuesto del LEFT (menos usado).

FULL JOIN: todas filas de ambas tablas (no disponible en MySQL sin UNION).

CROSS JOIN: producto cartesiano.

Ejemplo: obtener agentes asignados a misiones:

SELECT a.codename, m.title, ass.role
FROM assignment ass
JOIN agents a ON ass.agent_id = a.agent_id
JOIN missions m ON ass.mission_id = m.mission_id
WHERE m.status = 'active';


LEFT JOIN ejemplo (mostrar misiones aunque no tengan agentes):

SELECT m.mission_id, m.title, a.codename
FROM missions m
LEFT JOIN assignment ass ON m.mission_id = ass.mission_id
LEFT JOIN agents a ON ass.agent_id = a.agent_id;

7) Subconsultas (subqueries) y CTEs (Common Table Expressions)

Subconsulta en WHERE:

SELECT codename FROM agents
WHERE agent_id IN (SELECT agent_id FROM assignment WHERE mission_id = 5);


CTE (más legible; Postgres/MySQL 8+):

WITH active_missions AS (
  SELECT mission_id FROM missions WHERE status = 'active'
)
SELECT a.codename, m.title
FROM assignment ass
JOIN agents a ON ass.agent_id = a.agent_id
JOIN missions m ON ass.mission_id = m.mission_id
WHERE m.mission_id IN (SELECT mission_id FROM active_missions);

## 8) INSERT / UPDATE / DELETE (manipulación)

Insertar:

INSERT INTO agents (codename, real_name, rank, active, recruited_date)
VALUES ('ZYANETRALYS','María','operational', true, '2025-11-01');


Insertar múltiple:

INSERT INTO assets (asset_name, type, location)
VALUES ('Drone-X','drone','Sector 7'), ('Server-3','server','Bunker A');


Update:

UPDATE missions SET status = 'active' WHERE mission_id = 2;


Delete:

DELETE FROM logs WHERE log_time < '2024-01-01';


⚠️ Siempre haz SELECT antes de un UPDATE o DELETE para validar afectación. Usa BEGIN; ... ROLLBACK; en pruebas.

## 9) Transacciones y bloqueo

Patrón:

BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
-- o ROLLBACK si algo falla


En Postgres/MariaDB puedes usar SERIALIZABLE o REPEATABLE READ según necesidad. Importante para integridad en operaciones críticas.

## 10) Índices, performance y plan de ejecución

Índices aceleran búsquedas por columna; cuestan en inserts/updates.

Crear índice:

CREATE INDEX idx_agents_codename ON agents (codename);


Índices compuestos:

CREATE INDEX idx_assignment_agent_mission ON assignment (agent_id, mission_id);


Usa EXPLAIN (MySQL) o EXPLAIN ANALYZE (Postgres) para ver plan de ejecución y detectar full table scans.

Buenas prácticas:

Indexa columnas usadas en WHERE, JOIN y ORDER BY.

Evita SELECT * en producción.

Normaliza para evitar duplicación; desnormaliza solo por necesidad de performance.

Limita JOIN innecesarios; filtra temprano (WHERE antes de agrupar).

## 11) Normalización rápida (1NF, 2NF, 3NF)

1NF: columnas atómicas (no listas en un campo).

2NF: tablas con PK; no dependencias parciales.

3NF: eliminar dependencias transitivas; cada columna depende directamente de la PK.
Objetivo: integridad y facilidad de consultas. En rendimiento, a veces sacrificas normalización.

## 12) SQL avanzado (resumen operativo)

Window functions (OVER(), ROW_NUMBER(), RANK(), LEAD(), LAG()):

SELECT codename, rank,
       ROW_NUMBER() OVER (PARTITION BY rank ORDER BY recruited_date) AS rn
FROM agents;


Upsert (INSERT ... ON CONFLICT Postgres / INSERT ... ON DUPLICATE KEY UPDATE MySQL):

-- Postgres
INSERT INTO assets (asset_id, asset_name) VALUES (1,'X')
ON CONFLICT (asset_id) DO UPDATE SET asset_name = EXCLUDED.asset_name;


JSON columns (Postgres/MySQL): almacenar datos semi-estructurados.

Full Text Search (FTS) en Postgres (tsvector) o MySQL FULLTEXT.

Particionamiento de tablas para grandes volúmenes.

Materialized views (Postgres) para consultas costosas (recálculo manual o programado).

# 13) Diferencias rápidas entre motores (Postgres vs MySQL)

Postgres: más rico en funciones (CTE, window funcs, JSONB potente, RETURNING), fuerte en consistencia.

MySQL: más usado en web, más simple historically; InnoDB con transacciones, mejoras en versiones modernas.

Sintaxis muy similar para lo básico, divergen en features avanzadas y en tipos como SERIAL vs AUTO_INCREMENT.

## 14) Plan de entrenamiento — misiones diarias (8 semanas)

Semana 1 — Fundamentos

Día 1-2: DDL, crear tablas, tipos.

Día 3-4: SELECT, WHERE, filtros.

Día 5-7: INSERT, UPDATE, DELETE.

Semana 2 — Consultas y agrupaciones

GROUP BY, agregaciones, HAVING.

Semana 3 — JOINs y relaciones

INNER, LEFT, RIGHT, CROSS, práctica con schema.

Semana 4 — Subqueries y CTEs

CTEs, subconsultas correlacionadas.

Semana 5 — Indexación y performance

EXPLAIN, índices, optimización.

Semana 6 — Transacciones y seguridad

ACID, roles/privilegios (GRANT), backups.

Semana 7 — Avanzado

Window functions, JSON, upserts.

Semana 8 — Proyecto final

Modela una DB real, carga datos, resuelve 20 queries complejas y optimiza.

Cada día: teoría 30 min, práctica 60–90 min, reto sorpresa 30 min. Sin excusas.

## 15) Chuleta rápida (comandos)

SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT

JOIN (INNER/LEFT/RIGHT/FULL), ON

INSERT INTO ... VALUES (...)

UPDATE ... SET ... WHERE ...

DELETE FROM ... WHERE ...

CREATE TABLE, ALTER TABLE, DROP TABLE

CREATE INDEX, DROP INDEX

BEGIN, COMMIT, ROLLBACK

EXPLAIN [ANALYZE] <query>

WITH <cte> AS (...)

## 16) Ejercicios prácticos (con soluciones)

Ejercicio 1: listar codenames de agentes reclutados después del 2025-01-01 y que estén activos.
Solución:

SELECT codename FROM agents
WHERE recruited_date > '2025-01-01' AND active = true;


Ejercicio 2: contar misiones por estado, ordenadas desc.
Solución:

SELECT status, COUNT(*) AS n
FROM missions
GROUP BY status
ORDER BY n DESC;


Ejercicio 3: obtener top 3 agentes con más misiones asignadas.
Solución:

SELECT a.codename, COUNT(*) AS missions_count
FROM assignment ass
JOIN agents a ON ass.agent_id = a.agent_id
GROUP BY a.agent_id, a.codename
ORDER BY missions_count DESC
LIMIT 3;


Ejercicio 4 (avanzado): para cada misión activa, obtener el número de agentes asignados y el nombre del agente con role = 'lead' si existe.
Solución:

WITH counts AS (
  SELECT mission_id, COUNT(*) AS n_agents
  FROM assignment
  GROUP BY mission_id
),
leads AS (
  SELECT mission_id, MAX(CASE WHEN role = 'lead' THEN agent_id END) AS lead_agent_id
  FROM assignment
  GROUP BY mission_id
)
SELECT m.mission_id, m.title, coalesce(c.n_agents,0) AS n_agents, a.codename AS lead_codename
FROM missions m
LEFT JOIN counts c ON m.mission_id = c.mission_id
LEFT JOIN leads l ON m.mission_id = l.mission_id
LEFT JOIN agents a ON l.lead_agent_id = a.agent_id
WHERE m.status = 'active';
