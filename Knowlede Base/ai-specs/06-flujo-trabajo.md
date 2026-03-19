# Flujo de Trabajo Recomendado

## 🎯 Metodología AI-Specs

El flujo de trabajo de AI-Specs está diseñado para maximizar la autonomía de la IA mientras mantiene alta calidad y consistencia.

---

## 📊 Flujo Completo: De Ticket a Production

```mermaid
graph TD
    A[Ticket/User Story] --> B{¿Detallada?}
    B -->|No| C[/enrich-us]
    B -->|Sí| D[Enriquecer Manualmente]
    C --> E[US Enriquecida]
    D --> E
    E --> F{Backend o Frontend?}
    F -->|Backend| G[/plan-backend-ticket]
    F -->|Frontend| H[/plan-frontend-ticket]
    F -->|Both| I[Ambos Plans]
    G --> J[Plan Backend]
    H --> K[Plan Frontend]
    I --> J
    I --> K
    J --> L[Review Plan]
    K --> L
    L --> M{¿Aprobado?}
    M -->|No| N[Ajustar]
    M -->|Sí| O[/develop-backend]
    N --> G
    O --> P[Implementación Backend]
    P --> Q[Tests 90%+]
    K --> R[/develop-frontend]
    R --> S[Implementación Frontend]
    S --> T[Tests E2E + Unit]
    Q --> U{¿Tests Pass?}
    T --> U
    U -->|No| V[Debug & Fix]
    U -->|Sí| W[/update-docs]
    V --> P
    V --> S
    W --> X[Docs Actualizadas]
    X --> Y[/commit]
    Y --> Z[Git Commit]
    Z --> AA[Code Review]
    AA --> AB{¿Aprobado?}
    AB -->|No| AC[Cambios Solicitados]
    AB -->|Sí| AD[Merge to Main]
    AC --> V
    AD --> AE[Deploy]
    AE --> AF[QA Testing]
    AF --> AG{¿QA Pass?}
    AG -->|No| AH[Bug Fixes]
    AG -->|Sí| AI[Production]
    AH --> V
```

---

## 🔄 Fases Detalladas

### Fase 1: Análisis y Enriquecimiento

**Objetivo:** Tener una user story completa y detallada

**Input:** Ticket básico
```
SCRUM-10: Como reclutador, quiero actualizar posiciones
```

**Proceso:**

1. **Evaluar detalle de la US**
   ```
   ¿Tiene acceptance criteria?
   ¿Especifica validaciones?
   ¿Define edge cases?
   ¿Incluye testing requirements?
   ```

2. **Si falta detalle:**
   ```
   Actúa como Product Strategy Analyst
   /enrich-us SCRUM-10
   ```

3. **Output: US Enriquecida**
   ```markdown
   # SCRUM-10: Update Position Feature
   
   ## User Story
   As a recruiter
   I want to update position details
   So that I can keep listings current
   
   ## Acceptance Criteria
   - [ ] Can update all fields
   - [ ] Validates input
   - [ ] Shows errors clearly
   ...
   
   ## Edge Cases
   - Empty title → Error
   - Invalid status → Error
   ...
   ```

4. **Review**
   - Verificar que todos los criterios están claros
   - Confirmar que no falta información
   - Ajustar si es necesario

---

### Fase 2: Planificación

**Objetivo:** Generar planes detallados de implementación

**Input:** US enriquecida

**Proceso Backend:**

1. **Activar agente**
   ```
   Actúa como Backend Developer
   ```

2. **Generar plan**
   ```
   /plan-backend-ticket SCRUM-10
   ```

3. **Output:** `ai-specs/changes/SCRUM-10_backend.md`
   - Architecture context
   - Step-by-step instructions
   - Code examples
   - Test specifications
   - Error handling
   - Documentation updates

4. **Review del Plan**
   - ¿Sigue los estándares?
   - ¿Cubre todos los acceptance criteria?
   - ¿Tests comprehensivos?
   - ¿Documentación incluida?

**Proceso Frontend:**

1. **Activar agente**
   ```
   Actúa como Frontend Developer
   ```

2. **Generar plan**
   ```
   /plan-frontend-ticket SCRUM-10
   ```

3. **Output:** `ai-specs/changes/SCRUM-10_frontend.md`
   - Component structure
   - State management approach
   - Bootstrap implementation
   - Cypress E2E tests
   - Jest unit tests

4. **Review del Plan**
   - ¿UI/UX bien definido?
   - ¿State management claro?
   - ¿Tests E2E y unit?
   - ¿Responsive design?

---

### Fase 3: Implementación

**Objetivo:** Código funcionando con tests completos

#### Backend

1. **Seguir plan paso a paso**
   ```
   Actúa como Backend Developer
   /develop-backend @SCRUM-10_backend.md
   ```

2. **Proceso automatizado:**
   ```
   ✓ Step 0: Create feature branch
   ✓ Step 1: Implement validation
   ✓ Step 2: Implement service
   ✓ Step 3: Implement controller
   ✓ Step 4: Add routes
   ✓ Step 5: Write tests (all layers)
   ✓ Step 6: Update documentation
   ```

3. **Verificaciones en cada paso:**
   - Código compila sin errores
   - Tests pasan
   - Cobertura ≥ 90%
   - ESLint sin warnings

#### Frontend

1. **Seguir plan**
   ```
   Actúa como Frontend Developer
   /develop-frontend @SCRUM-10_frontend.md
   ```

2. **Proceso automatizado:**
   ```
   ✓ Step 0: Create feature branch
   ✓ Step 1: Create components
   ✓ Step 2: Implement state
   ✓ Step 3: Add styling
   ✓ Step 4: Write E2E tests
   ✓ Step 5: Write unit tests
   ✓ Step 6: Update docs
   ```

3. **Verificaciones:**
   - Components render correctamente
   - State management funciona
   - Styling responsive
   - E2E tests pasan
   - Unit tests pasan

---

### Fase 4: Testing

**Objetivo:** Garantizar calidad y cobertura 90%+

**Niveles de Testing:**

#### Unit Tests
```bash
npm test
npm run test:coverage
```

**Verificar:**
- Coverage ≥ 90% (branches, functions, lines, statements)
- Todos los tests pasan
- Mock correctos en cada capa

#### Integration Tests
```bash
npm run test:integration
```

**Verificar:**
- Flujos completos funcionan
- Database integration correcta
- API endpoints responden bien

#### E2E Tests (Frontend)
```bash
npm run cypress:run
```

**Verificar:**
- User flows completos
- Interacción con backend
- Error handling en UI

#### Manual Testing
**Checklist:**
- [ ] Happy path funciona
- [ ] Edge cases manejan bien
- [ ] Error messages claros
- [ ] Performance aceptable
- [ ] UI responsive

---

### Fase 5: Documentación

**Objetivo:** Mantener docs sincronizadas con código

**Proceso:**

1. **Identificar cambios**
   ```
   ¿Cambió la API? → Actualizar api-spec.yml
   ¿Cambió la BD? → Actualizar data-model.md
   ¿Cambió el setup? → Actualizar development_guide.md
   ```

2. **Actualizar documentación**
   ```
   /update-docs
   ```

3. **Verificación:**
   - [ ] API spec refleja nuevos endpoints
   - [ ] Data model actualizado
   - [ ] README tiene nueva info si aplica
   - [ ] Todos los docs en inglés

---

### Fase 6: Commit y Code Review

**Objetivo:** Git commit descriptivo y PR limpio

**Proceso:**

1. **Generar commit message**
   ```
   /commit
   ```

   Output:
   ```
   feat(positions): add update position endpoint

   - Implement PUT /positions/:id endpoint
   - Add validatePositionUpdate function
   - Add updatePositionService with business logic
   - Add updatePosition controller
   - Write comprehensive tests (92% coverage)
   - Update API documentation

   Resolves SCRUM-10
   ```

2. **Commit**
   ```bash
   git add .
   git commit -m "[mensaje generado]"
   git push origin feature/SCRUM-10-backend
   ```

3. **Crear Pull Request**
   - Title: `feat(positions): add update position endpoint`
   - Description: Link to ticket, summary of changes
   - Reviewers: Asignar

4. **Code Review Checklist:**
   - [ ] Sigue los estándares
   - [ ] Tests comprehensivos
   - [ ] No hay código duplicado
   - [ ] Error handling correcto
   - [ ] Documentación actualizada
   - [ ] English only
   - [ ] Performance aceptable

---

### Fase 7: Deploy y QA

**Objetivo:** Feature en producción funcionando

**Proceso:**

1. **Merge a main**
   ```bash
   git checkout main
   git merge feature/SCRUM-10-backend
   git push origin main
   ```

2. **Deploy a staging**
   ```bash
   npm run deploy:staging
   ```

3. **QA Testing**
   - Smoke tests
   - Regression tests
   - Performance tests
   - Security checks

4. **Deploy a production**
   ```bash
   npm run deploy:production
   ```

5. **Monitoring**
   - Check logs
   - Monitor errors
   - Verify metrics

---

## ⚡ Workflow Acelerado (Features Simples)

Para features muy simples que no requieren enriquecimiento:

```mermaid
graph LR
    A[Ticket] --> B[/plan-backend-ticket]
    B --> C[/develop-backend]
    C --> D[Tests]
    D --> E[/update-docs]
    E --> F[/commit]
    F --> G[PR]
```

**Comandos:**
```bash
/plan-backend-ticket SCRUM-10
/develop-backend @SCRUM-10_backend.md
npm test
/update-docs
/commit
git push
```

---

## 🎓 Best Practices del Workflow

### ✅ DO's

1. **Seguir el orden de fases**
   - No saltar pasos
   - Completar cada fase antes de avanzar

2. **Review en cada etapa**
   - Revisar plan antes de implementar
   - Verificar tests antes de commit
   - Check docs antes de PR

3. **Mantener feature branches pequeñas**
   - Una feature por branch
   - Commits frecuentes
   - PRs del tamaño correcto

4. **Usar agentes apropiados**
   - Backend Dev para backend
   - Frontend Dev para frontend
   - Product Analyst para US

5. **Tests primero**
   - TDD approach
   - 90%+ coverage
   - All layers tested

### ❌ DON'Ts

1. **No saltear testing**
   - Testing NO es opcional
   - Coverage debe ser 90%+

2. **No ignorar documentación**
   - Update docs es mandatory
   - Debe estar antes del commit

3. **No mezclar concerns**
   - Backend y frontend en branches separadas
   - Multiple features en PRs separados

4. **No código sin plan**
   - Siempre generar plan primero
   - No improvisar arquitectura

5. **No commits sin mensaje descriptivo**
   - Usar /commit para generar
   - Seguir conventional commits

---

## 🔄 Iteración y Refinamiento

### Cuando algo no funciona

1. **Identificar en qué fase está el problema**
   - Planning → Revisar y ajustar plan
   - Implementation → Debug y fix
   - Testing → Agregar tests faltantes
   - Documentation → Completar docs

2. **Volver a la fase apropiada**
   - No forzar avanzar con problemas
   - Fix en la fase correcta

3. **Re-ejecutar verificaciones**
   - Tests deben pasar
   - Coverage debe ser ≥ 90%
   - Docs deben estar actualizadas

---

## 📊 Métricas de Éxito

### Por Feature

- ✅ Coverage ≥ 90%
- ✅ All tests passing
- ✅ No ESLint warnings
- ✅ Documentation updated
- ✅ Code reviewed and approved
- ✅ Deployed successfully

### Por Sprint

- ✅ Velocity consistente
- ✅ Quality metrics estables
- ✅ Technical debt bajo control
- ✅ Documentation up to date

---

**Próximo paso:** Lee [Ejemplos de Uso](./07-ejemplos-uso.md) para ver el workflow en acción.

**Última actualización:** Marzo 2025
