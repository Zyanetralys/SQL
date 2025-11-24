Día 2 – Operación SQL Avanzado: JOINs y Relaciones

🎯 Objetivos del día

- Comprender y usar INNER JOIN, LEFT JOIN y RIGHT JOIN.
- Combinar datos de varias tablas para análisis operativo.
- Realizar consultas complejas para descubrir asignaciones y roles.
- Practicar pensamiento táctico: filtrar y priorizar información relevante.

🔹 Misión 1: Agentes asignados a misiones

Escenario:
- Debes entregar la lista de agentes activos y las misiones a las que están asignados.

Ejercicio práctico:
- Usa INNER JOIN entre assignment y agents.
- Incluye la columna role de la asignación.

Comando:
```
SELECT a.codename, m.title, ass.role
FROM assignment ass
JOIN agents a ON ass.agent_id = a.agent_id
JOIN missions m ON ass.mission_id = m.mission_id
WHERE a.active = true;
```

Interrogatorio sorpresa:

- ¿Qué pasaría si un agente activo no tiene misión asignada?
- ¿Cómo lo mostrarías igualmente?

🔹 Misión 2: Misiones completas con todos los agentes

Escenario:
Algunas misiones no tienen agentes asignados aún. Nirith necesita la lista completa de misiones y los codenames si existen.

Ejercicio práctico:
- Usa LEFT JOIN para asegurar que todas las misiones aparezcan.
- Incluye codename de agentes si existen.

Comando:
```
SELECT m.mission_id, m.title, a.codename
FROM missions m
LEFT JOIN assignment ass ON m.mission_id = ass.mission_id
LEFT JOIN agents a ON ass.agent_id = a.agent_id;
```

Interrogatorio sorpresa:
- ¿Qué diferencia hay entre INNER JOIN y LEFT JOIN?
- ¿Qué sucede si cambias LEFT JOIN por RIGHT JOIN?

🔹 Misión 3: Contar agentes por misión

Escenario:
- La jefa quiere saber cuántos agentes hay en cada misión activa.

Ejercicio práctico:
- Agrupa por mission_id y title.
- Cuenta el número de agentes asignados.
- Ordena por número de agentes descendente.

Comando:
```
SELECT m.title, COUNT(a.agent_id) AS n_agents
FROM missions m
LEFT JOIN assignment ass ON m.mission_id = ass.mission_id
LEFT JOIN agents a ON ass.agent_id = a.agent_id
WHERE m.status = 'active'
GROUP BY m.mission_id, m.title
ORDER BY n_agents DESC;
```
Interrogatorio sorpresa:
- ¿Qué pasaría si usas INNER JOIN en lugar de LEFT JOIN para esta consulta?
- ¿Cómo incluirías solo agentes activos?

🔹 Reto sorpresa del día – Descubrir agentes sin asignación
- “Quiero que me entregues los codenames de todos los agentes activos que NO tienen misión asignada.”

Comando:
```
SELECT codename
FROM agents a
WHERE active = true
AND agent_id NOT IN (SELECT agent_id FROM assignment);
```
Interrogatorio sorpresa:
- ¿Se puede hacer esto con LEFT JOIN y IS NULL?
- ¿Cuál es más eficiente: NOT IN o LEFT JOIN + IS NULL en bases grandes?

🔹 Debrief del día
- ✅ Comprendes INNER y LEFT JOIN
- ✅ Sabes contar agentes por misión
- ✅ Puedes identificar agentes sin asignación
- ✅ Puedes responder preguntas de eficiencia y filtrado
Riesgos de no filtrar correctamente agentes inactivos.

Cómo estructurarías una consulta para un informe rápido para Nirith.
