# Arquitectura interactiva · Widgets App

[Abrir el diagrama en GitHub Pages](https://fariasdgs.github.io/Practicas_DMI_230389/practica05/) · [HTML local](../arquitectura.html)

Diagrama de tipo `architecture`, generado con Archify y basado en la revisión `fad7d84cc78fa5435f45ae0670ec469159d0fb9c`. Cada uno de los nueve componentes incluye una referencia al código verificada por la herramienta.

## Cómo explorarlo

1. Abre el HTML en un navegador.
2. Selecciona una vista: inicio y navegación, tema compartido o estado con Riverpod.
3. Usa la búsqueda para localizar componentes y el zoom para ampliar etiquetas.
4. Selecciona un componente para consultar sus relaciones y su archivo de origen.
5. Utiliza los controles de tema, presentación y exportación del visor.

El contenido está en español; Archify utiliza inglés para los controles fijos y el atributo `lang` del HTML. El visor funciona sin instalar Flutter; los enlaces al repositorio necesitan internet.

## Alcance y lectura

- `MainApp` configura `MaterialApp.router` dentro de `ProviderScope`.
- `GoRouter` define once rutas: inicio y diez ejemplos.
- `HomeScreen` construye el menú a partir de `appMenuItems`.
- `ThemeNotifier` conserva un `AppTheme`; `MainApp` observa sus cambios.
- `CounterScreen` observa e incrementa `counterProvider`, cuyo valor inicial es 5.
- El nodo «Ejemplos de widgets» agrupa las pantallas restantes; la relación con `picsum.photos` representa específicamente la descarga de fotografías de `InfiniteScrollScreen`.
- Los proveedores mantienen su estado en memoria. No hay un backend ni una base de datos en esta práctica.
- La vista sintetiza relaciones principales. Por ejemplo, el acceso a `ThemeNotifier` desde el contador y el selector de tema está explicado en el código y en el README principal, sin dibujar todas las dependencias cruzadas.
- Las imágenes del tutorial y `jar-loading.gif` siguen pendientes. El diagrama no afirma que esos recursos estén disponibles.

## Fuente y comprobantes

- `widgets-app.architecture.json`: especificación editable.
- `delivery-receipt.json`: hashes SHA-256, tamaños y validación del HTML entregado.
- `../arquitectura.visual-check.json`: resultado de la comprobación automática del navegador.
- `visual-review.json`: alcance de la revisión manual en Safari.

La entrega aprobó **9/9 comprobaciones showcase, con 0 errores y 0 advertencias de composición**. La revisión manual comprobó la presentación clara y oscura y el funcionamiento de las vistas guiadas en Safari. La prueba automática de cuatro tamaños de escritorio quedó omitida por ausencia de Chrome/Chromium. No se afirma haber medido contención en esos cuatro tamaños ni haber probado las exportaciones descargadas.

## Regeneración

Desde la raíz del repositorio, sustituye `RUTA_ARCHIFY` por la carpeta de la habilidad instalada:

```bash
node RUTA_ARCHIFY/bin/archify.mjs validate architecture Practica05/widgets_app/docs/archify/widgets-app.architecture.json --repo-root . --quality showcase --json
node RUTA_ARCHIFY/bin/archify.mjs deliver architecture Practica05/widgets_app/docs/archify/widgets-app.architecture.json Practica05/widgets_app/docs/arquitectura.html --repo-root . --quality showcase --json
node RUTA_ARCHIFY/bin/archify.mjs visual-check Practica05/widgets_app/docs/arquitectura.html --json
```

Si se cambia la revisión del código, hay que revisar también las referencias del modelo. La copia de publicación está en `docs/practica05/index.html`, desde la raíz del repositorio. Si regeneras el HTML, actualiza también esa copia para que el visor publicado coincida.
