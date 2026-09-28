# Modelo interactivo · Yes, No, Maybe

[Abre el diagrama](../arquitectura.html) en Chrome, Safari u otro navegador. El HTML es autónomo y se puede copiar a otra computadora sin instalar Flutter. En GitHub, descarga el archivo antes de abrirlo si aparece como código fuente.

## Recorrido para exponer

1. **Mensaje y estado.** Explica que `MyApp` registra `ChatProvider`. El usuario escribe desde `MessageFieldBox`; `sendMessage` elimina espacios, descarta mensajes vacíos y guarda el mensaje en memoria. Un texto sin `?` aparece en pantalla, pero no consulta la API.
2. **Probabilidad y API.** Si termina en `?`, `Random.nextInt(100)` selecciona Sí (0–39), No (40–79) o Tal Vez (80–99). `force` pide a yesno.wtf el GIF de esa categoría. Son probabilidades independientes, no cuotas exactas cada diez preguntas.
3. **Respuesta y hora.** Se valida el JSON, se traduce la categoría al español y se crea `Message` con `sentAt`. `herReply` agrega la respuesta y llama a `notifyListeners`. `ChatScreen` escucha mediante `context.watch`; `MessageBubble` presenta texto, GIF y hora local fija. El provider desplaza el chat al último mensaje.
4. **Cierra con los retos.** Las tres tarjetas inferiores resumen el ícono personalizado, la distribución 40/40/20 y la hora en las burbujas.

El mapa enfatiza el recorrido de una pregunta respondida correctamente. La actualización inmediata del mensaje propio, los avisos por error y el desplazamiento se explican en las vistas y tarjetas; no son conexiones adicionales dibujadas. Todo el código salvo la API externa se ejecuta dentro de la app Flutter. No hay servidor propio ni base de datos.

## Controles útiles

- Selecciona uno de los tres capítulos superiores para resaltar esa parte del recorrido.
- Haz clic en un componente para explorar sus relaciones.
- Usa **Light / Dark** para cambiar de tema.
- Usa **Live / Still** para activar o detener el recorrido animado.
- Usa **Present** para el modo de presentación.
- Usa los controles de zoom para leer los nombres del código en detalle.
- **Export** ofrece formatos de imagen y SVG; la grabación WebM depende del soporte del navegador.
- **Escape** permite salir de los paneles de exploración.

La explicación está escrita en español. Esta versión de Archify ofrece su interfaz fija en inglés o chino; se conserva el inglés para los controles y el atributo `<html lang>`.

## Relación con los archivos reales

| Elemento del mapa | Código |
| --- | --- |
| Arranque de la app | [main.dart](../../lib/main.dart) |
| Escribir y enviar | [message_field_box.dart](../../lib/presentation/widgets/shared/message_field_box.dart) |
| Estado de la conversación | [chat_provider.dart](../../lib/presentation/providers/chat_provider.dart) |
| Elegir, consultar y validar | [get_yes_no_answer.dart](../../lib/config/helpers/get_yes_no_answer.dart) |
| Crear respuesta con hora | [message.dart](../../lib/domain/entities/message.dart) |
| Actualizar la pantalla | [chat_screen.dart](../../lib/presentation/chat/chat_screen.dart) |
| Mostrar la conversación | [message_bubble.dart](../../lib/presentation/widgets/chat/message_bubble.dart) |
| Ícono personalizado | [app_icon.png](../../assets/icon/app_icon.png) |

## Archivos de entrega

- [HTML interactivo](../arquitectura.html).
- [JSON editable](chat.architecture.json).
- [Recibo de validación y entrega](entrega.json).
- [Evidencia automatizada en navegador](../arquitectura.visual-check.json).
- [Capturas en claro y oscuro](../arquitectura.visual-check.html).
- [Registro de revisión visual](revision-visual.json).

El resultado permanece dentro de `Practica03/yes_no_app`; el modelo anterior del contador no se reemplazó. El archivo es local y todavía no se ha publicado en GitHub Pages.
