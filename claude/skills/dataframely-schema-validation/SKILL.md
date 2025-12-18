---
name: dataframely-schema-validation
description: Define and enforce schemas on Polars DataFrames with type safety, validation rules, and cross-table business logic.
---

# Dataframely Schema Validation

## What is Dataframely?

Dataframely is a Python library for defining and enforcing schemas on Polars DataFrames. It provides:
- **Schema Definition**: Declarative column constraints and validation rules
- **Type Safety**: Enforce column types with automatic casting
- **Custom Validation**: Define cross-column and cross-table business rules
- **Collection Support**: Validate relationships between multiple related DataFrames
- **Soft & Strict Modes**: Choose between raising exceptions or filtering invalid rows

## When to Use This Skill

Use dataframely when:
- You need to enforce data quality on DataFrame inputs or outputs
- Column constraints (nullable, min/max values, string lengths) should be enforced
- Business rules span multiple columns or tables
- You want type hints that integrate with the code editor
- Function signatures need to specify expected DataFrame schemas (per project standards)

## When NOT to Use This Skill

- The user explicitly requests not to use dataframely
- Working with Pandas DataFrames (dataframely only supports Polars)

## Key Questions to Ask Before Implementation

Before defining a schema, clarify the data model with the user:

1. **Unique Row Identifier**: What makes a row unique?
   - Primary key column(s)?
   - Composite keys?
   - No strict uniqueness requirement?

2. **Table Relationships**: How do tables relate in collections?
   - One-to-many relationships?
   - Foreign key constraints?
   - Business rule: "each X must have at least one Y"?

3. **Column Constraints**: For each column, what are the constraints?
   - Required vs. optional (nullable)?
   - Type and expected value ranges?
   - String length constraints?
   - Allowed enumerated values?

4. **Cross-Table Rules**: Are there validation rules spanning multiple tables?
   - "Date B must be after Date A"?
   - "Invoice must have exactly one primary diagnosis"?
   - Aggregate rules: "total amount must equal sum of line items"?

## Core Patterns

### Basic Schema Definition

```python
import dataframely as dy
import polars as pl

class PersonSchema(dy.Schema):
    name = dy.String(nullable=False, min_length=1)
    age = dy.UInt8(nullable=False)
    email = dy.String(nullable=True)
```

### Column-Level Constraints

```python
class HouseSchema(dy.Schema):
    # Required fields
    zip_code = dy.String(nullable=False, min_length=3)
    num_bedrooms = dy.UInt8(nullable=False, min_value=0)

    # Optional fields with constraints
    price = dy.Float32(nullable=True, min_value=0)

    # String enumeration
    state = dy.String(nullable=False)

    # Primary key
    house_id = dy.String(nullable=False)
```

### Custom Validation Rules

```python
class InvoiceSchema(dy.Schema):
    invoice_id = dy.String(nullable=False)
    amount = dy.Float64(nullable=False)
    admission_date = dy.Date(nullable=False)
    discharge_date = dy.Date(nullable=False)
    received_date = dy.Date(nullable=False)

    @dy.rule()
    def discharge_after_admission(cls) -> pl.Expr:
        """Discharge date must be after or equal to admission date."""
        return pl.col("discharge_date") >= pl.col("admission_date")

    @dy.rule()
    def received_after_discharge(cls) -> pl.Expr:
        """Invoice received date must be after discharge."""
        return pl.col("received_date") >= pl.col("discharge_date")

    @dy.rule()
    def positive_amount(cls) -> pl.Expr:
        """Invoice amount must be positive."""
        return pl.col("amount") > 0
```

### Validation Methods

```python
# Strict validation - raises exception on invalid data
try:
    validated_df = InvoiceSchema.validate(df, cast=True)
except dy.ValidationError as e:
    print(f"Validation failed: {e}")

# Soft validation - separates valid and invalid rows
valid_df, invalid_df = InvoiceSchema.filter(df)

# Type casting only (no validation checks)
casted_df = InvoiceSchema.cast(df)
```

### Multi-Table Collections

For validating relationships between multiple tables, use `dy.Collection` with `@dy.filter()` decorators:

```python
class InvoiceSchema(dy.Schema):
    invoice_id = dy.String(nullable=False)
    patient_id = dy.String(nullable=False)
    amount = dy.Float64(nullable=False)

class DiagnosisSchema(dy.Schema):
    diagnosis_id = dy.String(nullable=False)
    invoice_id = dy.String(nullable=False)
    diagnosis_code = dy.String(nullable=False)
    is_primary = dy.Boolean(nullable=False)

class HospitalClaimsCollection(dy.Collection):
    """Validates relationships between invoices and diagnoses tables."""

    invoices: dy.LazyFrame[InvoiceSchema]
    diagnoses: dy.LazyFrame[DiagnosisSchema]

    @dy.filter()
    def each_invoice_has_diagnosis(self) -> pl.LazyFrame:
        """Each invoice must have at least one diagnosis."""
        return self.invoices.join(
            self.diagnoses.select(pl.col("invoice_id").unique()),
            on="invoice_id",
            how="inner",
        )

    @dy.filter()
    def exactly_one_primary_per_invoice(self) -> pl.LazyFrame:
        """Each invoice must have exactly one primary diagnosis."""
        valid_invoices = (
            self.diagnoses
            .filter(pl.col("is_primary"))
            .group_by("invoice_id")
            .agg(pl.count().alias("primary_count"))
            .filter(pl.col("primary_count") == 1)
            .select("invoice_id")
        )
        return self.invoices.join(valid_invoices, on="invoice_id", how="inner")

# Validate collection
collection = HospitalClaimsCollection(
    invoices=pl.LazyFrame(invoices_df),
    diagnoses=pl.LazyFrame(diagnoses_df),
)
collection.validate()
```

**Key differences from Schema validation:**
- Use `dy.Collection` class (not `dy.Schema`)
- Define table members as `dy.LazyFrame[Schema]` attributes
- Use `@dy.filter()` decorator (not `@dy.rule()`)
- Filter methods return `pl.LazyFrame` with join logic to enforce constraints

### Function Type Hinting

Dataframely schemas & collections can be used as return types for functions. This improves their readability.

example:
```python
def process_claims(claims: HospitalClaimsCollection) -> HospitalClaimsCollection
    # some work happens in here that adheres to collection rules & filters
    ...
```

## Real-World Examples

See [examples.md](./examples.md) for detailed examples including:
- Hospital invoice validation with cross-column business rules
- Multi-table validation with relationships and aggregates
- Function signatures with dataframely type annotations

ALWAYS reference the examples file before writing or using any dataframely schemas.

## Best Practices

1. **Ask Questions First**: Always understand the data model and business rules before writing schema code
2. **Start Simple**: Define basic column types and constraints before adding complex cross-column rules
3. **Use Soft Validation**: Use `.filter()` for data cleaning; use `.validate()` only when strict enforcement is required
4. **Version Your Schemas**: If schema changes, consider backward compatibility
5. **Document Business Rules**: Add comments explaining the "why" behind validation rules
6. **Test Edge Cases**: Validate schemas with boundary values, nulls, and empty DataFrames
7. **Group Related Rules**: Use `group_by` for collection-level validation when validating multiple related rows

## References

- [Dataframely Documentation](https://dataframely.readthedocs.io/stable/)
- [Quickstart Guide](https://dataframely.readthedocs.io/stable/guides/quickstart.html)
- [Schema API Reference](https://dataframely.readthedocs.io/stable/api/schema/index.html)
- [Collection API Reference](https://dataframely.readthedocs.io/stable/api/collection/index.html)
- [Real-World Examples Guide](https://dataframely.readthedocs.io/stable/guides/examples/real-world.html)
- Project AGENTS.md: "Dataframes" section for DataFrame best practices
