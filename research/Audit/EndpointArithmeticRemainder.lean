import Erdos647Research.Endpoint.ArithmeticRemainder

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Real Erdos647Sieve Erdos647Sieve.Endpoint

example : ∀ (X : ℕ) (_ : 0 < X)
    (_ : 0 < windowLength X) (_ : 0 < truncationOrder X),
  Real.exp (amplificationExponent X) *
      ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X =
      Real.exp (Real.log (X : ℝ) / 4 +
        (truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) +
        amplificationExponent X) :=
  Erdos647Sieve.Endpoint.amplified_arithmetic_remainder_eq
#check Erdos647Sieve.Endpoint.amplified_arithmetic_remainder_eq
#print axioms Erdos647Sieve.Endpoint.amplified_arithmetic_remainder_eq

example : ∀ᶠ X : ℕ in atTop,
      (truncationOrder X : ℝ) * Real.log (windowLength X : ℝ) +
        (windowLength X : ℝ) / 500 ≤ Real.log (X : ℝ) / 4 :=
  Erdos647Sieve.Endpoint.eventually_arithmetic_overhead_le
#check Erdos647Sieve.Endpoint.eventually_arithmetic_overhead_le
#print axioms Erdos647Sieve.Endpoint.eventually_arithmetic_overhead_le

example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      Real.exp (amplificationExponent X) *
        ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X ≤
        Real.exp (Real.log (X : ℝ) / 2) :=
  Erdos647Sieve.Endpoint.eventually_amplified_arithmetic_remainder_le
#check Erdos647Sieve.Endpoint.eventually_amplified_arithmetic_remainder_le
#print axioms Erdos647Sieve.Endpoint.eventually_amplified_arithmetic_remainder_le

example : ∀ᶠ X : ℕ in atTop,
      (windowLength X : ℝ) ≤ Real.exp (Real.log (X : ℝ) / 2) :=
  Erdos647Sieve.Endpoint.eventually_exceptional_window_le
#check Erdos647Sieve.Endpoint.eventually_exceptional_window_le
#print axioms Erdos647Sieve.Endpoint.eventually_exceptional_window_le

-- No disappearance of the amplification multiplier behind a named expression.
example : ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
    Real.exp ((-Real.log (1 - momentT X)) * (correctedBudget (windowLength X) : ℝ)) *
      ((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X ≤
      Real.exp (Real.log (X : ℝ) / 2) := by
  simpa only [amplificationExponent, endpointEta] using
    eventually_amplified_arithmetic_remainder_le
