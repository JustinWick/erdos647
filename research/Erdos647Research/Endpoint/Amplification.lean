/-
Exponential amplification and the principal contribution at the actual endpoint
parameters. The sign condition on the integer budget is kept explicit.
-/
import Erdos647Research.Endpoint.MassBudgetBounds
import Erdos647Research.EndpointLogBounds

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- The logarithmic weight used by the finite counting theorem. -/
def endpointEta (X : ℕ) : ℝ := -Real.log (1 - momentT X)

/-- The growing numerator of the truncated exponential moment. -/
def endpointMu (X : ℕ) : ℝ :=
  momentT X * primeMass (windowLength X) (primeCutoff X)

/-- The full amplification exponent, with a signed integer budget. -/
def amplificationExponent (X : ℕ) : ℝ :=
  endpointEta X * (correctedBudget (windowLength X) : ℝ)

/-- The quadratic logarithm estimate and a convenient linear consequence. -/
theorem neg_log_weight_bounds (t : ℝ) (ht0 : 0 ≤ t) (ht : t ≤ 1 / 2) :
    0 ≤ -Real.log (1 - t) ∧
      -Real.log (1 - t) ≤ t + t ^ 2 ∧ -Real.log (1 - t) ≤ 2 * t := by
  have hq := Elementary.neg_log_one_sub_le_add_sq t ht0 ht
  have hs := mul_nonneg ht0 (show 0 ≤ 1 - t by linarith)
  refine ⟨?_, hq, ?_⟩
  · have hlog := Real.log_nonpos (by linarith : 0 ≤ 1 - t)
      (by linarith : 1 - t ≤ 1)
    linarith
  · nlinarith

/-- Real-variable amplification algebra. Nonnegativity of B is needed before
multiplying an upper estimate for the logarithmic weight by B. -/
theorem amplification_exponents_le (H L B lam : ℝ)
    (hL : 0 < L) (ht : 1 / (1000 * L) ≤ (1 : ℝ) / 2)
    (hB0 : 0 ≤ B) (hB : B ≤ H * L) (hgap : (3 / 2 : ℝ) * H ≤ lam - B) :
    (-Real.log (1 - 1 / (1000 * L))) * B ≤ H / 500 ∧
      (-Real.log (1 - 1 / (1000 * L))) * B - (1 / (1000 * L)) * lam ≤
        -(1499 / 1000000 : ℝ) * (H / L) := by
  let t : ℝ := 1 / (1000 * L)
  have ht0 : 0 ≤ t := le_of_lt (div_pos zero_lt_one (mul_pos (by norm_num) hL))
  have he := neg_log_weight_bounds t ht0 ht
  have htL : t * L = (1 : ℝ) / 1000 := by
    dsimp only [t]
    rw [← div_div, div_mul_cancel₀ _ hL.ne']
  constructor
  · calc
      (-Real.log (1 - t)) * B ≤ (2 * t) * B :=
        mul_le_mul_of_nonneg_right he.2.2 hB0
      _ ≤ (2 * t) * (H * L) :=
        mul_le_mul_of_nonneg_left hB (mul_nonneg (by norm_num) ht0)
      _ = 2 * H * (t * L) := by ring
      _ = H / 500 := by rw [htL]; ring
  · have hmain := mul_le_mul_of_nonneg_right he.2.1 hB0
    have hdebit := mul_le_mul_of_nonneg_left hgap ht0
    have hquad := mul_le_mul_of_nonneg_left hB (sq_nonneg t)
    calc
      (-Real.log (1 - t)) * B - t * lam ≤
          -t * ((3 / 2 : ℝ) * H) + t ^ 2 * (H * L) := by
        nlinarith [hmain, hdebit, hquad]
      _ = -(3 / 2 : ℝ) * (t * H) + (t * H) * (t * L) := by ring
      _ = -(1499 / 1000 : ℝ) * (t * H) := by rw [htL]; ring
      _ = -(1499 / 1000000 : ℝ) * (H / L) := by
        dsimp only [t]
        rw [← div_div]
        ring

/-- The exact numerator mu(X) is nonnegative and at most H/1000, eventually. -/
theorem eventually_endpointMu_bounds :
    ∀ᶠ X : ℕ in atTop,
      0 ≤ endpointMu X ∧ endpointMu X ≤ (windowLength X : ℝ) / 1000 := by
  filter_upwards [eventually_endpoint_mass_budget_bounds, eventually_momentT_bounds]
    with X hb ht
  have htL : momentT X * Real.log (Real.log (X : ℝ)) = (1 : ℝ) / 1000 := by
    unfold momentT
    rw [← div_div, div_mul_cancel₀ _ hb.2.1.ne']
  refine ⟨mul_nonneg ht.1.le hb.2.2.1, ?_⟩
  calc
    endpointMu X ≤ momentT X *
        ((windowLength X : ℝ) * Real.log (Real.log (X : ℝ))) :=
      mul_le_mul_of_nonneg_left hb.2.2.2.1 ht.1.le
    _ = (windowLength X : ℝ) * (momentT X * Real.log (Real.log (X : ℝ))) := by ring
    _ = (windowLength X : ℝ) / 1000 := by rw [htL]; ring

/-- Specialize the algebra to the actual signed budget and prime mass. -/
theorem eventually_amplification_exponents_le :
    ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      amplificationExponent X ≤ (windowLength X : ℝ) / 500 ∧
      amplificationExponent X - endpointMu X ≤
        -(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ))) := by
  filter_upwards [eventually_endpoint_mass_budget_bounds, eventually_momentT_bounds]
    with X hb ht
  intro hB
  have hBR : 0 ≤ (correctedBudget (windowLength X) : ℝ) := by exact_mod_cast hB
  exact amplification_exponents_le (windowLength X : ℝ)
    (Real.log (Real.log (X : ℝ))) (correctedBudget (windowLength X) : ℝ)
    (primeMass (windowLength X) (primeCutoff X)) hb.2.1 ht.2 hBR
    hb.2.2.2.2.1 hb.2.2.2.2.2

/-- The full multiplier is bounded, not omitted from the errors. -/
theorem eventually_amplification_le :
    ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      Real.exp (amplificationExponent X) ≤ Real.exp ((windowLength X : ℝ) / 500) := by
  filter_upwards [eventually_amplification_exponents_le] with X h hB
  exact Real.exp_le_exp.mpr (h hB).1

/-- The actual principal contribution, including interval length X. -/
theorem eventually_principal_contribution_le :
    ∀ᶠ X : ℕ in atTop, 0 ≤ correctedBudget (windowLength X) →
      (X : ℝ) * Real.exp (amplificationExponent X - endpointMu X) ≤
        (X : ℝ) * Real.exp (-(1499 / 1000000 : ℝ) *
          ((windowLength X : ℝ) / Real.log (Real.log (X : ℝ)))) := by
  filter_upwards [eventually_amplification_exponents_le] with X h hB
  exact mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (h hB).2) (Nat.cast_nonneg X)

end Erdos647Sieve.Endpoint
end
