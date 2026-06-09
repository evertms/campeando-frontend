# Campeando Frontend

Campeando es una plataforma SaaS multi-tenant para logística y gestión de eventos como campamentos y conferencias.

## Estructura

El proyecto sigue una arquitectura feature-first en `lib/`, con Clean Architecture interna por feature y un `core/` para capacidades compartidas como API, persistencia, tema y widgets globales.

## Requisitos

- Flutter SDK instalado
- Dependencias resueltas con `flutter pub get`

## Ejecutar

1. Instala dependencias:
	`flutter pub get`
2. Ejecuta la aplicación:
	`flutter run`

## Notas

La base está preparada para las features de Auth, Eventos, Inscripciones con OTP y Logística, con aislamiento por Tenant mediante headers o claims.
