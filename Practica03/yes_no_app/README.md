# Yes, No, Maybe · Chat con Flutter

Proyecto de la **Práctica 03: Chat con API de Respuestas Automáticas**, desarrollado para la asignatura **Desarrollo Móvil Integral**.

## Diagrama interactivo del proyecto

[Explorar el modelo Archify de Yes, No, Maybe](docs/arquitectura.html)

El modelo muestra el recorrido desde el envío de un mensaje hasta la respuesta con GIF y hora. Incluye tres vistas guiadas, selección de componentes, zoom, temas claro y oscuro, modo de presentación y exportación.

Para verlo localmente, abre `docs/arquitectura.html` en tu navegador. Es un archivo autónomo: no necesita ejecutar Flutter ni consultar la API. Si lo visitas desde GitHub y ves código, descarga el HTML y ábrelo en el navegador.

- [Guía para presentar el modelo](docs/archify/README.md).
- [Vista previa del diagrama](docs/arquitectura.visual-check.2048x1320.dark.png).
- [Especificación editable](docs/archify/chat.architecture.json).

El contenido está en español; los controles del visor y su atributo HTML de idioma usan inglés por las opciones disponibles en Archify.

## Descripción

La aplicación simula una conversación de chat en la que el usuario puede escribir mensajes y recibir respuestas automáticas cuando envía una pregunta terminada en **`?`**. Las respuestas posibles son **Sí**, **No** y **Tal Vez**, acompañadas de un GIF obtenido de la API de [yesno.wtf](https://yesno.wtf/).

La interfaz conserva el contacto **CBUM**, un tema en tonos morados y burbujas de conversación con la hora de cada mensaje. Los mensajes del usuario aparecen a la derecha y las respuestas a la izquierda, con una distribución similar a un chat de WhatsApp.

El proyecto utiliza **Provider** para administrar el estado de la conversación y actualizar la pantalla al enviar o recibir mensajes.

## Objetivo

Desarrollar una aplicación de chat con Flutter y Dart que permita consumir una API, manejar operaciones asíncronas y actualizar la interfaz mediante un administrador de estado, incorporando respuestas con probabilidades definidas, un ícono personalizado y la hora de envío de los mensajes.

### Objetivos específicos

- Construir una interfaz de chat con widgets reutilizables.
- Administrar la lista de mensajes mediante `ChangeNotifier` y `Provider`.
- Consultar una API utilizando solicitudes HTTP y procesar respuestas JSON.
- Responder únicamente a los mensajes terminados en `?`.
- Implementar una distribución de 40% Sí, 40% No y 20% Tal Vez.
- Mostrar el GIF correspondiente a la respuesta elegida.
- Registrar y presentar la hora de cada mensaje.
- Personalizar el ícono de la aplicación.
- Manejar fallos de conexión y validar el funcionamiento con pruebas.

## Funcionalidades

| Función | Comportamiento |
| --- | --- |
| Enviar mensajes | Permite enviar desde el botón o la acción de envío del teclado |
| Detectar preguntas | Consulta la API cuando el texto termina en `?`, ignorando espacios al final |
| Evitar mensajes vacíos | Ignora textos vacíos o que contienen únicamente espacios |
| Responder automáticamente | Selecciona Sí, No o Tal Vez con probabilidades de 40%, 40% y 20% |
| Mostrar GIF | Incluye en la burbuja la imagen animada de la categoría seleccionada |
| Mostrar hora | Presenta la hora local de cada mensaje en formato `HH:mm` |
| Actualizar el chat | Notifica a los widgets cuando cambia la lista de mensajes |
| Desplazar la conversación | Mueve la lista hacia el último mensaje |
| Controlar el teclado | Conserva el foco después de enviar y lo retira al tocar fuera del campo |
| Manejar errores | Muestra un aviso si falla la consulta o no se puede cargar el GIF |

La conversación se mantiene **en memoria durante la ejecución**. No se guarda en una base de datos ni se recupera después de reiniciar la aplicación. Las respuestas son aleatorias y no interpretan el significado de la pregunta.

## Retos de la práctica

### 1. Ícono personalizado

El ícono representa una burbuja blanca sobre fondo violeta con tres símbolos: una palomita verde para **Sí**, una cruz coral para **No** y un signo de interrogación dorado para **Tal Vez**.

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Ícono personalizado de Yes, No, Maybe" width="200">
</p>

El diseño se creó con asistencia de **ImageGen**. El archivo original está en [assets/icon/app_icon.png](assets/icon/app_icon.png) y la descripción utilizada para generarlo está en [assets/icon/prompt.txt](assets/icon/prompt.txt).

La herramienta `flutter_launcher_icons` genera los tamaños necesarios para **Android, iOS, web, Windows y macOS**, siguiendo la configuración de [flutter_launcher_icons.yaml](flutter_launcher_icons.yaml).

Para regenerarlos desde la carpeta de la app:

```bash
dart run flutter_launcher_icons
```

El cambio de ícono requiere detener y volver a ejecutar la aplicación; **hot reload no actualiza los recursos nativos**. Si el dispositivo conserva el ícono anterior en caché, reinstala la aplicación.

### 2. Distribución de respuestas 40/40/20

La lógica se encuentra en [get_yes_no_answer.dart](lib/config/helpers/get_yes_no_answer.dart). Se genera un número entero aleatorio de **0 a 99** mediante `Random.nextInt(100)`:

| Valor generado | Respuesta | Probabilidad | Parámetro enviado a la API |
| --- | --- | --- | --- |
| 0–39 | Sí | 40% | `force=yes` |
| 40–79 | No | 40% | `force=no` |
| 80–99 | Tal Vez | 20% | `force=maybe` |

La aplicación elige primero la categoría y después solicita su GIF mediante el parámetro `force` de la [API yesno.wtf](https://yesno.wtf/). Por ejemplo:

```text
GET https://yesno.wtf/api?force=maybe
```

Se valida que la categoría recibida coincida con la solicitada y que exista una URL de imagen. El texto se presenta en español y el GIF se muestra dentro de la misma burbuja.

**Estos porcentajes son probabilidades por pregunta.** No significa que cada diez preguntas produzcan exactamente cuatro Sí, cuatro No y dos Tal Vez. En una muestra pequeña pueden aparecer varias respuestas iguales seguidas.

Si la solicitud falla, la app muestra un aviso para volver a intentarlo. Ese aviso no cuenta como una respuesta Sí, No o Tal Vez.

### 3. Hora de envío en las burbujas

El modelo [Message](lib/domain/entities/message.dart) contiene el campo `sentAt`, que guarda el instante en el que se crea cada mensaje.

El widget [MessageBubble](lib/presentation/widgets/chat/message_bubble.dart) muestra la hora local en formato de 24 horas, por ejemplo **09:05** o **18:42**, con texto pequeño y alineado abajo a la derecha. La hora permanece fija aunque la pantalla se reconstruya.

Las burbujas tienen esquinas redondeadas, colores distintos para cada participante y una esquina inferior más pequeña que indica el lado de la conversación. El GIF, cuando existe, aparece entre el texto y la hora.

## Flujo de funcionamiento

1. El usuario escribe y envía un mensaje desde `MessageFieldBox`.
2. `ChatProvider` elimina los espacios al inicio y al final, y descarta mensajes vacíos.
3. Crea un `Message`, lo agrega a `messageList` y notifica a la pantalla.
4. Si el mensaje termina en `?`, solicita una respuesta a `GetYesNoAnswer`.
5. El helper elige la categoría con la distribución 40/40/20 y consulta la API.
6. La respuesta se convierte en un mensaje recibido con texto, GIF y hora.
7. El provider agrega el mensaje, actualiza la interfaz y desplaza la conversación hacia abajo.

Los mensajes que no terminan en `?` se muestran en el chat, pero no provocan una respuesta automática.

## Tecnologías utilizadas

| Tecnología | Uso en el proyecto |
| --- | --- |
| Flutter | Construcción de pantallas, formularios y burbujas |
| Dart | Modelos, lógica de selección y operaciones asíncronas |
| Material Design | Tema, componentes visuales e íconos de la interfaz |
| `provider` | Acceso al estado y reconstrucción de widgets al recibir cambios |
| `http` | Solicitudes a la API y clientes simulados en las pruebas |
| `dart:convert` | Conversión del JSON recibido |
| `dart:math` | Selección aleatoria de respuestas |
| `flutter_launcher_icons` | Generación de íconos nativos |
| `flutter_test` | Pruebas de lógica y de widgets |

Las versiones de las dependencias se declaran en [pubspec.yaml](pubspec.yaml).

## Estructura principal

```text
Practica03/yes_no_app/
├── assets/icon/
│   ├── app_icon.png
│   └── prompt.txt
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── helpers/get_yes_no_answer.dart
│   │   └── theme/app_theme.dart
│   ├── domain/entities/message.dart
│   └── presentation/
│       ├── chat/chat_screen.dart
│       ├── providers/chat_provider.dart
│       └── widgets/
│           ├── chat/
│           │   ├── message_bubble.dart
│           │   ├── my_message_bubble.dart
│           │   └── her_message_bubble.dart
│           └── shared/message_field_box.dart
├── test/
│   ├── chat_provider_test.dart
│   ├── get_yes_no_answer_test.dart
│   ├── message_bubble_test.dart
│   └── widget_test.dart
├── docs/retos.md
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── flutter_launcher_icons.yaml
├── pubspec.yaml
└── README.md
```

| Archivo o componente | Responsabilidad |
| --- | --- |
| `main.dart` | Inicia la app, registra `ChatProvider` y configura el tema y la pantalla inicial |
| `AppTheme` | Define la apariencia y el esquema de colores |
| `Message` | Representa texto, imagen opcional, remitente y hora del mensaje |
| `ChatProvider` | Administra mensajes, respuestas, notificaciones y desplazamiento |
| `GetYesNoAnswer` | Selecciona la respuesta y obtiene su GIF mediante HTTP |
| `ChatScreen` | Construye la pantalla y escucha los cambios del provider |
| `MyMessageBubble` y `HerMessageBubble` | Reciben los mensajes de cada participante y utilizan la burbuja compartida |
| `MessageBubble` | Dibuja el texto, el GIF opcional y la hora según el remitente |
| `MessageFieldBox` | Administra el campo de texto, el foco y el envío |

## Requisitos

- Flutter instalado y disponible en la terminal.
- Dart compatible con **`^3.13.2`**, según `pubspec.yaml`.
- Un editor como Visual Studio Code.
- Conexión a internet para instalar dependencias, consultar la API y cargar los GIF.
- Para Android: Android SDK y un emulador o dispositivo configurado.
- Para iOS: una Mac con Xcode y un simulador o dispositivo configurado.
- Para web: un navegador compatible, como Chrome.

## Instalación y ejecución

Desde la raíz de este repositorio:

```bash
cd Practica03/yes_no_app
flutter pub get
flutter devices
flutter run
```

Si ya abriste `yes_no_app` como carpeta de trabajo, ejecuta los comandos sin repetir `cd Practica03/yes_no_app`.

Para elegir un dispositivo concreto, utiliza el identificador mostrado por `flutter devices`:

```bash
flutter run -d ID_DEL_DISPOSITIVO
```

### Ejecutar en iPhone

Abre un simulador de iPhone y selecciónalo al ejecutar `flutter run`. Si trabajas desde VS Code, utiliza **Flutter: Select Device** en la paleta de comandos y después presiona **F5**.

Para abrir el proyecto nativo en Xcode, utiliza `ios/Runner.xcworkspace`.

### Ejecutar en Chrome

```bash
flutter run -d chrome
```

### Ver cambios durante el desarrollo

En la terminal donde corre Flutter:

| Tecla | Acción |
| --- | --- |
| `r` | Hot reload: actualiza la interfaz y conserva el estado cuando es posible |
| `R` | Hot restart: reinicia la app y la conversación |
| `q` | Detiene la ejecución |

## Verificación

Desde la carpeta `yes_no_app`:

```bash
flutter analyze
flutter test
```

Las pruebas incluyen:

- Envío de mensajes, rechazo de textos vacíos y respuesta solo a preguntas.
- Manejo de errores de consulta.
- Recorrido de los 100 valores posibles para verificar la distribución 40/40/20.
- Correspondencia entre la categoría seleccionada, el texto y la URL del GIF.
- Rechazo de respuestas incompletas o de una categoría incorrecta.
- Visualización de horas fijas y mensajes largos en pantallas pequeñas.
- Configuración del chat y envío mediante botón y teclado.

Las consultas HTTP de las pruebas se simulan para que los resultados no dependan de la conexión a internet.

### Prueba manual en el simulador

| Acción | Resultado esperado |
| --- | --- |
| Enviar `¿Hoy voy al gimnasio?` | Aparece el mensaje y después Sí, No o Tal Vez con su GIF |
| Enviar `¿Voy a pasar la materia?` | Se realiza una nueva selección aleatoria |
| Enviar `Hola` | Aparece el mensaje sin respuesta automática |
| Enviar únicamente espacios | No se agrega un mensaje |
| Revisar las burbujas | Cada mensaje muestra su hora abajo a la derecha |
| Enviar varios mensajes | La conversación se desplaza hacia el último mensaje |
| Ir al inicio del teléfono | Se observa el ícono personalizado de la app |

Para comprobar la compilación de iOS sin firma, en una Mac con Xcode:

```bash
flutter build ios --simulator --debug
```

## Aprendizajes de la práctica

El proyecto integra el manejo de estado con Provider, la comunicación con un servicio externo y el uso de `Future`, `async` y `await`. También aplica separación de responsabilidades entre modelos, acceso a datos y presentación, reutilización de widgets y pruebas automáticas de reglas de negocio e interfaz.

La explicación complementaria de los tres retos está en [docs/retos.md](docs/retos.md).

## Datos de la práctica

- **Práctica:** 03 — Yes, No, Maybe: Chat con API de Respuestas Automáticas.
- **Asignatura:** Desarrollo Móvil Integral.
- **Carrera:** Ingeniería en Desarrollo y Gestión de Software.
- **Alumno:** Al Farias Leyva.
- **Matrícula:** 230389.
- **Docente:** M.T.I. Marco A. Ramírez Hernández.
- **Periodo:** Septiembre - Diciembre 2026.

---

[Volver al README principal del repositorio](../../README.md)
