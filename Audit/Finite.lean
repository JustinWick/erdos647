import Erdos647Sieve

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators

-- These are type checks, not assumed axioms. Expanded statements prevent a
-- successful check of an implication from being mistaken for its premises.
example (n : ℕ) : Erdos647Sieve.Candidate n ↔
    24 < n ∧ ∀ k : ℕ, 1 ≤ k → k < n →
      (n - k).divisors.card ≤ k + 2 := Iff.rfl

example : Erdos647Sieve.FiniteMomentClaim := Erdos647Sieve.finiteMoment
example : Erdos647Sieve.BudgetDebitClaim := Erdos647Sieve.budgetDebit
example : Erdos647Sieve.FiniteCountingClaim := Erdos647Sieve.finiteCounting

example : ∀ (A : ℤ) (X H : ℕ) (y z : ℝ) (J : ℕ),
    1 ≤ X → 1 ≤ H → (H : ℝ) < y → 0 < z → z < 1 → Even J →
    (∑ n ∈ Finset.Icc (A + 1) (A + (X : ℤ)),
      z ^ Erdos647Sieve.hitCount H y n) ≤
        Erdos647Sieve.momentBound X H y z J := Erdos647Sieve.finiteMoment

example : ∀ (n H : ℕ) (y : ℝ),
    1 ≤ H → (H : ℝ) < y → Erdos647Sieve.Prefix H n →
    (Erdos647Sieve.hitCount H y (n : ℤ) : ℤ) ≤
      Erdos647Sieve.correctedBudget H := Erdos647Sieve.budgetDebit

example : ∀ (X H : ℕ) (y z : ℝ) (J : ℕ),
    1 ≤ X → 1 ≤ H → (H : ℝ) < y → 0 < z → z < 1 → Even J →
    0 ≤ Erdos647Sieve.correctedBudget H →
    (Erdos647Sieve.candidateCount X : ℝ) ≤ (H : ℝ) +
      Real.exp ((-Real.log z) * (Erdos647Sieve.correctedBudget H : ℝ)) *
        Erdos647Sieve.momentBound X H y z J := Erdos647Sieve.finiteCounting

#print Erdos647Sieve.Candidate
#print Erdos647Sieve.Prefix
#print Erdos647Sieve.hitCount
#print Erdos647Sieve.correctedBudget
#print Erdos647Sieve.momentBound
#check Erdos647Sieve.finiteMoment
#print axioms Erdos647Sieve.finiteMoment
#check Erdos647Sieve.budgetDebit
#print axioms Erdos647Sieve.budgetDebit
#check Erdos647Sieve.finiteCounting
#print axioms Erdos647Sieve.finiteCounting
