# Agri-PV Navigator --- Master Development Guide

## Purpose

`MASTER.md` is the **entry point for every AI coding-agent session**.

The agent must read this file **first** before doing any project work.

This file explains:

-   What the project is.
-   Which documents control development.
-   Which document must be read for each type of task.
-   How the documents relate to each other.
-   How the agent should move through the development phases.
-   How to update project state.
-   Which files are authoritative for different decisions.
-   What the agent must do before changing code.

`MASTER.md` is a navigation and orchestration document. It should remain
concise and should point the agent to the correct source of information
instead of duplicating all project rules.

------------------------------------------------------------------------

# 1. First Rule --- Read MASTER.md First

At the beginning of **every new AI-agent session**, do this first:

``` text
1. Read MASTER.md
2. Identify the current task
3. Read the documents required for that task
4. Inspect the actual repository
5. Confirm the current implementation state
6. Implement only the requested work
7. Test the changes
8. Update PROJECT_MEMORY.md
```

Do not start coding before completing steps 1--5.

------------------------------------------------------------------------

# 2. Project Identity

## Project

**Agri-PV Navigator: Visualise, Assess & Design**

## Core Purpose

Build a farmer-centric mobile decision-support application that allows
users to:

``` text
Enter Farm / Field Information
        ↓
Assess Site Suitability
        ↓
Configure Agri-PV Design
        ↓
Generate Layout
        ↓
Estimate Solar / Energy
        ↓
Assess Agricultural Usability
        ↓
Estimate Preliminary Economics
        ↓
Visualise in 3D / AR
        ↓
Compare Configurations
        ↓
Generate Report
```

The application provides preliminary decision support and must not
present results as engineering certification, construction-ready design,
guaranteed agricultural outcomes, or investment-grade financial advice.

------------------------------------------------------------------------

# 3. The Project Documentation System

The project uses these core Markdown documents:

``` text
MASTER.md
RULE.md
PHASES.md
PROJECT_MEMORY.md
PRD.md
architecture.md
methodology.md
data-model.md
api.md
assumptions.md
```

They have different responsibilities.

------------------------------------------------------------------------

# 4. Document Hierarchy

Use the documents in this conceptual order:

``` text
MASTER.md
    │
    ├── RULE.md
    │
    ├── PHASES.md
    │
    ├── PROJECT_MEMORY.md
    │
    └── Technical Documentation
          ├── PRD.md
          ├── architecture.md
          ├── methodology.md
          ├── data-model.md
          ├── api.md
          └── assumptions.md
```

### Meaning

``` text
MASTER.md
→ How to navigate the project documentation.

RULE.md
→ How the project must be engineered.

PHASES.md
→ What must be built and in what order.

PROJECT_MEMORY.md
→ What has actually been built and what is happening now.

PRD.md
→ What the product is required to do.

architecture.md
→ How the system is structured.

methodology.md
→ How scientific/domain calculations are performed.

data-model.md
→ How information is stored and related.

api.md
→ How application components communicate.

assumptions.md
→ Current assumptions, inputs, limitations, and external dependencies.
```

------------------------------------------------------------------------

# 5. Source-of-Truth Rules

Different questions must be answered from different files.

  Question                               Read
  -------------------------------------- -----------------------------------
  How should I work?                     `RULE.md`
  What should I build next?              `PHASES.md`
  What has already been built?           `PROJECT_MEMORY.md` + repository
  What does the product require?         `PRD.md`
  How is the architecture designed?      `architecture.md`
  How should a calculation work?         `methodology.md`
  What data/schema should exist?         `data-model.md`
  What API should exist?                 `api.md`
  What assumptions are currently used?   `assumptions.md`
  What happened in previous work?        `PROJECT_MEMORY.md`
  What libraries should be used?         `RULE.md`
  What phase/task is active?             `PROJECT_MEMORY.md` + `PHASES.md`

If the task affects multiple areas, read all relevant documents.

------------------------------------------------------------------------

# 6. Mandatory Files Before Coding

For **any coding task**, read:

``` text
MASTER.md
RULE.md
PHASES.md
PROJECT_MEMORY.md
```

Then read the task-specific documentation.

Do not assume the current phase from the conversation alone.

Verify it in:

``` text
PROJECT_MEMORY.md
```

and against the actual repository.

------------------------------------------------------------------------

# 7. Task-to-Document Guide

## 7.1 Project Setup / Architecture

Read:

``` text
MASTER.md
RULE.md
PHASES.md
PROJECT_MEMORY.md
architecture.md
```

Use when:

-   Creating project structure
-   Adding services
-   Changing architecture
-   Adding infrastructure
-   Making technology decisions

------------------------------------------------------------------------

# 8. Flutter / Mobile Tasks

For Flutter UI or mobile work, read:

``` text
MASTER.md
RULE.md
PHASES.md
PROJECT_MEMORY.md
PRD.md
architecture.md
api.md
```

Also inspect the relevant existing feature.

Examples:

### Farm UI

Read:

``` text
PRD.md
architecture.md
api.md
```

### Design UI

Read:

``` text
PRD.md
architecture.md
methodology.md
api.md
```

### 3D

Read:

``` text
RULE.md
architecture.md
PRD.md
```

### AR

Read:

``` text
RULE.md
architecture.md
PRD.md
```

Do not move scientific calculations into Flutter merely because the
feature is displayed there.

------------------------------------------------------------------------

# 9. Backend/API Tasks

Read:

``` text
MASTER.md
RULE.md
PHASES.md
PROJECT_MEMORY.md
architecture.md
api.md
data-model.md
```

Use these before:

-   Creating endpoints
-   Modifying endpoints
-   Creating services
-   Adding authentication
-   Changing request/response structures
-   Adding background jobs

After changing an API contract:

``` text
Update api.md
Update PROJECT_MEMORY.md
Add/update tests
```

------------------------------------------------------------------------

# 10. Database Tasks

Read:

``` text
MASTER.md
RULE.md
PROJECT_MEMORY.md
data-model.md
architecture.md
```

Before changing:

-   Prisma schema
-   PostgreSQL tables
-   PostGIS geometry
-   Relationships
-   Indexes
-   Migrations

After a meaningful schema change:

``` text
Update data-model.md
Update PROJECT_MEMORY.md
Run migration/tests
```

Never modify the database schema casually.

------------------------------------------------------------------------

# 11. Calculation Engine Tasks

Calculation work requires more documentation than ordinary UI work.

Always read:

``` text
MASTER.md
RULE.md
PHASES.md
PROJECT_MEMORY.md
methodology.md
assumptions.md
architecture.md
```

Also read:

``` text
data-model.md
```

if calculation inputs/outputs are stored in the database.

Use this for:

-   Suitability
-   Layout
-   Solar
-   Shadow
-   Agriculture
-   Energy
-   Economics
-   Simulation pipeline

------------------------------------------------------------------------

# 12. Suitability Tasks

Read:

``` text
RULE.md
PHASES.md
PROJECT_MEMORY.md
methodology.md
assumptions.md
architecture.md
```

The agent must determine:

``` text
What inputs are required?
What external data is required?
What calculations already exist?
What methodology is approved?
What assumptions are active?
What output is expected?
```

Do not invent suitability weights or scientific assumptions if they are
not documented.

------------------------------------------------------------------------

# 13. Layout / Design Tasks

Read:

``` text
RULE.md
PHASES.md
PROJECT_MEMORY.md
methodology.md
data-model.md
architecture.md
```

The canonical Agri-PV design must remain the source of truth.

Any layout change must consider its effect on:

``` text
Solar
Shadow
Agriculture
Energy
Economics
3D
AR
Comparison
Reports
```

------------------------------------------------------------------------

# 14. Solar / Energy Tasks

Read:

``` text
RULE.md
PHASES.md
PROJECT_MEMORY.md
methodology.md
assumptions.md
```

Use established libraries such as `pvlib` for generic solar/PV
calculations.

Do not implement solar astronomy from scratch unless explicitly
justified and documented.

------------------------------------------------------------------------

# 15. Shadow / Agriculture Tasks

Read:

``` text
RULE.md
PHASES.md
PROJECT_MEMORY.md
methodology.md
assumptions.md
```

Check:

``` text
Crop assumptions
Shadow methodology
Geometry
Time resolution
Agricultural interpretation
Model version
```

Never invent crop-specific scientific parameters.

------------------------------------------------------------------------

# 16. Economics Tasks

Read:

``` text
RULE.md
PHASES.md
PROJECT_MEMORY.md
methodology.md
assumptions.md
```

Economic changes require explicit assumptions.

If formulas or assumptions change:

``` text
Update methodology.md
Update assumptions.md
Update model version
Update tests
Update PROJECT_MEMORY.md
```

------------------------------------------------------------------------

# 17. 3D / AR Tasks

For 3D:

``` text
MASTER.md
RULE.md
PROJECT_MEMORY.md
architecture.md
PRD.md
```

For AR:

``` text
MASTER.md
RULE.md
PROJECT_MEMORY.md
architecture.md
PRD.md
```

The 3D/AR layer must visualize the canonical Agri-PV design.

Do not create an independent design model for visualization.

------------------------------------------------------------------------

# 18. Report Tasks

Read:

``` text
MASTER.md
RULE.md
PROJECT_MEMORY.md
PRD.md
methodology.md
assumptions.md
```

Reports must contain appropriate:

-   Inputs
-   Results
-   Assumptions
-   Methodology
-   Limitations
-   Model/version information

Do not present preliminary calculations as guaranteed outcomes.

------------------------------------------------------------------------

# 19. Bug-Fixing Workflow

For any bug:

``` text
1. Read MASTER.md
2. Read RULE.md
3. Read PROJECT_MEMORY.md
4. Identify the relevant phase
5. Read task-specific documentation
6. Inspect the actual code
7. Reproduce the issue
8. Identify root cause
9. Fix the smallest appropriate area
10. Add/update regression test
11. Run relevant tests
12. Update PROJECT_MEMORY.md
```

Do not rewrite large sections of the project to fix a localized issue
unless the architecture genuinely requires it.

------------------------------------------------------------------------

# 20. Adding a New Library

Before adding a dependency:

``` text
1. Read RULE.md
2. Check whether the existing stack already solves the problem.
3. Check whether an established library should be used.
4. Check compatibility with Flutter/backend/Python architecture.
5. Check licensing and maintenance.
6. Add the dependency.
7. Document the decision if it affects architecture.
8. Update PROJECT_MEMORY.md.
```

Do not introduce a dependency simply because it is convenient for one
small function.

------------------------------------------------------------------------

# 21. Changing Architecture

Architecture changes require:

``` text
MASTER.md
RULE.md
PROJECT_MEMORY.md
architecture.md
PHASES.md
```

The agent must:

1.  Explain why the existing architecture is insufficient.
2.  Identify affected components.
3.  Make the smallest appropriate architectural change.
4.  Update architecture documentation.
5.  Update relevant phase/task information.
6.  Record the decision in `PROJECT_MEMORY.md`.

Do not silently change the architecture.

------------------------------------------------------------------------

# 22. Changing Scientific Methodology

Any change to:

``` text
Suitability
Layout rules
Solar calculations
Shadow calculations
Crop model
Agricultural model
Energy model
Economic model
```

requires:

``` text
RULE.md
methodology.md
assumptions.md
PROJECT_MEMORY.md
```

Also:

``` text
Add/update tests
Update model version
```

Scientific changes must never be silently introduced during ordinary
feature development.

------------------------------------------------------------------------

# 23. Working With Existing Code

Before creating a new implementation:

``` text
Search the repository.
Check existing services.
Check existing utilities.
Check existing models.
Check existing API endpoints.
Check existing tests.
```

Do not duplicate:

-   API clients
-   database services
-   geometry utilities
-   calculation functions
-   models
-   UI components
-   validation schemas

Reuse existing project abstractions where appropriate.

------------------------------------------------------------------------

# 24. Phase Execution

The agent must follow `PHASES.md`.

For each phase:

``` text
Read phase
    ↓
Check PROJECT_MEMORY.md
    ↓
Inspect repository
    ↓
Identify current task
    ↓
Implement task
    ↓
Test
    ↓
Document
    ↓
Update PROJECT_MEMORY.md
```

The agent must **not automatically jump to the next phase**.

Finish the current phase/task first.

------------------------------------------------------------------------

# 25. Project Memory Protocol

`PROJECT_MEMORY.md` is the state tracker.

The agent must update it after meaningful work.

Always keep these sections accurate:

``` text
Current Phase
Current Task
Phase Status
Completed Work
Current Work
Remaining Work
Known Issues
Blockers
Active Technical Decisions
Scientific / Methodology State
Next Recommended Action
Handoff
```

Do not store secrets or credentials.

------------------------------------------------------------------------

# 26. Documentation Update Matrix

  Change                   Update
  ------------------------ ---------------------
  Product requirement      `PRD.md`
  Engineering rule         `RULE.md`
  Development order/task   `PHASES.md`
  Current status           `PROJECT_MEMORY.md`
  Architecture             `architecture.md`
  Scientific methodology   `methodology.md`
  Database/schema          `data-model.md`
  API contract             `api.md`
  Assumption/data source   `assumptions.md`

If a change affects multiple categories, update all relevant files.

------------------------------------------------------------------------

# 27. What Not to Put in Each File

## MASTER.md

Do not put:

-   Detailed implementation
-   Full code
-   Long scientific explanations
-   Current bug lists
-   Detailed API definitions

It is the navigation guide.

## RULE.md

Do not put:

-   Current task status
-   Session history
-   Temporary bugs
-   Detailed phase progress

It is the engineering rulebook.

## PHASES.md

Do not put:

-   Session history
-   Detailed implementation logs
-   Temporary debugging notes

It is the roadmap.

## PROJECT_MEMORY.md

Do not put:

-   Full technical documentation
-   Large code blocks
-   Secrets
-   Complete API definitions
-   Complete scientific methodology

It is the current project state.

## Technical documentation

Keep detailed implementation information in the relevant technical
document.

------------------------------------------------------------------------

# 28. Repository Inspection Rule

Markdown files describe the intended project state.

The repository shows the actual implementation.

Therefore, before making decisions:

``` text
Documentation
+
Actual code
+
Tests
```

must be considered together.

If they disagree:

1.  Do not blindly follow the Markdown.
2.  Inspect the implementation.
3.  Determine what is actually true.
4.  Resolve the discrepancy.
5.  Update the appropriate documentation.

------------------------------------------------------------------------

# 29. New Session Checklist

Every new AI-agent session must begin with:

``` text
[ ] Read MASTER.md
[ ] Read RULE.md
[ ] Read PHASES.md
[ ] Read PROJECT_MEMORY.md
[ ] Identify current phase
[ ] Identify current task
[ ] Read task-specific documentation
[ ] Inspect relevant repository files
[ ] Confirm implementation state
```

Only then start implementation.

------------------------------------------------------------------------

# 30. End-of-Task Checklist

Before reporting a task as complete:

``` text
[ ] Requirement implemented
[ ] Existing architecture respected
[ ] Correct libraries used
[ ] No duplicated logic
[ ] Tests added/updated
[ ] Tests/checks executed
[ ] Documentation updated if necessary
[ ] PROJECT_MEMORY.md updated
[ ] Next task identified
```

------------------------------------------------------------------------

# 31. End-of-Session Checklist

Before ending an agent session:

``` text
[ ] Current phase updated
[ ] Current task updated
[ ] Completed work recorded
[ ] Remaining work updated
[ ] Issues/blockers recorded
[ ] Important decisions recorded
[ ] Tests/status recorded
[ ] Handoff updated
[ ] Next action clearly defined
```

------------------------------------------------------------------------

# 32. Master Decision Flow

When the agent receives a request, use this flow:

``` text
                  USER REQUEST
                       ↓
                   MASTER.md
                       ↓
             What type of task?
                       ↓
       ┌───────────────┼────────────────┐
       ↓               ↓                ↓
   Product          Engineering      Current State
       ↓               ↓                ↓
    PRD.md          RULE.md       PROJECT_MEMORY.md
       │               │                │
       └───────────────┼────────────────┘
                       ↓
                Which phase/task?
                       ↓
                  PHASES.md
                       ↓
             Which technical area?
                       ↓
       ┌───────────────┼────────────────┐
       ↓               ↓                ↓
 Architecture       Calculation       Data/API
       ↓               ↓                ↓
architecture.md  methodology.md   data-model.md
                 assumptions.md       api.md
                       ↓
                Inspect repository
                       ↓
                   Implement
                       ↓
                    Test
                       ↓
            Update PROJECT_MEMORY.md
```

------------------------------------------------------------------------

# 33. Core Agent Principle

The agent should always think:

``` text
MASTER
  ↓
Understand the documentation system

RULE
  ↓
Understand how to build

PHASES
  ↓
Understand what to build

PROJECT_MEMORY
  ↓
Understand where the project currently is

Technical docs
  ↓
Understand how the specific component works

Repository
  ↓
Verify what actually exists

Implement
  ↓
Test

PROJECT_MEMORY
  ↓
Record the new state
```

------------------------------------------------------------------------

# 34. Final Rule

> **Never start a new development session by guessing what the project
> needs.**

Always start with:

``` text
MASTER.md
```

Then use it to determine exactly which other documents must be read.

The goal of this documentation system is that a completely new AI coding
agent can enter the repository, read `MASTER.md`, follow its
document-routing instructions, understand the current state from
`PROJECT_MEMORY.md`, understand the required work from `PHASES.md`,
follow the engineering constraints from `RULE.md`, and then safely
continue implementation without relying on previous chat history.
