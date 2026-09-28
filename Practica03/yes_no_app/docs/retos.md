# Práctica 03 — Yes, No, Maybe

Los tres retos están implementados dentro de `Practica03/yes_no_app`.

## 1. Ícono personalizado

El original está en `assets/icon/app_icon.png`. Se generó con la herramienta integrada ImageGen: burbuja de chat blanca sobre violeta, con palomita verde, cruz coral y signo de interrogación dorado.

Configuración: `flutter_launcher_icons.yaml`. Incluye Android, iOS, web, Windows y macOS.

Para regenerar los tamaños nativos, desde `yes_no_app`:

```sh
flutter pub get
dart run flutter_launcher_icons
```

Detén y vuelve a ejecutar la app para ver el nuevo ícono; hot reload no actualiza los recursos nativos. Si el lanzador conserva el anterior, reinstala la app.

## 2. Respuestas 40% Sí, 40% No y 20% Tal Vez

En `lib/config/helpers/get_yes_no_answer.dart`, `Random.nextInt(100)` produce un entero de 0 a 99:

| Valores | Respuesta | Probabilidad |
| --- | --- | --- |
| 0–39 | Sí | 40% |
| 40–79 | No | 40% |
| 80–99 | Tal Vez | 20% |

La app solicita `https://yesno.wtf/api?force=yes`, `force=no` o `force=maybe`. El texto y el GIF vienen de la misma categoría, validada antes de construir el mensaje. Documentación: https://yesno.wtf/

Es una probabilidad independiente por pregunta, no una cuota exacta cada diez preguntas. El resultado observado se aproxima a esos porcentajes con muchas preguntas. Los errores de conexión se muestran como avisos, no como respuestas Sí/No/Tal Vez.

Solo se consulta la API al enviar un mensaje terminado en `?`; se ignoran espacios al final. Se requiere internet para recibir respuestas y cargar los GIF.

## 3. Hora en las burbujas

`Message.sentAt` guarda el instante de creación del mensaje. `MessageBubble` presenta la hora local en formato de 24 horas `HH:mm`, pequeña y alineada a la derecha dentro de la burbuja. No cambia al reconstruir la pantalla.

Los mensajes propios van a la derecha y los recibidos a la izquierda. El GIF forma parte de la misma burbuja que la respuesta y su hora.

## Verificación

```sh
flutter analyze
flutter test
flutter run
```

Las pruebas recorren los 100 valores de selección para comprobar 40/40/20, verifican la categoría del GIF, los errores HTTP, el envío por botón y teclado y las horas de las burbujas, incluidos mensajes largos en una pantalla pequeña. Las pruebas de API usan un cliente simulado para no depender de internet.

Prueba manual: envía `¿Hoy toca entrenar?`, comprueba respuesta, GIF y hora; después envía `Hola` y verifica que no llega una respuesta automática.
