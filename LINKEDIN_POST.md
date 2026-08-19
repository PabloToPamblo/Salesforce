# Contact Tracing - Formación.

---

🐛 Un bug de una sola línea que casi todo el mundo comete en su primer trigger de Apex (y cómo lo he resuelto de forma bulk-safe).

Contexto: en un proyecto de Contact Tracing sobre Salesforce, necesitaba mantener en cada `Account` un campo `Active_Contacts__c` (Number) con el total de `Contact` activos vinculados a esa cuenta.

La primera versión del trigger tenía la lógica invertida: el `else` estaba fuera del `if` que debía protegerlo, así que el primer contacto activo de una cuenta nunca se contaba, y los contactos inactivos sí generaban una entrada falsa en el mapa. Un clásico: el bug no está en la sintaxis, está en dónde pones las llaves.

Además, la primera versión solo cubría el `insert`. Pero en el mundo real los contactos también se actualizan (se desactivan, cambian de cuenta) y se borran — y en cada uno de esos casos el contador tiene que reaccionar igual.

Así que lo he reescrito para cubrir el ciclo completo:

✅ Insert — suma los contactos activos nuevos
✅ Update — detecta las transiciones reales comparando `Trigger.oldMap` vs `Trigger.new` (activo→inactivo, inactivo→activo, cambio de cuenta) y ajusta solo lo que cambió
✅ Delete — resta el contacto borrado si contaba como activo

Todo con un patrón bulk-safe: se acumulan los cambios netos por cuenta en un `Map<Id, Integer>` dentro del loop, y solo se hace una query y un `update` al final — nunca SOQL ni DML dentro de un bucle, que es de las primeras reglas que se aprenden (y se rompen) en Apex.

Si quieres montar esta funcionalidad en tu propio Org, solo necesitas dos campos:
- `Active__c` (Checkbox) en `Contact`
- `Active_Contacts__c` (Number) en `Account`

Código completo aquí 👉 [enlace al repo]

*Nota: es un ejemplo didáctico pensado para explicar el patrón, no un componente listo para producción tal cual — le faltaría, por ejemplo, protección contra recursión y tests unitarios.*

#Salesforce #Apex #CleanCode #ContactTracing #DesarrolloSalesforce
