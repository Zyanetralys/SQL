# Día 1 – Operación SQL Básico: Reconocimiento de Base de Datos

## 🎯 Objetivos del día
1. Comprender estructura de tablas y relaciones.
2. Ejecutar consultas SELECT simples.
3. Aprender filtrado básico con `WHERE`.
4. Registrar hallazgos y resultados como agente HUMINT en misión.

---

## 🔹 Misión 1: Reconocer agentes activos

**Escenario:**  
Eres la analista asignada a la unidad. Necesitas identificar todos los agentes activos en tu base de datos para reportar.

**Comando base:**
```sql
SELECT * FROM agents;
```

Observa la estructura: columnas, tipos, valores nulos.

Evalúa: ¿qué columna identifica unívocamente a cada agente? → agent_id

Tarea:

Filtra solo agentes activos (active = true).

Muestra solo codename y rank.

Respuesta esperada:


```
SELECT codename, rank
FROM agents
WHERE active = true;
```

Interrogatorio sorpresa:
¿Qué pasa si ejecutas SELECT codename, rank WHERE active = true;?
¿Qué columna usarías para ordenar por antigüedad de reclutamiento?

🔹 Misión 2: Misiones activas
Escenario:
Debes entregar la lista de misiones actualmente activas para priorizar recursos.

Ejercicio práctico:

Selecciona mission_id y title de misiones status = 'active'.

Ordena por start_date ascendente.

Respuesta esperada:

```
SELECT mission_id, title
FROM missions
WHERE status = 'active'
ORDER BY start_date ASC;
```

Interrogatorio sorpresa:

¿Qué función usarías para contar cuántos agentes están asignados a cada misión activa?

¿Qué diferencias hay entre WHERE y HAVING?

🔹 Misión 3: Registro y reporte
Escenario:
Registrarás los hallazgos en logs como si fueras parte de HUMINT operando en terreno.

Ejercicio práctico:

Inserta un log: “Analista completó reconocimiento de agentes activos.”

Asocia con agent_id = 1 y mission_id = 1.

Comando operativo:

```
INSERT INTO logs (mission_id, agent_id, message)
VALUES (1, 1, 'Analista completó reconocimiento de agentes activos.');
```

Interrogatorio sorpresa:

¿Qué pasaría si olvidas mission_id que es FK?

¿Cómo evitarías errores de FK en producción?

🔹 Reto sorpresa del día
“Quiero que me entregues solo codenames de agentes activos que hayan sido reclutados después del 01-01-2025, ordenados por rango descendente. Sin fallo.”

Comando:

```
SELECT codename
FROM agents
WHERE active = true AND recruited_date > '2025-01-01'
ORDER BY rank DESC;
```

🔹 Debrief del día

- ✅ Entiendes SELECT básico
- ✅ Sabes filtrar con WHERE
- ✅ Puedes ordenar resultados
- ✅ Insertas registros en logs
- ✅ Puedes responder preguntas sorpresa
  
- ¿Cuál fue la columna más crítica hoy y por qué?

- ¿Qué errores podrían arruinar la misión si no los controlas?
