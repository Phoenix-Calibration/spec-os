# AI Specs - Documentación Completa

## 📋 Índice de Documentación

Esta carpeta contiene la documentación completa del repositorio **ai-specs** de LIDR Academy, un sistema avanzado de especificaciones y estándares para desarrollo asistido por IA.

### Documentos Disponibles

1. **[Estructura General](./01-estructura-general.md)** - Organización completa del repositorio
2. **[Conceptos Clave](./02-conceptos-clave.md)** - Fundamentos y principios del sistema
3. **[Estándares de Desarrollo](./03-estandares-desarrollo.md)** - Reglas y convenciones técnicas
4. **[Sistema de Comandos](./04-comandos.md)** - Comandos disponibles y su uso
5. **[Sistema de Agentes](./05-agentes.md)** - Roles y configuración de agentes IA
6. **[Flujo de Trabajo](./06-flujo-trabajo.md)** - Metodología y procesos recomendados
7. **[Ejemplos de Uso](./07-ejemplos-uso.md)** - Casos prácticos y plantillas

---

## 🎯 ¿Qué es AI Specs?

**AI Specs** es un repositorio que contiene un conjunto integral de:

- ✅ **Reglas de desarrollo** - Estándares de código para backend, frontend y documentación
- ✅ **Configuración multi-copilot** - Compatible con Claude, Cursor, GitHub Copilot y Gemini
- ✅ **Sistema de comandos** - Prompts reutilizables para tareas comunes
- ✅ **Definición de agentes** - Roles especializados para desarrollo asistido por IA
- ✅ **Flujo de trabajo estructurado** - Metodología para desarrollo autónomo con IA

---

## 🚀 Inicio Rápido

### Para Comenzar

1. **Lee primero**: [Conceptos Clave](./02-conceptos-clave.md) para entender la filosofía
2. **Revisa**: [Estructura General](./01-estructura-general.md) para familiarizarte con la organización
3. **Aprende**: [Flujo de Trabajo](./06-flujo-trabajo.md) para implementar la metodología
4. **Practica**: [Ejemplos de Uso](./07-ejemplos-uso.md) para ver casos reales

### Características Principales

#### 🤖 Multi-Copilot
- Funciona con Claude, Cursor, GitHub Copilot y Gemini
- Una única fuente de verdad para todas las reglas
- Enlaces simbólicos evitan duplicación

#### 📐 Estándares Completos
- Backend (Node.js, TypeScript, Express, Prisma)
- Frontend (React, TypeScript, Bootstrap)
- Documentación técnica y AI specs
- TDD con cobertura 90%+

#### ⚙️ Sistema de Comandos
- Comandos predefinidos para tareas repetitivas
- Enriquecer historias de usuario
- Planificar tickets (backend/frontend)
- Desarrollar features
- Commit y documentación

#### 👥 Agentes Especializados
- Backend Developer
- Frontend Developer
- Product Strategy Analyst
- Roles personalizables

---

## 📊 Arquitectura del Sistema

```
ai-specs/
├── specs/                      # Especificación técnicas
│   ├── base-standards.mdc      # ⭐ Fuente única de verdad
│   ├── backend-standards.mdc
│   ├── frontend-standards.mdc
│   └── documentation-standards.mdc
├── .commands/                  # Comandos reutilizables
│   ├── plan-backend-ticket.md
│   ├── develop-backend.md
│   ├── enrich-us.md
│   └── ...
├── .agents/                    # Definición de agentes
│   ├── backend-developer.md
│   ├── frontend-developer.md
│   └── product-strategy-analyst.md
└── changes/                    # Planes de implementación
    └── SCRUM-10_backend.md     # Ejemplo
```

---

## 🎓 Conceptos Fundamentales

### Single Source of Truth
Todas las reglas de desarrollo están definidas en `base-standards.mdc`. Los archivos específicos de cada copilot (CLAUDE.md, codex.md, GEMINI.md) referencian esta fuente única.

### Workflow Basado en Comandos
El desarrollo sigue un flujo estructurado:
1. **Enrich** → Enriquecer historia de usuario (opcional)
2. **Plan** → Generar plan detallado de implementación
3. **Develop** → Implementar siguiendo el plan
4. **Test** → Validar con cobertura 90%+
5. **Document** → Actualizar documentación técnica

### Test-Driven Development (TDD)
Todo código nuevo debe:
- Comenzar con tests fallidos
- Implementación mínima para pasar tests
- Refactorización
- Cobertura mínima 90%

---

## 🔗 Enlaces Útiles

- **Repositorio Original**: [LIDR-academy/ai-specs](https://github.com/LIDR-academy/ai-specs)
- **Programa AI4Devs**: [lidr.co/ia-devs](https://lidr.co/ia-devs)
- **Framework OpenSpec**: [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)

---

## 📝 Notas Importantes

### Idioma
- Todo el código, comentarios y documentación **DEBE** estar en inglés
- Esta documentación está en español para facilitar el estudio inicial
- Al usar el sistema en producción, cambiar a inglés

### Licencia
- MIT License
- © 2025 LIDR.co
- Parte del programa AI4Devs

### Contribuciones
Cuando contribuyas al repositorio original:
1. Actualiza `base-standards.mdc` primero
2. Prueba con múltiples AI copilots
3. Actualiza ejemplos si es necesario
4. Documenta cambios breaking
5. Sigue los mismos estándares que defines

---

## 📞 Soporte y Comunidad

Para preguntas, problemas o sugerencias:
- Visita [lidr.co/ia-devs](https://lidr.co/ia-devs)
- Revisa issues en GitHub
- Únete a la comunidad LIDR

---

**Hecho con 🤖 por la comunidad LIDR**

*Última actualización: Marzo 2025*
