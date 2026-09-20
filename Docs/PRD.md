# Agri-PV Navigator — Product Requirements Document (PRD)

**Status:** Draft — aligned with Problem Statement 02  
**Project:** Agri-PV Navigator: Visualise, Assess & Design  
**Primary Platform:** Farmer-centric mobile application  
**Reference Concept:** Sunbiose Agri-PV / AgriSolar Augmented Reality Application  
**Document Basis:** Problem Statement 02, project architecture, concept presentation, and stated feature requirements

---

# 1. Product Definition

## 1.1 Product Name

**Agri-PV Navigator: Visualise, Assess & Design**

## 1.2 Product Summary

Agri-PV Navigator is a farmer-centric mobile decision-support application that helps assess the feasibility of installing **Agrivoltaic (Agri-PV) systems on agricultural land**.

The application accepts basic information about:

- Location
- Land area / field boundary
- Crop
- Farming conditions

and allows the farmer to configure an Agri-PV system and receive a **preliminary, site-specific Agri-PV proposal**.

The product is designed to help the farmer understand how solar panels could coexist with agricultural activities **before installation and before making an investment decision**.

The central product flow is:

> **Visualise → Assess → Design → Compare → Decide**

---

# 2. Problem Statement

## 2.1 Challenge

Farmers considering Agri-PV need to understand whether a solar installation can coexist with agricultural activities on their land.

Before investing, they need visibility into questions such as:

- Is the site suitable for Agri-PV?
- How will the proposed panels fit on the land?
- How much cultivation area will remain available?
- What panel arrangement, spacing, orientation, mounting structure, and coverage could be used?
- How much solar energy could be generated?
- How will different configurations affect agricultural usability?
- What could the project approximately cost?
- What potential benefits could result from the proposed system?
- What will the proposed installation actually look like on the farmer's land?

The application must therefore provide a way to **see, understand, configure, and compare** a proposed Agri-PV system before installation.

## 2.2 Core User Need

> **Help the farmer see, understand, and evaluate an Agri-PV project on their own agricultural land before it is installed.**

---

# 3. Product Objective

Create an intuitive decision-support tool that enables farmers to:

1. Assess the preliminary suitability of their site for Agri-PV.
2. Configure important Agri-PV system parameters.
3. Visualise the proposed installation on the actual site.
4. Compare different configurations.
5. Understand the implications for agriculture, land use, and solar generation.
6. Review a preliminary techno-economic assessment.
7. Make a more informed decision about whether and how to explore an Agri-PV installation further.

The application is a **decision-support prototype**, not a substitute for detailed engineering, agricultural, legal, structural, or investment-grade assessment.

---

# 4. Target User

## Primary User

### Farmer / Landholder

The primary user is a farmer evaluating whether an Agri-PV installation could work on agricultural land.

The product experience should prioritize:

- Simple inputs
- Clear language
- Visual understanding
- Site-specific information
- Configurable designs
- Direct comparison
- Practical agricultural considerations

## Secondary Users

The concept may also be useful to:

- Agricultural consultants
- Renewable-energy planners
- Researchers
- Policy makers
- Residents / community stakeholders

These secondary users are not required to drive the MVP unless explicitly added.

---

# 5. Source Requirements

The following requirements come directly from **Problem Statement 02**.

## 5.1 Minimum Application Capabilities

The application must, at minimum:

### A. Site Suitability

Assess site suitability for Agri-PV based on relevant:

- Agricultural parameters
- Solar parameters

### B. System Configuration

Allow configuration of key system parameters including:

- Panel arrangement
- Mounting structure
- Spacing
- Orientation
- Coverage

### C. Interactive Visualisation

Provide an interactive:

- 3D representation
- AR representation

of the proposed installation on the actual site, allowing users to view the structure from different perspectives.

### D. Configuration Comparison

Allow comparison of different configurations based on factors including:

- Available cultivation area
- Solar generation
- Agricultural usability

### E. Preliminary Techno-Economic Assessment

Provide preliminary estimates including:

- PV capacity
- Energy generation
- Project cost
- Potential benefits

## 5.2 Expected Deliverable

The expected deliverable is a:

> **Functional application prototype with a clear user interface, representative Agri-PV visualisation, site-specific assessment, configurable system design, and a concise project report explaining the methodology and assumptions.**

---

# 6. Product Scope

## 6.1 MVP / Prototype Scope

The prototype shall include:

- Farm/project creation
- Location input
- Land area and/or field boundary
- Crop selection
- Basic farming-condition input
- Site suitability assessment
- Configurable Agri-PV design
- Panel arrangement
- Mounting structure selection
- Spacing
- Orientation
- Coverage
- PV layout generation
- Agricultural usability checks
- Interactive 3D representation
- Representative AR representation
- Solar generation estimation
- Cultivation-area estimation
- Configuration comparison
- Preliminary project cost estimation
- Potential-benefit estimation
- PV capacity estimation
- Energy-generation estimation
- Concise project/methodology report

## 6.2 Proposed Enhancements

The following can extend the core prototype where implementation time permits:

- Detailed shadow simulation
- Time-of-day shadow slider
- Machinery-clearance validation
- CO₂ savings
- Payback
- NPV
- Land Equivalent Ratio (LER)
- More detailed crop-impact modelling
- Advanced GIS layers
- Multi-farm planning
- Advanced optimisation

These enhancements should not displace the mandatory requirements from the Problem Statement.

---

# 7. Core User Journey

```text
                    FARMER
                       │
                       ▼
              Enter Farm Details
                       │
                       ▼
              Assess Site Suitability
                       │
                       ▼
              Configure Agri-PV Design
                       │
                       ▼
              Generate Proposed Layout
                       │
                       ▼
              Visualise on Actual Site
                       │
                       ▼
            Compare Different Designs
                       │
                       ▼
          Review Technical & Economic
                   Assessment
                       │
                       ▼
               Generate Report
```

A simplified product flow is:

```text
1. Enter Farm
       ↓
2. Assess
       ↓
3. Design
       ↓
4. Visualise
       ↓
5. Compare
       ↓
6. Evaluate
```

---

# 8. Functional Requirements

# FR-01 — Farm and Location Input

The system shall allow the farmer to provide basic information about the agricultural site.

### Required Inputs

- Project/farm name
- Location
- Land area
- Field boundary where available
- Crop
- Basic farming conditions

### Location

The application should support location input through an appropriate mobile mechanism such as:

- GPS/location selection
- Map selection
- Manual location input

### Acceptance Criteria

- User can create a farm/project.
- User can identify the site.
- User can enter or define the land area.
- User can select the crop.
- User can provide the required basic farming conditions.

---

# FR-02 — Site Suitability Assessment

The system shall assess the preliminary suitability of the site for Agri-PV.

The assessment shall consider relevant:

### Solar Parameters

Potential parameters may include:

- Solar resource
- Solar exposure
- Site orientation
- Other relevant solar characteristics

### Agricultural Parameters

Potential parameters may include:

- Crop
- Farming conditions
- Crop/shading compatibility
- Land conditions

### Output

The application shall present:

- Overall preliminary suitability
- Factor-level information
- Reasons/explanations for important results

If a numerical score is used, the score must be explainable and its methodology must be documented.

Example:

```text
Preliminary Site Suitability
78 / 100

Solar Resource       Good
Crop Compatibility   Moderate
Land Conditions      Good
Water/Farming        Moderate

Key observations:
✓ Strong solar resource
✓ Suitable agricultural conditions
⚠ Crop response to shading requires consideration
```

The exact scoring formula is **TBD** and shall not be assumed to be scientifically authoritative until defined.

---

# FR-03 — Agri-PV System Configuration

The system shall allow the farmer to configure key Agri-PV parameters.

### Required Parameters

- Panel arrangement
- Mounting structure
- Spacing
- Orientation
- Coverage

### Additional Parameters

Where needed by the selected system:

- Panel type
- Panel dimensions
- Tilt
- Mounting height
- Row spacing
- Inter-panel spacing

The configuration interface must make the consequences of changes understandable to the user.

---

# FR-04 — PV Layout Generation

The system shall generate a representative Agri-PV layout from the selected configuration and site information.

The layout should consider:

- Field boundary
- Land area
- Panel dimensions
- Panel arrangement
- Orientation
- Spacing
- Coverage
- Mounting structure
- Agricultural constraints

### Output

The system should calculate or represent:

- Panel count
- Layout/row arrangement
- Occupied PV area
- Remaining cultivation area
- Coverage
- Layout warnings

---

# FR-05 — Agricultural Usability

The system shall account for the continued usability of the agricultural land.

The comparison and proposal should communicate:

- Available cultivation area
- PV-covered/occupied area
- Agricultural usability
- Relevant farming constraints

Where machinery clearance is supported, the system may additionally evaluate:

- Machinery width
- Required corridor
- Row spacing
- Turning/operation space

A failure should explain the reason rather than only returning an invalid status.

---

# FR-06 — Solar and External Data

The system may use external data sources to support site-specific calculations.

The current architecture identifies:

- Solar data
- PV generation data
- Elevation data
- Soil data
- Geographic/map data

Potential sources identified during architecture planning include:

- NASA POWER
- PVGIS
- Elevation datasets
- Soil datasets

The exact source selection and variable mapping remain **TBD**.

External data should be normalized before being consumed by the calculation engine.

---

# FR-07 — Solar Generation Estimation

The system shall estimate solar generation for a proposed configuration.

Relevant inputs may include:

- Site solar resource
- PV capacity
- Panel orientation
- Panel tilt where applicable
- System configuration
- System losses/assumptions

### Required Output

```text
Estimated PV Capacity
Estimated Annual Energy Generation
```

The output must clearly identify that it is an estimate and expose the major assumptions used.

---

# FR-08 — 3D Visualisation

The system shall provide a representative interactive 3D representation of the proposed Agri-PV installation.

### User Capabilities

The farmer should be able to:

- View the proposed installation from different perspectives.
- Inspect panel placement.
- See the relationship between panels and agricultural land.
- Change the design configuration.
- Observe the updated representation.

The 3D representation should correspond to the proposed system configuration.

---

# FR-09 — AR Visualisation

The system shall provide a representative AR representation of the proposed installation on the actual site as part of the prototype's visualisation capability.

The AR experience should allow the user to understand:

- Approximate placement
- Scale
- Spatial relationship with the agricultural land
- Structure from different perspectives

AR is a presentation/visualisation layer. Core engineering calculations must not depend on AR availability.

---

# FR-10 — Shadow Visualisation

Where included in the prototype, the system shall represent the movement of shadows generated by the proposed PV structure.

A possible interaction is:

```text
Morning ───────── Midday ───────── Evening
                 │
                 ▼
          Shadow position changes
```

If a time-of-day slider is implemented, the visualization should be driven by the same solar/shadow assumptions used by the calculation engine.

---

# FR-11 — Configuration Comparison

The system shall allow the farmer to compare different Agri-PV configurations.

The minimum comparison should include factors identified in the Problem Statement:

- Available cultivation area
- Solar generation
- Agricultural usability

The comparison may additionally include:

- PV coverage
- PV capacity
- Project cost
- Potential benefits
- Crop/shading indicators
- Payback
- NPV
- CO₂ savings
- LER

### Example

```text
                     Design A    Design B    Design C

PV Coverage             --          --          --
Cultivation Area        --          --          --
PV Capacity             --          --          --
Energy Generation       --          --          --
Agricultural Usability  --          --          --
Project Cost            --          --          --
Potential Benefits      --          --          --
```

The system should present the trade-offs between configurations rather than automatically declaring one configuration to be universally best.

---

# FR-12 — Preliminary Techno-Economic Assessment

The system shall provide a preliminary techno-economic assessment.

### Mandatory Outputs

- Estimated PV capacity
- Estimated energy generation
- Estimated project cost
- Potential benefits

### Potential Economic Outputs

Where sufficient assumptions are available:

- Annual electricity value/revenue
- Payback
- NPV
- O&M
- Lifetime
- Other relevant financial indicators

### Important Limitation

The results are **preliminary estimates** intended for decision support.

They are not:

- Investment-grade financial advice
- Guaranteed project returns
- A final EPC quotation
- A structural/electrical engineering approval

---

# FR-13 — Potential Benefits

The system shall communicate potential benefits associated with the proposed configuration.

Potential benefit categories may include:

### Agricultural

- Continued cultivation
- Available cultivation area
- Agricultural usability

### Energy

- Renewable energy generation
- Estimated PV capacity
- Annual energy generation

### Economic

- Potential electricity value/revenue
- Preliminary financial indicators
- Potential project benefits

### Environmental

Where supported:

- CO₂ savings
- Renewable-energy contribution
- Dual-use land benefits

The system must distinguish calculated outputs from assumptions.

---

# FR-14 — Project Report

The expected deliverable includes a concise project report explaining methodology and assumptions.

The application should also be able to generate/share a concise proposal report where practical.

### Report Content

1. Farm/site information
2. Crop information
3. Site suitability
4. Selected configuration
5. Layout summary
6. 3D/visualisation representation where supported
7. Cultivation area
8. PV capacity
9. Energy generation
10. Project cost
11. Potential benefits
12. Comparison of configurations
13. Methodology
14. Assumptions
15. Limitations

---

# 9. Calculation Architecture

The calculation engine is the technical core of the application.

The intended logical flow is:

```text
Farm / Field Data
       ↓
Site Assessment
       ↓
Design Configuration
       ↓
PV Layout
       ↓
Solar Data
       ↓
Sun / Solar Calculation
       ↓
Shadow / Agricultural Impact
       ↓
PV Generation
       ↓
Economic Assessment
       ↓
Scenario Comparison
       ↓
Proposal
```

The exact calculation models are **TBD** and must be documented in the methodology.

---

# 10. Proposed Technical Architecture

```text
                         FARMER
                            │
                            ▼
                  ┌────────────────────┐
                  │    Flutter App     │
                  │                    │
                  │ Farm Input         │
                  │ Design             │
                  │ 3D / AR            │
                  │ Comparison         │
                  │ Results            │
                  └─────────┬──────────┘
                            │
                       HTTPS / JSON
                            │
                            ▼
                  ┌────────────────────┐
                  │ Node.js + Express  │
                  │    API Gateway     │
                  │                    │
                  │ Authentication     │
                  │ Validation         │
                  │ Routing            │
                  │ Project Management │
                  │ Calculation Jobs   │
                  └─────────┬──────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
       ┌────────────┐ ┌─────────────┐ ┌──────────────┐
       │ PostgreSQL │ │ Python      │ │ External     │
       │ + PostGIS  │ │ Calculation │ │ Data APIs    │
       │            │ │ Engine      │ │              │
       └────────────┘ └──────┬──────┘ └──────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
                    ▼                   ▼
             Technical Models     Economic Models
                    │
                    ▼
              Calculated Results
                    │
             ┌──────┴──────┐
             ▼             ▼
        3D / AR         Report
       Visualisation    Generator
```

---

# 11. Technology Requirements

## Frontend

Preferred:

- Flutter (Dart)

Responsibilities:

- Farmer-facing interface
- Farm/field input
- Design controls
- Results
- Comparison
- 3D/AR interface

## Backend

Preferred:

- Node.js
- Express

Responsibilities:

- API
- Authentication
- Input validation
- Project management
- Calculation orchestration
- Result retrieval

## Calculation Engine

Preferred:

- Python

Responsibilities:

- Site assessment calculations
- PV layout calculations
- Solar calculations
- Shadow calculations
- Energy estimation
- Agricultural-impact calculations
- Economic calculations

## Database

Preferred:

- PostgreSQL
- PostGIS

Responsibilities:

- Users
- Farms
- Fields
- Geographic boundaries
- Designs
- Simulation inputs/results
- Project history

## 3D / AR

A suitable mobile-compatible 3D/AR technology shall be selected during technical design.

The technology choice must support the prototype's requirement to represent the proposed installation on the actual site.

---

# 12. Initial Data Model

The initial domain model should support:

```text
User
 │
 └── Farm / Project
      │
      └── Field
           │
           ├── Location
           ├── Boundary
           ├── Crop
           ├── Farming Conditions
           │
           ├── Site Assessment
           │
           └── Design
                │
                ├── Panel Configuration
                ├── Mounting Structure
                ├── Spacing
                ├── Orientation
                ├── Coverage
                │
                ├── Layout
                ├── Solar Results
                ├── Agricultural Results
                └── Economic Results
```

Detailed schema design will follow after the PRD and methodology are approved.

---

# 13. API Responsibilities

The Node.js API should expose application-level operations such as:

```text
/auth
/farms
/fields
/crops
/assessments
/designs
/layouts
/simulations
/comparisons
/reports
```

The API should:

- Authenticate users
- Validate inputs
- Store project information
- Trigger calculations
- Retrieve calculation results
- Return results to the mobile application
- Generate/request reports

The Python engine should remain responsible for domain calculations rather than general application CRUD.

---

# 14. Non-Functional Requirements

## NFR-01 — Usability

The application should be intuitive enough for a farmer to understand without requiring engineering knowledge.

## NFR-02 — Visual Clarity

The proposed installation should be understandable through visual representation rather than numbers alone.

## NFR-03 — Site Specificity

Where data is available, calculations and visualisations should reflect the user's actual site.

## NFR-04 — Consistency

The configuration shown in the UI, calculated by the engine, displayed in 3D/AR, and presented in the report should represent the same design.

## NFR-05 — Explainability

Important results should communicate:

- What was calculated
- What inputs were used
- What assumptions were made
- What limitations apply

## NFR-06 — Reliability

External-data failures must be visible and handled gracefully.

The application must not silently replace missing data with misleading values.

## NFR-07 — Security

- Authentication
- Authorization
- Input validation
- Protected project data
- Secure API communication

---

# 15. MVP Acceptance Criteria

The prototype satisfies the core Problem Statement when a user can complete the following flow:

### 1. Provide Site Information

The farmer can provide:

- Location
- Land area/field
- Crop
- Basic farming conditions

### 2. Assess Site

The application produces a preliminary site-specific Agri-PV suitability assessment using relevant solar and agricultural parameters.

### 3. Configure System

The farmer can configure:

- Panel arrangement
- Mounting structure
- Spacing
- Orientation
- Coverage

### 4. Visualise

The farmer can see a representative Agri-PV installation on the actual site through an interactive 3D/AR representation and view it from different perspectives.

### 5. Compare

The farmer can compare different configurations based at minimum on:

- Cultivation area
- Solar generation
- Agricultural usability

### 6. Evaluate Economics

The application provides a preliminary assessment including:

- PV capacity
- Energy generation
- Project cost
- Potential benefits

### 7. Explain Methodology

The project includes a concise report explaining:

- Methodology
- Assumptions
- Key limitations

---

# 16. Out of Scope / Not Guaranteed

The prototype shall not claim to provide:

- Final engineering approval
- Structural certification
- Electrical design certification
- Grid interconnection approval
- Guaranteed crop yield
- Guaranteed financial return
- Investment-grade financial advice
- Final EPC quotation
- Legal/regulatory approval
- Complete agricultural consultancy

The application provides a **preliminary decision-support assessment**.

---

# 17. Assumptions and Open Questions

The Problem Statement establishes the required capabilities but does not specify the exact scientific or financial methodology.

The following therefore remain to be defined.

## Site Assessment

- Which solar parameters?
- Which agricultural parameters?
- Which soil parameters?
- Which water/farming parameters?
- Will a 0–100 suitability score be used?
- If yes, what are the weights?

## Crop Assessment

- Which crops will the prototype support?
- How will agricultural usability be represented?
- Will crop shading be qualitative or quantitative?
- What crop data source will be used?

## PV Design

- Which panel types?
- Which mounting structures?
- Which arrangement types?
- What spacing limits?
- What orientation rules?
- What coverage limits?

## Solar Calculation

- Which solar-data source?
- Which PV-generation methodology?
- What temporal resolution?
- What system-loss assumptions?

## 3D / AR

- Which 3D technology?
- Which AR technology?
- How will the actual site be aligned with the virtual structure?
- What level of geographic accuracy is required?

## Economics

- Cost per kWp
- O&M
- Electricity value/tariff
- Project lifetime
- Discount rate
- Degradation
- Subsidies/incentives

## Optional Advanced Metrics

- LER methodology
- CO₂ methodology
- Crop-yield model
- Payback methodology
- NPV methodology

These must be documented before being presented as authoritative outputs.

---

# 18. Reference Concept

The Problem Statement identifies:

> **Sunbiose Agri-PV App / AgriSolar Augmented Reality Application for Farmers, Policy Makers and Residents**

as a reference.

This reference should be treated as conceptual inspiration for the problem space and user experience.

Agri-PV Navigator should define its own:

- User workflow
- Calculation methodology
- System architecture
- Visualisation approach
- Data sources
- Assumptions

The prototype should not claim equivalence with the reference application unless specific capabilities have been independently implemented and verified.

---

# 19. Development Priorities

The development should prioritize the requirements explicitly stated in the Problem Statement.

## Priority 1 — Required Core

```text
Farm Input
   ↓
Site Assessment
   ↓
System Configuration
   ↓
Site-Specific Proposal
```

## Priority 2 — Required Experience

```text
3D / AR Visualisation
   ↓
Configuration Comparison
```

## Priority 3 — Required Assessment

```text
PV Capacity
Energy Generation
Project Cost
Potential Benefits
```

## Priority 4 — Enhancements

```text
Detailed Shadows
Machinery Clearance
LER
CO₂
Payback
NPV
Advanced Crop Modelling
```

---

# 20. Final Product Definition

Agri-PV Navigator is a **farmer-centric mobile decision-support prototype** for evaluating Agri-PV systems on agricultural land.

The application takes:

```text
LOCATION
+
LAND
+
CROP
+
FARMING CONDITIONS
+
PV CONFIGURATION
```

and produces:

```text
SITE ASSESSMENT
+
AGRI-PV DESIGN
+
3D / AR VISUALISATION
+
CONFIGURATION COMPARISON
+
PRELIMINARY TECHNO-ECONOMIC ASSESSMENT
+
PROJECT REPORT
```

The intended experience is:

> **Don't just tell the farmer about Agri-PV. Let them see, understand, configure, and evaluate it on their farm before installation.**

The success of the prototype is therefore not defined by producing the most complex engineering model. It is defined by successfully connecting **site-specific assessment, configurable Agri-PV design, representative visualisation, comparison, and preliminary techno-economic evaluation** into one understandable farmer-facing workflow.
