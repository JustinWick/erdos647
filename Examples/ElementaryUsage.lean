import Erdos647Sieve.Elementary

set_option autoImplicit false
open scoped Topology

example : ∀ (H : ℕ) (_ : 2 ≤ H),
    (H : ℝ) * (Real.log (Real.log (H : ℝ)) - 2) ≤
      (Erdos647Sieve.smallPrimeDebit H : ℝ) :=
  Erdos647Sieve.Elementary.smallPrimeDebit_lower

example : ∀ (ε : ℝ) (_ : 0 < ε),
    ∀ᶠ H : ℕ in Filter.atTop,
      (Erdos647Sieve.correctedBudget H : ℝ) / (H : ℝ) ≤
        Real.log (H : ℝ) / Real.log 2 - Real.log (Real.log (H : ℝ)) +
          2 - 1 / Real.log 2 + ε :=
  Erdos647Sieve.Elementary.correctedBudget_upper_eventually
