# Arquitectura interactiva · Práctica 03

[Abre el diagrama](../arquitectura.html) en un navegador. HTML autónomo generado con Archify a partir del código actual de `lib/`.

## Componentes y relaciones

- `MyApp` registra `ChatProvider` mediante `ChangeNotifierProvider`, configura `AppTheme` y abre `ChatScreen`.
- `ChatScreen` contiene `MessageFieldBox` y la lista de mensajes. Envía texto mediante `sendMessage` y observa el estado con `context.watch<ChatProvider>()`.
- `ChatProvider` mantiene `List<Message>` en memoria, notifica cambios y controla el desplazamiento. Solo consulta el helper si el texto termina en `?`; captura errores para mostrar un mensaje de fallo.
- `GetYesNoAnswer` selecciona localmente yes/no/maybe con probabilidades 40/40/20, consulta por HTTPS la API yesno.wtf con `force`, valida el JSON y retorna un `Message`. Timeout: 15 segundos.
- `Message` define texto, URL opcional de imagen, remitente y hora de envío.
- `MyMessageBubble` y `HerMessageBubble` delegan en `MessageBubble`, que presenta texto, GIF opcional y hora HH:mm. El GIF se descarga con `Image.network` desde la URL recibida.

Las flechas muestran relaciones entre componentes, no una secuencia temporal. La inyección del provider y la devolución de la respuesta se explican en las tarjetas para conservar un mapa legible. El modelo y el helper se ejecutan dentro de Flutter; no hay servidor propio ni base de datos. La descarga del GIF y el avatar son detalles de presentación que no se dibujan como servicios independientes.

## Interacción

Selecciona componentes para explorar relaciones; usa búsqueda, zoom, Light / Dark, Present y Export. El contenido está en español; la interfaz fija y el atributo HTML lang de esta versión de Archify usan inglés.

## Entrega y evidencia

- [HTML interactivo](../arquitectura.html)
- [Especificación editable](chat.architecture.json)
- [Recibo de entrega y hashes SHA-256](entrega.json)
- [Evidencia automatizada en Chrome](../arquitectura.visual-check.json)
- [Capturas](../arquitectura.visual-check.html)
- [Revisión visual](revision-visual.json)

Tipo: architecture. Validación showcase: 9/9, cero errores y advertencias. Navegador: aprobado en 1440×900, 1600×1000, 1920×1080 y 2048×1320, sin desbordamiento. Revisión de capturas: aprobada en tema claro grande y oscuro de laptop. Una ronda de corrección de etiquetas. Archivo local, sin publicación.
