# Clean Architecture

## Objetivo

El cliente móvil del Sistema Aplicador/Evaluador de Exámenes utiliza una
estructura basada en Clean Architecture para separar la interfaz, las reglas
de negocio y el acceso a datos.

## Capas

### Core

Contiene los recursos compartidos por toda la aplicación:

- Configuración.
- Constantes.
- Errores comunes.
- Componentes de red.
- Tema visual.
- Utilidades.

### Domain

Contiene las reglas de negocio independientes de la infraestructura:

- Entidades.
- Contratos de repositorios.
- Casos de uso.

La capa `domain` no debe depender de `data` ni de `presentation`.

### Data

Contiene las implementaciones relacionadas con los datos:

- Fuentes de datos locales.
- Fuentes de datos remotas.
- Modelos.
- Implementaciones de repositorios.

La capa `data` puede depender de los contratos definidos en `domain`.

### Presentation

Contiene los elementos relacionados con la interacción con el usuario:

- Pantallas.
- Estado de presentación.
- Componentes visuales.

La capa `presentation` puede utilizar los casos de uso definidos en `domain`.

## Regla de dependencias

Las dependencias deben apuntar hacia las reglas centrales del negocio.

Flujo general:

`presentation -> domain <- data`

`core` contiene recursos transversales, pero no debe utilizarse para introducir
dependencias circulares entre capas.

## Estructura

```text
lib/
├── core/
├── data/
├── domain/
├── presentation/
└── main.dart

```

## Pruebas

La carpeta `test` debe reflejar la organización principal del código:

```text
test/
├── core/
├── data/
├── domain/
└── presentation/
```

## Alcance de TK-002

Esta tarea establece únicamente la estructura inicial de Clean Architecture.

Las siguientes configuraciones quedan fuera de su alcance:

- Navegación.
- Gestión de estado.
- Configuración de entornos.
- Cliente HTTP.
- Persistencia local.
- Funcionalidades de usuario.
