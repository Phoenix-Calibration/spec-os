# Estándares de Desarrollo

## 📚 Visión General

AI-Specs define estándares completos para tres áreas principales:

1. **Backend Development** - Node.js, TypeScript, Express, Prisma
2. **Frontend Development** - React, TypeScript, Bootstrap
3. **Documentation** - Technical docs y AI specs

---

## 🔧 Backend Standards

### Technology Stack

**Core Technologies:**
- Node.js (Runtime)
- TypeScript 4.9.5+ (Type safety)
- Express.js (Web framework)
- Prisma (ORM)
- PostgreSQL (Database)

**Testing:**
- Jest (Unit & Integration)
- Coverage threshold: 90% minimum
- Test location: `__tests__/` directories

**Deployment:**
- AWS Lambda (Serverless)
- Serverless Framework

### Project Structure

```
backend/
├── src/
│   ├── domain/              # Domain layer (entities, interfaces)
│   │   ├── models/
│   │   └── repositories/
│   ├── application/         # Application layer (business logic)
│   │   ├── services/
│   │   └── validator.ts
│   ├── presentation/        # Presentation layer (HTTP)
│   │   └── controllers/
│   ├── infrastructure/      # Infrastructure (DB, logger)
│   │   ├── logger.ts
│   │   └── prismaClient.ts
│   ├── routes/
│   ├── middleware/
│   ├── index.ts
│   └── lambda.ts
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── test-utils/
│   ├── builders/
│   └── mocks/
├── jest.config.js
├── tsconfig.json
└── serverless.yml
```

### Naming Conventions

```typescript
// Variables y funciones: camelCase
const candidateId = 1;
function findCandidateById() { }

// Clases e Interfaces: PascalCase
class Candidate { }
interface ICandidateRepository { }

// Constantes: UPPER_SNAKE_CASE
const MAX_CANDIDATES_PER_PAGE = 50;

// Archivos: camelCase
// candidateService.ts
// candidateController.ts
```

### API Design Standards

**RESTful Endpoints:**
```
GET    /candidates          # List all
GET    /candidates/:id      # Get by ID
POST   /candidates          # Create new
PUT    /candidates/:id      # Update
DELETE /candidates/:id      # Delete
```

**Response Format:**
```typescript
// Success (200)
{
    "success": true,
    "data": { ... },
    "message": "Operation completed successfully"
}

// Error (400/404/500)
{
    "success": false,
    "error": {
        "message": "Error description",
        "code": "ERROR_CODE"
    }
}
```

**HTTP Status Codes:**
- 200: Success
- 201: Created
- 400: Bad Request (validation errors)
- 404: Not Found
- 500: Internal Server Error

### Error Handling

```typescript
// Custom error classes
export class NotFoundError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'NotFoundError';
    }
}

// In controller
try {
    const candidate = await candidateService.findById(id);
    if (!candidate) {
        throw new NotFoundError('Candidate not found');
    }
    res.json(candidate);
} catch (error) {
    next(error);
}
```

### Testing Standards

**Test Structure (AAA Pattern):**
```typescript
describe('CandidateService - findById', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should return candidate when found', async () => {
        // Arrange - Setup test data
        const candidateId = 1;
        const mockCandidate = new Candidate({ id: 1, firstName: 'John' });
        (CandidateRepository.findById as jest.Mock)
            .mockResolvedValue(mockCandidate);

        // Act - Execute function
        const result = await candidateService.findById(candidateId);

        // Assert - Verify results
        expect(result).toEqual(mockCandidate);
        expect(CandidateRepository.findById)
            .toHaveBeenCalledWith(candidateId);
    });
});
```

**Naming Convention:**
```typescript
// Describe blocks: Component - method
describe('PositionService - updatePosition', () => {
    // Test blocks: should_[behavior]_when_[condition]
    it('should_update_position_when_valid_data_provided', async () => {
        // Test implementation
    });
});
```

**Coverage Requirements:**
- Branches: 90%
- Functions: 90%
- Lines: 90%
- Statements: 90%

---

## 🎨 Frontend Standards

### Technology Stack

**Core:**
- React 18.3.1 (Functional components + hooks)
- TypeScript 4.9.5
- Create React App 5.0.1
- React Router DOM 6.23.1

**UI:**
- Bootstrap 5.3.3
- React Bootstrap 2.10.2
- React Bootstrap Icons 1.11.4
- React DatePicker 6.9.0

**Testing:**
- Cypress 14.4.1 (E2E)
- Jest (Unit)
- React Testing Library

### Project Structure

```
frontend/
├── public/
├── src/
│   ├── components/         # Reusable components
│   ├── services/          # API service layer
│   ├── pages/             # Page components
│   ├── assets/            # Images, fonts
│   ├── App.js
│   ├── index.tsx
│   └── index.css
├── cypress/
│   └── e2e/               # E2E tests
├── package.json
├── tsconfig.json
└── cypress.config.ts
```

### Component Conventions

**Functional Components:**
```typescript
// ✅ Preferred - TypeScript functional component
import React, { useState, useEffect } from 'react';

type CandidateCardProps = {
    candidate: Candidate;
    index: number;
    onClick: (candidate: Candidate) => void;
};

const CandidateCard: React.FC<CandidateCardProps> = ({ 
    candidate, 
    index, 
    onClick 
}) => {
    const [isLoading, setIsLoading] = useState(false);
    
    const handleCardClick = () => {
        onClick(candidate);
    };
    
    return (
        <div className="candidate-card" onClick={handleCardClick}>
            {/* Component JSX */}
        </div>
    );
};

export default CandidateCard;
```

### State Management

**Local State:**
```javascript
const [formData, setFormData] = useState({
    title: '',
    description: '',
    status: 'Borrador'
});

const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
        ...prev,
        [name]: value
    }));
};
```

**Loading & Error States:**
```javascript
const [loading, setLoading] = useState(true);
const [error, setError] = useState('');
const [success, setSuccess] = useState('');

try {
    setLoading(true);
    const data = await apiCall();
    setSuccess('Operation completed successfully');
} catch (error) {
    setError('Error message: ' + error.message);
} finally {
    setLoading(false);
}
```

### Service Layer

```javascript
// candidateService.js
import axios from 'axios';

const API_BASE_URL = 'http://localhost:3010';

export const candidateService = {
    getAllCandidates: async () => {
        try {
            const response = await axios.get(`${API_BASE_URL}/candidates`);
            return response.data;
        } catch (error) {
            console.error('Error fetching candidates:', error);
            throw error;
        }
    },
    
    updateCandidate: async (id, data) => {
        try {
            const response = await axios.put(
                `${API_BASE_URL}/candidates/${id}`, 
                data
            );
            return response.data;
        } catch (error) {
            console.error('Error updating candidate:', error);
            throw error;
        }
    }
};
```

### Testing (Cypress)

```typescript
describe('Positions API - Update', () => {
    beforeEach(() => {
        cy.window().then((win) => {
            win.localStorage.clear();
        });
    });

    it('should update a position successfully', () => {
        const updateData = {
            title: 'Updated Test Position',
            status: 'Open'
        };

        cy.request({
            method: 'PUT',
            url: `${API_URL}/positions/${testPositionId}`,
            body: updateData
        }).then((response) => {
            expect(response.status).to.eq(200);
            expect(response.body.data.title).to.eq(updateData.title);
        });
    });
});
```

---

## 📝 Documentation Standards

### General Rules

1. **ALWAYS WRITE IN ENGLISH** - Code, comments, docs, tickets
2. **Update before commits** - Mandatory review process
3. **Maintain consistency** - Follow established structure

### Files to Update

**When API changes:**
- `api-spec.yml` - OpenAPI specification

**When data model changes:**
- `data-model.md` - Database schemas

**When setup changes:**
- `development_guide.md` - Installation, workflows
- `*-standards.mdc` - Process changes

### Update Process

**Mandatory before commit:**

1. Review recent changes in codebase
2. Identify which docs need updates
3. Update each affected doc file (in English)
4. Ensure proper formatting
5. Verify changes are reflected
6. Report which files were updated

**Example Update:**

```yaml
# api-spec.yml
/positions/{id}:
  put:
    summary: Update position
    description: Update an existing position. Supports partial updates.
    tags:
      - Positions
    parameters:
      - in: path
        name: id
        required: true
        schema:
          type: integer
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/UpdatePositionRequest'
    responses:
      '200':
        description: Position updated successfully
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdatePositionResponse'
      '400':
        description: Validation error
      '404':
        description: Position not found
      '500':
        description: Internal server error
```

---

## 🎯 Code Quality Standards

### TypeScript

**Strict Mode ON:**
```json
// tsconfig.json
{
    "compilerOptions": {
        "strict": true,
        "noImplicitAny": true,
        "strictNullChecks": true
    }
}
```

**Explicit Types:**
```typescript
// ✅ Good
async function findById(id: number): Promise<Candidate | null> {
    return await repository.findById(id);
}

// ❌ Avoid
function findById(id) {
    return repository.findById(id);
}
```

### ESLint

- No errors allowed
- Consistent code style
- Auto-formatting enabled

### Git Workflow

**Feature Branches:**
```bash
feature/SCRUM-10-backend
feature/SCRUM-15-frontend
```

**Commit Messages:**
```
feat(positions): add update position endpoint

- Implement PUT /positions/:id
- Add validation function
- Add service and controller
- Write comprehensive tests (90%+ coverage)
- Update API documentation

Resolves SCRUM-10
```

---

## ✅ Checklist de Calidad

### Antes de Commit

- [ ] TypeScript compiles without errors
- [ ] ESLint passes without warnings
- [ ] All tests pass (npm test)
- [ ] Coverage ≥ 90% (npm run test:coverage)
- [ ] All code in English
- [ ] No console.log statements
- [ ] Documentation updated
- [ ] Descriptive commit message prepared

### Antes de PR

- [ ] Feature branch up to date with main
- [ ] No merge conflicts
- [ ] All tests pass on CI
- [ ] Code review checklist completed
- [ ] Breaking changes documented

---

**Próximo paso:** Lee [Sistema de Comandos](./04-comandos.md) para aprender a usar los comandos disponibles.

**Última actualización:** Marzo 2025