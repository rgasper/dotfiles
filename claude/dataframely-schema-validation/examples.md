# Dataframely Examples Reference

## Example 1: Hospital Invoice Validation (Single Table)

```python
class HospitalInvoiceSchema(dy.Schema):
    """Schema for hospital invoice records with cross-column validation."""

    # Primary identifiers
    invoice_id = dy.String(nullable=False)
    patient_id = dy.String(nullable=False)

    # Dates with business logic constraints
    admission_date = dy.Date(nullable=False)
    discharge_date = dy.Date(nullable=False)
    invoice_date = dy.Date(nullable=False)

    # Financial data
    total_amount = dy.Float64(nullable=False)
    insurance_paid = dy.Float64(nullable=False, min_value=0)
    patient_responsibility = dy.Float64(nullable=False, min_value=0)

    # Status tracking
    status = dy.String(nullable=False)
    received_date = dy.Date(nullable=True)

    # Validation rules
    @dy.rule()
    def discharge_after_admission(cls) -> pl.Expr:
        """Discharge cannot be before admission."""
        return pl.col("discharge_date") >= pl.col("admission_date")

    @dy.rule()
    def invoice_after_discharge(cls) -> pl.Expr:
        """Invoice cannot be before discharge."""
        return pl.col("invoice_date") >= pl.col("discharge_date")

    @dy.rule()
    def received_after_invoice(cls) -> pl.Expr:
        """Received date must be after or on invoice date when present."""
        return (
            pl.col("received_date").is_null() |
            (pl.col("received_date") >= pl.col("invoice_date"))
        )

    @dy.rule()
    def positive_total_amount(cls) -> pl.Expr:
        """Total amount must be positive."""
        return pl.col("total_amount") > 0

    @dy.rule()
    def payment_breakdown_matches(cls) -> pl.Expr:
        """Insurance paid + patient responsibility should equal total."""
        return (
            (pl.col("insurance_paid") + pl.col("patient_responsibility"))
            == pl.col("total_amount")
        )

# Validate returns valid dataframes - will raise dataframely.exc.ValidationError if any schema rules are violated
invoices_df = pl.read_parquet("invoices.parquet")
valid_invoices, invalid_invoices = HospitalInvoiceSchema.filter(invoices_df)
print(f"Valid rows: {len(valid_invoices)}, Invalid rows: {len(invalid_invoices)}")
```

## Example 2: Multi-Table Validation with Collections

Use `dy.Collection` with `@dy.filter()` decorators to enforce cross-table business rules:

```python
class InvoiceSchema(dy.Schema):
    """Individual invoice records."""
    invoice_id = dy.String(nullable=False)
    patient_id = dy.String(nullable=False)
    amount = dy.Float64(nullable=False, min_value=0)

    @dy.rule()
    def some_rule_just_for_invoices(cls) -> pl.Expr:
        ...

class DiagnosisSchema(dy.Schema):
    """Individual diagnosis records."""
    diagnosis_id = dy.String(nullable=False)
    invoice_id = dy.String(nullable=False)
    diagnosis_code = dy.String(nullable=False, min_length=3)
    description = dy.String(nullable=True)
    is_primary = dy.Boolean(nullable=False)

    @dy.rule()
    def some_rule_just_for_diagnoses(cls) -> pl.Expr:
        ...

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

    @dy.filter()
    def valid_diagnosis_codes(self) -> pl.LazyFrame:
        """Diagnosis codes must follow ICD-10 format."""
        valid_diagnoses = self.diagnoses.filter(
            pl.col("diagnosis_code").str.contains(r"^[A-Z]\d{2}")
        ).select("invoice_id").unique()
        return self.invoices.join(valid_diagnoses, on="invoice_id", how="inner")

# Usage
invoices_df = pl.read_parquet("invoices.parquet")
diagnoses_df = pl.read_parquet("diagnoses.parquet")

# Create and validate collection
collection = HospitalClaimsCollection(
    invoices=pl.LazyFrame(invoices_df),
    diagnoses=pl.LazyFrame(diagnoses_df),
)

# Validate returns valid dataframes - will raise dataframely.exc.ValidationError if any rules are violated for either of the schemas, OR any filters of the collection are violated
validated = collection.validate()

print(f"Valid invoices: {len(validated.invoices.collect())}")
print(f"Valid diagnoses: {len(validated.diagnoses.collect())}")
```

**Key points:**
- Use `dy.Collection` (not `dy.Schema`) for multi-table validation
- Define member tables as `dy.LazyFrame[SchemaType]` attributes
- Use `@dy.filter()` decorators (not `@dy.rule()`) for cross-table constraints
- Filter methods return `pl.LazyFrame` with join logic to enforce business rules
- Filters remove invalid rows across all related tables

## Example 3: Function Signature with Dataframely Annotations

Per project standards, use dataframely schemas in function type hints:

```python
from dataframely import Schema
import polars as pl

def process_invoices(invoices: HospitalInvoiceSchema) -> pl.DataFrame:
    """
    Process hospital invoice data.

    Args:
        invoices: Invoice DataFrame matching HospitalInvoiceSchema

    Returns:
        Processed DataFrame with additional computed fields
    """
    # Invoices are already validated by schema
    invoices_df = invoices
    # ... processing logic
    return invoices_df.with_columns(
        pl.col("patient_responsibility").cast(pl.Float32)
    )
```
