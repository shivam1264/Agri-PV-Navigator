# Agri-PV Navigator — System Architecture

**Project:** Agri-PV Navigator — Visualise, Assess & Design  
**Architecture Style:** Modular Monolith + Asynchronous Calculation Workers  
**Primary Client:** Flutter Application (Dart)  
**Backend:** Node.js + Express  
**Calculation Engine:** Python  
**Database:** PostgreSQL + PostGIS  
**Cache / Queue:** Redis  
**Storage:** S3-compatible Object Storage

---

# 1. Architecture Overview

Agri-PV Navigator is designed as a farmer-centric, site-specific decision-support platform.

The architecture separates the system into five major areas:

```text
┌──────────────────────────────────────────────────────────────┐
│                         FARMER                               │
│                                                              │
│                      Flutter App                             │
│                                                              │
│  Farm Input → Assessment → Design → 3D/AR → Compare → Report│
└──────────────────────────────┬───────────────────────────────┘
                               │
                         HTTPS / JSON
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                    API / APPLICATION LAYER                   │
│                                                              │
│                    Node.js + Express                         │
│                                                              │
│ Auth | Farm | Field | Assessment | Design | Comparison | PDF │
└───────────────┬──────────────────────┬───────────────────────┘
                │                      │
                ▼                      ▼
       ┌─────────────────┐     ┌─────────────────────────┐
       │ PostgreSQL      │     │ Redis                   │
       │ + PostGIS       │     │                         │
       │                 │     │ Cache + Job Queue       │
       │ Core data       │     │ Simulation jobs         │
       │ Geo data        │     │ Temporary state         │
       └─────────────────┘     └────────────┬────────────┘
                                             │
                                      Async Jobs
                                             │
                                             ▼
                              ┌──────────────────────────┐
                              │ Python Calculation Engine│
                              │                          │
                              │ Suitability              │
                              │ Layout                   │
                              │ Solar                    │
                              │ Shadow                   │
                              │ Agriculture              │
                              │ Energy                   │
                              │ Economics                │
                              └─────────────┬────────────┘
                                            │
                                            ▼
                                  Simulation Results
                                            │
                       ┌────────────────────┼───────────────────┐
                       ▼                    ▼                   ▼
                    3D / AR              Compare             PDF
                  Visualization          Results             Report

                              ▲
                              │
                    ┌─────────┴─────────┐
                    │ External Data     │
                    │                   │
                    │ Solar             │
                    │ Elevation         │
                    │ Soil              │
                    │ Crop data         │
                    │ Maps              │
                    └───────────────────┘
```

---

# 2. Core Architecture Principles

## 2.1 Modular, Not Microservice-Heavy

The initial backend uses a **modular monolith**.

Node.js contains clearly separated application modules:

```text
Auth
Farm
Field
Assessment
Design
Comparison
Report
```

These modules are internally separated so that individual components can later be extracted into independent services if the platform grows.

We do not introduce unnecessary microservices during the prototype stage.

---

## 2.2 Calculation Engine Is Isolated

Scientific and engineering calculations are handled by Python.

Node.js is responsible for:

- API requests
- Authentication
- Validation
- Persistence
- Job orchestration
- Result delivery

Python is responsible for:

- Site suitability
- PV layout
- Solar calculations
- Shadow calculations
- Agricultural calculations
- Energy generation
- Economic calculations

This separation keeps the calculation logic independent from the application API.

---

## 2.3 One Canonical Design

A single Agri-PV design must be the source of truth for:

```text
2D Layout
   │
   ├── 3D Visualization
   │
   ├── AR Visualization
   │
   ├── Calculations
   │
   └── PDF Report
```

The 3D/AR layer must not independently create a different engineering layout.

---

## 2.4 Asynchronous Heavy Calculations

Heavy simulations should not block normal API requests.

The flow is:

```text
Mobile App
    │
    ▼
Node.js API
    │
    ▼
Create Simulation Job
    │
    ▼
Redis Queue
    │
    ▼
Python Worker
    │
    ▼
Calculate
    │
    ▼
Save Results
    │
    ▼
Job Completed
```

This allows calculation workers to scale independently.

---

## 2.5 Reproducible Calculations

Every simulation should retain:

```text
Input parameters
External data source
Data timestamp/version
Calculation engine version
Model version
Output
Timestamp
```

Example:

```json
{
  "simulationId": "sim_001",
  "engineVersion": "1.0.0",
  "modelVersion": "agri-pv-v1",
  "status": "COMPLETED"
}
```

This allows old results to remain explainable even after the calculation model changes.

---

# 3. Flow of the Platform

This section describes how information moves through the complete platform.

---

## 3.1 High-Level Product Flow

```text
                    FARMER
                       │
                       ▼
                1. ENTER FARM
                       │
                       ▼
              2. DEFINE FIELD
                       │
                       ▼
           3. SITE SUITABILITY
                       │
                       ▼
             4. DESIGN SYSTEM
                       │
                       ▼
              5. GENERATE LAYOUT
                       │
                       ▼
              6. RUN SIMULATION
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
           Solar     Shadow     Crop
             │         │         │
             └─────────┼─────────┘
                       ▼
                 Energy + Land
                       │
                       ▼
                  Economics
                       │
                       ▼
               7. VISUALISE
                       │
                 ┌─────┴─────┐
                 ▼           ▼
                3D           AR
                 │           │
                 └─────┬─────┘
                       ▼
               8. COMPARE
                       │
                       ▼
               9. FINAL REPORT
```

---

# 4. Detailed Platform Flow

## Step 1 — Farmer Creates a Project

The farmer opens the mobile application and creates a farm/project.

### Input

```text
Project name
Location
```

The project becomes the parent object for the field and Agri-PV designs.

---

## Step 2 — Field Definition

The farmer defines the agricultural land.

### Input

```text
GPS / Map location
Field boundary
Land area
Crop
Farming conditions
```

The field boundary is stored as geospatial data using PostGIS.

### Flow

```text
Flutter App
      │
      ▼
Node.js API
      │
      ▼
PostgreSQL + PostGIS
      │
      ▼
Saved Field
```

---

# 5. Step 3 — Site Suitability

The farmer requests a preliminary site assessment.

```text
Field
  │
  ├── Location
  ├── Area
  ├── Crop
  └── Farming conditions
          │
          ▼
   Assessment Service
          │
          ├── Solar data
          ├── Terrain
          ├── Soil
          └── Crop parameters
          │
          ▼
   Suitability Result
```

The result should contain:

```text
Overall assessment
+
Factor-level results
+
Reasons / explanations
+
Input/data assumptions
```

---

# 6. Step 4 — Design Configuration

The farmer configures an Agri-PV system.

### Main parameters

```text
Panel arrangement
Mounting structure
Spacing
Orientation
Coverage
```

Optional parameters can include:

```text
Panel type
Panel dimensions
Tilt
Mounting height
Row spacing
Machinery clearance
```

### Flow

```text
Farmer
  │
  ▼
Design UI
  │
  ▼
Node.js Design Service
  │
  ▼
Validate configuration
  │
  ▼
Save Design
```

---

# 7. Step 5 — Layout Generation

The design engine converts the configuration into a spatial layout.

```text
Field Boundary
      +
Design Parameters
      │
      ▼
Layout Engine
      │
      ├── Panel positions
      ├── Row arrangement
      ├── Coverage
      ├── Occupied area
      └── Cultivation area
```

The resulting layout becomes the **canonical design geometry**.

---

# 8. Step 6 — Simulation

Simulation is executed asynchronously.

### Request

```text
POST /api/v1/designs/:designId/simulations
```

### API Response

```json
{
  "simulationId": "sim_123",
  "status": "QUEUED"
}
```

### Processing

```text
                 Redis Queue
                     │
                     ▼
              Python Worker
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
      Solar        Shadow       Agriculture
        │            │            │
        └────────────┼────────────┘
                     ▼
                   Energy
                     │
                     ▼
                 Economics
                     │
                     ▼
              Final Results
```

---

# 9. Simulation Stages

## 9.1 Site / Input Validation

Check that all required inputs exist and are valid.

```text
✓ Location
✓ Field geometry
✓ Crop
✓ Design parameters
✓ Required external data
```

---

## 9.2 Solar Calculation

The engine obtains or reads normalized solar data.

Potential sources:

```text
NASA POWER
PVGIS
Other supported provider
```

The external provider is hidden behind a data-adapter layer.

```text
External API
    │
    ▼
Data Adapter
    │
    ▼
Normalized SolarData
    │
    ▼
Solar Engine
```

---

## 9.3 Shadow Calculation

Inputs:

```text
Panel geometry
Mounting height
Tilt
Orientation
Sun position
Location
```

Outputs:

```text
Shadow geometry
Shaded area
Time-dependent shadow position
```

---

## 9.4 Agricultural Calculation

The engine estimates agricultural implications from the available crop and shading model.

Outputs may include:

```text
Cultivable area
Shaded area
Agricultural usability
Crop-impact indicator
```

The exact crop-response methodology remains a project-defined model.

---

## 9.5 Energy Calculation

The engine estimates:

```text
PV capacity
Annual energy generation
```

The result retains the assumptions used.

---

## 9.6 Economic Calculation

The engine can calculate:

```text
Estimated project cost
Potential electricity value/revenue
Payback
NPV
Other supported indicators
```

The MVP must clearly identify these as preliminary estimates.

---

# 10. Step 7 — Result Storage

After calculation:

```text
Python Worker
     │
     ▼
Simulation Results
     │
     ├── PostgreSQL
     │
     └── Object Storage
```

Structured values go into PostgreSQL.

Large artifacts such as:

```text
PDF
3D files
terrain meshes
images
exports
```

go into object storage.

---

# 11. Step 8 — 3D / AR Visualization

The visualization layer consumes the canonical design.

```text
Canonical Design
       │
       ▼
Visualization Data
       │
 ┌─────┴─────┐
 ▼           ▼
3D          AR
```

The farmer can:

- Rotate the scene
- Inspect the installation
- View the field
- View the panels
- Change configurations
- Observe the installation from different perspectives

Where shadow simulation is implemented, the visualization should use the same solar/shadow model as the calculation engine.

---

# 12. Step 9 — Scenario Comparison

The farmer can compare multiple designs for the same field.

```text
Field
 │
 ├── Design A
 │
 ├── Design B
 │
 └── Design C
        │
        ▼
    Comparison
        │
        ├── Cultivation area
        ├── Solar generation
        ├── Agricultural usability
        ├── PV capacity
        ├── Project cost
        └── Potential benefits
```

The comparison presents trade-offs rather than automatically deciding which configuration the farmer should choose.

---

# 13. Step 10 — Report Generation

The report service collects:

```text
Farm information
Field information
Site assessment
Design
Layout
Simulation results
Comparison
Methodology
Assumptions
Limitations
```

and generates:

```text
PDF Proposal
```

The generated PDF is stored in object storage.

The mobile application receives a secure reference for viewing/downloading the report.

---

# 14. Tech Stack

## 14.1 Frontend

### Flutter (Dart)

Used for the farmer-facing mobile application.

Responsibilities:

```text
Farm input
Field definition
Site assessment UI
Design configuration
Results
Comparison
3D / AR
Report access
```

---

## 14.2 Backend API

### Node.js + Express

Responsibilities:

```text
Authentication
Authorization
API routing
Input validation
Farm management
Field management
Design management
Assessment orchestration
Simulation job creation
Comparison
Report requests
```

Node.js does not perform heavy scientific calculations directly.

---

## 14.3 Validation

### Zod / Equivalent Validation Layer

Used for:

```text
API request validation
Design configuration validation
Simulation request validation
Environment/config validation
```

Validation must happen before data enters the calculation pipeline.

---

## 14.4 Database

### PostgreSQL

Used for:

```text
Users
Farms
Fields
Crops
Designs
Simulations
Results
Comparisons
Reports
Metadata
```

---

## 14.5 Spatial Database

### PostGIS

Used for:

```text
Field boundaries
Coordinates
Geospatial queries
Panel geometry
Spatial calculations
Terrain-related geometry
```

---

## 14.6 Cache and Job Queue

### Redis

Redis has three main responsibilities.

### Cache

```text
Solar data
External API results
Reusable environmental data
```

### Job Queue

```text
Simulation jobs
Report jobs
Large calculations
External-data jobs
```

### Temporary State

```text
Job status
Progress
Short-lived computation state
```

---

## 14.7 Calculation Engine

### Python

The Python engine contains the domain/scientific calculations.

Main modules:

```text
Suitability Engine
Layout Engine
Solar Engine
Shadow Engine
Agriculture Engine
Energy Engine
Economics Engine
Environmental Engine
```

---

## 14.8 Worker System

Python calculation workers consume jobs from Redis.

```text
Node.js
   │
   ▼
Redis Queue
   │
   ▼
Python Worker
```

Workers can later be horizontally scaled.

```text
             Redis Queue
          ┌──────┼──────┐
          ▼      ▼      ▼
       Worker  Worker  Worker
          1      2      3
```

---

## 14.9 Object Storage

S3-compatible object storage is used for large/generated files.

Examples:

```text
PDF reports
3D assets
AR assets
Terrain meshes
Images
Exports
```

Object storage should not replace PostgreSQL for structured application data.

---

## 14.10 External Data

The platform may integrate external datasets/APIs for:

```text
Solar
Elevation / terrain
Soil
Crop information
Maps / imagery
```

Potential sources identified during architecture planning include:

```text
NASA POWER
PVGIS
SRTM / other elevation datasets
SoilGrids / FAO datasets
OpenStreetMap / map providers
```

Exact providers are configuration decisions and must be validated before implementation.

---

## 14.11 3D / AR

The 3D/AR technology should be selected based on:

- Flutter compatibility
- Mobile performance
- Geographic placement support
- AR support
- Asset interoperability

The visualization engine consumes canonical design geometry produced by the platform.

---

## 14.12 API Security

The application should use:

```text
HTTPS
JWT authentication
Authorization
Input validation
Rate limiting
Secure secrets
```

A gateway/edge layer can later provide:

```text
WAF
Load balancing
Rate limiting
TLS termination
```

---

## 14.13 Monitoring

The platform should include:

```text
Structured application logs
Calculation/job logs
Error tracking
Performance monitoring
External API failure tracking
```

Every simulation should have an identifiable:

```text
simulationId
requestId
engineVersion
status
```

---

# 15. Folder Structure

The repository should be organized as a scalable monorepo.

```text
agri-pv-navigator/
│
├── apps/
│   │
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
│       │
│       ├── android/
│       ├── ios/
│       ├── package.json
│       └── README.md
│
├── services/
│   │
│   ├── api/
│   │   ├── src/
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   │   ├── auth.controller.js
│   │   │   │   │   ├── auth.service.js
│   │   │   │   │   ├── auth.repository.js
│   │   │   │   │   ├── auth.routes.js
│   │   │   │   │   └── auth.schema.js
│   │   │   │   │
│   │   │   │   ├── farms/
│   │   │   │   ├── fields/
│   │   │   │   ├── assessments/
│   │   │   │   ├── designs/
│   │   │   │   ├── comparisons/
│   │   │   │   └── reports/
│   │   │   │
│   │   │   ├── jobs/
│   │   │   │   ├── simulation.queue.js
│   │   │   │   ├── report.queue.js
│   │   │   │   └── job.handlers.js
│   │   │   │
│   │   │   ├── middleware/
│   │   │   ├── config/
│   │   │   ├── database/
│   │   │   ├── infrastructure/
│   │   │   │   ├── redis/
│   │   │   │   ├── storage/
│   │   │   │   ├── logging/
│   │   │   │   └── external-data/
│   │   │   │
│   │   │   ├── utils/
│   │   │   └── server.js
│   │   │
│   │   ├── prisma/
│   │   │   ├── schema.prisma
│   │   │   └── migrations/
│   │   │
│   │   ├── tests/
│   │   └── package.json
│   │
│   └── calculation-engine/
│       ├── app/
│       │   ├── core/
│       │   │   ├── models/
│       │   │   ├── geometry/
│       │   │   ├── units/
│       │   │   └── validation/
│       │   │
│       │   ├── suitability/
│       │   │   ├── solar.py
│       │   │   ├── terrain.py
│       │   │   ├── soil.py
│       │   │   ├── crop.py
│       │   │   └── scorer.py
│       │   │
│       │   ├── design/
│       │   │   ├── panel.py
│       │   │   ├── layout.py
│       │   │   ├── spacing.py
│       │   │   └── clearance.py
│       │   │
│       │   ├── solar/
│       │   │   ├── sun_position.py
│       │   │   ├── irradiation.py
│       │   │   └── generation.py
│       │   │
│       │   ├── shadow/
│       │   │   ├── geometry.py
│       │   │   └── simulation.py
│       │   │
│       │   ├── agriculture/
│       │   │   ├── crop_model.py
│       │   │   ├── shading.py
│       │   │   └── usability.py
│       │   │
│       │   ├── energy/
│       │   │   └── pv_generation.py
│       │   │
│       │   ├── economics/
│       │   │   ├── capex.py
│       │   │   ├── revenue.py
│       │   │   ├── payback.py
│       │   │   └── npv.py
│       │   │
│       │   ├── environmental/
│       │   │   └── carbon.py
│       │   │
│       │   ├── pipeline/
│       │   │   └── simulation.py
│       │   │
│       │   └── workers/
│       │       └── simulation_worker.py
│       │
│       ├── tests/
│       ├── requirements.txt
│       └── README.md
│
├── packages/
│   │
│   ├── shared-types/
│   │   ├── src/
│   │   └── package.json
│   │
│   ├── shared-config/
│   │   ├── src/
│   │   └── package.json
│   │
│   └── design-schema/
│       ├── src/
│       └── package.json
│
├── infrastructure/
│   ├── docker/
│   │   ├── api.Dockerfile
│   │   ├── calculation.Dockerfile
│   │   └── mobile.Dockerfile
│   │
│   ├── nginx/
│   │   └── nginx.conf
│   │
│   ├── database/
│   │   └── init/
│   │
│   └── deployment/
│       ├── staging/
│       └── production/
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
│   ├── seed/
│   ├── migration/
│   └── development/
│
├── .env.example
├── docker-compose.yml
├── package.json
├── README.md
└── LICENSE
```

---

# 16. Folder Responsibility

## `apps/mobile`

Contains everything directly related to the Flutter (Dart) application.

```text
screens
components
navigation
state
API client
3D/AR UI
feature-specific UI
```

---

## `services/api`

Contains the Node.js application backend.

The backend is a **modular monolith**.

Each module follows:

```text
controller
    ↓
service
    ↓
repository
    ↓
database
```

Example:

```text
design.controller
       ↓
design.service
       ↓
design.repository
       ↓
PostgreSQL
```

---

## `services/calculation-engine`

Contains all scientific/engineering computation.

It should not contain:

- Mobile UI logic
- Authentication
- User CRUD
- General API controllers

It should focus on domain calculations.

---

## `packages/shared-types`

Contains types/interfaces shared between application components.

Examples:

```text
Farm
Field
Design
Simulation
SimulationResult
Comparison
Report
```

---

## `packages/design-schema`

Defines the canonical Agri-PV design structure.

This is important because the same design needs to be understood by:

```text
Node.js
Python
Dart (Flutter)
3D
AR
PDF
```

---

## `infrastructure`

Contains deployment and infrastructure configuration.

---

## `docs`

Contains project documentation.

The important documents are:

```text
PRD.md
architecture.md
methodology.md
api.md
data-model.md
assumptions.md
```

---

# 17. Canonical Design Object

The design schema is a critical boundary between services.

Conceptually:

```json
{
  "designId": "design_001",
  "fieldId": "field_001",

  "panel": {
    "type": "monocrystalline",
    "width": 2.2,
    "height": 1.1,
    "powerWp": 550
  },

  "mounting": {
    "type": "fixed",
    "height": 3.5
  },

  "orientation": 180,
  "tilt": 25,

  "spacing": {
    "row": 6.0,
    "panel": 0.5
  },

  "coverage": 60
}
```

The actual schema will be finalized during technical design.

---

# 18. Simulation Result Object

A simulation should produce a structured result.

Conceptually:

```json
{
  "simulationId": "sim_001",
  "status": "COMPLETED",

  "engineVersion": "1.0.0",

  "site": {
    "suitability": 78
  },

  "layout": {
    "panelCount": 420,
    "coverage": 0.60,
    "cultivableArea": 0.82
  },

  "solar": {
    "annualGenerationKWh": 520000
  },

  "agriculture": {
    "usability": 0.81
  },

  "economics": {
    "estimatedCost": 0,
    "paybackYears": null,
    "npv": null
  }
}
```

The final schema will be defined once the calculation methodology is finalized.

---

# 19. API and Worker Relationship

The most important backend relationship is:

```text
             Mobile App
                  │
                  ▼
             Node.js API
                  │
             Create Job
                  │
                  ▼
             Redis Queue
                  │
                  ▼
          Python Calculation
              Worker
                  │
                  ▼
          PostgreSQL Results
                  │
                  ▼
             Node.js API
                  │
                  ▼
             Mobile App
```

This prevents long-running calculations from blocking the API.

---

# 20. Scalability Model

The architecture is designed to scale in layers.

## Level 1 — Prototype

```text
1 API
1 PostgreSQL
1 Redis
1 Python Worker
1 Object Storage
```

## Level 2 — Growing Usage

```text
Multiple API instances
Multiple Python workers
Managed PostgreSQL
Managed Redis
Object storage
Load balancer
```

## Level 3 — High Compute Load

```text
                    Job Queue
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   Solar Worker   Shadow Worker   Agriculture
        │              │              │
        └──────────────┼──────────────┘
                       ▼
                  Result Store
```

Only introduce this level when actual workload requires it.

---

# 21. Complete End-to-End Relation

The complete relationship between platform components is:

```text
                         FARMER
                           │
                           ▼
                      Flutter App
                           │
                           │ HTTPS
                           ▼
                    API Gateway
                           │
                           ▼
                   Node.js Backend
                           │
          ┌────────────────┼─────────────────┐
          │                │                 │
          ▼                ▼                 ▼
     PostgreSQL          Redis          Object Storage
      + PostGIS         Queue/Cache       Files/Assets
                           │
                           │ Job
                           ▼
                    Python Workers
                           │
          ┌────────────────┼──────────────────┐
          │                │                  │
          ▼                ▼                  ▼
      Site Model       PV Model          Agriculture
          │                │                  │
          └────────────────┼──────────────────┘
                           ▼
                     Result Model
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
            3D             AR         Comparison
             │             │             │
             └─────────────┼─────────────┘
                           ▼
                        Report
                           │
                           ▼
                         Farmer
```

---

# 22. Architecture Rules

The following rules should be maintained during development.

### Rule 1

**Flutter must not contain core scientific calculations.**

### Rule 2

**Node.js must not become a giant calculation module.**

### Rule 3

**Python calculation code must remain independent from UI code.**

### Rule 4

**3D/AR must consume canonical design geometry.**

### Rule 5

**External APIs must be accessed through adapters.**

### Rule 6

**Heavy work must use asynchronous jobs.**

### Rule 7

**Every simulation must be reproducible from stored inputs and versions.**

### Rule 8

**Structured data belongs in PostgreSQL; large artifacts belong in object storage.**

### Rule 9

**The initial system remains a modular monolith rather than prematurely splitting into microservices.**

### Rule 10

**The architecture should allow calculation workers and API instances to scale independently.**

---

# 23. Architecture-to-PRD Mapping

| PRD Requirement | Architecture Component |
|---|---|
| Farm input | Flutter + Farm API |
| Field definition | Flutter + PostGIS |
| Site suitability | Assessment module + Python Suitability Engine |
| Panel configuration | Design module |
| Layout generation | Python Layout Engine |
| Solar generation | Python Solar/Energy Engine |
| Agricultural usability | Python Agriculture Engine |
| 3D visualization | Mobile 3D layer |
| AR visualization | Mobile AR layer |
| Configuration comparison | Comparison module |
| Project cost | Economics Engine |
| Potential benefits | Economics/Agriculture/Energy outputs |
| PDF report | Report Service + Object Storage |
| External solar data | External Data Adapter Layer |
| Scalable simulation | Redis Queue + Python Workers |
| Geographic data | PostgreSQL + PostGIS |
| Generated assets | Object Storage |

---

# 24. Final Architecture Summary

Agri-PV Navigator uses a **farmer-facing Flutter application**, a **Node.js modular backend**, a **PostgreSQL/PostGIS spatial database**, **Redis for caching and asynchronous jobs**, a **Python calculation engine**, external data adapters, and object storage for generated assets.

The fundamental architecture is:

```text
INPUT
  ↓
FARM + FIELD
  ↓
SITE ASSESSMENT
  ↓
AGRI-PV DESIGN
  ↓
CANONICAL LAYOUT
  ↓
ASYNC SIMULATION
  ↓
SOLAR + SHADOW + AGRICULTURE + ENERGY + ECONOMICS
  ↓
RESULTS
  ↓
3D / AR + COMPARISON + REPORT
  ↓
FARMER DECISION
```

The most important architectural relationship is:

> **One canonical Agri-PV design → one calculation pipeline → multiple consistent outputs.**

This keeps the platform understandable during the prototype stage while providing a clean path toward higher traffic, more calculation workers, more external data providers, and future platform expansion.
