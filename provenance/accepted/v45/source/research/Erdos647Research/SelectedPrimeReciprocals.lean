/-
New v15 source: connect the new analytic sum to the unchanged selectedPrimes and
primeMass. Cutoff convergence is a reusable implication, not the endpoint's
parameter analysis. No finite proof file is edited or replaced.
-/
import Erdos647Research.CleanMertens
import Erdos647Sieve.Specification

set_option autoImplicit false
open scoped BigOperators Topology
open Finset Filter

noncomputable section
namespace Erdos647Sieve.Analytic

theorem selectedPrimeSum_eq_difference (H : ℕ) (y : ℝ) (hy : (H : ℝ) ≤ y) :
    (∑ p ∈ selectedPrimes H y, (1 : ℝ) / (p : ℝ)) =
      reciprocalPrimeSum y - reciprocalPrimeSum (H : ℝ) := by
  classical
  have hH : H ≤ Nat.floor y := Nat.le_floor hy
  have hpartition :
      (Finset.Iic (Nat.floor y)).filter Nat.Prime =
        ((Finset.Iic H).filter Nat.Prime) ∪ selectedPrimes H y := by
    ext p
    simp only [selectedPrimes, Finset.mem_filter, Finset.mem_Iic,
      Finset.mem_union, Finset.mem_Icc]
    constructor
    · rintro ⟨hpy, hp⟩
      by_cases hpH : p ≤ H
      · exact Or.inl ⟨hpH, hp⟩
      · exact Or.inr ⟨⟨by omega, hpy⟩, hp⟩
    · rintro (⟨hpH, hp⟩ | ⟨⟨_hHp, hpy⟩, hp⟩)
      · exact ⟨hpH.trans hH, hp⟩
      · exact ⟨hpy, hp⟩
  have hdisjoint : Disjoint ((Finset.Iic H).filter Nat.Prime) (selectedPrimes H y) := by
    apply Finset.disjoint_left.mpr
    intro p hp hq
    have hpH : p ≤ H := Finset.mem_Iic.mp (Finset.mem_filter.mp hp).1
    have hHp : H + 1 ≤ p := (Finset.mem_Icc.mp
      (Finset.mem_filter.mp hq).1).1
    omega
  have hsplit : reciprocalPrimeSum y = reciprocalPrimeSum (H : ℝ) +
      ∑ p ∈ selectedPrimes H y, (1 : ℝ) / (p : ℝ) := by
    simp only [reciprocalPrimeSum, Nat.floor_natCast]
    rw [hpartition, Finset.sum_union hdisjoint]
  linarith

theorem primeMass_eq_reciprocal_difference (H : ℕ) (y : ℝ) (hy : (H : ℝ) ≤ y) :
    primeMass H y =
      (H : ℝ) * (reciprocalPrimeSum y - reciprocalPrimeSum (H : ℝ)) := by
  unfold primeMass
  rw [selectedPrimeSum_eq_difference H y hy]

/-- A vanishing error for the exact selected-prime sum at two diverging cutoffs. -/
theorem selectedPrimeSum_difference_tendsto_zero {ι : Type*} {l : Filter ι}
    (H : ι → ℕ) (y : ι → ℝ)
    (hH : Tendsto (fun i => (H i : ℝ)) l atTop) (hy : Tendsto y l atTop)
    (hle : ∀ᶠ i in l, (H i : ℝ) ≤ y i) :
    Tendsto (fun i =>
      (∑ p ∈ selectedPrimes (H i) (y i), (1 : ℝ) / (p : ℝ)) -
        (Real.log (Real.log (y i)) - Real.log (Real.log (H i : ℝ))))
      l (nhds 0) := by
  have h := reciprocalPrime_difference_tendsto_zero (fun i => (H i : ℝ)) y hH hy
  apply h.congr'
  filter_upwards [hle] with i hi
  rw [selectedPrimeSum_eq_difference (H i) (y i) hi]

end Erdos647Sieve.Analytic
end
