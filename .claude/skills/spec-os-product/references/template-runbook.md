# Template — docs/runbooks/

Use this template when creating the `docs/runbooks/` folder index or any runbook file inside it.

Runbooks document how to perform operational tasks — deployments, incident response,
maintenance procedures, environment setup. They are written for the person on call
or the developer who needs to act quickly without deep context.

---

## README.md (folder index)

```markdown
# runbooks/

Operational procedures for development and production workflows.

## Suggested files (create as needed)

| File | Purpose |
|------|---------|
| deployment.md | Deploy to staging or production |
| rollback.md | Undo a deployment or migration |
| testing.md | Run test suites and interpret results |
| debugging.md | Common debugging procedures |
| build.md | Build pipeline and artifact creation |
| database-migration.md | Run and verify database migrations |
| incident-response.md | What to do when something breaks |
| {environment}-setup.md | Environment setup (e.g. local-setup.md) |

## Agent instructions

Read the relevant runbook before executing any operational task.
Never skip the Verification section. Never skip the Rollback section when undoing changes.
```

---

## Naming convention

```
docs/runbooks/
  deployment.md           ← deployment procedure
  rollback.md             ← rollback procedure
  testing.md              ← running test suites
  debugging.md            ← common debugging procedures
  build.md                ← build pipeline and artifacts
  database-migration.md   ← running and verifying migrations
  incident-response.md    ← what to do when something breaks
  {environment}-setup.md  ← environment setup (e.g. local-setup.md, staging-setup.md)
  {operation}.md          ← any other repeatable operational task
```

## Writing principles

- **Written for someone under pressure.** Assume the reader is stressed and time-constrained.
  Use numbered steps. No ambiguity. No "it depends" without an explicit branch.
- **Commands are copy-paste ready.** Every command shown must be runnable as-is,
  with `{placeholders}` clearly marked where substitution is needed.
- **Include expected output.** After key steps, show what success looks like.
- **Include failure signals.** What does a failed step look like? What to do next?

---

## Template

```markdown
# {Runbook Title}

> Last updated: {ISO-date}
> Owner: {team or role responsible for keeping this current}
> Applies to: {project name | all | specific environment}
> Estimated time: {N minutes | N–M minutes}

## Purpose
{One sentence: what this runbook accomplishes and when to use it.}

## Prerequisites

Before starting, verify:

- [ ] {Access requirement or tool installed}
- [ ] {Permission or credential needed}
- [ ] {Environment state that must be true}

## Steps

### 1. {Step title}

```{shell}
{command}
```

Expected output:
```
{what you should see on success}
```

If this fails: {what to check or do next}

---

### 2. {Step title}

```{shell}
{command}
```

Expected output:
```
{what you should see on success}
```

If this fails: {what to check or do next}

---

### 3. {Step title}

{Steps that require judgment rather than a command — describe clearly what to look for
and what constitutes a passing or failing state.}

---

## Verification

After completing all steps, verify the operation succeeded:

- [ ] {Observable success criterion 1}
- [ ] {Observable success criterion 2}

## Rollback

If the operation needs to be undone:

{Either link to the rollback runbook or provide inline rollback steps.}

## Escalation

If this runbook does not resolve the situation:

- Contact: {team or person}
- Channel: {Slack channel, Teams channel, or on-call rotation}
- Ticket: {link to incident tracker or escalation process}
```
