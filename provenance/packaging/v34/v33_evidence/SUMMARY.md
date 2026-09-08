# Repository check results

Run: `erdos647_repo_v33_results_20260908T061726Z_5c0e7860`
Status: **FAIL_OR_BLOCKED**

| Gate | This invocation |
|---|---|
| core | PASS |
| reciprocal_kernel | FAIL |
| reciprocal_abel | BLOCKED |
| analytic_inputs | BLOCKED |
| clean_mertens | BLOCKED |
| selected_prime_reciprocals | BLOCKED |
| endpoint_log_bounds | FAIL |
| factorial_bounds | FAIL |
| factorial_estimate | BLOCKED |
| log_budget_factorial | BLOCKED |
| prime_reciprocal_lower | FAIL |
| small_prime_debit_estimate | BLOCKED |
| corrected_budget_estimate | BLOCKED |

## Gate details

- `reciprocal_kernel`: reciprocal_kernel_audit_0: exit 1; see logs/013_reciprocal_kernel_audit_0.log
- `reciprocal_abel`: Failed prerequisite: reciprocal_kernel
- `analytic_inputs`: Failed prerequisite: reciprocal_kernel
- `clean_mertens`: Failed prerequisite: reciprocal_abel, analytic_inputs
- `selected_prime_reciprocals`: Failed prerequisite: clean_mertens
- `endpoint_log_bounds`: endpoint_log_bounds_audit_0: exit 1; see logs/015_endpoint_log_bounds_audit_0.log
- `factorial_bounds`: factorial_bounds_audit_0: exit 1; see logs/017_factorial_bounds_audit_0.log
- `factorial_estimate`: Failed prerequisite: factorial_bounds
- `log_budget_factorial`: Failed prerequisite: factorial_estimate
- `prime_reciprocal_lower`: prime_reciprocal_lower_audit_0: exit 1; see logs/019_prime_reciprocal_lower_audit_0.log
- `small_prime_debit_estimate`: Failed prerequisite: prime_reciprocal_lower
- `corrected_budget_estimate`: Failed prerequisite: log_budget_factorial, small_prime_debit_estimate

Historical proof acceptance is not a current run result.
A selected failure or blocked gate makes the overall command fail.
The asymptotic endpoint remains outside the completed theorem inventory.
