##  PART 2: RELATIONSHIP ANALYSIS

We have analyzed all 20 tables in **REVENUE_ADMINISTRATION_DB** and established their relationships based on the defined primary keys, foreign keys, and business rules.

---

### 1. One‑to‑One Relationships

| Parent Table | Child Table | Explanation |
| :--- | :--- | :--- |
| **TAX_PAYMENT** | **TAX_REFUND** | Each refund is linked to exactly **one** payment. The `payment_id` in `TAX_REFUND` has a `UNIQUE` constraint, ensuring a one‑to‑one relationship. |
| **TAX_DECLARATION** | **TAX_ASSESSMENT** | Each declaration generates **one** assessment (though not enforced by a `UNIQUE` constraint, it is business‑wise one‑to‑one; we could add a unique constraint on `declaration_id` in `TAX_ASSESSMENT` if needed). For this analysis, we treat it as one‑to‑one. |

---

### 2. One‑to‑Many Relationships

| Parent Table | Child Table | Cardinality |
| :--- | :--- | :--- |
| **TAXPAYER** | TAX_REGISTRATION | One taxpayer can have multiple registrations |
| | TAX_AUDIT | One taxpayer can have multiple audits |
| | TAX_REFUND | One taxpayer can have multiple refunds |
| | TAX_OBJECTION | One taxpayer can have multiple objections |
| | ENFORCEMENT_CASE | One taxpayer can have multiple enforcement cases |
| | BUSINESS | One taxpayer can own multiple businesses |
| | PROPERTY | One taxpayer can own multiple properties |
| | VEHICLE | One taxpayer can own multiple vehicles |
| **TAX_CENTRE** | TAX_OFFICER | One centre can have multiple officers |
| | TAX_REGISTRATION | One centre can handle multiple registrations |
| | REVENUE_TARGET | One centre can have multiple revenue targets |
| **TAX_TYPE** | TAX_REGISTRATION | One tax type can have multiple registrations |
| | TAX_PERIOD | One tax type can have multiple periods |
| | AUDIT_FINDING | One tax type can have multiple findings |
| | REVENUE_TARGET | One tax type can have multiple targets |
| **TAX_OFFICER** | TAX_ASSESSMENT | One officer can process multiple assessments |
| | TAX_AUDIT | One officer can conduct multiple audits |
| | ENFORCEMENT_CASE | One officer can handle multiple enforcement cases |
| **TAX_REGISTRATION** | TAX_DECLARATION | One registration can have multiple declarations |
| **TAX_PERIOD** | TAX_DECLARATION | One period can have multiple declarations |
| **TAX_ASSESSMENT** | TAX_PAYMENT | One assessment can have multiple payments |
| | PENALTY | One assessment can have multiple penalties |
| | TAX_OBJECTION | One assessment can have multiple objections |
| **BANK** | TAX_PAYMENT | One bank can collect multiple payments |
| **TAX_AUDIT** | AUDIT_FINDING | One audit can have multiple findings |

---

### 3. Many‑to‑Many Relationships (and how they are resolved)

| Entity 1 | Entity 2 | Junction (Resolution) Table |
| :--- | :--- | :--- |
| **TAXPAYER** | **TAX_TYPE** | `TAX_REGISTRATION` (a taxpayer can register for multiple tax types, and a tax type can have many taxpayers) |
| **TAX_CENTRE** | **TAX_TYPE** | `REVENUE_TARGET` (each centre can have targets for multiple tax types, and each tax type can be targeted in multiple centres) |
| **TAXPAYER** | **TAX_OFFICER** | `TAX_AUDIT` (a taxpayer can be audited by multiple officers over time, and an officer can audit many taxpayers) |

> All these junction tables contain the foreign keys from both parent tables and may have additional attributes (e.g., `registration_date`, `target_amount`, `audit_start_date`).

---

### 4. Parent Tables (tables that are referenced by others but do not contain foreign keys)

The following tables have **no foreign keys** and serve as the root entities:

- **TAXPAYER**
- **TAX_CENTRE**
- **TAX_TYPE**
- **BANK**

---

### 5. Child Tables (tables that contain foreign keys)

All other tables are children of one or more of the above. They are:

- **TAX_OFFICER** (depends on TAX_CENTRE)
- **TAX_REGISTRATION** (depends on TAXPAYER, TAX_TYPE, TAX_CENTRE)
- **TAX_PERIOD** (depends on TAX_TYPE)
- **TAX_DECLARATION** (depends on TAX_REGISTRATION, TAX_PERIOD)
- **TAX_ASSESSMENT** (depends on TAX_DECLARATION, TAX_OFFICER)
- **TAX_PAYMENT** (depends on TAX_ASSESSMENT, BANK)
- **PENALTY** (depends on TAX_ASSESSMENT)
- **TAX_AUDIT** (depends on TAXPAYER, TAX_OFFICER)
- **AUDIT_FINDING** (depends on TAX_AUDIT, TAX_TYPE)
- **TAX_REFUND** (depends on TAXPAYER, TAX_PAYMENT)
- **TAX_OBJECTION** (depends on TAX_ASSESSMENT, TAXPAYER)
- **ENFORCEMENT_CASE** (depends on TAXPAYER, TAX_OFFICER)
- **BUSINESS** (depends on TAXPAYER)
- **PROPERTY** (depends on TAXPAYER)
- **VEHICLE** (depends on TAXPAYER)
- **REVENUE_TARGET** (depends on TAX_CENTRE, TAX_TYPE)

---

### 6. Mandatory Relationships

All foreign key columns are defined as **NOT NULL**. This means every child record **must** reference an existing parent record.  
Therefore, **all relationships are mandatory** – there is no optional participation.

---

### 7. Optional Relationships

Since all foreign keys are **NOT NULL**, there are **no optional relationships** in this design.  
However, from a business perspective, some associations can be considered “optional” in terms of data existence (e.g., a taxpayer may not have any refund, objection, or enforcement case). But the foreign key constraint itself does not allow a NULL parent reference.

---

### 8. Primary‑Key and Foreign‑Key Relationships Summary

| Table | Primary Key | Foreign Key(s) | References |
| :--- | :--- | :--- | :--- |
| TAXPAYER | `taxpayer_id` | – | – |
| TAX_CENTRE | `tax_centre_id` | – | – |
| TAX_TYPE | `tax_type_id` | – | – |
| BANK | `bank_id` | – | – |
| TAX_OFFICER | `officer_id` | `tax_centre_id` | TAX_CENTRE |
| TAX_REGISTRATION | `registration_id` | `taxpayer_id`, `tax_type_id`, `tax_centre_id` | TAXPAYER, TAX_TYPE, TAX_CENTRE |
| TAX_PERIOD | `tax_period_id` | `tax_type_id` | TAX_TYPE |
| TAX_DECLARATION | `declaration_id` | `registration_id`, `tax_period_id` | TAX_REGISTRATION, TAX_PERIOD |
| TAX_ASSESSMENT | `assessment_id` | `declaration_id`, `officer_id` | TAX_DECLARATION, TAX_OFFICER |
| TAX_PAYMENT | `payment_id` | `assessment_id`, `bank_id` | TAX_ASSESSMENT, BANK |
| PENALTY | `penalty_id` | `assessment_id` | TAX_ASSESSMENT |
| TAX_AUDIT | `audit_id` | `taxpayer_id`, `officer_id` | TAXPAYER, TAX_OFFICER |
| AUDIT_FINDING | `finding_id` | `audit_id`, `tax_type_id` | TAX_AUDIT, TAX_TYPE |
| TAX_REFUND | `refund_id` | `taxpayer_id`, `payment_id` | TAXPAYER, TAX_PAYMENT |
| TAX_OBJECTION | `objection_id` | `assessment_id`, `taxpayer_id` | TAX_ASSESSMENT, TAXPAYER |
| ENFORCEMENT_CASE | `enforcement_id` | `taxpayer_id`, `officer_id` | TAXPAYER, TAX_OFFICER |
| BUSINESS | `business_id` | `taxpayer_id` | TAXPAYER |
| PROPERTY | `property_id` | `taxpayer_id` | TAXPAYER |
| VEHICLE | `vehicle_id` | `taxpayer_id` | TAXPAYER |
| REVENUE_TARGET | `target_id` | `tax_centre_id`, `tax_type_id` | TAX_CENTRE, TAX_TYPE |

