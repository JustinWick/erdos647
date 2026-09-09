/-
New v15 source: specialized reciprocal-prime partial summation from Mathlib Abel
summation, not from RS_prime.eq_413 or any of its downstream identities.
No analytic growth estimate is a hypothesis of these identities.
-/
import Erdos647Research.ReciprocalKernel
import Mathlib.NumberTheory.AbelSummation
import Mathlib.NumberTheory.Chebyshev

set_option autoImplicit false
open scoped BigOperators Topology
open Finset MeasureTheory

noncomputable section
namespace Erdos647Sieve.Analytic

/-- The exact prime reciprocal sum needed by the endpoint. -/
def reciprocalPrimeSum (x : ℝ) : ℝ :=
  ∑ p ∈ (Finset.Iic (Nat.floor x)).filter Nat.Prime, (1 : ℝ) / (p : ℝ)

/-- Logarithmic prime coefficients; zero at 0 and 1. -/
def primeLogCoefficient (n : ℕ) : ℝ :=
  if n.Prime then Real.log (n : ℝ) else 0

theorem primeLogCoefficient_partial_sum (x : ℝ) :
    (∑ n ∈ Finset.Icc 0 (Nat.floor x), primeLogCoefficient n) = Chebyshev.theta x := by
  rw [Chebyshev.theta_eq_sum_Icc, Finset.sum_filter]
  rfl

theorem reciprocalPrimeSum_eq_weighted_sum (x : ℝ) :
    reciprocalPrimeSum x =
      ∑ n ∈ Finset.Icc 0 (Nat.floor x), reciprocalLog (n : ℝ) * primeLogCoefficient n := by
  classical
  have hset : (Finset.Iic (Nat.floor x) : Finset ℕ) = Finset.Icc 0 (Nat.floor x) := by
    ext n
    simp
  rw [reciprocalPrimeSum, hset, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro n hn
  by_cases hp : n.Prime
  · have hn0 : (n : ℝ) ≠ 0 := by exact_mod_cast hp.ne_zero
    have hl0 : Real.log (n : ℝ) ≠ 0 :=
      ne_of_gt (Real.log_pos (by exact_mod_cast hp.one_lt))
    simp only [hp, if_true, primeLogCoefficient, reciprocalLog]
    field_simp [hn0, hl0]
  · simp [primeLogCoefficient, hp]

/-- Abel's exact identity, retaining the derivative form needed for splitting off theta-x. -/
theorem reciprocalPrimeSum_abel {x : ℝ} (hx : 2 ≤ x) :
    reciprocalPrimeSum x = reciprocalLog x * Chebyshev.theta x -
      ∫ t in (2 : ℝ)..x, deriv reciprocalLog t * Chebyshev.theta t := by
  have h := sum_mul_eq_sub_integral_mul₁ primeLogCoefficient
    (f := reciprocalLog) (by simp [primeLogCoefficient])
    (by simp [primeLogCoefficient]) x
    (fun t ht => (hasDerivAt_reciprocalLog t (by linarith [ht.1])).differentiableAt)
    (deriv_reciprocalLog_integrableOn x)
  rw [← reciprocalPrimeSum_eq_weighted_sum] at h
  simp_rw [primeLogCoefficient_partial_sum] at h
  rw [← intervalIntegral.integral_of_le hx] at h
  exact h

/-- The reciprocal-prime specialization of the previously rejected summation route. -/
theorem reciprocalPrimeSum_partial_summation (x : ℝ) (hx : 2 ≤ x) :
    reciprocalPrimeSum x = Chebyshev.theta x / (x * Real.log x) +
      ∫ t in (2 : ℝ)..x,
        Chebyshev.theta t * (1 + Real.log t) / (t ^ 2 * Real.log t ^ 2) := by
  rw [reciprocalPrimeSum_abel hx]
  have hboundary : reciprocalLog x * Chebyshev.theta x =
      Chebyshev.theta x / (x * Real.log x) := by
    simp only [reciprocalLog, div_eq_mul_inv]
    ring
  have hint : (∫ t in (2 : ℝ)..x, deriv reciprocalLog t * Chebyshev.theta t) =
      -(∫ t in (2 : ℝ)..x,
          Chebyshev.theta t * (1 + Real.log t) / (t ^ 2 * Real.log t ^ 2)) := by
    rw [← intervalIntegral.integral_neg]
    apply intervalIntegral.integral_congr
    intro t ht
    have ht2 : 2 ≤ t := (Set.uIcc_of_le hx ▸ ht).1
    change deriv reciprocalLog t * Chebyshev.theta t =
      -(Chebyshev.theta t * (1 + Real.log t) / (t ^ 2 * Real.log t ^ 2))
    rw [deriv_reciprocalLog (by linarith)]
    dsimp [reciprocalKernel]
    ring
  rw [hboundary, hint, sub_neg_eq_add]

/-- Separates the elementary main term from the PNT error; no PNT premise is used. -/
theorem reciprocalPrimeSum_error_identity (x : ℝ) (hx : 2 ≤ x) :
    reciprocalPrimeSum x - Real.log (Real.log x) =
      mainPrimitive 2 + (Chebyshev.theta x - x) / (x * Real.log x) -
        ∫ t in (2 : ℝ)..x, (Chebyshev.theta t - t) * deriv reciprocalLog t := by
  have hiT : IntervalIntegrable
      (fun t => deriv reciprocalLog t * Chebyshev.theta t) volume 2 x := by
    rw [intervalIntegrable_iff_integrableOn_Icc_of_le hx]
    have h := integrableOn_mul_sum_Icc primeLogCoefficient (a := (2 : ℝ))
      (m := 0) (by norm_num) (deriv_reciprocalLog_integrableOn x)
    simpa only [primeLogCoefficient_partial_sum] using h
  have hiId : IntervalIntegrable (fun t : ℝ => t * deriv reciprocalLog t) volume 2 x :=
    ContinuousOn.intervalIntegrable_of_Icc hx
      (continuousOn_id.mul (deriv_reciprocalLog_continuousOn x))
  have hsplit :
      (∫ t in (2 : ℝ)..x, (Chebyshev.theta t - t) * deriv reciprocalLog t) =
        (∫ t in (2 : ℝ)..x, deriv reciprocalLog t * Chebyshev.theta t) -
          (mainPrimitive x - mainPrimitive 2) := by
    calc
      _ = ∫ t in (2 : ℝ)..x,
          deriv reciprocalLog t * Chebyshev.theta t - t * deriv reciprocalLog t := by
            apply intervalIntegral.integral_congr
            intro t ht
            ring
      _ = _ := by rw [intervalIntegral.integral_sub hiT hiId, mainPrimitive_integral x hx]
  rw [reciprocalPrimeSum_abel hx, hsplit]
  have hx0 : x ≠ 0 := by linarith
  have hl0 : Real.log x ≠ 0 := ne_of_gt (Real.log_pos (by linarith))
  have hlog2 : Real.log (2 : ℝ) ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  dsimp [reciprocalLog, mainPrimitive]
  field_simp [hx0, hl0, hlog2]
  ring

end Erdos647Sieve.Analytic
end
