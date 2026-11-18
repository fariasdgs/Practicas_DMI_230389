# Cinemapedia · Desarrollo Móvil Integral

Proyecto académico para explorar películas, consultar su ficha y guardar favoritas. Integra un catálogo regional de TMDB, gestión de cuentas y notificaciones en una app Flutter.

| Datos de la entrega |                                                             |
| ------------------- | ----------------------------------------------------------- |
| **Alumno**          | Al Farias Leyva                                             |
| **Matrícula**       | 230389                                                      |
| **Docente**         | M.T.I. Marco A. Ramírez Hernández                           |
| **Programa**        | Ingeniería en Desarrollo y Gestión de Software              |
| **Asignatura**      | Desarrollo Móvil Integral                                   |
| **Periodo**         | Septiembre–diciembre de 2026                                |
| **Alcance**         | Integración de los contenidos del curso hasta la sección 26 |

## Prácticas y proyecto de la asignatura

| No. | Nombre                                                                | Descripción                                                                                                                         | Potenciador | Estatus      |
| --- | --------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------------ |
| 1.  | Metodología de Evaluación de la Materia                               | Transcribir en libreta y comprender la metodología y fechas de evaluación de la asignatura                                          | 5           | 🟢 Concluida |
| 2.  | [Mi Primer Aplicación Móvil con Flutter](Practica02/hello_world_app/) | Codificar la app móvil en el framework de Flutter manejando Stateless y Stateful Widgets                                            | 20          | 🟢 Concluida |
| 3.  | [Yes No App](Practica03/yes_no_app/)                                  | Crear una app que responda preguntas con respuestas automáticas Yes/No/Maybe                                                        | 30          | 🟢 Concluida |
| 4.  | [Tikitoki App](Practica04/tikitoki/)                                  | El alumno creará una app de reproducción de videos verticales con el uso de Provider y tematización temporal de Halloween y Navidad | 30          | 🟢 Concluida |
| 5. | [Widgets App](Practica05/widgets_app/) | Explorar controles, tarjetas, animaciones, desplazamiento infinito y cambios de tema en Flutter. | — | Desarrollada |
| Proyecto integrador | [Cinemapedia](practica06/cinemapedia/) | Catálogo regional, favoritos, tráileres, notificaciones y autenticación. Contenidos hasta la sección 26. | — | Verificado en simulador |

## Ejecutar Cinemapedia

1. Abre el simulador de iOS desde Xcode.
2. En `practica06/cinemapedia/.env`, configura `THE_MOVIEDB_KEY` con tu clave de TMDB.
3. Desde la raíz del repositorio, ejecuta:

   ```sh
   cd practica06/cinemapedia
   flutter pub get
   flutter run
   ```

**Mi cuenta** requiere que la API local esté en ejecución. Para verificar el envío de notificaciones push reales, hace falta configurar Firebase para la app y APNs en iOS. El aviso local se puede probar en el simulador desde **Menú → Notificaciones**. [Configuración técnica de Cinemapedia](practica06/cinemapedia/README.md)

La versión se compiló para el simulador de iOS. Se verificaron el aviso local y el flujo de autenticación del backend con PostgreSQL. El análisis de Flutter y las 22 pruebas pasaron.
