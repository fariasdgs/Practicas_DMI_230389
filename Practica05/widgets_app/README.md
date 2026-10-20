# Widgets App · Componentes de Flutter y Material 3

Proyecto de la **Práctica 05: Widgets App**, desarrollado por **Al Farias Leyva · 230389** para la asignatura **Desarrollo Móvil Integral**.

## Diagrama interactivo del proyecto

[**Abrir la arquitectura interactiva de Widgets App**](docs/arquitectura.html)

El diagrama permite explorar el inicio de la aplicación, la navegación con GoRouter, el tema global y el contador con Riverpod. Incluye tres vistas guiadas, búsqueda, zoom, selección de componentes, temas claro y oscuro y exportación de imágenes o SVG.

Descarga o abre `docs/arquitectura.html` en un navegador para utilizar el visor; la vista de archivos de GitHub no ejecuta el HTML. Es un archivo autónomo y no necesita iniciar Flutter. Los enlaces al código apuntan a la revisión documentada del repositorio.

- [Fuente editable del diagrama](docs/archify/widgets-app.architecture.json).
- [Guía, alcance y validación](docs/archify/README.md).

El contenido del proyecto está en español. Los controles fijos del visor y el atributo de idioma del HTML utilizan inglés, según las opciones de Archify. El archivo está preparado para uso local; aún no está publicado en GitHub Pages.

## Descripción

La aplicación reúne ejemplos de widgets de Flutter en un menú principal llamado **Flutter + Material 3**. Cada opción abre una pantalla para explorar botones, tarjetas, indicadores de progreso, diálogos, animaciones, controles de selección y listas con desplazamiento infinito.

El proyecto también incorpora un tutorial introductorio, un contador administrado con **Riverpod** y un selector que cambia los colores y el modo claro u oscuro de toda la aplicación. La navegación entre pantallas se configura con **GoRouter**.

## Objetivo

Construir una aplicación de ejemplos con Flutter y Dart que permita practicar la composición de interfaces, la navegación entre pantallas y la administración del estado, utilizando componentes de Material 3.

### Objetivos específicos

- Organizar las pantallas, las rutas, el menú y el tema en archivos separados.
- Navegar mediante rutas definidas con `GoRouter`.
- Utilizar `StatelessWidget`, `StatefulWidget` y widgets consumidores de Riverpod.
- Actualizar controles locales mediante `setState`.
- Administrar el contador y la configuración del tema con proveedores.
- Mostrar mensajes temporales, diálogos e indicadores de progreso.
- Implementar animaciones, páginas deslizables y carga de elementos al desplazarse.
- Comprobar el comportamiento con el analizador y pruebas de widgets.

## Pantallas y funcionalidades

| Pantalla                     | Ruta             | Comportamiento                                                                     |
| ---------------------------- | ---------------- | ---------------------------------------------------------------------------------- |
| Inicio                       | `/`              | Presenta el menú con los diez ejemplos disponibles                                 |
| Riverpod Counter             | `/counter-river` | Inicia en 5, incrementa el valor y permite alternar el tema global                 |
| Botones                      | `/buttons`       | Muestra distintas variantes de botones de Material                                 |
| Tarjetas                     | `/cards`         | Presenta ejemplos de tarjetas y composición de contenido                           |
| Progress Indicators          | `/progress`      | Muestra progreso circular indeterminado y progreso circular y lineal controlado    |
| Snackbars y diálogos         | `/snackbars`     | Abre un aviso temporal, un diálogo de confirmación y la información de licencias   |
| Animated container           | `/animated`      | Cambia de forma animada el tamaño, el color y los bordes de un contenedor          |
| UI Controls + Tiles          | `/ui-controls`   | Incluye interruptores, selección de transporte y casillas de comidas               |
| Introducción a la aplicación | `/tutorial`      | Presenta tres páginas con las opciones Salir y Comenzar                            |
| InfiniteScroll y Pull        | `/infinite`      | Agrega imágenes al acercarse al final y permite actualizar arrastrando hacia abajo |
| Cambiar tema                 | `/theme-changer` | Permite seleccionar uno de nueve colores y alternar el modo claro u oscuro         |

### Estado y tema global

La aplicación inicia dentro de `ProviderScope`. `MainApp` observa `themeNotifierProvider` y aplica el resultado de `AppTheme.getTheme()` a `MaterialApp.router`.

- `counterProvider` conserva el valor del contador durante la ejecución.
- `themeNotifierProvider` administra el índice del color y el modo oscuro mediante `ThemeNotifier`.
- `colorListProvider` expone la paleta disponible para la pantalla de selección.
- El cambio de tema se refleja también al regresar a la pantalla principal.

Estos valores se mantienen en memoria: no se guardan en almacenamiento local y se restablecen al reiniciar la aplicación.

## Tecnologías utilizadas

Las versiones siguientes corresponden a las restricciones declaradas en [pubspec.yaml](pubspec.yaml).

| Tecnología           | Versión declarada | Uso                                                |
| -------------------- | ----------------- | -------------------------------------------------- |
| Flutter y Material 3 | SDK de Flutter    | Construcción de la interfaz y componentes visuales |
| Dart                 | `^3.13.2`         | Lógica, clases y operaciones asíncronas            |
| `go_router`          | `^18.0.2`         | Navegación y configuración de rutas                |
| `flutter_riverpod`   | `^3.4.3`          | Administración del estado del contador y del tema  |
| `animate_do`         | `^5.1.0`          | Animaciones de entrada y del indicador de carga    |
| `cupertino_icons`    | `^1.0.8`          | Biblioteca de íconos Cupertino                     |
| `flutter_test`       | SDK de Flutter    | Pruebas de widgets                                 |
| `flutter_lints`      | `^6.0.0`          | Reglas del analizador                              |

## Estructura principal

```text
Practica05/widgets_app/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── menu/menu_items.dart
│   │   ├── router/app_router.dart
│   │   └── theme/app.theme.dart
│   └── presentation/
│       ├── providers/
│       │   ├── counter_provider.dart
│       │   └── theme_provider.dart
│       ├── screens/
│       │   ├── animated/
│       │   ├── app_tutorial/
│       │   ├── buttons/
│       │   ├── cards/
│       │   ├── counter/
│       │   ├── home/
│       │   ├── infinite_scroll/
│       │   ├── progress/
│       │   ├── snackbar/
│       │   ├── theme_changer/
│       │   ├── ui_controls/
│       │   └── screens.dart
│       └── widgets/side_menu.dart
├── test/widget_test.dart
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
```

| Archivo                                                                   | Responsabilidad                                                      |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| [main.dart](lib/main.dart)                                                | Inicializa Riverpod y configura el router y el tema de la aplicación |
| [menu_items.dart](lib/config/menu/menu_items.dart)                        | Define los títulos, descripciones, íconos y enlaces del menú         |
| [app_router.dart](lib/config/router/app_router.dart)                      | Relaciona las rutas con las pantallas                                |
| [app.theme.dart](lib/config/theme/app.theme.dart)                         | Define la paleta y construye el tema claro u oscuro                  |
| [theme_provider.dart](lib/presentation/providers/theme_provider.dart)     | Administra los cambios del tema global                               |
| [counter_provider.dart](lib/presentation/providers/counter_provider.dart) | Define el estado inicial del contador                                |
| [screens.dart](lib/presentation/screens/screens.dart)                     | Agrupa las exportaciones de las pantallas                            |

El componente `SideMenu` está definido en el proyecto, pero el inicio actual utiliza una lista de opciones y no lo incorpora como menú lateral.

## Requisitos

- Flutter instalado y disponible en la terminal, con Dart compatible con `^3.13.2`.
- Un editor como Visual Studio Code o Android Studio.
- Para Android: Android SDK y un emulador o dispositivo configurado.
- Para iOS: una Mac con Xcode y un simulador o dispositivo configurado.
- Conexión a internet para descargar las dependencias y mostrar las imágenes remotas.

## Instalación y ejecución

Desde la raíz del repositorio:

```bash
cd Practica05/widgets_app
flutter pub get
```

Abre el emulador o simulador y ejecuta:

```bash
flutter devices
flutter run
```

Para elegir un dispositivo, sustituye `ID_DEL_DISPOSITIVO` por el identificador mostrado en la lista:

```bash
flutter run -d ID_DEL_DISPOSITIVO
```

Durante la ejecución, presiona `r` para aplicar hot reload, `R` para reiniciar la aplicación o `q` para detenerla.

## Recursos gráficos pendientes

El proyecto todavía no incluye la carpeta `assets/images/`. El tutorial referencia `1.png`, `2.png` y `3.png`; si no puede cargarlas, muestra un ícono de restaurante como alternativa.

La pantalla de desplazamiento infinito obtiene imágenes de `picsum.photos` y referencia `assets/images/jar-loading.gif` como imagen de carga. Este GIF falta y puede provocar errores de carga al abrir esa pantalla. Para completar los recursos, agrega los cuatro archivos y registra la carpeta dentro de la sección `flutter` de `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

Después de agregarlos, ejecuta `flutter pub get` y vuelve a iniciar la aplicación. La lista infinita también necesita acceso a internet para descargar las fotografías.

## Verificación

Desde la carpeta del proyecto:

```bash
flutter analyze
flutter test
```

Las tres pruebas de [widget_test.dart](test/widget_test.dart) comprueban:

1. El incremento del contador de 5 a 6 y el cambio al tema oscuro desde esa pantalla.
2. La apertura del tutorial y el ícono alternativo cuando faltan las imágenes.
3. El cambio del color y del modo de toda la aplicación, conservando el modo oscuro al regresar al inicio.

Para una revisión manual, abre las opciones del menú, prueba los botones y controles, cambia la forma del contenedor animado y recorre las páginas del tutorial. Una vez agregados los recursos gráficos, verifica también la carga y la actualización de la lista infinita.

## Datos de la práctica

- **Práctica:** 05 · Widgets App.
- **Alumno:** Al Farias Leyva.
- **Matrícula:** 230389.
- **Asignatura:** Desarrollo Móvil Integral.
- **Carrera:** Ingeniería en Desarrollo y Gestión de Software.
- **Docente:** M.T.I. Marco A. Ramírez Hernández.
- **Periodo:** Septiembre - Diciembre 2026.

---

[Volver al README principal del repositorio](../../README.md)
