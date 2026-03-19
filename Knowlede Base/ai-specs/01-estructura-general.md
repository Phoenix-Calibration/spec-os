# Estructura General del Repositorio AI-Specs

## 📂 Organización Principal

El repositorio ai-specs está organizado de manera jerárquica y modular para facilitar su uso y mantenimiento:

```
ai-specs/                           # Repositorio principal
├── .claude/                        # Configuración específica para Claude
│   ├── .agents/                    # Agentes para Claude (symlinks)
│   └── .commands/                  # Comandos para Claude (symlinks)
├── .cursor/                        # Configuración específica para Cursor
│   ├── .agents/                    # Agentes para Cursor (symlinks)
│   └── .commands/                  # Comandos para Cursor (symlinks)
├── ai-specs/                       # ⭐ Directorio principal con todas las reglas
│   ├── specs/                      # Especificaciones de desarrollo
│   │   ├── base-standards.mdc      # 🔥 FUENTE ÚNICA DE VERDAD
│   │   ├── backend-standards.mdc   # Estándares backend detallados
│   │   ├── frontend-standards.mdc  # Estándares frontend detallados
│   │   ├── documentation-standards.mdc # Estándares de documentación
│   │   ├── api-spec.yml            # Especificación OpenAPI
│   │   ├── data-model.md           # Modelos de datos y BD
│   │   └── development_guide.md    # Guía de desarrollo
│   ├── .commands/                  # Comandos reutilizables
│   │   ├── commit.md               # Comando para commits
│   │   ├── develop-backend.md      # Desarrollo backend
│   │   ├── develop-frontend.md     # Desarrollo frontend
│   │   ├── enrich-us.md            # Enriquecer user stories
│   │   ├── explain.md              # Explicar código
│   │   ├── meta-prompt.md          # Meta-prompts
│   │   ├── plan-backend-ticket.md  # Planificar tickets backend
│   │   ├── plan-frontend-ticket.md # Planificar tickets frontend
│   │   └── update-docs.md          # Actualizar documentación
│   ├── .agents/                    # Definiciones de agentes IA
│   │   ├── backend-developer.md    # Agente backend
│   │   ├── frontend-developer.md   # Agente frontend
│   │   └── product-strategy-analyst.md # Agente de producto
│   └── changes/                    # Planes de implementación generados
│       ├── SCRUM-10-Position-Update.md # Ejemplo: US enriquecida
│       └── SCRUM-10_backend.md     # Ejemplo: Plan de implementación
├── AGENTS.md                       # Configuración genérica de agentes
├── CLAUDE.md                       # Configuración para Claude
├── GEMINI.md                       # Configuración para Gemini
├── codex.md                        # Configuración para GitHub Copilot
├── README.md                       # Documentación principal
└── .DS_Store                       # Archivo de sistema (macOS)
```

---

## 🔍 Desglose Detallado

### 1. Carpetas de Configuración por Copilot

#### `.claude/` y `.cursor/`
Estas carpetas contienen enlaces simbólicos (symlinks) que apuntan al contenido real en `ai-specs/.agents/` y `ai-specs/.commands/`.

**Propósito:**
- Permitir que cada copilot encuentre su configuración en su ubicación esperada
- Evitar duplicación de código
- Mantener sincronización automática

**Ejemplo de symlink:**
```bash
.claude/.agents/backend-developer.md -> ../../ai-specs/.agents/backend-developer.md
```

---

### 2. Directorio `ai-specs/` (Principal)

Este es el corazón del sistema. Contiene todas las especificaciones, comandos y agentes reales.

#### 2.1 `specs/` - Especificaciones Técnicas

##### `base-standards.mdc` ⭐
**El archivo más importante del repositorio.**

**Contenido:**
- Principios core de desarrollo
- Reglas de idioma (English only)
- Referencias a estándares específicos
- Configuración `alwaysApply: true`

**Frontmatter YAML:**
```yaml
---
description: This document contains all development rules and guidelines for this project
alwaysApply: true
---
```

**Secciones principales:**
1. **Core Principles**
   - Small tasks, one at a time
   - Test-Driven Development (TDD)
   - Type Safety
   - Clear Naming
   - Incremental Changes

2. **Language Standards**
   - English only requirement
   - Applies to code, comments, docs, tickets, schemas, git messages

3. **Specific Standards**
   - Links a backend, frontend y documentation standards

##### `backend-standards.mdc`
**Estándares detallados para desarrollo backend.**

**Contenido (~10,539 caracteres):**
- Technology Stack (Node.js, TypeScript, Express, Prisma, PostgreSQL)
- Architecture Overview (DDD, Layered Architecture)
- Domain-Driven Design Principles
- SOLID and DRY Principles
- Coding Standards
- API Design Standards
- Database Patterns
- Testing Standards (90%+ coverage)
- Performance Best Practices
- Security Best Practices
- Development Workflow
- Serverless Deployment

**Estructura del proyecto backend:**
```typescript
backend/
├── src/
│   ├── domain/
│   │   ├── models/         # Entidades de negocio
│   │   └── repositories/   # Interfaces de repositorios
│   ├── application/
│   │   ├── services/       # Lógica de negocio
│   │   └── validator.ts    # Validación de entrada
│   ├── presentation/
│   │   └── controllers/    # Manejo HTTP
│   ├── infrastructure/
│   │   ├── logger.ts
│   │   └── prismaClient.ts
│   ├── routes/
│   ├── middleware/
│   └── index.ts
├── prisma/
│   ├── schema.prisma
│   └── migrations/
└── test-utils/
```

##### `frontend-standards.mdc`
**Estándares detallados para desarrollo frontend.**

**Contenido (~10,036 caracteres):**
- Technology Stack (React 18, TypeScript, Bootstrap)
- Project Structure
- Coding Standards
- Component Conventions
- State Management
- Service Layer Architecture
- UI/UX Standards
- Testing Standards (Cypress, Jest)
- Configuration Standards
- Performance Best Practices
- Development Workflow
- Migration Strategy

**Stack tecnológico:**
- React 18.3.1 con hooks
- TypeScript 4.9.5
- Create React App 5.0.1
- React Router DOM 6.23.1
- Bootstrap 5.3.3 + React Bootstrap 2.10.2
- Cypress 14.4.1 para E2E testing

##### `documentation-standards.mdc`
**Reglas para documentación técnica y AI specs.**

**Contenido:**
- General rules (English only)
- Technical Documentation update process
- AI specs learning and improvement process
- Common pitfalls para AI evitar

**Proceso mandatory antes de commits:**
1. Review recent changes
2. Identify docs que necesitan updates
3. Update each affected doc file
4. Ensure proper formatting
5. Verify changes reflected
6. Report files updated

##### `api-spec.yml`
**Especificación OpenAPI 3.0 del proyecto.**

Documento de referencia del proyecto LIDR. Contiene:
- Endpoints disponibles
- Request/Response schemas
- Error formats
- Authentication requirements

##### `data-model.md`
**Modelos de dominio y esquemas de base de datos.**

Documenta:
- Database structure
- Domain entities
- Relationships
- Validation rules

##### `development_guide.md`
**Guía de setup y workflows.**

Incluye:
- Installation instructions
- Environment setup
- Development workflows
- Project-specific procedures

---

#### 2.2 `.commands/` - Comandos Reutilizables

Sistema de prompts predefinidos para automatizar tareas comunes.

##### `commit.md` (~5,933 bytes)
Comando para generar commits descriptivos siguiendo convenciones.

**Uso típico:**
```
/commit
```

##### `develop-backend.md` (~832 bytes)
Implementa features backend siguiendo el plan generado.

**Uso típico:**
```
/develop-backend @SCRUM-10_backend.md
```

##### `develop-frontend.md` (~2,977 bytes)
Implementa features frontend siguiendo el plan generado.

**Uso típico:**
```
/develop-frontend @SCRUM-15_frontend.md
```

##### `enrich-us.md` (~1,577 bytes)
Enriquece user stories con:
- Detailed acceptance criteria
- Edge cases
- Technical considerations
- Testing scenarios

**Uso típico:**
```
/enrich-us SCRUM-10
```

##### `explain.md` (~5,150 bytes)
Explica código, conceptos o arquitectura del proyecto.

**Uso típico:**
```
/explain [código o concepto]
```

##### `meta-prompt.md` (~377 bytes)
Comando para crear meta-prompts.

##### `plan-backend-ticket.md` (~5,655 bytes)
Genera plan detallado de implementación para tickets backend.

**Output:** Archivo en `ai-specs/changes/[TICKET-ID]_backend.md`

**Contenido del plan:**
- Architecture context
- Step-by-step instructions
- Complete code examples
- Comprehensive test specifications
- Error handling
- Business rules
- Testing checklist

**Uso típico:**
```
/plan-backend-ticket SCRUM-10
```

##### `plan-frontend-ticket.md` (~5,936 bytes)
Genera plan detallado de implementación para tickets frontend.

**Uso típico:**
```
/plan-frontend-ticket SCRUM-15
```

##### `update-docs.md` (~121 bytes)
Actualiza documentación técnica.

**Uso típico:**
```
/update-docs
```

---

#### 2.3 `.agents/` - Definiciones de Agentes

Roles especializados para diferentes aspectos del desarrollo.

##### `backend-developer.md` (~10,539 bytes)
**Rol:** Backend Development Expert

**Responsabilidades:**
- Implementar APIs RESTful
- Diseño de base de datos
- Testing con Jest
- Deployment serverless
- Code reviews

**Skills:**
- Node.js, TypeScript, Express
- Prisma ORM, PostgreSQL
- DDD, SOLID principles
- AWS Lambda, Serverless Framework

##### `frontend-developer.md` (~10,036 bytes)
**Rol:** Frontend Development Expert

**Responsabilidades:**
- Desarrollar componentes React
- Implementar UI/UX
- State management
- E2E testing con Cypress

**Skills:**
- React 18, TypeScript
- Bootstrap, CSS
- React Router, Hooks
- Testing Library, Cypress

##### `product-strategy-analyst.md` (~4,494 bytes)
**Rol:** Product Strategy & User Story Expert

**Responsabilidades:**
- Analizar user stories
- Definir acceptance criteria
- Identificar edge cases
- Enriquecer requirements

**Skills:**
- Product analysis
- Technical feasibility
- Requirements engineering
- Risk assessment

---

#### 2.4 `changes/` - Planes de Implementación

Carpeta donde se guardan los planes generados y user stories enriquecidas.

##### Ejemplo: `SCRUM-10_backend.md`
Plan completo de implementación para actualizar posición (LIDR project).

**Estructura del plan:**
1. **Overview** - Descripción general
2. **Architecture Context** - Capas involucradas, componentes
3. **Implementation Steps** - Paso a paso detallado:
   - Step 0: Create Feature Branch
   - Step 1: Create Validation Function
   - Step 2: Create Service Method
   - Step 3: Create Controller Method
   - Step 4: Add Route
   - Step 5: Write Comprehensive Tests (ALL layers)
   - Step 6: Update Technical Documentation
4. **Implementation Order** - Orden de ejecución
5. **Testing Checklist** - Unit, manual, integration, regression
6. **Error Response Format** - Mapeo de HTTP status codes
7. **Partial Update Support** - Explicación de updates parciales
8. **Dependencies** - Librerías y dependencias internas
9. **Notes** - Recordatorios importantes, business rules
10. **Implementation Verification** - Checklist final

**Características del plan:**
- ✅ Extremadamente detallado (código de ejemplo completo)
- ✅ Tests comprehensivos con ejemplos
- ✅ Manejo de errores explícito
- ✅ Validaciones paso a paso
- ✅ Documentación técnica incluida

---

### 3. Archivos de Configuración Root

#### `AGENTS.md`
Configuración genérica de agentes que funciona con la mayoría de copilots.

#### `CLAUDE.md`
Configuración optimizada para Claude/Cursor. Referencia a `base-standards.mdc`.

#### `codex.md`
Configuración optimizada para GitHub Copilot/Codex. Referencia a `base-standards.mdc`.

#### `GEMINI.md`
Configuración optimizada para Google Gemini. Referencia a `base-standards.mdc`.

**Todos estos archivos:**
- Apuntan a la misma fuente de verdad (`ai-specs/specs/base-standards.mdc`)
- Permiten customizaciones específicas por copilot
- Mantienen consistencia en las reglas core

---

## 🔗 Sistema de Enlaces Simbólicos

### ¿Por qué symlinks?

1. **Zero Duplication** - Un solo conjunto de archivos reales
2. **Automatic Sync** - Cambios se reflejan en todos los copilots
3. **Easy Maintenance** - Actualizar una vez, funciona en todos lados
4. **Copilot Compatibility** - Cada herramienta encuentra config en su ubicación esperada

### Estructura de Symlinks

```
.claude/
  ├── .agents/ -> ../../ai-specs/.agents/
  └── .commands/ -> ../../ai-specs/.commands/

.cursor/
  ├── .agents/ -> ../../ai-specs/.agents/
  └── .commands/ -> ../../ai-specs/.commands/
```

### Crear Symlinks (referencia)

**Linux/macOS:**
```bash
ln -s ../../ai-specs/.agents/ .claude/.agents
ln -s ../../ai-specs/.commands/ .claude/.commands
```

**Windows (PowerShell como admin):**
```powershell
New-Item -ItemType SymbolicLink -Path ".\.claude\.agents" -Target "..\..\ai-specs\.agents"
New-Item -ItemType SymbolicLink -Path ".\.claude\.commands" -Target "..\..\ai-specs\.commands"
```

---

## 📊 Flujo de Archivos

### 1. Lectura de Config por Copilot

```
Claude solicita reglas
    ↓
Lee CLAUDE.md
    ↓
CLAUDE.md referencia ai-specs/specs/base-standards.mdc
    ↓
base-standards.mdc referencia backend-standards.mdc, etc.
    ↓
Claude carga todas las reglas
```

### 2. Ejecución de Comando

```
Usuario: /plan-backend-ticket SCRUM-10
    ↓
Claude busca comando en .claude/.commands/
    ↓
Encuentra symlink -> ai-specs/.commands/plan-backend-ticket.md
    ↓
Lee el prompt del comando
    ↓
Ejecuta siguiendo las instrucciones + reglas de base-standards
    ↓
Genera plan en ai-specs/changes/SCRUM-10_backend.md
```

### 3. Uso de Agente

```
Usuario: Actúa como Backend Developer
    ↓
Claude busca agente en .claude/.agents/
    ↓
Encuentra symlink -> ai-specs/.agents/backend-developer.md
    ↓
Carga rol, responsabilidades y skills
    ↓
Aplica las reglas de backend-standards.mdc
    ↓
Responde según el contexto del agente
```

---

## 🎯 Ventajas de Esta Estructura

### ✅ Portable
- Copiar carpeta ai-specs/ a cualquier proyecto
- Funciona inmediatamente sin configuración

### ✅ Scalable
- Agregar nuevos comandos fácilmente
- Definir nuevos agentes según necesidades
- Extender estándares sin romper existentes

### ✅ Maintainable
- Single source of truth
- Cambios centralizados
- Versionado con Git

### ✅ Flexible
- Soporte multi-copilot
- Customizable por proyecto
- Adaptable a diferentes stacks

### ✅ Consistent
- Mismas reglas para todo el equipo
- Mismas reglas para todos los AI tools
- Calidad de código uniforme

---

## 📝 Notas Importantes

### Archivos Críticos (NO eliminar)
- `ai-specs/specs/base-standards.mdc` - Core rules
- `ai-specs/specs/backend-standards.mdc` - Backend rules
- `ai-specs/specs/frontend-standards.mdc` - Frontend rules
- `ai-specs/.commands/` - Todos los comandos
- `ai-specs/.agents/` - Todas las definiciones

### Archivos de Ejemplo (Pueden adaptarse)
- `ai-specs/specs/api-spec.yml` - Ejemplo del proyecto LIDR
- `ai-specs/specs/data-model.md` - Ejemplo del proyecto LIDR
- `ai-specs/changes/SCRUM-10_backend.md` - Template reference

### Symlinks (Regenerar si se pierden)
- `.claude/.agents/` y `.claude/.commands/`
- `.cursor/.agents/` y `.cursor/.commands/`

---

## 🔄 Actualización y Mantenimiento

### Para Actualizar Reglas
1. Modificar `base-standards.mdc`
2. Si es necesario, actualizar standards específicos
3. Commit y push
4. Todos los copilots verán los cambios automáticamente

### Para Agregar Comando
1. Crear `nuevo-comando.md` en `ai-specs/.commands/`
2. Seguir formato de comandos existentes
3. Si es necesario, crear versiones específicas en `.claude/` o `.cursor/`

### Para Agregar Agente
1. Crear `nuevo-agente.md` en `ai-specs/.agents/`
2. Definir rol, responsabilidades, skills
3. Referencias a standards relevantes

---

**Última actualización:** Marzo 2025
