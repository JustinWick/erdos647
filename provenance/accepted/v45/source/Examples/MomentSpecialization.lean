import Erdos647Sieve.Finite

open scoped BigOperators

namespace Erdos647Sieve.Examples

/-- A concrete choice of weights/window, still uniform in the translation and length. -/
theorem halfWeightedMoment (A : ℤ) (X : ℕ) (hX : 1 ≤ X) :
    (∑ n ∈ Finset.Icc (A + 1) (A + (X : ℤ)),
      (1 / 2 : ℝ) ^ Erdos647Sieve.hitCount 1 2 n) ≤
        Erdos647Sieve.momentBound X 1 2 (1 / 2) 0 := by
  exact Erdos647Sieve.finiteMoment A X 1 2 (1 / 2) 0 hX
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) ⟨0, rfl⟩

end Erdos647Sieve.Examples
