# Simulator — Laboratorio de procesos

Aplicación nativa en Godot 4.7 para explorar visualmente el canon de Garlia y consultar el motor físico de Supabase.

## Espacios de trabajo

- **Wiki:** lectura del canon. Permite consultar fichas, fórmulas, leyes, relaciones y topologías; oculta las acciones de simulación y los controles que cambian estados.
- **Sandbox:** espacio experimental separado. Permite evaluar montajes IUM, calcular demanda de Eterium para procesos y preparar una copia de un objeto en una sesión Sandbox. Se puede ajustar su temperatura, evaluar un proceso contra el estado experimental y descartar la sesión. La entidad canónica del catálogo no se modifica.

## Laboratorios incluidos

- **Procesos:** catálogo canónico, entradas, transformaciones, salidas, conservación, leyes cuantitativas, fórmulas, variables requeridas y modelos de resolución. Cuando existe configuración funcional, también representa los IUM participantes, las uniones, la topología, el Oris principal y la demanda estructural de Eterium registrada.
- **Demanda de Eterium:** selecciona un proceso y un Oris realmente vinculado. Introduce el contexto físico como JSON y el simulador consulta la función RPC calcular_requerimiento_eterium_proceso_v1, que integra organización, demanda física, coste temporal y estabilización.
- **Oris / IUM:** consulta Oris, IUMs y partículas TASI; revisa topologías funcionales, composición de partículas, régimen de Garin y demanda estructural.
- **Montaje IUM experimental:** selecciona uno o más IUMs y mira la vista previa de sus salidas principales en el orden seleccionado. Después solicita simular_organizacion_ium_v1; el resultado expone salidas funcionales, uniones, procesos candidatos y ambigüedad. Los enlaces se envían como dirigidos.
- **Materia:** catálogos de elementos, compuestos, materiales y estructuras; propiedades y relaciones canónicas disponibles.
- **Cálculo de materia:** simula compuestos desde elementos y materiales desde compuestos mediante simular_compuesto_desde_elementos y simular_material_desde_compuestos.
- **Objetos y organismos:** consulta objetos físicos, materiales, geometrías, estructuras, sistemas y órganos biológicos.

## Ejecutar

1. Descarga o clona este repositorio.
2. Abre la carpeta del proyecto con Godot 4.7.
3. Ejecuta el proyecto con F6/F5 o el botón de ejecutar.
4. Se requiere conexión a Internet para consultar el canon actualizado.

## Usar el laboratorio

### Wiki y Sandbox

En **Wiki**, selecciona cualquier registro para leer su ficha. Las operaciones que calculan, montan o cambian estados permanecen ocultas/deshabilitadas. En **Sandbox**, puedes montar IUMs existentes para evaluarlos sin canonizar el resultado, calcular la demanda de Eterium de un proceso y crear una sesión experimental para un objeto. La temperatura se aplica a la copia Sandbox a través de `establecer_temperatura_sandbox`; no se escribe en `items`. Puedes evaluar un proceso con `resolver_ejecucion_proceso_sandbox_v1` y descartar la sesión al terminar.

La síntesis de un IUM nuevo a partir de partículas consumiendo Eterium y la inserción validada de ese IUM en un objeto todavía requieren un contrato/RPC canónico específico. Simulator no inventa ese coste ni persiste un IUM ficticio: actualmente el motor permite consultar IUMs existentes, evaluar montajes y preparar objetos experimentales.

### Calcular una demanda de Eterium

Abre **Procesos**, selecciona un proceso que tenga un Oris activo y revisa la ley y las magnitudes requeridas que muestra la interfaz. Escribe un objeto JSON con las variables físicas que necesita esa ley. Escoge el arquetipo temporal y define k, duración y práctica. El resultado detallará la resolución física, el coste de organización, el coste temporal, el Eterium estable y la liberación necesaria.

Los procesos sin ley, contexto suficiente o vínculo activo mostrarán el estado que devuelva Supabase; la interfaz no sustituye la ley que falta. El inspector también separa el estado del cálculo del estado/version de la configuración IUM: un cálculo resuelto no convierte una configuración propuesta en canon formal.

### Montar una organización IUM

Abre **Oris / IUM → IUMs**. Selecciona cada IUM del montaje con **Incluir en selección** y usa **Resolver en Supabase**. Las selecciones se conectan en orden mediante uniones dirigidas; el resultado no se guarda y sirve para explorar qué patrones funcionales reconoce el motor.

### Simular materia

En **Materia → Elementos**, selecciona dos o más elementos para pedir un compuesto. En **Compuestos**, selecciona dos o más compuestos para pedir una simulación de material. Las propias RPC identifican estas rutas como simulaciones sin enlaces o estructura real, por lo que sus resultados no se presentan como una creación canónica persistida.

## Seguridad y límites

La app usa únicamente una clave publishable de Supabase, apta para clientes públicos. No incluye service_role, claves secretas ni credenciales de usuario. Los catálogos se consultan en modo lectura; las operaciones POST son llamadas a funciones RPC de cálculo y no operaciones de escritura. Supabase sigue aplicando sus permisos y políticas RLS.

Si una tabla o vista no permite lectura por el Data API, la interfaz muestra el error correspondiente. Si Supabase responde con un arreglo vacío, la interfaz advierte que puede tratarse de un catálogo vacío o de filas limitadas por RLS; no deduce que el canon completo esté vacío. Los grafos son representaciones visuales de relaciones registradas, no un sustituto de las funciones de cálculo.

## Estructura

- scenes/main.tscn: escena principal.
- scripts/simulator.gd: interfaz, grafos, inspector y coordinación de solicitudes.
- scripts/supabase_config.gd: URL y clave publishable del proyecto.
