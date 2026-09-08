# Repository check results

Run: `erdos647_repo_v39_results_20260908T085147Z_14bd13d1`
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
| endpoint_cutoff_parameters | FAIL |
| endpoint_prime_mass_parameters | BLOCKED |

## Gate details

- `endpoint_cutoff_parameters`: endpoint_cutoff_parameters_build: exit 1; see logs/044_endpoint_cutoff_parameters_build.log
- `endpoint_prime_mass_parameters`: Failed prerequisite: endpoint_cutoff_parameters

Historical proof acceptance is not a current run result.
A selected failure or blocked gate makes the overall command fail.
The asymptotic endpoint remains outside the completed theorem inventory.
