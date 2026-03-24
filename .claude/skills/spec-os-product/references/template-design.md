# Template — docs/design/

Reference for creating and maintaining the `docs/design/` folder and all its files.

---

## Folder structure

```
docs/design/
  README.md               ← index of all design files (always exists)
  00-overview.md          ← system history, architecture overview, future technical vision
  01-stack.md             ← technologies, frameworks, versions
  02-security.md          ← auth, authorization, data protection
  03-performance.md       ← targets, caching strategy, optimization
  04-metrics.md           ← KPIs, monitoring, alerting
  05-data-model.md        ← core entities, relationships, value objects
  06-integrations.md      ← external systems, APIs, webhooks
  07-error-handling.md    ← error types, patterns, API responses
  08-glossary.md          ← domain terminology with precise definitions
  09-design-system.md     ← UI components, palette, typography, patterns
  adr/
    README.md             ← ADR index and format guide (see template-adr.md)
```

**Base files (00–09):** always created, never renamed or deleted.
**Dynamic files (10+):** created by agent when justified. Must include a one-line justification in the file header. Same naming convention: `{number}-{kebab-title}.md`.

---

## README.md

```markdown
# design/

Technical, functional, and visual design of the solution.

## Base files (always exist, never renamed or deleted)

| File                 | Content                                        |
|----------------------|------------------------------------------------|
| 00-overview.md       | System history, architecture overview, future technical vision |
| 01-stack.md          | Technologies, frameworks, versions             |
| 02-security.md       | Auth, authorization, data protection           |
| 03-performance.md    | Targets, caching strategy, optimization        |
| 04-metrics.md        | KPIs, monitoring, alerting                     |
| 05-data-model.md     | Core entities, relationships, value objects    |
| 06-integrations.md   | External systems, APIs, webhooks               |
| 07-error-handling.md | Error types, patterns, API responses           |
| 08-glossary.md       | Domain terminology with precise definitions    |
| 09-design-system.md  | UI components, palette, typography, patterns   |

## Dynamic files (agent creates when justified)

Files 10- and above. Agent must include a one-line justification
in the file header. Follow same naming: `{number}-{kebab-title}.md`

## adr/ subfolder

Architecture Decision Records. One file per significant decision.
See `adr/README.md` for format.

## Agent instructions

When generating a spec.md:
1. Always read `00-overview.md`
2. Read the relevant domain file from `spec-os/specs/{domain}/spec.md`
3. Read only design files relevant to the feature
4. Do NOT load all files — only what is relevant
5. Never contradict an accepted ADR without flagging it
```

---

## 00-overview.md

```markdown
# {Product Name} — Overview

> Last updated: {ISO-date}
> Status: {active | draft}
> Product context: see [docs/mission.md](../mission.md)

## History
{How the product came to be and major evolutionary milestones.
Useful context for understanding design decisions. Brief — 3-5 bullet points max.}

## Architecture overview
{High-level description of the system architecture.
How the main parts connect. Prefer a text diagram if helpful.}

## Future vision
{Where the system is technically headed — infrastructure, scalability, architectural evolution.
Strategic direction only — not a feature list. For product roadmap see docs/roadmap.md.}
```

---

## 01-stack.md

```markdown
# Stack

> Last updated: {ISO-date}

## Languages & runtimes

| Language | Version | Usage |
|----------|---------|-------|
| {lang}   | {x.y.z} | {what it's used for} |

## Frameworks

| Framework | Version | Usage |
|-----------|---------|-------|
| {name}    | {x.y.z} | {what it's used for} |

## Key libraries

| Library | Version | Purpose |
|---------|---------|---------|
| {name}  | {x.y.z} | {why it's used} |

## Infrastructure

| Component | Provider / Tool | Notes |
|-----------|----------------|-------|
| Hosting   | {provider}     | {details} |
| Database  | {db + version} | {details} |
| Cache     | {tool}         | {details} |
| CI/CD     | {tool}         | {details} |

## Deprecated / migration in progress
{List anything being phased out and its replacement, if applicable.}
```

---

## 02-security.md

```markdown
# Security

> Last updated: {ISO-date}

## Authentication
{How users authenticate. Protocol, provider, token strategy.}

## Authorization
{How access is controlled. Roles, permissions model, enforcement layer.}

## Data protection
{Encryption at rest, encryption in transit, PII handling, retention policies.}

## Secrets management
{Where credentials and secrets are stored and how they are accessed at runtime.}

## Known constraints / accepted risks
{Security trade-offs accepted and why. Be honest — this section prevents surprises.}
```

---

## 03-performance.md

```markdown
# Performance

> Last updated: {ISO-date}

## Targets

| Metric | Target | Measured at |
|--------|--------|-------------|
| {e.g. API p95 latency} | {e.g. < 200ms} | {load level} |
| {e.g. page load time}  | {e.g. < 2s}    | {condition}  |

## Caching strategy
{What is cached, where (client / CDN / server / DB), and for how long.}

## Known bottlenecks
{Areas identified as performance risks or already observed as slow.}

## Optimization decisions
{Architectural or implementation choices made specifically for performance.}
```

---

## 04-metrics.md

```markdown
# Metrics & Monitoring

> Last updated: {ISO-date}

## Business KPIs
{Key business metrics the system must support measuring.}

| KPI | Definition | How measured |
|-----|-----------|--------------|
| {name} | {what it measures} | {data source / event} |

## Technical metrics
{System health metrics: error rate, latency, throughput, availability.}

## Alerting
{What triggers an alert, at what threshold, and who is notified.}

| Alert | Condition | Severity | Notification |
|-------|-----------|----------|-------------|
| {name} | {threshold} | {critical/warning} | {channel} |

## Dashboards
{Links to active monitoring dashboards, if any.}
```

---

## 05-data-model.md

```markdown
# Data Model

> Last updated: {ISO-date}

## Core entities

### {EntityName}
{What this entity represents in the domain.}

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| {field} | {type} | {yes/no} | {description} |

### {EntityName}
...

## Relationships
{How entities relate to each other. Use text diagram if helpful.}

## Value objects
{Immutable domain concepts that have no identity — e.g. Money, Address, DateRange.}

| Value object | Fields | Invariants |
|-------------|--------|-----------|
| {name} | {fields} | {rules it enforces} |

## Status enumerations
{All status/state fields with their valid values and transition rules.}
```

---

## 06-integrations.md

```markdown
# Integrations

> Last updated: {ISO-date}

## External systems

### {System Name}
- **Direction:** {inbound | outbound | bidirectional}
- **Protocol:** {REST | GraphQL | SOAP | event | file | other}
- **Authentication:** {how we authenticate to this system}
- **Trigger:** {what triggers the integration}
- **Data exchanged:** {what is sent/received}
- **Error handling:** {what happens on failure}
- **SLA / rate limits:** {any constraints imposed by the external system}

---

### {System Name}
...

## Webhooks received
{External systems that push events to this system.}

| Source | Event | Endpoint | Validation |
|--------|-------|----------|-----------|
| {system} | {event type} | {our endpoint} | {how we validate the payload} |
```

---

## 07-error-handling.md

```markdown
# Error Handling

> Last updated: {ISO-date}

## Error categories

| Category | Description | Examples |
|----------|-------------|---------|
| Validation | Input does not meet requirements | Missing field, invalid format |
| Authorization | Request not permitted | Insufficient role, expired token |
| Not found | Resource does not exist | Invalid ID |
| Conflict | State prevents the operation | Duplicate, optimistic lock |
| External | Third-party system failure | API timeout, webhook failure |
| Internal | Unexpected system error | Unhandled exception |

## API response format
{Standard error response structure returned by the API.}

```json
{
  "error": {
    "code": "{machine-readable code}",
    "message": "{human-readable message}",
    "details": [{}]
  }
}
```

## Retry policy
{Which operations are retried, how many times, with what backoff strategy.}

## Logging
{What is logged on error, at what level, and where.}

## Dead-letter / fallback
{What happens to failed messages or jobs that cannot be retried.}
```

---

## 08-glossary.md

```markdown
# Glossary

> Last updated: {ISO-date}

Domain terminology with precise definitions. When a term has a specific meaning
in this system that differs from common usage, make that explicit.

---

**{Term}**
{Definition. Be precise — vague glossary entries are worse than no glossary.
Include: what the term means in this domain, how it differs from common usage if relevant,
and which other terms it relates to.}

---

**{Term}**
{Definition.}
```

---

## 09-design-system.md

```markdown
# Design System

> Last updated: {ISO-date}
> Note: skip this file if the product has no UI layer.

## Color palette

| Token | Value | Usage |
|-------|-------|-------|
| {token-name} | {hex / var} | {when to use} |

## Typography

| Role | Font | Size | Weight |
|------|------|------|--------|
| Heading 1 | {font} | {size} | {weight} |
| Body | {font} | {size} | {weight} |

## Spacing scale
{Base unit and scale used for margins, padding, gaps.}

## Component library
{Name and version of the UI component library in use, if any.
Link to Storybook or equivalent if available.}

## Key patterns

### {Pattern name}
{When to use this pattern and how it behaves.}
```

---

## adr/README.md

```markdown
# Architecture Decision Records

One file per significant architectural decision.
See `template-adr.md` in the skill references for the full ADR format.

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| 001 | {title} | {proposed | accepted | superseded} | {date} |

## When to write an ADR

- Choosing between two or more viable technical approaches
- Adopting a new framework, library, or external service
- Establishing a pattern that will be followed across the codebase
- Making a trade-off that accepts known downsides
- Superseding a previous architectural decision
```
