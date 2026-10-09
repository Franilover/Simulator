# Simulator — Laboratorio de procesos

Aplicación nativa hecha con Godot 4.7 para explorar visualmente el canon de Garlia y consultar los catálogos de Supabase.

## Qué incluye esta primera versión

- Catálogos de procesos, Oris, IUMs, partículas TASI, elementos, compuestos, materiales, estructuras, objetos y organismos.
- Grafo visual contextual para representar entradas, transformaciones, salidas y relaciones registradas.
- Inspector de cada entidad con sus datos canónicos, propiedades y vínculos disponibles.
- Cálculo de compuesto desde elementos y de material desde compuestos mediante funciones RPC ya existentes en Supabase.
- Estado de conexión, contadores y errores de lectura visibles en pantalla.

## Ejecutar

1. Abre la carpeta del proyecto con Godot 4.7.
2. Ejecuta el proyecto con F6/F5 o el botón de ejecutar.
3. Necesita conexión a Internet para consultar el canon actualizado.

## Seguridad y límites

La app usa únicamente una clave publishable de Supabase, apropiada para clientes públicos. No incluye service_role, claves secretas ni credenciales de usuario. Los catálogos se consultan en modo lectura; las únicas llamadas POST previstas son RPC de cálculo, no operaciones de escritura. Supabase sigue aplicando sus permisos y políticas RLS.

Si un catálogo no permite lectura o el Data API no lo expone, la interfaz muestra el error correspondiente. Un fallo de acceso no se interpreta como un catálogo canónico vacío. El grafo es una representación de relaciones registradas, no un sustituto de los cálculos del motor.

## Estructura

- scenes/main.tscn: escena principal.
- scripts/simulator.gd: interfaz, grafo, inspector y solicitudes.
- scripts/supabase_config.gd: URL y clave publishable del proyecto.
