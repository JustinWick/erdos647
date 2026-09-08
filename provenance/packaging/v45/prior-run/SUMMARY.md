# Repository check results

Run: `erdos647_repo_v44_results_20260908T123705Z_9d028f71`
Status: **FAIL_OR_BLOCKED**

| Gate | This invocation |
|---|---|
| core | PASS |
| reciprocal_kernel | PASS |
| reciprocal_abel | PASS |
| pntplus_inputs | PASS |
| analytic_inputs | PASS |
| clean_mertens | PASS |
| selected_prime_reciprocals | PASS |
| endpoint_log_bounds | PASS |
| factorial_bounds | PASS |
| factorial_estimate | PASS |
| log_budget_factorial | PASS |
| prime_reciprocal_lower | PASS |
| small_prime_debit_estimate | PASS |
| corrected_budget_estimate | PASS |
| endpoint_statement | PASS |
| endpoint_window_parameters | PASS |
| endpoint_truncation_parameters | PASS |
| endpoint_cutoff_parameters | PASS |
| endpoint_prime_mass_parameters | PASS |
| endpoint_prime_mass_gap | PASS |
| endpoint_mass_budget_bounds | PASS |
| endpoint_amplification | FAIL |
| endpoint_moment_tail | BLOCKED |
| endpoint_error_scales | FAIL |
| endpoint_arithmetic_remainder | BLOCKED |
| endpoint_counting_reduction | BLOCKED |

## Gate details

- `endpoint_amplification`: endpoint_amplification_audit_0: exit 1; see logs/053_endpoint_amplification_audit_0.log
- `endpoint_moment_tail`: Failed prerequisite: endpoint_amplification
- `endpoint_error_scales`: endpoint_error_scales_audit_0: exit 1; see logs/055_endpoint_error_scales_audit_0.log
- `endpoint_arithmetic_remainder`: Failed prerequisite: endpoint_amplification, endpoint_error_scales
- `endpoint_counting_reduction`: Failed prerequisite: endpoint_moment_tail, endpoint_arithmetic_remainder

Historical proof acceptance is not a current run result.
A selected failure or blocked gate makes the overall command fail.
The asymptotic endpoint remains outside the completed theorem inventory.
