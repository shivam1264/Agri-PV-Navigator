# Agri-PV Navigator --- Project Memory

## Purpose

`PROJECT_MEMORY.md` is the persistent working-state document for the AI
coding agent.

It tells the agent:

-   What has already been built.
-   What is currently being worked on.
-   What remains to be implemented.
-   What decisions have already been made.
-   What problems are currently known.
-   What should be done next.
-   What must not be changed without an explicit decision.

This file is a **project state document**, not a replacement for
`RULE.md`, `PHASES.md`, or the technical documentation.

------------------------------------------------------------------------

# 1. How the Agent Must Use This File

Before starting any development task, the agent must read:

``` text
RULE.md
PHASES.md
PROJECT_MEMORY.md
```

Then inspect the actual repository before assuming that the memory is
still correct.

### Important

`PROJECT_MEMORY.md` is useful project context, but the **actual
repository state is the source of truth for implementation status**.

If this file says something is complete but the code does not contain
it, treat the code/repository as authoritative and update the memory.

If the code contains work that is not recorded here, update the memory
after verifying it.

------------------------------------------------------------------------

# 2. Memory Update Rule

The agent must update this file whenever a meaningful development change
occurs.

Update it after:

-   Completing a task.
-   Starting a significant task.
-   Changing architecture.
-   Changing a technology/library decision.
-   Changing a scientific methodology.
-   Discovering a significant bug.
-   Fixing a significant bug.
-   Adding/removing a dependency.
-   Changing an API contract.
-   Changing the database schema.
-   Changing a calculation model.
-   Changing assumptions.
-   Blocking progress because of a missing dependency, dataset, API, or
    decision.

Do not update it for trivial edits such as:

-   Typo fixes.
-   Formatting-only changes.
-   Minor variable renaming with no architectural impact.

------------------------------------------------------------------------

# 3. Never Treat Memory as Permission

This file records project state.

It does **not** authorize the agent to:

-   Skip `RULE.md`.
-   Skip testing.
-   Skip documentation.
-   Change the architecture without justification.
-   Change scientific assumptions silently.
-   Start future phases without instruction.
-   Remove existing functionality without checking dependencies.

`RULE.md` remains the engineering authority.

`PHASES.md` remains the implementation roadmap.

`PROJECT_MEMORY.md` records the current state of that roadmap.

------------------------------------------------------------------------

# 4. Current Project Identity

## Project

**Agri-PV Navigator: Visualise, Assess & Design**

## Product Purpose

A farmer-centric mobile decision-support application for preliminary
assessment and design of Agrivoltaic systems on agricultural land.

The application should help a farmer:

``` text
Farm / Field
    ↓
Site Suitability
    ↓
Agri-PV Design
    ↓
Layout
    ↓
Solar / Energy
    ↓
Agricultural Assessment
    ↓
Economics
    ↓
3D / AR
    ↓
Comparison
    ↓
Report
```

The system provides **preliminary decision support**.

It is not:

-   Engineering certification.
-   Construction-ready EPC design.
-   Investment-grade financial modelling.
-   Guaranteed crop-yield prediction.
-   Construction-grade surveying.

------------------------------------------------------------------------

# 5. Technology Baseline

The current technology direction is:

## Mobile

``` text
Flutter
Dart
```

## Backend

``` text
Node.js
Express
```

## Database

``` text
PostgreSQL
PostGIS
Prisma
```

## Queue / Cache

``` text
Redis
BullMQ or equivalent
```

## Calculation Engine

``` text
Python
NumPy
Pandas
SciPy
```

## Solar / PV

``` text
pvlib
```

## GIS / Geometry

``` text
Shapely
PyProj
GeoPandas where useful
Rasterio/GDAL where required
PostGIS
Turf.js where client-side GeoJSON operations are useful
```

## Maps

Use a suitable maintained Flutter-compatible map SDK.

Do not lock the project to a specific map package unless an
implementation decision has been documented.

## 3D

Use a suitable maintained Flutter-compatible 3D/scene solution.

Do not build a 3D rendering engine.

## AR

``` text
ARKit — iOS
ARCore — Android
```

Use suitable Flutter/native integrations.

## Infrastructure

``` text
Docker
S3-compatible object storage where required
```

------------------------------------------------------------------------

# 6. Build vs Library Boundary

The following boundary must be preserved.

## Use libraries for

``` text
Authentication
Password hashing
API framework
Validation
Database
PostGIS
GIS primitives
Solar position
PV modelling
Numerical computation
Coordinate transformation
Terrain/raster processing
Maps
3D rendering
AR tracking
PDF generation
Queue
Cache
Logging
Testing
```

## Build ourselves

``` text
Agri-PV suitability methodology
Agri-PV layout algorithm
Panel spacing logic
Agricultural constraints
Machinery clearance
Shadow → crop impact
Crop compatibility
Cultivation usability
Scenario comparison
Techno-economic model
Canonical Agri-PV design
Simulation orchestration
Farmer-facing interpretation
```

------------------------------------------------------------------------

# 7. Development Roadmap

The project follows the phases defined in `PHASES.md`.

``` text
Phase 0  — Project Foundation
Phase 1  — Flutter Mobile Foundation
Phase 2  — Backend, Database & Queue
Phase 3  — Farm, Field & Crop Data
Phase 4  — Site Data & Suitability Engine
Phase 5  — Agri-PV Design & Layout Engine
Phase 6  — Solar & Energy Engine
Phase 7  — Shadow & Agricultural Assessment
Phase 8  — Preliminary Techno-Economic Assessment
Phase 9  — Simulation Pipeline & Scenario Comparison
Phase 10 — 3D Visualization
Phase 11 — AR Visualization
Phase 12 — Results Dashboard & Report
Phase 13 — Integration, Testing & Validation
Phase 14 — Deployment & Demo
```

The agent must work through these phases sequentially unless explicitly
instructed otherwise.

------------------------------------------------------------------------

# 8. Current Phase

> **Agent: update this section whenever the active phase changes.**

``` text
Current Phase: Phase 0
Current Task: Not started
Status: Not started
```

------------------------------------------------------------------------

# 9. Phase Status

Use only these statuses:

``` text
NOT STARTED
IN PROGRESS
BLOCKED
COMPLETED
```

Update the table after meaningful progress.

  Phase                                                   Status        Notes
  ------------------------------------------------------- ------------- -------
  Phase 0 --- Project Foundation                          NOT STARTED   
  Phase 1 --- Flutter Mobile Foundation                   NOT STARTED   
  Phase 2 --- Backend, Database & Queue                   NOT STARTED   
  Phase 3 --- Farm, Field & Crop Data                     NOT STARTED   
  Phase 4 --- Site Data & Suitability Engine              NOT STARTED   
  Phase 5 --- Agri-PV Design & Layout Engine              NOT STARTED   
  Phase 6 --- Solar & Energy Engine                       NOT STARTED   
  Phase 7 --- Shadow & Agricultural Assessment            NOT STARTED   
  Phase 8 --- Preliminary Techno-Economic Assessment      NOT STARTED   
  Phase 9 --- Simulation Pipeline & Scenario Comparison   NOT STARTED   
  Phase 10 --- 3D Visualization                           NOT STARTED   
  Phase 11 --- AR Visualization                           NOT STARTED   
  Phase 12 --- Results Dashboard & Report                 NOT STARTED   
  Phase 13 --- Integration, Testing & Validation          NOT STARTED   
  Phase 14 --- Deployment & Demo                          NOT STARTED   

------------------------------------------------------------------------

# 10. Completed Work

Keep a concise record of completed work.

Format:

``` text
### YYYY-MM-DD — Phase X — Task X.X

Completed:
- ...
- ...

Important implementation details:
- ...

Tests:
- ...

Documentation updated:
- ...
```

Do not copy entire commit messages or large code sections into this
file.

------------------------------------------------------------------------

# 11. Current Work

This section must contain only the work currently in progress.

Format:

``` text
## Current Task

Phase:
Task:

Objective:
...

Files being changed:
- ...

Implementation status:
- [ ] ...
- [ ] ...
- [ ] ...

Current issue:
...

Next immediate action:
...
```

When a task is completed, move its important outcome to **Completed
Work** and clear/update this section.

------------------------------------------------------------------------

# 12. Remaining Work

Keep this list focused on work that is actually outstanding.

Organize by phase:

``` text
## Phase X

- [ ] Task X.X — ...
- [ ] Task X.X — ...
```

Do not add speculative future features here unless they are already part
of the approved roadmap.

------------------------------------------------------------------------

# 13. Known Issues

Record active issues that may affect development.

Format:

``` text
### Issue ID: ISSUE-001

Status: OPEN
Severity: HIGH / MEDIUM / LOW

Problem:
...

Affected area:
...

Known cause:
...

Current workaround:
...

Next action:
...
```

When fixed:

``` text
Status: RESOLVED
Resolution:
...
```

Do not delete important resolved issues if their history may prevent the
same problem from returning.

------------------------------------------------------------------------

# 14. Blockers

Record anything preventing progress.

Examples:

``` text
### BLOCKER-001

Blocked task:
Phase X / Task X.X

Reason:
...

Required decision/resource:
...

Possible workaround:
...

Status:
OPEN
```

A blocker should be removed from this section once resolved.

------------------------------------------------------------------------

# 15. Active Technical Decisions

Record decisions that affect implementation.

Format:

``` text
### Decision: <short name>

Date:
Status: ACTIVE

Decision:
...

Reason:
...

Affected components:
- ...

Do not:
...
```

Examples of decisions worth recording:

-   Flutter instead of React Native.
-   Node.js API + Python calculation engine.
-   PostgreSQL + PostGIS.
-   Redis/BullMQ for heavy calculations.
-   Canonical Agri-PV design as the single source of truth.
-   Libraries for generic technical functionality.
-   Custom implementation for Agri-PV-specific methodology.

Do not record trivial implementation choices here.

------------------------------------------------------------------------

# 16. Scientific / Methodology State

This section tracks the current state of scientific calculations.

Record:

``` text
Suitability model:
Status:
Version:
Current factors:

Layout model:
Status:
Version:
Current rules:

Solar model:
Status:
Version:
Library/data source:

Shadow model:
Status:
Version:
Current methodology:

Agricultural model:
Status:
Version:
Current assumptions:

Economic model:
Status:
Version:
Current assumptions:
```

Whenever one of these models changes, update:

-   Version
-   Assumptions
-   Relevant tests
-   Documentation

Never silently change a scientific model.

------------------------------------------------------------------------

# 17. External Data State

Track external data dependencies.

  Data        Provider                  Status   Version/Date   Notes
  ----------- ------------------------- -------- -------------- -------
  Solar       TBD / selected provider   TBD                     
  Elevation   TBD / selected provider   TBD                     
  Soil        TBD / selected provider   TBD                     
  Weather     TBD / selected provider   TBD                     
  Map         Selected map provider     TBD                     

The agent must not invent provider details.

If a provider is changed, update this table and the relevant
documentation.

------------------------------------------------------------------------

# 18. Database State

Track important schema changes.

``` text
Current migration:
...

Latest schema change:
...

New entities:
- ...

Changed entities:
- ...

Important indexes:
- ...

Spatial changes:
- ...
```

Do not use this section as a duplicate of the Prisma schema. Record only
important state and changes.

------------------------------------------------------------------------

# 19. API State

Track implemented API areas.

  Area          Status        Notes
  ------------- ------------- -------
  Auth          NOT STARTED   
  Farms         NOT STARTED   
  Fields        NOT STARTED   
  Assessments   NOT STARTED   
  Designs       NOT STARTED   
  Simulations   NOT STARTED   
  Comparisons   NOT STARTED   
  Reports       NOT STARTED   

When an endpoint or module is implemented, update the relevant status.

Detailed endpoint documentation belongs in `docs/api.md`, not here.

------------------------------------------------------------------------

# 20. Calculation Engine State

Track the calculation modules.

  Module        Status        Tests   Notes
  ------------- ------------- ------- -------
  Suitability   NOT STARTED           
  Layout        NOT STARTED           
  Solar         NOT STARTED           
  Shadow        NOT STARTED           
  Agriculture   NOT STARTED           
  Energy        NOT STARTED           
  Economics     NOT STARTED           
  Pipeline      NOT STARTED           

Detailed implementation belongs in the source code and methodology
documentation.

------------------------------------------------------------------------

# 21. Flutter State

Track the mobile application at a high level.

  Feature          Status        Notes
  ---------------- ------------- -------
  Authentication   NOT STARTED   
  Home             NOT STARTED   
  Farms            NOT STARTED   
  Fields           NOT STARTED   
  Assessment       NOT STARTED   
  Design           NOT STARTED   
  Visualization    NOT STARTED   
  Comparison       NOT STARTED   
  Reports          NOT STARTED   

Do not record widget-level details here.

------------------------------------------------------------------------

# 22. Testing State

Record only meaningful testing status.

``` text
Unit tests:
...

Integration tests:
...

Scientific/reference tests:
...

End-to-end tests:
...

Known failing tests:
...
```

When a calculation changes, verify the affected tests before marking the
task complete.

------------------------------------------------------------------------

# 23. Last Verified Repository State

After completing a meaningful task, record:

``` text
Last verified:
Date:

Build:
PASS / FAIL

Tests:
PASS / FAIL

Lint:
PASS / FAIL

Database:
PASS / FAIL / NOT CHECKED

Calculation engine:
PASS / FAIL / NOT CHECKED

Flutter app:
PASS / FAIL / NOT CHECKED

Notes:
...
```

This section describes the **last verified state**, not an assumption.

------------------------------------------------------------------------

# 24. Next Recommended Action

The agent must maintain one clear next action.

``` text
Next Phase:
Next Task:
Reason:
Expected output:
```

Do not list ten possible next actions.

The next action should be the smallest useful step that moves the
current phase forward.

------------------------------------------------------------------------

# 25. Session Handoff

When an agent session ends or a task is completed, update this section
so another agent can continue.

Format:

``` text
## Handoff

Last completed:
...

Currently working on:
...

Files changed:
- ...

Tests run:
...

Known problems:
...

Important decisions:
...

Next action:
...
```

The next agent should be able to continue without reconstructing the
entire previous session from chat history.

------------------------------------------------------------------------

# 26. Rules for Keeping Memory Clean

The agent must:

-   Keep entries concise.
-   Record decisions, not conversations.
-   Record current state, not every action.
-   Remove stale information when it is superseded.
-   Preserve important historical decisions when they affect future
    implementation.
-   Never store secrets, passwords, API keys, tokens, or credentials.
-   Never store large code blocks.
-   Never duplicate complete documentation from other files.
-   Link/reference the relevant documentation path instead.

------------------------------------------------------------------------

# 27. Conflict Resolution

If information conflicts:

### Implementation state

``` text
Actual repository/code
    >
PROJECT_MEMORY.md
```

### Engineering rules

``` text
RULE.md
    >
PROJECT_MEMORY.md
```

### Approved roadmap

``` text
PHASES.md
    >
PROJECT_MEMORY.md
```

### Scientific methodology

Use the current documented methodology and explicit project decisions.
If the methodology is unclear or contradictory, do not silently invent a
resolution. Record the issue as a blocker/decision requiring
clarification.

------------------------------------------------------------------------

# 28. Agent Startup Procedure

At the beginning of every development session:

``` text
1. Read RULE.md.
2. Read PHASES.md.
3. Read PROJECT_MEMORY.md.
4. Inspect the repository.
5. Verify the current phase and task against the code.
6. Check known issues and blockers.
7. Confirm the next action.
8. Implement only the current task.
9. Run appropriate tests/checks.
10. Update PROJECT_MEMORY.md.
```

------------------------------------------------------------------------

# 29. Agent Shutdown Procedure

Before finishing a development session:

``` text
1. Verify the work completed.
2. Run relevant tests/checks.
3. Record completed work.
4. Update current task status.
5. Record new issues/blockers.
6. Record important technical decisions.
7. Update phase status if applicable.
8. Update the next recommended action.
9. Update the handoff section.
```

------------------------------------------------------------------------

# 30. Core Memory Rule

> **`PROJECT_MEMORY.md` must always answer four questions:**

``` text
1. Where are we?
2. What are we currently doing?
3. What has already been completed?
4. What is the next thing that must be done?
```

If another AI agent opens the repository without access to the previous
conversation, it should be able to read:

``` text
RULE.md
PHASES.md
PROJECT_MEMORY.md
```

and understand the current project state well enough to continue safely
without guessing.
