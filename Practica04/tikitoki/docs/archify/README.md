# Modelo Archify · Tikitoki

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

El HTML está en `docs/practica04/index.html`, separado del modelo que ya existe en `docs/index.html`. Su URL de Pages estará disponible cuando se publique desde la rama configurada para servir `docs/`. Los archivos nuevos permanecen locales hasta su publicación.
