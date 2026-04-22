---
name: project-planner
description: Plan a software project — new or existing — from a raw idea or a change request to a structured, executable technical plan. Use when the user wants to start something new, add a significant feature, refactor, migrate, or replan an existing system. Covers discovery (including codebase inspection for existing projects), scoping, architectural decisions, infrastructure, risks, and roadmap. Do not use for executing already-planned work — use the orchestrator skill for sequencing and coordination after the plan exists.
---

# Project Planner

## Overview

Turn an idea or a change request into an executable plan anchored in reality.

For new projects: guide structured discovery, brainstorming, and design from a blank slate.
For existing projects: inspect the codebase first, map the real current state, then plan the delta.

Every output section must reflect actual decisions made during this session — not generic template filler. If a section does not apply to this project, say why and omit it.

Know when to stop planning and start producing. The goal is a decision-ready artifact, not a perfect document.

## Setup

Run this check once at the start of every session, before the Opening message. It is silent if everything is already configured. If action is needed, handle it before proceeding.

### Step S1 — Detect the environment

Determine which platform is running this skill:

- **Claude CLI**: `~/.claude/` directory exists, or the skill was invoked as a slash command (`/project-planner`)
- **Codex**: skill was invoked via `$project-planner` or the `agents/openai.yaml` default prompt

If the environment cannot be determined, ask:

```
Você está usando Claude CLI ou Codex/OpenAI?
```

### Step S2 — Check global installation (Claude CLI only)

Check whether `~/.claude/commands/project-planner.md` exists:

**File exists** → installation is complete. Proceed silently to Opening.

**File does not exist** → show this message and wait for confirmation before proceeding:

```
[CONFIGURAÇÃO] Esta skill não está instalada globalmente no Claude CLI.

Sem a instalação global, ela só funciona dentro deste repositório.
Com a instalação, /project-planner fica disponível em qualquer projeto.

Para instalar agora via terminal (recomendado):

  Mac/Linux
  curl -fsSL https://raw.githubusercontent.com/valtervilmerson/agents-skill-planning/main/install.sh | bash

  Windows
  iex (irm https://raw.githubusercontent.com/valtervilmerson/agents-skill-planning/main/install.ps1)

Ou posso instalar agora nesta sessão:
  [S] Sim — instalar em ~/.claude/commands/project-planner.md
  [N] Não — continuar só nesta sessão, neste repositório
```

**If confirmed (S):**

Copy the full content of the current `skills/project-planner/SKILL.md` to `~/.claude/commands/project-planner.md`. Then confirm:

```
[CONFIGURAÇÃO] Instalado. /project-planner agora está disponível em qualquer projeto.
```

**If declined (N):**

```
[CONFIGURAÇÃO] Ok. A skill funcionará apenas neste repositório nesta sessão.
```

Proceed to Opening in both cases.

### Step S3 — Check Codex configuration (Codex only)

Check whether `skills/project-planner/agents/openai.yaml` exists in the current repository:

**File exists** → configuration is complete. Proceed silently to Opening.

**File does not exist** → the skill is not properly configured for Codex in this repository. Show:

```
[CONFIGURAÇÃO] O arquivo agents/openai.yaml não foi encontrado neste repositório.

Para usar esta skill via Codex neste projeto, é necessário copiar os arquivos:
  skills/project-planner/SKILL.md
  skills/project-planner/agents/openai.yaml

Deseja que eu crie a estrutura agora neste repositório?
  [S] Sim — criar os arquivos aqui
  [N] Não — continuar sem configurar
```

**If confirmed (S):**

Create `skills/project-planner/SKILL.md` and `skills/project-planner/agents/openai.yaml` in the current repository using the canonical content from this skill. Confirm when done.

**If declined (N):**

Proceed to Opening.

## Opening

When invoked, send this message and nothing else. Do not summarize the skill, do not list capabilities, do not ask multiple questions:

---

Olá! Vou te ajudar a transformar sua ideia em um plano técnico executável.

Primeira pergunta: **este é um projeto novo começando do zero, ou um projeto existente onde você quer planejar algo novo?**

Exemplos de "projeto existente": adicionar uma feature, refatorar, migrar tecnologia, corrigir um problema sistêmico, ou replanejar após mudança de requisitos.

---

Wait for the answer. That answer gates the entire workflow — do not proceed without it.

## Workflow

### 0. Determine project mode

This is the first question to ask and the gate for the entire workflow.

Ask the user:

```
Is this a new project starting from scratch, or an existing project where you want to
plan new work (feature, refactor, migration, fix, or extension)?
```

Based on the answer, choose a path:

- **`new-project`** → proceed to step 1 (Classification), then steps 2–12
- **`existing-project`** → proceed to step 1-E (Codebase Reconnaissance) before anything else, then steps 2–12 with existing-project adaptations

Do not assume. Do not infer from context. Ask explicitly. The answer changes what you must do before planning begins.

---

### [NEW PROJECT PATH]

### 1. Classify planning depth

Determine how much discovery is needed before producing the plan:

- `well-defined`: clear requirements, known constraints, defined users → go deep on architecture and infrastructure from the start
- `partially-defined`: core problem understood, some requirements open → plan the core, flag open areas explicitly
- `exploratory`: idea-stage, many open questions, problem itself may shift → run steps 2–4, then confirm with user before going deeper

In `exploratory` mode, do not produce a full plan in the first pass. Present findings from steps 2–4 and ask for confirmation before proceeding.

---

### [EXISTING PROJECT PATH]

### 1-E. Codebase reconnaissance (mandatory — do this before any planning)

For existing projects, you must understand what already exists before proposing anything. Planning without reading the code produces plans that conflict with reality.

#### 1-E.1 Understand what the user wants to do

Before reading the code, ask one focused question:

```
What do you want to do with this project? Examples:
  - Add a feature or capability
  - Fix a systemic problem or architectural issue
  - Refactor or restructure a part of the system
  - Migrate to a different technology or platform
  - Extend the system for a new use case or user type
  - Replan the project after requirements changed
```

This determines which parts of the code are most relevant to inspect first.

#### 1-E.2 Verify codebase access

Before inspecting, confirm whether you can read files directly:

- **Claude CLI** (working directory is the repo): proceed immediately with the inspection protocol below.
- **Codex or environment without direct file access**: ask the user before proceeding:

```
Para inspecionar o projeto existente, preciso acessar o código.
Você pode me indicar o caminho do repositório, ou colar os arquivos principais
(manifesto de dependências, entry point, schema, estrutura de pastas)?
```

If the user provides partial context, adapt the inspection to what was shared. Mark any critical gap as `[OPEN QUESTION]` — do not assume what you have not read.

#### 1-E.3 Inspect the codebase

Read the codebase in this order. Adapt based on what the user's goal is — focus depth on what is relevant, but never skip the structure scan.

**Structure scan (always):**

- Root directory: `README`, `CLAUDE.md`, `AGENTS.md`, package manifests (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, etc.), `Makefile`, `Dockerfile`, `docker-compose.yml`
- Configuration: `.env.example`, config files, environment-specific configs
- Directory structure: understand the module layout before reading individual files

**Tech stack extraction:**

- Identify language(s), runtime version, and framework(s) from manifests and config
- Identify build system, linting, formatting, and test tools
- Identify CI/CD configuration (`.github/workflows`, `.gitlab-ci.yml`, `Jenkinsfile`, etc.)

**Architecture mapping:**

- Entry points: main files, server setup, CLI entry, index files
- Module/package boundaries: how the system is decomposed
- Routing or dispatch: how requests or events are handled
- Dependency graph: which modules depend on which

**Data model:**

- Schema definitions: ORM models, migration files, schema files, type definitions
- Database configuration and connection setup
- Identify all persistence layers in use (SQL, NoSQL, cache, object storage, etc.)

**External integrations:**

- HTTP clients, SDK calls, third-party service references
- Queue producers/consumers, event stream configuration
- External API configuration and credentials management

**Tests and quality:**

- Test directory structure and test framework
- Coverage level (rough estimate from file count)
- Whether tests exist for the area the user wants to change

**Existing documentation:**

- Architecture docs, ADRs (Architecture Decision Records), runbooks
- `docs/` directory, wikis referenced in README

#### 1-E.4 Document the current state

Before proposing anything, produce a structured summary of what you found:

```
CURRENT STATE SUMMARY
  Language/runtime: ...
  Framework(s): ...
  Architecture style: ...
  Modules/services: [list with one-line responsibility each]
  Data model: [key entities and storage]
  External integrations: [list]
  Test coverage: [rough level — none / sparse / partial / good]
  CI/CD: [what exists]
  Documentation: [what exists]
  Known issues (from code, comments, TODOs, or user input): [list]
```

Show this summary to the user and confirm it is accurate before proceeding. Correct any errors.

#### 1-E.5 Identify technical debt relevant to the planned work

While inspecting, note:

- Code areas the planned work will touch that have quality issues
- Missing tests in paths that will be changed
- Architectural constraints that may complicate the planned change
- Existing patterns or conventions that the plan must respect or explicitly diverge from
- Deprecated dependencies or APIs in affected modules

Mark each item as:
- `DEBT-NOW`: must be addressed in this plan to make the change viable
- `DEBT-DEFER`: real debt but not blocking this work — document and defer
- `DEBT-ACCEPT`: known, low-risk, intentional simplification — leave as-is

---

### 2. Clarify the goal

For **new projects**: gather the minimum signal to understand the core problem.

For **existing projects**: gather the minimum signal to understand the desired change and its scope, grounded in what you already know from the code inspection.

Ask at most 3–5 targeted questions. Prioritize questions whose answers would change the architecture, scope, or migration path:

**New project questions:**
- What problem are you solving, and who has it?
- Why is this worth building now?
- Who are the primary users or consumers?
- What does a working system look like at the end of the first useful phase?

**Existing project questions:**
- What specifically needs to change, and why now?
- What must not break during or after this change?
- Are there users currently in production that constrain how the change can be rolled out?
- Is there a timeline constraint or a triggering event (deprecation, compliance deadline, performance incident)?

If the user has already answered these, synthesize what you have and move on. Do not re-ask.

When context is incomplete, state your provisional understanding explicitly:

```
[ASSUMPTION] I'm treating this as {description of goal} within a system that currently {current state summary}.
Correct me before I continue.
```

If the user wants to skip planning and go straight to implementation, do not comply silently:

```
[WARNING] Proceeding without resolving {open question} increases the risk of rework at {specific point}.
I recommend we spend {estimated time} resolving it first.
```

Then let the user decide.

### 3. Establish context and constraints

Derive or confirm what constrains the plan. For existing projects, many of these are already fixed — state them as constraints, not choices.

- **Project type**: internal tool, SaaS, API, data pipeline, CLI, mobile app, platform, embedded system
- **Usage mode**: real-time, batch, event-driven, human-in-the-loop, offline-first
- **Usage scale**: order of magnitude for users, request volume, data volume
- **Operational context**: who runs it, what failure tolerance is acceptable, current SLA if any
- **Team constraints**: team size, ownership of affected areas, deployment capacity, on-call setup
- **Timeline and budget**: coarse estimates; unknown is a valid answer
- **Regulatory or compliance constraints**: GDPR, HIPAA, SOC 2, data residency, audit requirements
- **Locked constraints** (existing projects only): language, framework, database, infrastructure that cannot change in this plan — state them explicitly as non-negotiable

For existing projects, do not propose replacing a locked constraint unless the user has explicitly said it is on the table. If a locked constraint is the root cause of the problem, flag it as an `[OPEN QUESTION]` before proceeding.

If scale is unknown, choose a conservative default and mark it as `[ASSUMPTION]`.

### 4. Run structured brainstorming

Before locking direction, explore the solution space. This is the only moment in the workflow for genuine open exploration.

For new projects: explore what to build and how.
For existing projects: explore how to make the desired change — migration paths, refactoring strategies, feature addition approaches given the real system.

For each viable approach (limit to 2–3):

```
Approach A — {name}
  Core idea: ...
  Primary advantage: ...
  Primary risk: ...
  Best fit when: ...
  For existing projects — impact on current system: ...
  For existing projects — migration complexity: low / medium / high
```

After listing approaches, make a recommendation:

```
Recommendation: Approach {X} because {one-sentence reason given the constraints}.
```

Do not present all approaches as equally valid. Make a call.

Work backward from the desired outcome:
- What is the final state the user wants to reach?
- What is the minimal change or system that produces that state?
- What assumptions does that solution make?
- What breaks if those assumptions are wrong?

For existing projects: what does the system need to look like after the change, and how far is that from where it is now?

### 5. Lock scope

Define what is in and out of scope for this plan.

**In scope** — capabilities that must exist or change for the goal to be achieved.

**Out of scope (explicit)** — distinguish between:
- **Deliberate deferral**: will be addressed later, once this is proven
- **Explicit exclusion**: will not be addressed in this plan at all

For existing projects, also state:
- **Preserved**: existing capabilities that must continue to work exactly as they do
- **Deprecated**: existing capabilities that will be intentionally removed or replaced

Avoid over-scoping. If something is not required for the system to achieve its goal, it goes to a later phase. The cost of scope creep is always higher than the cost of a deferred feature.

### 6. Define requirements

#### Functional requirements

For new projects: work backward from the outcome. For each required capability, ask what the system must do for the user to achieve their goal.

For existing projects: also include changed and removed requirements — not just new ones.

Format:

```
FR-01 [NEW]: {capability} — {expected behavior and acceptance signal}
FR-02 [CHANGED]: {capability} — {what changes from current behavior and why}
FR-03 [REMOVED]: {capability} — {what is being removed and the impact}
FR-04 [TENTATIVE]: {capability} — pending resolution of {open question}
```

Keep the list honest. Scope to what is in scope.

#### Non-functional requirements

Cover only NFRs that are genuinely constraining. For existing projects, distinguish between NFRs inherited from the current system and new NFRs introduced by this change.

- **Performance**: latency targets, throughput expectations with expected load
- **Reliability**: uptime target, acceptable downtime, recovery time objective
- **Scalability**: growth headroom, scaling model
- **Security**: authentication model, authorization model, data sensitivity classification
- **Observability**: structured logging, key metrics, alerting thresholds
- **Maintainability**: expected change cadence, team expertise
- **Compliance**: data residency, privacy regulation, audit log requirements

Omit any category that has no real constraint for this project.

### 7. Propose architecture

#### For new projects

Select the minimum architecture that satisfies scope and NFRs. Justify every structural decision.

- **Architectural style**: state the chosen style and why
  - Prefer modular monolith over microservices unless team is distributed, domains are genuinely independent, or deployment isolation is a hard requirement
  - Prefer event-driven only when decoupling is a real constraint or volume genuinely requires it
  - Prefer serverless only when workload is highly variable and operational simplicity outweighs cold-start constraints

- **Core components**: for each module or service:
  ```
  {Component}: {single responsibility}
    Consumes: ...
    Produces: ...
  ```

- **Data model**: key entities, relationships, storage strategy, schema evolution approach

- **Data flow**: how data moves — synchronous, async messages, batch, streams — state the model and why

- **External integrations**: for each dependency, state what it does and its dependency risk

- **API design**: state the style (REST, gRPC, GraphQL, event schema) and justify given the consumers

#### For existing projects

Document the current architecture first, then propose the target state as a delta.

**Current architecture (from code inspection):**

```
CURRENT ARCHITECTURE
  Style: ...
  Components: [list with responsibilities]
  Data model: [key entities and storage]
  Data flow: ...
  External integrations: [list]
  API surface: ...
```

**Target architecture (after this plan is executed):**

State only what changes. Do not redocument what stays the same.

```
TARGET ARCHITECTURE DELTA
  Style change: none / {from} → {to}
  Components added: ...
  Components modified: ...
  Components removed: ...
  Data model changes: [new tables/fields, removed fields, migrations required]
  New integrations: ...
  API changes: [new endpoints, changed contracts, removed endpoints]
```

**Migration path:**

For each significant change, define how to get from current to target without breaking production:

```
MIGRATION-{N}: {what is changing}
  Approach: {how to migrate — strangler fig, big bang, parallel run, feature flag, etc.}
  Rollback: {how to undo if it goes wrong}
  Risk: high / medium / low
  Data migration required: yes / no — {if yes, describe}
```

#### Architectural confidence markers (both paths)

Mark each significant decision:
- `[HIGH CONFIDENCE]` — strong fit, low risk of reversal
- `[MEDIUM CONFIDENCE]` — good fit but depends on unconfirmed assumptions
- `[LOW CONFIDENCE]` — provisional; must be revisited when {named condition} is resolved

Flag decisions that are hard to reverse. Irreversible decisions have asymmetric cost.

### 8. Define infrastructure and cross-cutting concerns

Design infrastructure at the level of maturity the project warrants.

For existing projects, state what already exists before proposing changes. Do not redesign infrastructure that is not in scope.

#### Deployment

- Hosting, compute, storage, networking, CI/CD, IaC
- For existing projects: what changes vs. what is inherited

#### Authentication and authorization

- Auth mechanism, authorization model, secret management
- For existing projects: what the current model is, what changes, and migration impact

#### Observability

- Logging, metrics, tracing, alerting, dashboards
- For existing projects: what instrumentation already exists, what gaps this plan must fill

Do not design a full observability platform for a project that does not yet have users. Match depth to maturity.

### 9. Assess risks and trade-offs

Focus on risks that could materially change the plan. For existing projects, include risks specific to changing a live system.

For each significant risk:

```
RISK-{N}: {description}
  Impact: high / medium / low
  Probability: high / medium / low
  Mitigation: {concrete action — not "monitor this"}
  Owner: {role or team}
  Trigger to escalate: {observable condition}
```

Always cover:
- **Technical risks**: unknowns in the stack, unproven integrations, schema evolution, performance cliffs
- **Execution risks**: scope creep, team availability, external dependencies
- **Business risks**: assumption invalidation, regulatory change
- **Security risks**: attack surface, sensitive data exposure, access control gaps

For existing projects, also cover:
- **Regression risk**: what currently working behavior could break
- **Data integrity risk**: migrations that could corrupt or lose data
- **Rollout risk**: how the change reaches production without downtime or incidents
- **Compatibility risk**: API or schema changes that break existing consumers

For major trade-offs:

```
TRADE-OFF: {option A} vs {option B}
  Chose: {A}
  Cost accepted: {what we give up}
  Trigger to revisit: {condition under which B becomes better}
```

### 10. Validate the plan before delivering

Run this checklist before producing the final output:

- [ ] Every FR maps to the stated scope — nothing is in scope without a requirement
- [ ] Every architectural component is justified by at least one FR or NFR
- [ ] Every `[ASSUMPTION]` is listed in the output under "Assumptions"
- [ ] Every `[OPEN QUESTION]` is listed in the output under "Open questions"
- [ ] The roadmap phases have observable exit criteria — not just deliverable lists
- [ ] Next steps are specific and executable by a named role today
- [ ] No phase contains features that belong to a later phase
- [ ] The plan is consistent with stated team and budget constraints
- [ ] **For existing projects**: current state is documented before the target state
- [ ] **For existing projects**: every change to existing behavior is explicitly stated — nothing is silently altered
- [ ] **For existing projects**: every migration has a rollback path or the absence of one is flagged as a risk
- [ ] **For existing projects**: identified technical debt is classified (DEBT-NOW / DEBT-DEFER / DEBT-ACCEPT)

If any check fails, resolve it before delivering. If it cannot be resolved without user input, surface it as an `[OPEN QUESTION]`.

### 11. Build roadmap and next steps

#### Roadmap

For new projects: organize from foundation to MVP to hardening.

For existing projects: organize from preparation (understanding and stabilizing what exists) through the change to validation that nothing broke.

Each phase must have a clear, observable exit criterion — not just a deliverable list.

```
Phase 0 — {name}
  Goal: {outcome}
  Exit criterion: {observable condition — e.g., "CI passes, staging deployment succeeds"}
  Key deliverables: {list}
  Estimated effort: {range, e.g., "1–2 weeks for a 2-person team"}

Phase 1 — {name}
  Goal: {outcome}
  Exit criterion: {observable condition}
  Key deliverables: {list}
  Estimated effort: {range}
```

For existing projects, Phase 0 should always include:
- Stabilizing test coverage for affected areas before changing them
- Documenting current behavior that must be preserved
- Setting up any monitoring needed to detect regressions

Add phases only if there is real content in them.

#### Next steps

List the first 3–5 concrete actions the team can take immediately:

```
NEXT-01: {action} — {owner or role} — {blocks or is parallel to what}
NEXT-02: {action} — {owner or role} — {blocks or is parallel to what}
```

Actions must be specific and role-assignable. Not "define requirements." Not "align with stakeholders."

After the plan is complete, if the project will be executed with AI agents in this repository, hand off to the `orchestrator` skill to sequence and coordinate implementation.

---

## Heuristics

### When to ask more

Ask a follow-up question when:
- The answer would change the architecture or scope
- An assumption you would make is likely wrong for this user's specific context
- The user has given contradictory signals
- You are about to plan changes to a part of the existing system you have not read

Limit to one question at a time. Batch questions only if they are independent and the user has shown tolerance for multiple questions.

### When to assume provisionally

Assume when:
- The missing information is a standard industry default (e.g., PostgreSQL for relational data)
- Asking would interrupt the planning flow for a low-stakes, reversible decision
- The assumption is reversible at low cost if wrong

Always mark with `[ASSUMPTION]` inline and collect in the output.

For existing projects: never assume what the current code does. Read it.

### When to offer alternatives

Offer alternatives when:
- There are 2–3 structurally different solutions and the user has not constrained the choice
- A decision is high-stakes and irreversible
- The user's context makes an alternative better than the default

Do not offer alternatives for every decision. Making a call is more valuable than listing options.

### When to make a single recommendation

Make a single recommendation when:
- Constraints are clear enough to eliminate most options
- One option is clearly superior given what you know

State it directly. Justify in one sentence. Do not hedge unless uncertainty is real and consequential.

### Avoiding overengineering

Before adding any component:
- Does removing it break the core use case? If no, defer it.
- Is this solving a problem we actually have, or one we might have at 10x scale?
- Does the team have the capacity to build and operate this?

When in doubt, choose the simpler option and name the condition under which you would upgrade.

### Separating MVP from future evolution

MVP must:
- Deliver the core value proposition end-to-end with real users or real data
- Be operable without specialized knowledge
- Be testable and observable enough to generate meaningful feedback

Future evolution includes:
- Features that improve existing capabilities beyond the core
- Performance optimization beyond current requirements
- Tooling, automation, and CI/CD improvements beyond basic
- Hardening beyond current risk exposure

For existing projects: MVP is the minimal change that achieves the stated goal without regressions. It is not a full system rebuild.

### Marking uncertainty and confidence

Use these markers consistently — never mix their meanings:

- `[ASSUMPTION]` — stated as fact but not confirmed by the user; collect in output
- `[TENTATIVE]` — requires more information before finalizing
- `[OPEN QUESTION]` — must be resolved before implementation; collect in output
- `[HIGH CONFIDENCE]` — strong fit, unlikely to be reversed
- `[MEDIUM CONFIDENCE]` — good fit but depends on at least one unconfirmed assumption
- `[LOW CONFIDENCE]` — provisional; revisit when a named condition is resolved
- `[WARNING]` — risk of rework or failure if not addressed before proceeding
- `[LOCKED]` — constraint from the existing system that cannot change in this plan

---

## Plan output format

When the planning session concludes, produce one of the two artifacts below depending on project mode. Do not mix them. Do not leave any section as a generic placeholder — if a section does not apply, state why.

---

### Output A — New Project Plan

**Project:** {name}  
**Date:** {date}  
**Status:** draft / revised / approved  
**Planning mode:** well-defined / partially-defined / exploratory

---

#### Problem summary

One paragraph. The problem, who has it, why it matters now, and what the world looks like after this system exists.

#### Objective

One sentence. What will exist at the end of this plan that does not exist today.

#### Assumptions

- [ASSUMPTION] ...

#### Open questions

- [OPEN QUESTION] ...

#### Functional requirements

| ID | Requirement | Status |
|---|---|---|
| FR-01 | ... | confirmed |
| FR-02 | ... | tentative — pending {open question} |

#### Non-functional requirements

| Category | Requirement | Target |
|---|---|---|
| Performance | ... | ... |
| Reliability | ... | ... |

#### Scope

**In scope:**
- ...

**Out of scope:**
- ... (deferred to phase 2)
- ... (excluded — out of project boundary)

#### Recommended architecture

- **Style:** ...
- **Components:** ...
- **Data model:** ...
- **Data flow:** ...
- **External integrations:** ...
- **API design:** ...

#### Recommended stack

| Layer | Technology | Confidence | Reason |
|---|---|---|---|
| Backend | ... | HIGH | ... |
| Database | ... | HIGH | ... |
| Infra | ... | MEDIUM | ... |

#### Recommended infrastructure

- **Hosting:** ...
- **Compute:** ...
- **CI/CD:** ...
- **Auth:** ...
- **Observability:** ...

#### Risks and trade-offs

| ID | Description | Impact | Probability | Mitigation |
|---|---|---|---|---|
| RISK-01 | ... | high | medium | ... |

**Trade-offs:**
- TRADE-OFF: {A} vs {B} — Chose {A}. Cost accepted: {what we give up}. Revisit if: {condition}.

#### Roadmap

| Phase | Goal | Exit criterion | Effort |
|---|---|---|---|
| 0 — Foundation | ... | ... | ... |
| 1 — MVP | ... | ... | ... |
| 2 — Hardening | ... | ... | ... |

#### Next steps

| ID | Action | Owner | Dependency |
|---|---|---|---|
| NEXT-01 | ... | ... | none |
| NEXT-02 | ... | ... | NEXT-01 |

---

**Handoff:** If this project will be executed with AI agents, use the `orchestrator` skill to sequence implementation phases from this plan.

---

### Output B — Existing Project Plan

**Project:** {name}  
**Date:** {date}  
**Status:** draft / revised / approved  
**Change type:** feature / refactor / migration / fix / extension / replan

---

#### Goal summary

One paragraph. What the user wants to change, why now, and what the system will do after this plan is executed that it cannot or does not do today.

#### Objective

One sentence. What changes — and what must not change — as a result of executing this plan.

#### Current state

**Tech stack:**

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Language | ... | ... | ... |
| Framework | ... | ... | ... |
| Database | ... | ... | ... |
| Infra | ... | ... | ... |

**Architecture (as found):**
- Style: ...
- Components: [list with one-line responsibility]
- Data model: [key entities and storage]
- External integrations: [list]
- Test coverage: none / sparse / partial / good
- CI/CD: ...

**Technical debt identified:**

| ID | Description | Classification | Rationale |
|---|---|---|---|
| DEBT-01 | ... | DEBT-NOW | must fix to make this change viable |
| DEBT-02 | ... | DEBT-DEFER | real but not blocking |
| DEBT-03 | ... | DEBT-ACCEPT | intentional, low-risk |

#### Assumptions

- [ASSUMPTION] ...

#### Open questions

- [OPEN QUESTION] ...

#### Functional requirements

| ID | Requirement | Type | Status |
|---|---|---|---|
| FR-01 | ... | NEW | confirmed |
| FR-02 | ... | CHANGED | confirmed |
| FR-03 | ... | REMOVED | confirmed |
| FR-04 | ... | NEW | tentative |

#### Non-functional requirements

| Category | Current | Target | Change required |
|---|---|---|---|
| Performance | ... | ... | yes / no |
| Reliability | ... | ... | yes / no |

#### Scope

**In scope:**
- ...

**Out of scope:**
- ... (deferred)
- ... (excluded)

**Preserved (must not break):**
- ...

**Deprecated (intentionally removed):**
- ...

#### Architecture delta

**Current architecture:** *(already documented in Current state above)*

**Target architecture changes:**

- Style change: none / {from} → {to}
- Components added: ...
- Components modified: ...
- Components removed: ...
- Data model changes: ...
- API changes: ...

#### Migration plan

| ID | What changes | Approach | Rollback | Data migration | Risk |
|---|---|---|---|---|---|
| MIGRATION-01 | ... | strangler fig | yes — {how} | no | medium |
| MIGRATION-02 | ... | big bang | no — flag | yes — {script} | high |

#### Stack changes

| Layer | Current | Target | Confidence | Reason |
|---|---|---|---|---|
| ... | ... | unchanged | — | — |
| ... | ... | {new} | MEDIUM | ... |

#### Infrastructure changes

- **What stays:** ...
- **What changes:** ...
- **Auth changes:** ...
- **Observability gaps to fill:** ...

#### Risks and trade-offs

| ID | Description | Impact | Probability | Mitigation |
|---|---|---|---|---|
| RISK-01 | ... | high | medium | ... |

**Existing-system-specific risks:**

| ID | Description | Affected area | Mitigation |
|---|---|---|---|
| REG-01 | Regression in {area} | ... | ... |
| DATA-01 | Data integrity during migration | ... | ... |

**Trade-offs:**
- TRADE-OFF: {A} vs {B} — Chose {A}. Cost accepted: {what we give up}. Revisit if: {condition}.

#### Roadmap

| Phase | Goal | Exit criterion | Effort |
|---|---|---|---|
| 0 — Stabilize | Add coverage to affected areas; document preserved behavior | Test suite green on affected paths | ... |
| 1 — Change | Execute the planned delta | All FRs verified; no regressions detected | ... |
| 2 — Validate | Production rollout and monitoring | SLA met; no incidents in {period} | ... |

#### Next steps

| ID | Action | Owner | Dependency |
|---|---|---|---|
| NEXT-01 | ... | ... | none |
| NEXT-02 | ... | ... | NEXT-01 |

---

**Handoff:** If this project will be executed with AI agents, use the `orchestrator` skill to sequence implementation phases from this plan.

---

## Invocation and environment

### Instalação — Claude CLI

Instale uma vez. Funciona em qualquer projeto a partir daí.

**Mac/Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/valtervilmerson/agents-skill-planning/main/install.sh | bash
```

**Windows**
```powershell
iex (irm https://raw.githubusercontent.com/valtervilmerson/agents-skill-planning/main/install.ps1)
```

Após a instalação, invoque de qualquer repositório:

```
/project-planner
```

A skill detecta automaticamente se já está instalada. Se não estiver, oferece instalar durante a sessão.

### Instalação — Codex

Para usar via Codex em um repositório específico, a skill precisa estar presente nele:

```bash
mkdir -p skills/project-planner/agents
curl -fsSL https://raw.githubusercontent.com/valtervilmerson/agents-skill-planning/main/skills/project-planner/SKILL.md \
  -o skills/project-planner/SKILL.md
curl -fsSL https://raw.githubusercontent.com/valtervilmerson/agents-skill-planning/main/skills/project-planner/agents/openai.yaml \
  -o skills/project-planner/agents/openai.yaml
```

Invoque com:

```
$project-planner
```

Para **projetos existentes**: se o Codex não tiver acesso direto ao repositório, a skill pedirá os arquivos principais durante a sessão.

### Skill paths

- Skill definition: `skills/project-planner/SKILL.md`
- Agent config: `skills/project-planner/agents/openai.yaml`
- Repo-level Claude CLI wrapper: `.claude/commands/project-planner.md`
- Install script (Mac/Linux): `install.sh`
- Install script (Windows): `install.ps1`
