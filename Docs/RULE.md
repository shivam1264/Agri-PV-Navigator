# Agri-PV Navigator --- Development Rules

**Project:** Agri-PV Navigator: Visualise, Assess & Design\
**Document:** `RULE.md`\
**Purpose:** Define the engineering, architecture, coding, scientific,
data, UI, and development rules that all contributors and coding agents
must follow.

------------------------------------------------------------------------

# 1. General Principles

## 1.1 Product Principle

Agri-PV Navigator is a **farmer-centric decision-support application**.

The application must help a farmer:

1.  Enter basic farm and field information.
2.  Assess preliminary site suitability.
3.  Configure an Agri-PV system.
4.  Generate a representative panel layout.
5.  Estimate solar generation and agricultural usability.
6.  Compare different configurations.
7.  Visualise the proposed system in 3D/AR.
8.  Review preliminary techno-economic information.
9.  Generate a concise report explaining the methodology and
    assumptions.

The system is a **preliminary assessment and design-support tool**, not
an engineering certification, EPC design system, or investment-grade
financial model.

------------------------------------------------------------------------

## 1.2 Build vs Library Principle

Follow this rule throughout the project:

> **Use libraries for generic technical problems. Build our own logic
> for Agri-PV-specific decision-making.**

### Use established libraries for

-   Authentication
-   Password hashing
-   HTTP/API framework
-   Request validation
-   Database access
-   Spatial database operations
-   Basic GIS geometry
-   Map rendering
-   Solar position
-   PV system modelling
-   Numerical computation
-   Coordinate transformations
-   Raster/terrain processing
-   3D rendering
-   AR tracking
-   PDF generation
-   Queues
-   Caching
-   Logging
-   Testing

### Build ourselves

-   Agri-PV site suitability methodology
-   Agri-PV layout generation
-   Panel spacing rules
-   Mounting configuration logic
-   Agricultural constraints
-   Machinery clearance logic
-   Shadow-to-crop-impact methodology
-   Crop compatibility methodology
-   Land-use / cultivation usability methodology
-   Scenario comparison
-   Preliminary techno-economic model
-   Canonical Agri-PV design model
-   Simulation orchestration
-   Farmer-facing decision-support workflow

Do not rewrite mature algorithms when an established, maintained library
already provides the required primitive.

Do not blindly depend on a library when the behaviour represents a core
Agri-PV product decision.

------------------------------------------------------------------------

# 2. Scope Discipline

## 2.1 MVP Must Follow the Problem Statement

The MVP must support:

-   Location input
-   Land/field area
-   Crop information
-   Farming conditions
-   Site suitability
-   Panel arrangement configuration
-   Mounting structure configuration
-   Spacing configuration
-   Orientation configuration
-   Coverage configuration
-   Representative 3D/AR visualisation
-   Configuration comparison
-   Cultivation-area assessment
-   Solar-generation estimation
-   Agricultural usability assessment
-   Estimated PV capacity
-   Estimated energy generation
-   Preliminary project cost
-   Potential benefits
-   Methodology and assumptions
-   Concise project report

------------------------------------------------------------------------

## 2.2 Do Not Overclaim

The application must not present preliminary calculations as guaranteed
results.

Avoid statements such as:

-   "Your crop yield will increase by 20%."
-   "This project will definitely be profitable."
-   "This is an engineering-approved design."
-   "This system is guaranteed to generate X kWh."
-   "This installation is safe to construct without further
    engineering."
-   "This is an investment-grade financial forecast."

Prefer:

-   "Estimated"
-   "Preliminary"
-   "Modelled"
-   "Based on the selected assumptions"
-   "Indicative"
-   "Requires site-specific validation"

------------------------------------------------------------------------

# 3. Architecture Principles

## 3.1 High-Level Architecture

The target architecture is:

``` text
Farmer
   ↓
Flutter Mobile App
   ↓ HTTPS / JSON
Node.js + Express API
   ↓
PostgreSQL + PostGIS
   ↓
Redis Queue / Cache
   ↓
Python Calculation Workers
   ├── Site Suitability
   ├── Layout
   ├── Solar
   ├── Shadow
   ├── Agriculture
   ├── Energy
   ├── Economics
   └── Environmental
   ↓
Simulation Results
   ↓
3D / AR Visualisation
   ↓
Comparison / Report
```

------------------------------------------------------------------------

## 3.2 Modular Monolith First

Do **not** create a large microservice architecture prematurely.

The initial backend should be a modular Node.js/Express application with
clear domain modules.

Recommended modules:

``` text
auth
farms
fields
assessments
designs
simulations
comparisons
reports
users
```

The Python calculation engine should remain an independently executable
calculation service/worker because numerical workloads may need to scale
independently.

------------------------------------------------------------------------

## 3.3 Asynchronous Heavy Calculations

Heavy calculations must not block normal API requests.

Use:

``` text
Mobile
  ↓
Node API
  ↓
Create Simulation Job
  ↓
Redis Queue
  ↓
Python Worker
  ↓
Run Calculation Pipeline
  ↓
Persist Results
  ↓
Mark Job Complete
  ↓
Mobile Retrieves Results
```

Use asynchronous jobs for:

-   Shadow calculations
-   Large layout generation
-   Solar simulations
-   Terrain processing
-   Multi-scenario comparison
-   Report generation
-   Large 3D asset generation

Simple CRUD operations should remain synchronous.

------------------------------------------------------------------------

# 4. Canonical Design Principle

The project must maintain one canonical representation of an Agri-PV
design.

``` text
Agri-PV Design
 ├── Field boundary
 ├── Panel type
 ├── Panel dimensions
 ├── Panel count
 ├── Row configuration
 ├── Column configuration
 ├── Mounting height
 ├── Tilt
 ├── Azimuth
 ├── Row spacing
 ├── Panel spacing
 ├── Coverage
 ├── Clearance
 └── Generated geometry
```

The same canonical design must be used by:

-   Layout calculation
-   Solar calculation
-   Shadow calculation
-   Agricultural analysis
-   Energy estimation
-   Economics
-   3D rendering
-   AR rendering
-   Comparison
-   Report generation

### Critical rule

**Never create separate "visual" and "calculation" versions of the same
design.**

The 3D/AR system must visualise the same design object used by the
calculation engine.

------------------------------------------------------------------------

# 5. Technology Standards

## 5.1 Mobile

### Primary

-   Flutter
-   Dart

### Mapping

-   MapLibre Flutter

### GIS utilities

-   Turf.js where lightweight client-side GeoJSON operations are
    required

### 3D

-   Three.js or an appropriate Flutter-compatible 3D rendering
    solution

### AR

-   Apple ARKit for iOS
-   Google ARCore for Android

### Rules

-   Use Dart.
-   Do not place business/scientific calculations directly inside UI
    components.
-   Keep API calls inside service/API layers.
-   Keep reusable UI components independent of domain calculations.
-   Do not duplicate backend calculation logic in the mobile app.
-   The mobile app should consume server-calculated assessment and
    simulation results.

------------------------------------------------------------------------

### 5.1.1 Flutter Architecture

Organize the Flutter application by feature rather than by a large global collection of unrelated widgets.

Recommended feature boundaries:

```text
features/
├── auth/
├── farms/
├── fields/
├── assessment/
├── design/
├── visualization/
├── comparison/
└── reports/
```

Each feature should keep its:

- Screens/pages
- Widgets
- State management
- Models
- API/repository integration
- Feature-specific utilities

The exact Flutter state-management package may be selected during implementation. Do not introduce a state-management dependency without documenting the choice.

Keep the following boundaries:

```text
Flutter UI
   ↓
Presentation / State
   ↓
Repositories / API
   ↓
Node.js API
   ↓
Python calculation engine
```

Do not duplicate the scientific calculation engine in Dart.

# 5.2 Backend

### Primary

-   Node.js
-   Express
-   TypeScript preferred

### Validation

-   Zod or equivalent schema validation library

### Database

-   PostgreSQL
-   PostGIS

### ORM / database access

-   Prisma or another established PostgreSQL ORM/query layer

### Queue / cache

-   Redis
-   BullMQ or equivalent job queue

### Logging

-   Pino or Winston

### Rules

-   Validate every external input.
-   Never trust client-side validation alone.
-   Use centralized error handling.
-   Use structured logging.
-   Keep business modules isolated.
-   Do not put database queries directly into route handlers.
-   Do not put scientific calculations inside Express controllers.

------------------------------------------------------------------------

# 6. Python Calculation Engine

## 6.1 Core Libraries

Use established scientific libraries where appropriate:

### Numerical computation

-   NumPy
-   Pandas
-   SciPy

### Solar/PV

-   pvlib

Use `pvlib` for established solar/PV calculations such as:

-   Solar position
-   Irradiance-related calculations
-   PV system modelling
-   PV performance modelling

Do not manually implement astronomical solar-position equations unless
there is a documented scientific reason.

### Geometry

-   Shapely

Use Shapely for:

-   Polygon operations
-   Intersections
-   Buffers
-   Spatial relationships
-   Geometry manipulation

### GIS / coordinate systems

-   PyProj
-   GeoPandas where useful
-   Rasterio / GDAL where required

### Database GIS

Use PostGIS for persistent spatial data and database-side spatial
operations.

------------------------------------------------------------------------

# 7. Calculation Engine: Build vs Library

## 7.1 Site Suitability

### Use libraries/data sources for

-   Solar resource
-   Elevation
-   Coordinate transformations
-   Terrain/raster processing
-   GIS geometry

### Build ourselves

The suitability methodology.

Example conceptual factors:

``` text
Solar suitability
Terrain suitability
Field geometry
Agricultural constraints
Water/farming constraints
Access/clearance
Land usability
Other project-specific constraints
```

The exact weighting must be documented in `docs/methodology.md`.

Never hide suitability weights inside arbitrary code.

Example:

``` text
solar_score × weight
terrain_score × weight
agriculture_score × weight
access_score × weight
...
```

Weights must be configurable and versioned.

------------------------------------------------------------------------

# 8. Agri-PV Layout Engine

The layout engine is a core project component and must be developed
in-house.

It should determine:

-   Panel placement
-   Row spacing
-   Panel spacing
-   Orientation
-   Tilt
-   Mounting height
-   Coverage
-   Exclusion zones
-   Field boundary constraints
-   Required clearances
-   Access corridors
-   Machinery corridors where applicable

Use:

-   Shapely
-   PostGIS
-   NumPy

for geometry and numerical primitives.

Do not build a custom geometry library.

------------------------------------------------------------------------

# 9. Solar Calculation

Use `pvlib` for established solar calculations.

The application layer should provide:

``` text
latitude
longitude
date/time
timezone
surface orientation
tilt
PV module configuration
system configuration
weather/irradiance data
```

The calculation engine then uses pvlib to estimate:

-   Solar position
-   Irradiance
-   PV output
-   Energy generation

The Agri-PV-specific configuration is ours.

------------------------------------------------------------------------

# 10. Shadow Calculation

Shadow analysis is a hybrid component.

## Use libraries for

-   Solar position → pvlib
-   Geometry → Shapely
-   Coordinate transformation → PyProj
-   Terrain/raster → Rasterio/GDAL where required

## Build ourselves

-   Panel/structure geometry
-   Shadow projection
-   Field intersection
-   Crop-zone shadow mapping
-   Time-based shadow aggregation
-   Shadow-to-agricultural-impact methodology

Do not create a custom solar-position implementation.

------------------------------------------------------------------------

# 11. Agricultural Analysis

Agricultural analysis is domain logic and must be built as project
methodology.

Possible inputs include:

-   Crop type
-   Crop growth conditions
-   Light requirements
-   Field conditions
-   Cultivation area
-   Shadow exposure
-   Farming access
-   Machinery requirements
-   Irrigation/access constraints

The system should clearly distinguish:

``` text
Observed/Input Data
        ↓
Model Assumptions
        ↓
Calculated Result
        ↓
Interpretation
```

Do not present model assumptions as measured agricultural facts.

------------------------------------------------------------------------

# 12. Crop Compatibility

Crop compatibility must be represented using an explicit, versioned
model.

Example:

``` text
Crop
 ├── crop_id
 ├── name
 ├── category
 ├── light_requirement
 ├── shade_tolerance
 ├── preferred_conditions
 ├── machinery_requirements
 └── model_version
```

If a crop parameter comes from external literature or a dataset, record:

-   Source
-   Date/version
-   Unit
-   Reference
-   Transformation applied

------------------------------------------------------------------------

# 13. Land and Cultivation Usability

The system must distinguish between:

``` text
Total field area
Panel-covered area
Structure/exclusion area
Access/corridor area
Remaining cultivation area
```

Do not simply calculate:

``` text
cultivation_area = total_area - panel_area
```

unless the methodology explicitly defines this approximation.

The calculation should account for the actual layout and project
assumptions.

------------------------------------------------------------------------

# 14. Energy Calculation

Energy results must be traceable.

At minimum record:

``` text
PV capacity
Energy estimate
Calculation period
Solar/weather source
Module assumptions
Tilt
Azimuth
System losses
Calculation engine version
```

Do not hard-code unexplained loss percentages.

All important assumptions must be visible in the methodology/report.

------------------------------------------------------------------------

# 15. Techno-Economic Model

The MVP requires a **preliminary** techno-economic assessment.

Build the economic formulas ourselves.

Use:

-   NumPy
-   Pandas

for numerical processing.

Potential inputs:

``` text
PV capacity
Estimated annual generation
System cost assumptions
Installation cost
Maintenance assumptions
Electricity value/tariff assumption
Project lifetime
Other documented assumptions
```

Potential outputs:

``` text
Estimated project cost
Estimated annual energy value
Potential benefits
Indicative payback
Other supported economic indicators
```

Only implement metrics whose assumptions can be properly documented.

Do not present preliminary economics as an investment-grade financial
model.

------------------------------------------------------------------------

# 16. Scenario Comparison

Comparison is a product feature and must be built ourselves.

A scenario may contain:

``` text
Design A
Design B
Design C
```

Compare supported metrics such as:

-   PV capacity
-   Energy generation
-   Cultivation area
-   Coverage
-   Agricultural usability
-   Estimated cost
-   Other documented indicators

Do not create an overall "best design" score unless the methodology
explicitly requires one and its weighting is scientifically justified.

Show the underlying metrics and assumptions so the farmer can understand
the trade-offs.

------------------------------------------------------------------------

# 17. 3D Visualisation

Do not build a 3D renderer from scratch.

Use an established 3D engine such as:

-   Three.js
-   Appropriate Flutter 3D library

The renderer should receive the canonical design geometry.

It should visualise:

-   Field
-   Terrain where available
-   Panel rows
-   Mounting structures
-   Orientation
-   Spacing
-   Access corridors
-   Representative surroundings

Visualisation is not the source of truth for calculations.

------------------------------------------------------------------------

# 18. AR

Do not build AR tracking from scratch.

Use:

-   ARKit
-   ARCore

The project should build:

-   Placement workflow
-   Design-to-world coordinate transformation
-   User controls
-   AR visualisation
-   Measurement/interaction UI where supported

AR is a representative visualisation feature, not proof of
construction-level positioning accuracy.

------------------------------------------------------------------------

# 19. GIS Rules

## Use

### PostGIS

For:

-   Persistent field boundaries
-   Spatial queries
-   Geographic storage
-   Server-side spatial operations

### Shapely

For:

-   Calculation-engine geometry
-   Layout operations
-   Intersection
-   Buffering
-   Geometry validation

### Turf.js

For:

-   Lightweight client-side GeoJSON operations
-   Map interaction utilities
-   Simple spatial calculations

### PyProj

For:

-   Coordinate reference system conversion
-   Projection handling

### Rasterio/GDAL

For:

-   Elevation/terrain rasters
-   Raster analysis
-   Terrain-related processing

### Rules

-   Never mix coordinate systems without explicit conversion.
-   Store the CRS with spatial data where appropriate.
-   Document whether a calculation uses geographic or projected
    coordinates.
-   Avoid performing precision geometry in raw latitude/longitude
    degrees.
-   Validate field polygons before simulation.
-   Preserve GeoJSON compatibility for client-server exchange where
    appropriate.

------------------------------------------------------------------------

# 20. External Data Sources

External data must be accessed through adapters.

Do not spread API-specific code throughout the calculation engine.

Use a structure such as:

``` text
external-data/
 ├── solar/
 ├── elevation/
 ├── soil/
 ├── weather/
 └── maps/
```

Each adapter should expose a stable internal interface.

Example:

``` text
SolarDataProvider
ElevationDataProvider
SoilDataProvider
```

This allows providers to be replaced without rewriting the calculation
engine.

------------------------------------------------------------------------

# 21. Data Provenance and Reproducibility

Every simulation must record:

``` text
Input parameters
External data source
External data timestamp/version
Calculation engine version
Model version
Methodology version
Output
Created timestamp
```

Example:

``` text
simulation_id
methodology_version
engine_version
solar_data_source
solar_data_timestamp
input_hash
created_at
```

A user must be able to understand how an old result was generated even
after the calculation engine changes.

------------------------------------------------------------------------

# 22. Versioning

Version all important scientific logic.

At minimum:

``` text
methodology_version
calculation_engine_version
suitability_model_version
agriculture_model_version
economic_model_version
```

Never silently change a scientific model while keeping old results
labelled as if they were generated by the new model.

------------------------------------------------------------------------

# 23. API Standards

Use REST-style APIs unless there is a strong reason otherwise.

Example:

``` text
POST   /api/farms
GET    /api/farms/:id

POST   /api/fields
GET    /api/fields/:id

POST   /api/assessments
GET    /api/assessments/:id

POST   /api/designs
GET    /api/designs/:id
PATCH  /api/designs/:id

POST   /api/simulations
GET    /api/simulations/:id

POST   /api/comparisons
GET    /api/comparisons/:id

POST   /api/reports
GET    /api/reports/:id
```

Use consistent:

-   HTTP status codes
-   Request schemas
-   Response schemas
-   Error formats
-   Pagination
-   Authentication
-   Authorization

------------------------------------------------------------------------

# 24. Error Handling

Never expose internal stack traces to mobile clients in production.

Use a consistent error format:

``` json
{
  "success": false,
  "error": {
    "code": "FIELD_NOT_FOUND",
    "message": "The requested field could not be found."
  }
}
```

Log detailed technical information on the server.

Errors should be actionable where possible.

------------------------------------------------------------------------

# 25. Security

Follow secure defaults.

## Authentication

Use established libraries for:

-   Password hashing
-   JWT/session handling
-   Token verification

Do not implement cryptography manually.

## API

Use:

-   Input validation
-   Authentication middleware
-   Authorization checks
-   Rate limiting
-   Secure headers
-   CORS configuration
-   Request size limits

## Database

-   Use parameterized queries / ORM mechanisms.
-   Never construct SQL from untrusted strings.
-   Apply least-privilege database credentials.

## File uploads

Validate:

-   File type
-   File size
-   File extension
-   MIME type where appropriate

Do not trust the filename supplied by the client.

------------------------------------------------------------------------

# 26. Coding Standards

## General

-   Prefer readable code over clever code.
-   Keep functions small and focused.
-   Avoid unnecessary abstraction.
-   Avoid duplicated business logic.
-   Use descriptive names.
-   Keep domain logic separate from infrastructure code.
-   Do not leave unexplained magic numbers.
-   Add comments for **why**, not merely **what**.

------------------------------------------------------------------------

## Dart / Flutter

Use:

- Dart null safety
- Strong typing
- Explicit types for public interfaces
- Reusable widgets
- Feature-oriented architecture
- Repository/data separation
- Clear presentation/domain/data boundaries

Avoid putting API calls, database logic, or scientific calculations directly inside widgets.

Keep Flutter-specific implementation details isolated from the backend calculation methodology.

## Python

Use:

-   Type hints
-   PEP 8-compatible formatting
-   Small pure functions where practical
-   Dataclasses/Pydantic-style schemas where appropriate
-   Unit tests for calculation functions

Scientific functions should be deterministic whenever their inputs are
deterministic.

------------------------------------------------------------------------

# 27. Constants and Configuration

Never bury important project assumptions inside calculation code.

Bad:

``` python
energy = capacity * 4.7 * 365
```

Better:

``` python
energy = capacity * daily_specific_yield * days_per_year
```

with the assumption defined and documented.

Keep configurable assumptions in a clearly defined configuration/model
layer.

------------------------------------------------------------------------

# 28. Units

Units must be explicit.

Examples:

``` text
Area       → m² / hectare
Distance   → m
Power      → kW / MW
Energy     → kWh / MWh
Irradiance → W/m²
Angle      → degrees
Time       → ISO 8601 / timezone-aware
```

Do not mix units silently.

Where possible, encode units in variable names or domain models.

Bad:

``` text
area
```

Better:

``` text
area_m2
area_hectares
```

------------------------------------------------------------------------

# 29. Time and Location

All location-dependent calculations must explicitly use:

``` text
latitude
longitude
elevation where available
timezone
date/time
```

Do not assume UTC or device local time without documenting the
conversion.

Solar calculations must use the correct site coordinates and timezone.

------------------------------------------------------------------------

# 30. Database Standards

Use PostgreSQL as the primary relational database.

Use PostGIS for spatial data.

Conceptual hierarchy:

``` text
User
 └── Farm
      └── Field
           ├── Crop
           ├── Farming Conditions
           ├── Assessment
           └── Designs
                ├── Configuration
                ├── Simulation
                └── Results
```

Designs should be immutable/versioned when required for reproducibility.

Do not overwrite historical simulation results.

------------------------------------------------------------------------

# 31. Project Structure

Recommended structure:

``` text
agri-pv-navigator/
│
├── apps/
│   └── mobile/
│       ├── src/
│       │   ├── components/
│       │   ├── screens/
│       │   ├── navigation/
│       │   ├── hooks/
│       │   ├── services/
│       │   ├── store/
│       │   ├── api/
│       │   ├── types/
│       │   ├── utils/
│       │   ├── features/
│       │   │   ├── auth/
│       │   │   ├── farms/
│       │   │   ├── fields/
│       │   │   ├── assessment/
│       │   │   ├── design/
│       │   │   ├── visualization/
│       │   │   ├── comparison/
│       │   │   └── reports/
│       │   └── assets/
│       ├── android/
│       ├── ios/
│       └── package.json
│
├── services/
│   ├── api/
│   │   ├── src/
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   ├── farms/
│   │   │   │   ├── fields/
│   │   │   │   ├── assessments/
│   │   │   │   ├── designs/
│   │   │   │   ├── comparisons/
│   │   │   │   └── reports/
│   │   │   ├── jobs/
│   │   │   ├── middleware/
│   │   │   ├── config/
│   │   │   ├── database/
│   │   │   ├── infrastructure/
│   │   │   └── server.ts
│   │   ├── prisma/
│   │   └── tests/
│   │
│   └── calculation-engine/
│       ├── app/
│       │   ├── core/
│       │   ├── suitability/
│       │   ├── design/
│       │   ├── solar/
│       │   ├── shadow/
│       │   ├── agriculture/
│       │   ├── energy/
│       │   ├── economics/
│       │   ├── environmental/
│       │   ├── pipeline/
│       │   └── workers/
│       ├── tests/
│       └── requirements.txt
│
├── packages/
│   ├── shared-types/
│   ├── shared-config/
│   └── design-schema/
│
├── infrastructure/
│   ├── docker/
│   ├── nginx/
│   ├── database/
│   └── deployment/
│
├── docs/
│   ├── PRD.md
│   ├── architecture.md
│   ├── methodology.md
│   ├── api.md
│   ├── data-model.md
│   └── assumptions.md
│
├── scripts/
├── .env.example
├── docker-compose.yml
├── package.json
├── README.md
└── RULE.md
```

------------------------------------------------------------------------

# 32. Documentation Standards

The following documents should remain synchronized with implementation:

``` text
docs/PRD.md
docs/architecture.md
docs/methodology.md
docs/api.md
docs/data-model.md
docs/assumptions.md
RULE.md
```

If a major architecture or methodology decision changes, update the
relevant documentation.

------------------------------------------------------------------------

# 33. Testing Standards

Testing is mandatory for calculation logic.

## Backend

Test:

-   Authentication
-   Authorization
-   Validation
-   CRUD operations
-   API responses
-   Error handling

## Calculation Engine

Test:

-   Geometry
-   Suitability
-   Layout
-   Solar calculations
-   Shadow calculations
-   Agricultural calculations
-   Energy calculations
-   Economics
-   Unit conversions

## Integration

Test:

``` text
API
 ↓
Job Queue
 ↓
Calculation Worker
 ↓
Database
 ↓
Result Retrieval
```

------------------------------------------------------------------------

# 34. Scientific Testing

Calculation tests should include known/reference cases.

For scientific calculations:

``` text
Input
↓
Expected/Reference Result
↓
Tolerance
```

Do not use exact equality for floating-point calculations when a
tolerance is scientifically appropriate.

Document acceptable tolerances.

------------------------------------------------------------------------

# 35. Determinism

Given the same:

``` text
Input
+ External data version
+ Methodology version
+ Engine version
```

the calculation engine should produce reproducible results.

If randomness is required, explicitly control and record the random
seed.

------------------------------------------------------------------------

# 36. Performance Rules

Do not optimise prematurely.

First ensure:

``` text
Correctness
→ Testability
→ Maintainability
→ Performance
```

Optimise when profiling demonstrates a real bottleneck.

Heavy operations should run in workers.

Cache expensive external data where appropriate.

Do not cache results without considering the input/model version.

------------------------------------------------------------------------

# 37. UI/UX Rules

The UI must be farmer-oriented.

Prefer:

-   Simple language
-   Visual explanations
-   Clear units
-   Progressive disclosure
-   Large touch targets
-   Clear warnings
-   Minimal technical jargon

Avoid exposing complex scientific parameters unless the user needs them.

Advanced configuration can be placed under an "Advanced" section.

Every major result should explain:

``` text
What is this?
Why does it matter?
What assumptions were used?
```

------------------------------------------------------------------------

# 38. Result Presentation

Do not present a single unexplained number.

For example, instead of:

``` text
Suitability: 78
```

show:

``` text
Site suitability: 78/100

Based on:
- Solar resource
- Field geometry
- Terrain
- Agricultural constraints
- Access/clearance

Important assumptions:
...
```

The exact score methodology must be documented.

------------------------------------------------------------------------

# 39. Warnings and Uncertainty

Where data quality is poor, the application should say so.

Examples:

``` text
Limited terrain data
Estimated solar resource
Agricultural parameters based on generic crop assumptions
Indicative cost assumptions
```

Do not create false precision.

Avoid displaying:

``` text
78.394728%
```

when the underlying model does not justify that precision.

------------------------------------------------------------------------

# 40. Dependency Rules

Before adding a dependency:

1.  Check whether an existing dependency already solves the problem.
2.  Prefer established and maintained libraries.
3.  Prefer libraries with clear documentation and active ecosystems.
4.  Check licensing compatibility.
5.  Avoid unnecessary dependencies.
6.  Avoid libraries that duplicate functionality already available in
    the stack.
7.  Document important dependencies in the project documentation.

Do not implement cryptography, GIS geometry engines, solar astronomy, or
AR tracking from scratch when mature libraries exist.

------------------------------------------------------------------------

# 41. Recommended Library Stack

  Area              Recommended Technology            Responsibility
  ----------------- --------------------------------- --------------------------------
  Mobile            Flutter                           Mobile application
  Language          Dart / TypeScript                 Mobile (Dart) / Backend (TypeScript) typing
  API               Express                           HTTP API
  Validation        Zod                               Runtime validation
  ORM               Prisma                            Database access
  Database          PostgreSQL                        Relational data
  Spatial DB        PostGIS                           Spatial storage/query
  Cache             Redis                             Cache/state
  Queue             BullMQ                            Background jobs
  Solar/PV          pvlib                             Solar/PV modelling
  Numerical         NumPy                             Numerical computation
  Data processing   Pandas                            Tabular processing
  Scientific        SciPy                             Scientific computation
  Geometry          Shapely                           Python geometry
  CRS               PyProj                            Coordinate systems
  GIS               GeoPandas                         Geospatial data handling
  Raster            Rasterio/GDAL                     Terrain/raster data
  Client GIS        Turf.js                           Lightweight GeoJSON operations
  Maps              MapLibre Flutter             Mobile maps
  3D                Three.js / RN-compatible engine   3D visualisation
  AR iOS            ARKit                             AR tracking
  AR Android        ARCore                            AR tracking
  Logging           Pino/Winston                      Structured logging
  Containers        Docker                            Packaging/deployment
  Testing JS        Jest/Vitest                       JS/TS testing
  Testing Python    Pytest                            Python testing
  Object storage    S3-compatible storage             Reports/assets
  PDF               Established PDF library           Report generation

Library versions should be selected during implementation based on
compatibility with the project's current runtime and platform
requirements. Do not blindly copy version numbers from old
documentation.

------------------------------------------------------------------------

# 42. What Must NOT Be Built From Scratch

Do not implement custom versions of:

-   JWT
-   Password hashing
-   Cryptographic primitives
-   HTTP server
-   ORM
-   Database engine
-   GIS geometry engine
-   Solar astronomy equations
-   PV modelling primitives
-   Coordinate transformation engine
-   Map renderer
-   3D renderer
-   AR tracking
-   PDF rendering engine
-   Job queue
-   Cache engine

Use mature libraries.

------------------------------------------------------------------------

# 43. What SHOULD Be Built From Scratch

These are core product IP/domain components:

``` text
Agri-PV suitability methodology
Agri-PV layout algorithm
Panel spacing logic
Agricultural constraints
Machinery clearance logic
Shadow-to-crop-impact model
Crop compatibility model
Cultivation usability model
Scenario comparison
Preliminary techno-economic model
Canonical design schema
Simulation pipeline
Farmer-facing interpretation
```

------------------------------------------------------------------------

# 44. Agent/Coding Assistant Rules

Any coding agent working on this repository must:

1.  Read `RULE.md` before making changes.
2.  Read the relevant documentation before modifying architecture or
    methodology.
3.  Reuse existing libraries before creating new implementations.
4.  Search the existing codebase before adding duplicate functionality.
5.  Never silently change scientific assumptions.
6.  Never invent data sources.
7.  Never hard-code unexplained scientific/economic constants.
8.  Add tests for calculation changes.
9.  Update documentation when methodology changes.
10. Keep calculation logic independent from UI.
11. Keep API logic independent from scientific implementation.
12. Preserve reproducibility.
13. Avoid unnecessary dependencies.
14. Avoid premature microservices.
15. Do not modify unrelated files.
16. Explain architectural trade-offs for significant changes.

------------------------------------------------------------------------

# 45. Change Protocol

Before implementing a major change:

``` text
1. Understand the requirement
2. Identify affected module
3. Check existing implementation
4. Check whether a library already solves the generic part
5. Identify domain-specific logic
6. Define inputs/outputs
7. Implement
8. Test
9. Update documentation
10. Verify no unrelated behaviour changed
```

------------------------------------------------------------------------

# 46. Scientific Change Protocol

Any change to:

-   Suitability weights
-   Crop assumptions
-   Shadow methodology
-   Energy assumptions
-   Cost assumptions
-   Economic formulas
-   Layout rules
-   Agricultural rules

must:

1.  Be explicitly documented.
2.  Receive a methodology/model version.
3.  Include or update tests.
4.  State affected outputs.
5.  Preserve old results where required.
6.  Never silently invalidate historical simulations.

------------------------------------------------------------------------

# 47. Definition of Done

A feature is not complete merely because the UI works.

A feature is complete when:

``` text
Requirement implemented
        ↓
Validation implemented
        ↓
Backend implemented
        ↓
Calculation logic implemented
        ↓
Tests added
        ↓
Error handling added
        ↓
Data persistence verified
        ↓
UI integrated
        ↓
Documentation updated
```

For scientific features, also require:

``` text
Methodology documented
Assumptions documented
Units documented
Version recorded
Reference/test case available
```

------------------------------------------------------------------------

# 48. Core Engineering Rule

The most important rule for this project is:

> **Do not reinvent generic technology, and do not outsource the
> project's core Agri-PV intelligence to generic libraries.**

Use mature libraries for the foundations.

Build and document the Agri-PV methodology ourselves.

The architecture should make it possible to replace a library or
external data provider without rewriting the core decision-support
logic.

------------------------------------------------------------------------

# 49. Final Architecture Boundary

The intended boundary is:

``` text
┌─────────────────────────────────────────────┐
│              USE LIBRARIES                 │
├─────────────────────────────────────────────┤
│ Auth                                        │
│ Database                                    │
│ PostGIS                                     │
│ GIS primitives                              │
│ Solar position                              │
│ PV modelling                                │
│ Numerical computing                         │
│ Coordinate systems                          │
│ Terrain/raster processing                   │
│ Maps                                        │
│ 3D rendering                                │
│ AR tracking                                 │
│ PDF generation                              │
│ Queue / cache                               │
│ Logging                                     │
│ Testing                                     │
└─────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│             BUILD OURSELVES                 │
├─────────────────────────────────────────────┤
│ Agri-PV suitability model                   │
│ Agri-PV layout algorithm                    │
│ Agricultural constraints                    │
│ Machinery clearance                         │
│ Shadow → crop impact                        │
│ Crop compatibility                          │
│ Cultivation usability                       │
│ Scenario comparison                         │
│ Techno-economic model                       │
│ Canonical Agri-PV design                    │
│ Simulation orchestration                    │
│ Farmer-facing decision support              │
└─────────────────────────────────────────────┘
```

This boundary should remain the default architectural decision unless
there is a documented reason to change it.
