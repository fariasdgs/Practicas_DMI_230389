# Modelo Archify · Tikitoki

## Nuevos diagramas

- [Arquitectura actual](https://fariasdgs.github.io/Practicas_DMI_230389/practica04/arquitectura.html), basada en el código local: presentación, estado, datos locales/remotos y reproducción.
- [Propuesta de Clean Architecture](https://fariasdgs.github.io/Practicas_DMI_230389/practica04/clean-architecture.html), con contratos y casos de uso pendientes de implementar.
- Fuentes editables: [arquitectura actual](tikitoki-current.architecture.json) y [Clean Architecture](tikitoki-clean.architecture.json).
- Recibos con hashes SHA-256 y tamaños de especificación y HTML: [arquitectura actual](delivery-current.json) y [Clean Architecture](delivery-clean.json).

Ambos diagramas son de tipo `architecture` y pasan las **9/9 comprobaciones showcase**, sin errores ni advertencias. La comprobación de navegador quedó omitida porque Chrome/Chromium no está disponible; la revisión visual está pendiente. Los resultados se registran junto a los HTML en los archivos `*.visual-check.json`. El contenido está en español y los controles del visor usan inglés.

En la arquitectura actual, la caché de Pixabay se explica en la tarjeta de almacenamiento; se omite su flecha para mantener una vista general clara. El diagrama de Clean Architecture muestra dependencias del código y una propuesta, no una refactorización realizada.

## Modelo anterior

[**Abrir el modelo HTML local**](../../../../docs/practica04/index.html) · [Enlace de GitHub Pages](https://fariasdgs.github.io/Practicas_DMI_230389/practica04/)

Modelo de arquitectura basado en el código local de la Práctica 04. Presenta un recorrido de lectura desde el arranque hasta el video y sus elementos superpuestos. Las flechas resumen relaciones de carga, transformación y composición; la conversión de datos devuelve entidades al provider antes de que este notifique a la pantalla.

## Cómo presentarlo

1. Sigue la fila superior: inicio, catálogo y conversión de datos.
2. Continúa por la fila central de derecha a izquierda: pantalla, navegación y preparación del controlador.
3. Termina en la fila inferior: recurso local, reproducción e interfaz superpuesta.
4. Usa las tarjetas para explicar estado, ciclo de vida y Git LFS.

El visor permite cambiar el tema, ampliar, buscar, seleccionar componentes y exportar. El contenido está en español; los controles fijos y el atributo HTML de idioma usan inglés.

## Archivos

- [Especificación editable](tikitoki.architecture.json).
- [Recibo de entrega y revisión](delivery.json).
- [Comprobación automática de navegador](../../../../docs/practica04/index.visual-check.json).
- [Capturas en ambos temas](../../../../docs/practica04/index.visual-check.html).

## Verificación

- Tipo: arquitectura.
- Calidad: showcase, **9/9 comprobaciones**, cero errores y cero advertencias.
- Navegador: comprobado a 1440×900, 1600×1000, 1920×1080 y 2048×1320, sin desbordamientos.
- Revisión visual: capturas clara de 1440×900 y oscura de 2048×1320 inspeccionadas.
- Correcciones: dos ajustes de posición de etiquetas para evitar solapamientos.

Los hashes y tamaños del HTML y la especificación están en el recibo. La comprobación automática y la revisión visual se registran por separado.

## Publicación

El HTML está en `docs/practica04/index.html`, separado del modelo que ya existe en `docs/index.html`. Su URL de Pages se publica desde `main` y la carpeta `docs/`.
