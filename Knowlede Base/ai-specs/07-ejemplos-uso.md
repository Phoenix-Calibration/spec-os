# Ejemplos de Uso

## 🎯 Casos Prácticos

Esta sección muestra ejemplos reales y completos de cómo usar AI-Specs en diferentes escenarios.

---

## 📝 Ejemplo 1: Feature Backend Completa

### Scenario
Implementar endpoint para actualizar posiciones en un sistema de reclutamiento.

**Ticket:** SCRUM-10 - Update Position Feature

### Paso 1: Enriquecer User Story

**Comando:**
```
Actúa como Product Strategy Analyst
/enrich-us SCRUM-10
```

**Input (US original):**
```
Como reclutador, quiero actualizar una posición 
para mantener la información actualizada.
```

**Output generado (`SCRUM-10-Position-Update.md`):**
```markdown
# SCRUM-10: Update Position Feature

## User Story
**As a** recruiter
**I want** to update existing position details
**So that** I can keep job listings current and accurate

## Technical Specification
### API Endpoint
PUT /positions/:id

### Request Body
{
  "title": "Senior Software Engineer",
  "description": "Updated description",
  "status": "Open",
  "salaryMin": 60000,
  "salaryMax": 80000
}

### Response (200)
{
  "success": true,
  "message": "Position updated successfully",
  "data": { ...position }
}

## Validation Rules
### Server-Side
- Title: Required, max 100 characters
- Status: Must be [Open, Contratado, Cerrado, Borrador]
- SalaryMin/Max: Number >= 0, min <= max
- ApplicationDeadline: Future date only
- CompanyId: Must exist in database
- InterviewFlowId: Must exist in database

## Acceptance Criteria
- [x] Recruiter can update all position fields
- [x] Partial updates supported
- [x] Invalid data shows clear error messages
- [x] 404 if position doesn't exist
- [x] 400 for validation errors
- [x] Success confirmation displayed

## Edge Cases
1. Empty title → "Title is required and must be a valid string"
2. Invalid status → "Invalid status. Must be one of: Open, Contratado..."
3. SalaryMin > SalaryMax → "Minimum salary cannot be greater than maximum"
4. Past deadline → "Application deadline cannot be in the past"
5. Nonexistent companyId → "Company not found"

## Testing Requirements
### Unit Tests
- Validation function tests (all rules)
- Service layer tests (business logic)
- Controller tests (HTTP handling)

### Integration Tests
- Full update flow
- Error scenarios
- Database transactions

### Manual Tests
- Happy path
- All edge cases
- Performance under load

## Definition of Done
- [x] Code implemented following DDD
- [x] Tests written (90%+ coverage)
- [x] Code reviewed and approved
- [x] API documentation updated
- [x] Deployed to staging
- [x] QA testing passed
```

---

### Paso 2: Planificar Implementación

**Comando:**
```
Actúa como Backend Developer
/plan-backend-ticket SCRUM-10
```

**Output generado (`SCRUM-10_backend.md` - extracto):**
```markdown
# Backend Implementation Plan: SCRUM-10

## Overview
Implement position update feature with PUT /positions/:id endpoint.
Follows DDD principles, layered architecture, and TDD.

## Architecture Context

### Layers Involved
- Presentation: positionController.ts
- Application: positionService.ts, validator.ts
- Domain: Position.ts (existing)
- Infrastructure: Prisma ORM

### Files to Modify
1. backend/src/application/validator.ts
2. backend/src/application/services/positionService.ts
3. backend/src/presentation/controllers/positionController.ts
4. backend/src/routes/positionRoutes.ts

## Implementation Steps

### Step 0: Create Feature Branch
```bash
git checkout main
git pull origin main
git checkout -b feature/SCRUM-10-backend
```

### Step 1: Create Validation Function

**File:** `backend/src/application/validator.ts`

**Function:**
```typescript
export const validatePositionUpdate = (data: any): void => {
    // Title validation
    if (data.title !== undefined) {
        if (!data.title || typeof data.title !== 'string' || 
            data.title.trim().length === 0) {
            throw new Error('Title is required and must be a valid string');
        }
        if (data.title.length > 100) {
            throw new Error('Title cannot exceed 100 characters');
        }
    }

    // Status validation
    if (data.status !== undefined) {
        const validStatuses = ['Open', 'Contratado', 'Cerrado', 'Borrador'];
        if (!validStatuses.includes(data.status)) {
            throw new Error('Invalid status. Must be one of: Open, Contratado, Cerrado, Borrador');
        }
    }

    // Salary validation
    if (data.salaryMin !== undefined && data.salaryMax !== undefined) {
        if (data.salaryMin > data.salaryMax) {
            throw new Error('Minimum salary cannot be greater than maximum salary');
        }
    }

    // ... más validaciones
};
```

### Step 2: Create Service Method

**File:** `backend/src/application/services/positionService.ts`

**Function:**
```typescript
export const updatePositionService = async (
    positionId: number, 
    updateData: any
): Promise<any> => {
    // Verify position exists
    const existingPosition = await Position.findOne(positionId);
    if (!existingPosition) {
        throw new Error('Position not found');
    }

    // Validate update data
    validatePositionUpdate(updateData);

    // Validate company reference if provided
    if (updateData.companyId !== undefined) {
        const company = await prisma.company.findUnique({
            where: { id: updateData.companyId }
        });
        if (!company) {
            throw new Error('Company not found');
        }
    }

    // Merge existing data with updates
    const mergedData = {
        ...existingPosition,
        ...updateData,
        id: positionId
    };

    // Create Position instance and save
    const position = new Position(mergedData);
    const updatedPosition = await position.save();

    return updatedPosition;
};
```

### Step 3: Create Controller Method

**File:** `backend/src/presentation/controllers/positionController.ts`

**Function:**
```typescript
export const updatePosition = async (
    req: Request, 
    res: Response
): Promise<void> => {
    try {
        // Parse and validate position ID
        const positionId = parseInt(req.params.id);
        if (isNaN(positionId)) {
            res.status(400).json({
                message: 'Invalid position ID format',
                error: 'Position ID must be a valid number'
            });
            return;
        }

        // Validate request body
        if (!req.body || Object.keys(req.body).length === 0) {
            res.status(400).json({
                message: 'No data provided for update',
                error: 'Request body cannot be empty'
            });
            return;
        }

        // Call service layer
        const updatedPosition = await updatePositionService(
            positionId, 
            req.body
        );

        // Success response
        res.status(200).json({
            message: 'Position updated successfully',
            data: updatedPosition
        });
    } catch (error) {
        if (error instanceof Error) {
            // Position not found
            if (error.message === 'Position not found') {
                res.status(404).json({
                    message: 'Position not found',
                    error: error.message
                });
                return;
            }

            // Validation errors
            if (error.message.includes('must be') || 
                error.message.includes('required')) {
                res.status(400).json({
                    message: 'Validation error',
                    error: error.message
                });
                return;
            }

            // Other errors
            res.status(500).json({
                message: 'Error updating position',
                error: error.message
            });
        }
    }
};
```

### Step 4: Add Route

**File:** `backend/src/routes/positionRoutes.ts`

```typescript
import { updatePosition } from '../presentation/controllers/positionController';

router.put('/:id', updatePosition);
```

### Step 5: Write Comprehensive Tests

**File:** `backend/src/application/__tests__/validator.test.ts`

```typescript
describe('validatePositionUpdate', () => {
    it('should not throw error with valid data', () => {
        const validData = {
            title: 'Senior Software Engineer',
            status: 'Open',
            salaryMin: 50000,
            salaryMax: 70000
        };
        expect(() => validatePositionUpdate(validData)).not.toThrow();
    });

    it('should throw error when title is empty', () => {
        expect(() => validatePositionUpdate({ title: '' }))
            .toThrow('Title is required and must be a valid string');
    });

    // ... más tests
});
```

### Step 6: Update Documentation

Update `api-spec.yml`:
```yaml
/positions/{id}:
  put:
    summary: Update position
    # ... specification
```

## Testing Checklist
- [x] Validation layer tests (90%+ coverage)
- [x] Service layer tests (90%+ coverage)
- [x] Controller layer tests (90%+ coverage)
- [x] All tests passing
- [x] Manual testing completed
```

---

### Paso 3: Implementar

**Comando:**
```
Actúa como Backend Developer
/develop-backend @SCRUM-10_backend.md
```

**La IA ejecuta:**
```
✅ Created branch: feature/SCRUM-10-backend
✅ Implemented validatePositionUpdate in validator.ts
✅ Implemented updatePositionService in positionService.ts
✅ Implemented updatePosition controller
✅ Added PUT /:id route
✅ Wrote validation layer tests (95% coverage)
✅ Wrote service layer tests (93% coverage)
✅ Wrote controller layer tests (91% coverage)
✅ Updated api-spec.yml
✅ All tests passing
✅ Ready for commit
```

---

### Paso 4: Tests

**Verificar cobertura:**
```bash
npm run test:coverage
```

**Output:**
```
PASS  src/application/__tests__/validator.test.ts
PASS  src/application/services/__tests__/positionService.test.ts
PASS  src/presentation/controllers/__tests__/positionController.test.ts

---------------------------|---------|----------|---------|---------|
File                       | % Stmts | % Branch | % Funcs | % Lines |
---------------------------|---------|----------|---------|---------|
All files                  |   92.5  |   91.2   |   93.1  |   92.8  |
 validator.ts              |   95.3  |   94.1   |   96.2  |   95.5  |
 positionService.ts        |   93.2  |   90.5   |   91.8  |   93.4  |
 positionController.ts     |   91.4  |   89.3   |   92.4  |   91.7  |
---------------------------|---------|----------|---------|---------|

Test Suites: 3 passed, 3 total
Tests:       47 passed, 47 total
```

---

### Paso 5: Documentación

**Comando:**
```
/update-docs
```

**Output:**
```
✅ Updated api-spec.yml - Added PUT /positions/:id endpoint
✅ Verified data-model.md - No changes needed
✅ No changes to development_guide.md required

Documentation updated successfully.
```

---

### Paso 6: Commit

**Comando:**
```
/commit
```

**Output generado:**
```
feat(positions): add update position endpoint

- Implement PUT /positions/:id endpoint
- Add validatePositionUpdate function with comprehensive validation rules
  - Title, status, salary, date validations
  - Reference validations (company, interview flow)
- Add updatePositionService with business logic
  - Position existence check
  - Data merging for partial updates
  - Reference validation
- Add updatePosition controller with HTTP handling
  - Request validation
  - Appropriate HTTP status codes
  - Descriptive error messages
- Add PUT /:id route to position routes
- Write comprehensive tests (92% average coverage)
  - 47 test cases across 3 test suites
  - Validation layer tests (95% coverage)
  - Service layer tests (93% coverage)
  - Controller layer tests (91% coverage)
- Update API documentation (api-spec.yml)
  - Added endpoint specification
  - Request/response schemas
  - Error response formats

All features tested and documented per backend-standards.mdc.

Resolves SCRUM-10
```

**Ejecutar:**
```bash
git add .
git commit -m "[mensaje generado]"
git push origin feature/SCRUM-10-backend
```

---

## 📱 Ejemplo 2: Feature Frontend Completa

### Scenario
Crear formulario de edición de posición en React.

**Ticket:** SCRUM-11 - Edit Position Form

### Paso 1: Planificar

```
Actúa como Frontend Developer
/plan-frontend-ticket SCRUM-11
```

**Output (`SCRUM-11_frontend.md` - extracto):**
```markdown
# Frontend Implementation Plan: SCRUM-11

## Overview
Create EditPosition component with React, TypeScript, and Bootstrap.
Integrates with PUT /positions/:id API.

## Component Structure

```
src/
├── components/
│   └── positions/
│       ├── EditPosition.tsx      # Main component
│       └── EditPosition.test.tsx # Unit tests
├── services/
│   └── positionService.ts        # API integration
└── cypress/
    └── e2e/
        └── edit-position.cy.ts   # E2E tests
```

## Implementation Steps

### Step 1: Update Position Service

**File:** `frontend/src/services/positionService.ts`

```typescript
export const positionService = {
    // ... existing methods
    
    updatePosition: async (id: number, data: UpdatePositionData) => {
        try {
            const response = await axios.put(
                `${API_BASE_URL}/positions/${id}`, 
                data
            );
            return response.data;
        } catch (error) {
            console.error('Error updating position:', error);
            throw error;
        }
    }
};
```

### Step 2: Create EditPosition Component

**File:** `frontend/src/components/positions/EditPosition.tsx`

```typescript
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Container, Form, Button, Alert } from 'react-bootstrap';
import { positionService } from '../../services/positionService';

type EditPositionProps = {};

const EditPosition: React.FC<EditPositionProps> = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        status: 'Open',
        location: '',
        salaryMin: '',
        salaryMax: ''
    });
    
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    
    useEffect(() => {
        loadPosition();
    }, [id]);
    
    const loadPosition = async () => {
        try {
            setLoading(true);
            const position = await positionService.getPositionById(Number(id));
            setFormData(position);
        } catch (err) {
            setError('Failed to load position');
        } finally {
            setLoading(false);
        }
    };
    
    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };
    
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        
        try {
            setSaving(true);
            setError('');
            
            await positionService.updatePosition(Number(id), formData);
            
            setSuccess('Position updated successfully!');
            setTimeout(() => navigate('/positions'), 2000);
        } catch (err: any) {
            setError(err.response?.data?.error || 'Failed to update position');
        } finally {
            setSaving(false);
        }
    };
    
    if (loading) return <div>Loading...</div>;
    
    return (
        <Container>
            <h2>Edit Position</h2>
            
            {error && <Alert variant="danger">{error}</Alert>}
            {success && <Alert variant="success">{success}</Alert>}
            
            <Form onSubmit={handleSubmit}>
                <Form.Group className="mb-3">
                    <Form.Label>Title *</Form.Label>
                    <Form.Control
                        type="text"
                        name="title"
                        value={formData.title}
                        onChange={handleInputChange}
                        required
                        maxLength={100}
                    />
                </Form.Group>
                
                <Form.Group className="mb-3">
                    <Form.Label>Status *</Form.Label>
                    <Form.Select
                        name="status"
                        value={formData.status}
                        onChange={handleInputChange}
                        required
                    >
                        <option value="Open">Open</option>
                        <option value="Contratado">Contratado</option>
                        <option value="Cerrado">Cerrado</option>
                        <option value="Borrador">Borrador</option>
                    </Form.Select>
                </Form.Group>
                
                {/* More form fields ... */}
                
                <Button type="submit" disabled={saving}>
                    {saving ? 'Saving...' : 'Save Changes'}
                </Button>
                
                <Button 
                    variant="secondary" 
                    onClick={() => navigate('/positions')}
                    className="ms-2"
                >
                    Cancel
                </Button>
            </Form>
        </Container>
    );
};

export default EditPosition;
```

### Step 3: Write E2E Tests

**File:** `frontend/cypress/e2e/edit-position.cy.ts`

```typescript
describe('Edit Position Flow', () => {
    const API_URL = Cypress.env('API_URL');
    
    beforeEach(() => {
        cy.visit('/positions/1/edit');
    });
    
    it('should load position data', () => {
        cy.get('[name="title"]').should('have.value', 'Existing Title');
        cy.get('[name="status"]').should('have.value', 'Open');
    });
    
    it('should update position successfully', () => {
        cy.get('[name="title"]').clear().type('Updated Title');
        cy.get('[name="description"]').clear().type('Updated description');
        cy.get('button[type="submit"]').click();
        
        cy.get('.alert-success')
            .should('contain', 'Position updated successfully');
    });
    
    it('should show error on validation failure', () => {
        cy.get('[name="title"]').clear();
        cy.get('button[type="submit"]').click();
        
        cy.get('.alert-danger')
            .should('contain', 'Title is required');
    });
});
```

### Step 4: Write Unit Tests

**File:** `frontend/src/components/positions/EditPosition.test.tsx`

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import EditPosition from './EditPosition';
import { positionService } from '../../services/positionService';

jest.mock('../../services/positionService');

describe('EditPosition Component', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });
    
    it('should render form with loaded data', async () => {
        const mockPosition = {
            id: 1,
            title: 'Test Position',
            status: 'Open'
        };
        
        (positionService.getPositionById as jest.Mock)
            .mockResolvedValue(mockPosition);
        
        render(
            <BrowserRouter>
                <EditPosition />
            </BrowserRouter>
        );
        
        await waitFor(() => {
            expect(screen.getByDisplayValue('Test Position')).toBeInTheDocument();
        });
    });
    
    // ... more tests
});
```
```

---

### Paso 2: Implementar

```
Actúa como Frontend Developer
/develop-frontend @SCRUM-11_frontend.md
```

**La IA ejecuta:**
```
✅ Created branch: feature/SCRUM-11-frontend
✅ Updated positionService with updatePosition method
✅ Created EditPosition component
✅ Implemented form state management
✅ Added Bootstrap styling
✅ Wrote E2E tests with Cypress (3 test cases)
✅ Wrote unit tests with Jest + RTL (8 test cases)
✅ All tests passing
✅ Component is responsive
✅ Ready for commit
```

---

## 🔄 Ejemplo 3: Fix de Bug

### Scenario
Bug report: El endpoint de actualización no valida correctamente el applicationDeadline.

**Ticket:** BUG-42 - Fix date validation in position update

### Paso 1: Identificar el

 Problema

**Investigación:**
```
/explain how date validation works in validatePositionUpdate
```

**La IA explica el código actual y encuentra el bug.**

### Paso 2: Fix

**Comando:**
```
Actúa como Backend Developer

Fix the date validation in validatePositionUpdate:
- Currently allows past dates
- Should only allow future dates
- Today should be valid
```

**La IA:**
```typescript
// Before (bugged)
if (data.applicationDeadline !== undefined) {
    const deadline = new Date(data.applicationDeadline);
    if (isNaN(deadline.getTime())) {
        throw new Error('Invalid application deadline');
    }
    // ❌ No check for past dates!
}

// After (fixed)
if (data.applicationDeadline !== undefined) {
    const deadline = new Date(data.applicationDeadline);
    if (isNaN(deadline.getTime())) {
        throw new Error('Invalid application deadline');
    }
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    deadline.setHours(0, 0, 0, 0);
    
    if (deadline < today) {
        throw new Error('Application deadline cannot be in the past');
    }
}
```

### Paso 3: Agregar Tests

```typescript
// Test for past date
it('should throw error when applicationDeadline is in the past', () => {
    const yesterday = new Date(Date.now() - 86400000);
    expect(() => validatePositionUpdate({ 
        applicationDeadline: yesterday.toISOString() 
    })).toThrow('Application deadline cannot be in the past');
});

// Test for today (should pass)
it('should accept today as applicationDeadline', () => {
    const today = new Date().toISOString();
    expect(() => validatePositionUpdate({ 
        applicationDeadline: today 
    })).not.toThrow();
});
```

### Paso 4: Commit

```
/commit
```

**Output:**
```
fix(validation): prevent past dates in applicationDeadline

- Add date comparison logic to validatePositionUpdate
- Set time to 00:00:00 for accurate day comparison
- Reject dates before today
- Accept today and future dates
- Add test for past date rejection
- Add test for today acceptance

Fixes BUG-42
```

---

## 🎓 Lecciones y Tips

### Para Features Nuevas
1. Siempre comenzar con `/enrich-us` si la US no está detallada
2. Generar plan antes de implementar
3. Review el plan cuidadosamente
4. Seguir el plan paso a paso
5. No saltar tests
6. Actualizar docs mandatory

### Para Bugs
1. Reproducir el bug primero2. Identificar la causa raíz
3. Escribir test que falle (reproduce el bug)
4. Fix el código
5. Verificar que el test ahora pasa
6. Agregar regression tests

### Para Refactoring
1. Tests comprehensivos ANTES de refactorizar
2. Refactorizar en pequeños pasos
3. Run tests después de cada paso
4. No cambiar behavior
5. Update docs si API cambió

---

**¡Has completado la documentación de AI-Specs!**

Ahora tienes todo el conocimiento necesario para usar el sistema efectivamente.

**Próximos pasos:**
1. Importar AI-Specs a tu proyecto
2. Adaptar los estándares a tu tech stack
3. Crear comandos específicos de tu proyecto
4. Definir agentes personalizados si es necesario

**Última actualización:** Marzo 2025
