# Hello World App · Contador con Flutter

Proyecto de la práctica **Mi Primer Aplicación Móvil con Flutter**, desarrollado para la asignatura **Desarrollo Móvil Integral**.

## Descripción

La aplicación consiste en un contador interactivo que permite incrementar, disminuir y reiniciar un valor numérico. Cada acción actualiza la pantalla y el número cambia de color dependiendo de si es positivo, cero o negativo.

La interfaz utiliza la tipografía **Montserrat**, un tema basado en tonos morados y tres botones flotantes reutilizables. El proyecto pone en práctica los fundamentos de Flutter mediante una pantalla sencilla y funcional.

## Objetivo

Desarrollar una aplicación con Flutter y Dart que permita comprender la construcción de interfaces con widgets, el manejo del estado y la respuesta a las acciones del usuario, incorporando componentes reutilizables y estilos personalizados.

### Objetivos específicos

- Comprender la diferencia entre `StatelessWidget` y `StatefulWidget`.
- Actualizar la interfaz mediante `setState`.
- Crear un widget reutilizable llamado `CustomButton`.
- Pasar acciones a los botones mediante `VoidCallback`.
- Aplicar condiciones para modificar el color del contador.
- Integrar una fuente local y personalizar la apariencia de la aplicación.

## Funcionalidades

| Función        | Comportamiento                                                            |
| -------------- | ------------------------------------------------------------------------- |
| Sumar          | Incrementa el contador en una unidad mediante el botón +1                 |
| Restar         | Disminuye el contador en una unidad y permite valores negativos           |
| Reiniciar      | Establece el contador en cero desde el botón flotante o la barra superior |
| Color dinámico | Cambia el color del número según su valor                                 |
| Texto dinámico | Muestra “Click” para el valor 1 y “Clicks” para los demás valores         |

### Colores del contador

| Valor       | Color    |
| ----------- | -------- |
| Mayor que 0 | 🟢 Verde |
| Igual a 0   | 🔵 Azul  |
| Menor que 0 | 🔴 Rojo  |

El contador comienza en cero y se mantiene en memoria durante la ejecución. No se guarda al cerrar y volver a iniciar la aplicación.

## Capturas de pantalla

La aplicación ejecutándose en el simulador de iPhone 17 Pro. Las capturas muestran los tres estados del contador con la fuente Montserrat y los botones para sumar, restar y reiniciar.

### Contador positivo · Verde

Al incrementar el contador, los valores mayores que cero se muestran en verde. En esta captura, el valor es **22**.

![Contador con valor positivo de 22 en color verde](<assets/fonts/img/Captura de pantalla 2026-09-14 a la(s) 17.51.38.png>)

### Contador en cero · Azul

El contador inicia en **0** y se muestra en azul. Los botones de reinicio también devuelven la aplicación a este estado.

![Contador con valor 0 en color azul](<assets/fonts/img/Captura de pantalla 2026-09-14 a la(s) 17.51.28.png>)

### Contador negativo · Rojo

Al disminuir el contador por debajo de cero, el número cambia a rojo. En esta captura, el valor es **−6**.

![Contador con valor negativo de menos 6 en color rojo](<assets/fonts/img/Captura de pantalla 2026-09-14 a la(s) 17.51.45.png>)

## Tecnologías utilizadas

- **Flutter:** construcción de la interfaz.
- **Dart:** lógica del contador y definición de widgets.
- **Material Design:** barra superior, íconos y botones flotantes.
- **Montserrat:** tipografía incluida en los recursos del proyecto, disponible sin descargarla durante el uso.

## Estructura principal

```text
hello_world_app/
├── lib/
│   ├── main.dart
│   └── presentation/screens/counter/
│       └── counter_screen.dart
├── assets/fonts/
│   ├── Montserrat.ttf
│   ├── OFL.txt
│   └── img/                  # Capturas de pantalla
├── android/
├── ios/
├── web/
├── test/
├── pubspec.yaml
└── README.md
```

| Archivo o componente     | Responsabilidad                                                           |
| ------------------------ | ------------------------------------------------------------------------- |
| `main.dart`              | Inicia la aplicación, configura el tema y establece la pantalla principal |
| `CounterFunctionsScreen` | Conserva el estado del contador y construye la pantalla                   |
| `_getCounterColor`       | Selecciona el color mediante condiciones `if/else`                        |
| `CustomButton`           | Define el diseño compartido de los tres botones flotantes                 |
| `pubspec.yaml`           | Declara las dependencias y registra Montserrat                            |

`CounterFunctionsScreen` y `CustomButton` se encuentran en [counter_screen.dart](lib/presentation/screens/counter/counter_screen.dart). Cada botón recibe su ícono, su acción `onPressed`, un `heroTag` diferente y un texto de ayuda.

## Requisitos

- Flutter instalado y disponible en la terminal.
- Una versión de Dart compatible con `^3.13.2`, según `pubspec.yaml`.
- Un editor como Visual Studio Code.
- Para Android: Android SDK y un emulador o dispositivo configurado.
- Para iOS: una Mac con Xcode y un simulador de iPhone instalado.
- Para web: Google Chrome.

## Instalación y ejecución

Desde la raíz del repositorio, entra al proyecto e instala las dependencias:

```bash
cd hello_world_app
flutter pub get
```

Inicia el emulador o simulador y consulta los dispositivos disponibles:

```bash
flutter devices
flutter run
```

Si aparece una lista de dispositivos, selecciona el que deseas utilizar. Para elegir uno directamente, ejecuta `flutter run -d ID_DEL_DISPOSITIVO`, sustituyendo el identificador por el mostrado en `flutter devices`.

### Ejecutar en iOS

Con el simulador de iPhone iniciado, ejecuta desde la carpeta del proyecto:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
flutter run
```

La ruta anterior corresponde a Xcode instalado en `/Applications/Xcode.app`. Para abrir el proyecto directamente en Xcode, utiliza `ios/Runner.xcworkspace`.

### Ejecutar en Chrome

```bash
flutter run -d chrome
```

### Ver cambios durante el desarrollo

Guarda los archivos y utiliza estas teclas en la terminal donde está corriendo Flutter:

| Tecla | Acción                                                              |
| ----- | ------------------------------------------------------------------- |
| `r`   | Hot reload: actualiza la app y conserva el estado cuando es posible |
| `R`   | Hot restart: reinicia la app y devuelve el contador a cero          |
| `q`   | Detiene la ejecución                                                |

Después de agregar fuentes o recursos nuevos, detén la aplicación y vuelve a ejecutar `flutter run`.

## Verificación

Para revisar el código mediante el analizador de Flutter:

```bash
flutter analyze
```

Para comprobar manualmente las funciones:

1. Confirma que el contador inicia en **0 y azul**.
2. Presiona **+1** y verifica que el número aumente y se muestre en verde.
3. Presiona **reiniciar** y comprueba que vuelva a cero y azul.
4. Presiona **−1** y verifica que el número sea negativo y rojo.
5. Prueba también el botón de reinicio de la barra superior.

## Datos de la práctica

- **Asignatura:** Desarrollo Móvil Integral.
- **Carrera:** Ingeniería en Desarrollo y Gestión de Software.
- **Docente:** M.T.I. Marco A. Ramírez Hernández.
- **Periodo:** Septiembre - Diciembre 2026.
- **Matrícula:** 230389.

## Licencia de la tipografía

La licencia de Montserrat se incluye en [assets/fonts/OFL.txt](assets/fonts/OFL.txt).

---

[Volver al README principal del repositorio](../README.md)
