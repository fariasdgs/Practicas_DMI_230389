# Modelo Archify · Widgets App

## Diagramas

- [Modelo de la aplicación](https://fariasdgs.github.io/Practicas_DMI_230389/practica05/): Home, menú, rutas y los cuatro grupos de pantallas.
- [Arquitectura](https://fariasdgs.github.io/Practicas_DMI_230389/practica05/arquitectura.html): inicio, navegación, pantallas, estado local, Riverpod, tema e imágenes en red.
- Fuentes editables: [modelo](widgets-modelo.architecture.json) y [arquitectura](widgets-arquitectura.architecture.json).
- Recibos con hashes SHA-256 y tamaños: [modelo](delivery.json) y [arquitectura](delivery-arquitectura.json).

## Cómo presentarlo

1. Empieza por el modelo: Home, menú lateral y GoRouter.
2. Recorre las tres filas: visuales, interacción, movimiento, Riverpod y tema.
3. Pasa a la arquitectura y sigue `routerConfig`, la construcción de pantallas y las dos formas de estado (`setState` y Riverpod).
4. Cierra con las tarjetas inferiores: capas, estado y límites.

## Verificación

- Tipo: arquitectura, perfil showcase.
- Calidad: **9/9 comprobaciones**, cero errores y cero advertencias en ambos diagramas.
- Navegador: `visual-check` aprobado en 1440×900 y 2048×1320, tema claro y oscuro. Los resultados están en `docs/practica05/*.visual-check.json`.
- Revisión visual: se revisaron las capturas clara del modelo y oscura de la arquitectura a 1440×900.
- El contenido está en español; los controles del visor y el atributo de idioma del HTML usan inglés.

El HTML está en `docs/practica05/` y se publica desde `main` con la carpeta `docs/`.
