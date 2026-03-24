# Scan Patterns — /spec-os-discover

Detailed strategies for extracting conventions from the codebase, organized by standard file.
Read this file during Step 2 of the discovery process.

---

## global/naming

**What to look for:** consistent casing, prefixes, suffixes, and structural patterns used across the project.

**Scan:**
- File names: `Glob("**/*.{cs,ts,py,js,tsx,jsx}")` — sample 20–30 files across directories
- Class and interface names: `Grep("^(public |private )?(class|interface|abstract class)", **/*.{cs,ts,py})`
- Method/function names: look for consistent verb patterns (Get/Fetch/Load, Handle/Process, Create/Build)
- Variable names: look at parameter names in constructor/function signatures
- Database naming: check migration files, ORM models (`Grep("Table\(|TableName|__tablename__|_name =", **/*)`), entity files
- API endpoint paths: check controller route attributes, route files, OpenAPI definitions

**Extract:**
- Casing per context: files (kebab, PascalCase), classes (Pascal), variables (camel, snake), DB (snake, UPPER)
- Consistent suffixes or prefixes in use (`Service`, `Repository`, `Handler`, `Controller`, `Dto`, `ViewModel`, `use{Name}`)
- File naming pattern per type (e.g., `{Entity}Controller.cs`, `{Name}.service.ts`, `use{Name}.ts`)

---

## global/commits

**What to look for:** the actual commit format used in this repo.

**Scan:**
- Git log: `git log --oneline -30` — look at the last 30 commits
- Check for: type prefixes (feat/fix/chore), scope in parentheses, tracker ID format

**Extract:**
- Commit message format in use
- Types in use (not just what's possible — what's actually used)
- Whether tracker IDs appear and their format (e.g., `[F042-T01]`, `#123`, `AB#456`)
- Branch naming pattern (from `git branch -a` or `git log --format=%D`)

---

## global/security

**What to look for:** how the project handles credentials, auth, and sensitive data.

**Scan:**
- Environment variable access: `Grep("process\.env\.|os\.environ|Environment\.GetEnvironmentVariable|getenv", **/*)`
- Auth enforcement: `Grep("\[Authorize\]|\[Permission\]|@login_required|requireAuth|useAuth", **/*)`
- Secret management references: look for `.env` references, config files, mentions of Key Vault, AWS Secrets, etc.
- Sensitive data patterns: `Grep("password|token|secret|apikey|api_key", **/*.{cs,ts,py,js})` (case-insensitive, look for how they're accessed not stored)

**Extract:**
- How env vars are loaded and accessed (direct `process.env.X`, via config object, via DI)
- Auth enforcement mechanism (attribute, middleware, decorator, HOC)
- Whether secrets management tooling is referenced

---

## backend/architecture

**What to look for:** the actual layer structure in use.

**Scan:**
- Top-level directories: `Bash("ls -la")` or `Glob("*/")` — look for layer folder names
- Namespace roots: `Grep("^namespace |^from \.|^package ", **/*.{cs,py,java})` — sample 10–15 files
- Import/dependency patterns between layers: which namespaces import which
- Base class inheritance: `Grep("(IRepository|IService|BaseEntity|AggregateRoot|ValueObject)", **/*.{cs,ts,py})`

**Extract:**
- Layer names as they actually appear (e.g., `Domain`, `Application`, `Infrastructure`, `Presentation` — or `Core`, `Services`, `Data`, `Api`)
- Whether DDD patterns are in use: Aggregate, Repository pattern, Value Objects, Domain Events
- Dependency direction — what the scan shows actually importing what

---

## backend/patterns

**What to look for:** how services, commands, handlers, and DI are structured.

**Scan:**
- DI registration: `Grep("AddScoped|AddTransient|AddSingleton|services\.", **/Program.cs, **/Startup.cs)` or equivalent for the stack
- Service class structure: `Grep("class.*Service", **/*.cs)` — read one or two to see constructor injection patterns
- Command/Query/Handler: `Grep("IRequest|ICommandHandler|IQueryHandler|Command\b|Query\b|Handler\b", **/*.{cs,ts})` — CQRS indicator
- Interface naming: `Grep("^(public )?interface I[A-Z]", **/*.{cs,ts})` — check prefix convention

**Extract:**
- Whether CQRS (command/query/handler) is in use
- Service registration lifetimes (all Scoped? mix of Scoped/Singleton?)
- Interface naming convention (prefix `I`, no prefix, suffix `Interface`)
- Constructor vs property injection

---

## backend/testing

**What to look for:** test structure, naming, and tooling.

**Scan:**
- Test file locations: `Glob("**/*{Test,Tests,Spec,spec}.{cs,py,ts,js}")` and `Glob("**/*.test.{ts,js}")`
- Test class/method naming: read 2–3 test files to see naming patterns
- Mocking library: `Grep("using Moq|from unittest.mock|import jest|from pytest|vi\.mock", **/*.{cs,py,ts})`
- Test structure: look for Arrange/Act/Assert comments or Given/When/Then structure

**Extract:**
- Test file and folder naming convention
- Test method naming convention (e.g., `{Method}_Should{Outcome}_When{Condition}`, `test_{method}_{scenario}`)
- Mocking library in use
- Whether tests follow AAA or GWT structure

---

## backend/error-handling

**What to look for:** custom exceptions, error response shape, logging strategy.

**Scan:**
- Custom exception types: `Grep("class.*Exception|class.*Error", **/*.{cs,py,ts})`
- Try/catch patterns: read 2–3 service files to see exception handling approach
- API error response: `Grep("ProblemDetails|ErrorResponse|ApiException|IActionResult", **/*.cs)` or equivalent
- Result<T> pattern: `Grep("Result<|OneOf<|Either<|\.Success\(|\.Failure\(", **/*.{cs,ts})`
- Logging: `Grep("_logger\.|logging\.|ILogger|console\.error", **/*.{cs,py,ts})`

**Extract:**
- Custom exception hierarchy (base exception + domain-specific variants)
- Whether Result<T> or exception-throwing is the primary error pattern
- API error response shape (field names, HTTP status mapping)
- What gets logged on error and at what level

---

## backend/dotnet

**Scan:**
- Project files: `Glob("**/*.csproj")` — look at target framework and key packages
- Async patterns: `Grep("async Task|await |\.ConfigureAwait", **/*.cs)` — check ConfigureAwait usage
- EF Core: `Glob("**/Migrations/*.cs")` — read one migration; `Grep("DbContext|DbSet<|HasKey|HasForeignKey", **/*.cs)`
- Result pattern: `Grep("Result<|FluentResults|ErrorOr<|OneOf<", **/*.cs)`
- DI lifetime: check `Program.cs` or `Startup.cs` for `AddScoped/AddTransient/AddSingleton` patterns

**Extract:**
- Target framework (.NET version)
- Async convention (ConfigureAwait(false) everywhere? only in libraries?)
- EF Core conventions (fluent config vs data annotations, migration naming)
- Error strategy (exceptions, Result<T>, ErrorOr, etc.)

---

## backend/python

**Scan:**
- Type hints: `Grep("def .*->|: str|: int|: list\[|: dict\[|: Optional\[", **/*.py)`
- Framework: `Grep("from fastapi|from django|from flask|import uvicorn", **/*.py)`
- Pydantic: `Grep("BaseModel|Field\(|validator|model_validator", **/*.py)`
- Async: `Grep("async def |await |asyncio", **/*.py)`

**Extract:**
- Framework in use and version (from `pyproject.toml` or `requirements.txt`)
- Type hint coverage (comprehensive, partial, none)
- Pydantic usage patterns (request/response models, config, validators)
- Async vs sync convention

---

## backend/odoo

**Scan:**
- Module manifests: `Glob("**/__manifest__.py")` — read one to understand module structure
- Model declarations: `Grep("_name =|_inherit =|_inherits =", **/*.py)`
- ORM method overrides: `Grep("def create\(|def write\(|def unlink\(", **/*.py)`
- Wizard pattern: `Grep("TransientModel|models\.TransientModel", **/*.py)`
- View files: `Glob("**/*.xml")` — sample 1–2 form views

**Extract:**
- Module naming convention
- _inherit vs _name usage patterns (extension vs new model)
- Whether ORM method overrides use `super()` consistently
- Wizard vs wizard naming/folder convention

---

## frontend/components

**Scan:**
- Component files: `Glob("**/*.{tsx,jsx,vue,svelte}")` — sample 10–15 across features
- Props typing: `Grep("interface.*Props|type.*Props|PropTypes\.", **/*.{tsx,jsx,ts})`
- Export style: `Grep("export default |export const |export function ", **/*.{tsx,jsx})`
- Composition vs class: `Grep("React\.Component|extends Component", **/*.{tsx,jsx})` — presence means class components

**Extract:**
- Component file naming (PascalCase, kebab-case)
- Props interface naming convention
- Default vs named export convention
- Composition (functional) vs class components
- Folder structure: one file per component? or `{Name}/index.tsx` pattern?

---

## frontend/state

**Scan:**
- State libraries: `Grep("from 'zustand'|from 'jotai'|from 'redux'|from '@reduxjs|useRecoilState", **/*.{ts,tsx})`
- Context usage: `Grep("createContext|useContext|Provider", **/*.{ts,tsx})`
- Server state: `Grep("useQuery|useMutation|from 'react-query'|from '@tanstack/react-query'|useSWR|from 'swr'", **/*.{ts,tsx})`
- Local state: count `useState` vs `useReducer` occurrences

**Extract:**
- Libraries in use for each type of state
- Convention for context naming and location
- Whether server state (React Query/SWR) is centralized or co-located with components

---

## frontend/testing

**Scan:**
- Test files: `Glob("**/*.{test,spec}.{ts,tsx,js,jsx}")` and `Glob("**/cypress/**/*.{ts,js}")`, `Glob("**/e2e/**/*.{ts,js}")`
- Testing library: `Grep("@testing-library/react|vitest|jest|cypress|playwright", **/*.{ts,json})`
- Selectors: `Grep("data-testid|getByRole|getByText|getByLabelText", **/*.{ts,tsx,js})`

**Extract:**
- Test runner in use (Jest, Vitest, etc.)
- E2E tool in use (Cypress, Playwright, none)
- Primary selector strategy (data-testid? role-based? text-based?)
- Test file co-location vs separate `__tests__` folder

---

## frontend/nextjs

**Scan:**
- Router type: check for `app/` directory (App Router) vs `pages/` (Pages Router)
- Server/client components: `Grep("\"use client\"|'use client'", **/*.{ts,tsx})` — count occurrences
- Data fetching: `Grep("fetch\(|getServerSideProps|getStaticProps|generateStaticParams|loader\(", **/*.{ts,tsx})`
- Route handlers: `Glob("**/route.{ts,js}")` vs `Glob("**/api/**/*.{ts,js}")`

**Extract:**
- App Router vs Pages Router
- "use client" placement convention (component level? feature level?)
- Primary data fetching pattern (server component fetch, Route Handler, tRPC, etc.)
- Layout and template file conventions

---

## frontend/react

**Scan:**
- Custom hooks: `Grep("^export.*function use[A-Z]|^const use[A-Z].*=", **/*.{ts,tsx})`
- Performance: `Grep("useMemo|useCallback|React\.memo|memo\(", **/*.{tsx,ts})`
- Context creation: `Grep("createContext", **/*.{ts,tsx})` — read one to see pattern

**Extract:**
- Custom hook naming and location convention
- Whether memo/useMemo/useCallback are used proactively or sparingly
- Context creation pattern (separate file? co-located with provider? typed with generics?)
