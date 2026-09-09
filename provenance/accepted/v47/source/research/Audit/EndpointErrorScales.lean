import Erdos647Research.Endpoint.ErrorScales

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (X : ℕ) (_ : 2 ≤ X),
  Real.rpow (Real.log (X : ℝ)) endpointExponent *
      Real.rpow (Real.log (X : ℝ)) (1 - endpointExponent) = Real.log (X : ℝ) :=
  Erdos647Sieve.Endpoint.window_complementary_scale_product
#check Erdos647Sieve.Endpoint.window_complementary_scale_product
#print axioms Erdos647Sieve.Endpoint.window_complementary_scale_product

example : Tendsto (fun X : ℕ => (windowLength X : ℝ) * Real.log (Real.log (X : ℝ)) /
      Real.log (X : ℝ)) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.window_mul_logLog_div_logX_tendsto_zero
#check Erdos647Sieve.Endpoint.window_mul_logLog_div_logX_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.window_mul_logLog_div_logX_tendsto_zero

example : Tendsto (fun X : ℕ => (windowLength X : ℝ) / Real.log (X : ℝ))
      atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.window_div_logX_tendsto_zero
#check Erdos647Sieve.Endpoint.window_div_logX_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.window_div_logX_tendsto_zero

example : Tendsto (fun X : ℕ => (truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) /
      Real.log (X : ℝ)) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.truncation_log_window_div_logX_tendsto_zero
#check Erdos647Sieve.Endpoint.truncation_log_window_div_logX_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.truncation_log_window_div_logX_tendsto_zero

example : Tendsto (fun X : ℕ =>
      ((truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) +
        (windowLength X : ℝ) / 500) / Real.log (X : ℝ)) atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.arithmetic_overhead_div_logX_tendsto_zero
#check Erdos647Sieve.Endpoint.arithmetic_overhead_div_logX_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.arithmetic_overhead_div_logX_tendsto_zero

example : Tendsto (fun X : ℕ => Real.log (windowLength X : ℝ) / Real.log (X : ℝ))
      atTop (𝓝 0) :=
  Erdos647Sieve.Endpoint.log_window_div_logX_tendsto_zero
#check Erdos647Sieve.Endpoint.log_window_div_logX_tendsto_zero
#print axioms Erdos647Sieve.Endpoint.log_window_div_logX_tendsto_zero

example : ∀ (X : ℕ) (_ : 0 < X)
    (_ : 0 < truncationOrder X),
  primeCutoff X ^ truncationOrder X = Real.rpow (X : ℝ) ((1 : ℝ) / 4) :=
  Erdos647Sieve.Endpoint.primeCutoff_pow_truncation_eq
#check Erdos647Sieve.Endpoint.primeCutoff_pow_truncation_eq
#print axioms Erdos647Sieve.Endpoint.primeCutoff_pow_truncation_eq

