import Erdos647Research.Endpoint.PrimeMassGap

set_option autoImplicit false
set_option warningAsError true
open scoped Topology
open Filter Erdos647Sieve

-- Pin the new constant independently of its name; it is not an endpoint coefficient.
example : Erdos647Sieve.Endpoint.primeMassGapConstant =
    Real.log ((25 : ℝ) / 2) + 1 / Real.log 2 - 2 := rfl

example : (3 / 2 : ℝ) < Erdos647Sieve.Endpoint.primeMassGapConstant :=
  Erdos647Sieve.Endpoint.primeMassGapConstant_gt_three_halves
#check Erdos647Sieve.Endpoint.primeMassGapConstant_gt_three_halves
#print axioms Erdos647Sieve.Endpoint.primeMassGapConstant_gt_three_halves

example : Tendsto (fun X : ℕ =>
  primeMass (windowLength X) (primeCutoff X) / (windowLength X : ℝ) -
    (Real.log (windowLength X : ℝ) / Real.log 2 -
      Real.log (Real.log (windowLength X : ℝ)) + 2 - 1 / Real.log 2))
  atTop (𝓝 (Real.log ((25 : ℝ) / 2) + 1 / Real.log 2 - 2)) :=
  Erdos647Sieve.Endpoint.endpoint_primeMass_budgetMain_gap_tendsto
#check Erdos647Sieve.Endpoint.endpoint_primeMass_budgetMain_gap_tendsto
#print axioms Erdos647Sieve.Endpoint.endpoint_primeMass_budgetMain_gap_tendsto

example : ∀ δ : ℝ, δ < Real.log ((25 : ℝ) / 2) + 1 / Real.log 2 - 2 →
  ∀ᶠ X : ℕ in atTop,
    δ * (windowLength X : ℝ) ≤
      primeMass (windowLength X) (primeCutoff X) -
        (correctedBudget (windowLength X) : ℝ) :=
  Erdos647Sieve.Endpoint.eventually_primeMass_gap_of_lt
#check Erdos647Sieve.Endpoint.eventually_primeMass_gap_of_lt
#print axioms Erdos647Sieve.Endpoint.eventually_primeMass_gap_of_lt

example : ∀ᶠ X : ℕ in atTop,
  (3 / 2 : ℝ) * (windowLength X : ℝ) ≤
    primeMass (windowLength X) (primeCutoff X) -
      (correctedBudget (windowLength X) : ℝ) :=
  Erdos647Sieve.Endpoint.eventually_primeMass_sub_correctedBudget_ge
#check Erdos647Sieve.Endpoint.eventually_primeMass_sub_correctedBudget_ge
#print axioms Erdos647Sieve.Endpoint.eventually_primeMass_sub_correctedBudget_ge

example : ∀ᶠ X : ℕ in atTop,
  (correctedBudget (windowLength X) : ℝ) ≤
    primeMass (windowLength X) (primeCutoff X) :=
  Erdos647Sieve.Endpoint.eventually_correctedBudget_le_primeMass
#check Erdos647Sieve.Endpoint.eventually_correctedBudget_le_primeMass
#print axioms Erdos647Sieve.Endpoint.eventually_correctedBudget_le_primeMass

