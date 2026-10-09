# Simulator — Laboratorio de procesos

Aplicación nativa en Godot 4.7 para explorar visualmente el canon de Garlia y consultar el motor físico de Supabase.

## Laboratorios incluidos

- **Procesos:** catálogo canónico, entradas, transformaciones, salidas, conservación, leyes cuantitativas, fórmulas, variables requeridas y modelos de resolución.
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

### Calcular una demanda de Eterium

Abre **Procesos**, selecciona un proceso que tenga un Oris activo y revisa la ley y las magnitudes requeridas que muestra la interfaz. Escribe un objeto JSON con las variables físicas que necesita esa ley. Escoge el arquetipo temporal y define k, duración y práctica. El resultado detallará la resolución física, el coste de organización, el coste temporal, el Eterium estable y la liberación necesaria.

Los procesos sin ley, contexto suficiente o vínculo activo mostrarán el estado que devuelva Supabase; la interfaz no sustituye la ley que falta.

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
