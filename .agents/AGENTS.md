# Campeando Frontend - Restricciones Técnicas y Reglas de Desarrollo

Este proyecto sigue normas técnicas muy estrictas. Actúa como Software Architect y Lead Developer respetando en todo momento las siguientes restricciones para el frontend:

## 1. Arquitectura
- **Feature-first obligatoria**: El proyecto debe estar estructurado por features.
- Estructura exacta a seguir: `/lib/features/{feature_name}/{domain,application,data,presentation}`.

## 2. Manejo de Estado
- Uso **único y exclusivo** de `Provider` + `ChangeNotifier`.
- ❌ **PROHIBIDO**: Riverpod, Bloc, GetX, o cualquier otra librería de estado.

## 3. Red (Networking)
- Uso **único y exclusivo** del paquete nativo `http`.
- ❌ **PROHIBIDO**: Dio o similares.

## 4. Persistencia Local
- Uso **único y exclusivo** de `shared_preferences`.
- ❌ **PROHIBIDO**: SQLite, Drift, Hive, ISAR, etc.

## 5. Estilo de Código
- Uso estricto de `dart format`.
- Todo archivo debe tener **ordenamiento alfabético de imports**.
- Ejecutar `flutter analyze`. Debe haber CERO issues found!

## 6. Control de Versiones
- **Git Flow obligatorio**: Las ramas deben llamarse con prefijos `feat/`, `fix/`, `chore/`, etc.
- **Commits convencionales**: Obligatorio usar Conventional Commits (ej. `feat:`, `fix:`, `chore:`).
