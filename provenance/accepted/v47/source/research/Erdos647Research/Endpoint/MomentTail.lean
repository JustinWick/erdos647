/-
Uniform factorial-tail bounds when the numerator and truncation order both grow.
The amplification multiplier is retained throughout.
-/
import Erdos647Research.Endpoint.Amplification
import Erdos647Research.FactorialBounds

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- A uniform ratio bound, not a fixed-numerator factorial limit. -/
theorem factorial_tail_le_geometric_exp (mu : ℝ) (q : ℕ)
    (hmu0 : 0 ≤ mu) (hq : 1 ≤ q) (hratio : mu ≤ (q : ℝ) / 20) :
    mu ^ q / (Nat.factorial q : ℝ) ≤ Real.exp ((1 - Real.log 20) * (q : ℝ)) := by
  have hqR : 0 < (q : ℝ) := by exact_mod_cast (show 0 < q by omega)
  have hbase : 0 < (q : ℝ) / Real.exp 1 := div_pos hqR (Real.exp_pos 1)
  have hratio' : mu / ((q : ℝ) / Real.exp 1) ≤ Real.exp 1 / 20 := by
    apply (div_le_iff₀ hbase).mpr
    calc
      mu ≤ (q : ℝ) / 20 := hratio
      _ = ((q : ℝ) * (Real.exp 1 / Real.exp 1)) / 20 := by
        rw [div_self (Real.exp_ne_zero 1), mul_one]
      _ = (Real.exp 1 / 20) * ((q : ℝ) / Real.exp 1) := by ring
  calc
    mu ^ q / (Nat.factorial q : ℝ) ≤ mu ^ q / ((q : ℝ) / Real.exp 1) ^ q :=
      div_le_div_of_nonneg_left (pow_nonneg hmu0 q) (pow_pos hbase q)
        (Elementary.factorial_pow_lower q)
    _ = (mu / ((q : ℝ) / Real.exp 1)) ^ q := (div_pow _ _ q).symm
    _ ≤ (Real.exp 1 / 20) ^ q :=
      pow_le_pow_left₀ (div_nonneg hmu0 hbase.le) hratio' q
    _ = Real.exp (Real.log ((Real.exp 1 / 20) ^ q)) :=
      (Real.exp_log (pow_pos (div_pos (Real.exp_pos 1) (by norm_num)) q)).symm
    _ = Real.exp ((1 - Real.log 20) * (q : ℝ)) := by
      rw [Real.log_pow, Real.log_div (Real.exp_ne_zero 1) (by norm_num : (20 : ℝ) ≠ 0),
        Real.log_exp]
      congr 1
      ring

/-- The accepted logarithm constant gives a comfortable exponential tail rate. -/
theorem amplified_factorial_tail_le (H A mu : ℝ) (q : ℕ)
    (hH : 0 ≤ H) (hA : A ≤ H / 500) (hmu0 : 0 ≤ mu)
    (hmu : mu ≤ H / 1000) (hq : 1 ≤ q) (horder : H / 50 ≤ (q : ℝ)) :
    Real.exp A * (mu ^ q / (Nat.factorial q : ℝ)) ≤ Real.exp (-H / 30) := by
  have hlog : 1 - Real.log 20 ≤ 0 := by
    linarith [Elementary.endpoint_tail_log_constant]
  have hratio : mu ≤ (q : ℝ) / 20 := by linarith
  have horder' := mul_le_mul_of_nonpos_left horder hlog
  have hconstant := mul_le_mul_of_nonneg_right Elementary.endpoint_tail_log_constant hH
  calc
    Real.exp A * (mu ^ q / (Nat.factorial q : ℝ)) ≤
        Real.exp A * Real.exp ((1 - Real.log 20) * (q : ℝ)) :=
      mul_le_mul_of_nonneg_left (factorial_tail_le_geometric_exp mu q hmu0 hq hratio)
        (Real.exp_pos A).le
    _ = Real.exp (A + (1 - Real.log 20) * (q : ℝ)) := (Real.exp_add _ _).symm
    _ ≤ Real.exp (-H / 30) := by
      apply Real.exp_le_exp.mpr
      nlinarith [horder', hconstant]

/-- Apply the uniform bound to mu(X) and q(X)=J(X)+1. -/
theorem eventually_amplified_moment_tail_le :
    ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      Real.exp (amplificationExponent X) *
        (endpointMu X ^ (truncationOrder X + 1) /
          (Nat.factorial (truncationOrder X + 1) : ℝ)) ≤
        Real.exp (-(windowLength X : ℝ) / 30) := by
  filter_upwards [eventually_amplification_exponents_le, eventually_endpointMu_bounds]
    with X hA hmu hB
  have horder : (windowLength X : ℝ) / 50 ≤ ((truncationOrder X + 1 : ℕ) : ℝ) := by
    push_cast
    linarith [(truncationOrder_bounds X).1]
  exact amplified_factorial_tail_le (windowLength X : ℝ) (amplificationExponent X)
    (endpointMu X) (truncationOrder X + 1) (Nat.cast_nonneg _) (hA hB).1
    hmu.1 hmu.2 (by omega) horder

/-- The entire tail contribution to the candidate count, with X restored. -/
theorem eventually_moment_tail_contribution_le :
    ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      (X : ℝ) * (Real.exp (amplificationExponent X) *
        (endpointMu X ^ (truncationOrder X + 1) /
          (Nat.factorial (truncationOrder X + 1) : ℝ))) ≤
        (X : ℝ) * Real.exp (-(windowLength X : ℝ) / 30) := by
  filter_upwards [eventually_amplified_moment_tail_le] with X h hB
  exact mul_le_mul_of_nonneg_left (h hB) (Nat.cast_nonneg X)

end Erdos647Sieve.Endpoint
end
