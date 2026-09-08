/-
Analytic continuation after the accepted finite-counting checkpoint.
New source in v15: compilation and transitive axiom acceptance are pending.
Only Mathlib is imported here; no PNT+ summation identity is used.
-/
import Mathlib

set_option autoImplicit false
open scoped BigOperators Topology
open MeasureTheory Filter

noncomputable section
namespace Erdos647Sieve.Analytic

/-- The smooth weight used in Abel summation. -/
def reciprocalLog (x : ℝ) : ℝ := 1 / x / Real.log x

/-- Minus the derivative of the Abel weight on `(1, infinity)`. -/
def reciprocalKernel (x : ℝ) : ℝ :=
  (1 + Real.log x) / (x ^ 2 * Real.log x ^ 2)

/-- An antiderivative of `x * reciprocalLog'(x)` on `(1, infinity)`. -/
def mainPrimitive (x : ℝ) : ℝ :=
  1 / Real.log x - Real.log (Real.log x)

theorem reciprocalLog_eq_inv (x : ℝ) :
    reciprocalLog x = (x * Real.log x)⁻¹ := by
  rw [reciprocalLog, div_div, one_div]

theorem hasDerivAt_reciprocalLog (x : ℝ) (hx : 1 < x) :
    HasDerivAt reciprocalLog (-reciprocalKernel x) x := by
  have hx0 : x ≠ 0 := ne_of_gt (lt_trans zero_lt_one hx)
  have hl0 : Real.log x ≠ 0 := ne_of_gt (Real.log_pos hx)
  have hd := ((hasDerivAt_id x).mul (Real.hasDerivAt_log hx0)).inv
    (mul_ne_zero hx0 hl0)
  convert! hd using 1
  · funext u
    change reciprocalLog u = (u * Real.log u)⁻¹
    exact reciprocalLog_eq_inv u
  · dsimp [reciprocalKernel]
    field_simp [hx0, hl0]
    ring

theorem deriv_reciprocalLog {x : ℝ} (hx : 1 < x) :
    deriv reciprocalLog x = -reciprocalKernel x :=
  (hasDerivAt_reciprocalLog x hx).deriv

theorem reciprocalKernel_continuousOn (b : ℝ) :
    ContinuousOn reciprocalKernel (Set.Icc 2 b) := by
  intro x hx
  have hx0 : x ≠ 0 := by linarith [hx.1]
  have hl0 : Real.log x ≠ 0 := ne_of_gt (Real.log_pos (by linarith [hx.1]))
  have hden : x ^ 2 * Real.log x ^ 2 ≠ 0 :=
    mul_ne_zero (pow_ne_zero 2 hx0) (pow_ne_zero 2 hl0)
  exact (show ContinuousAt reciprocalKernel x by
    unfold reciprocalKernel
    fun_prop (disch := assumption)).continuousWithinAt

theorem deriv_reciprocalLog_continuousOn (b : ℝ) :
    ContinuousOn (deriv reciprocalLog) (Set.Icc 2 b) := by
  apply (reciprocalKernel_continuousOn b).neg.congr
  intro x hx
  exact deriv_reciprocalLog (by linarith [hx.1])

theorem deriv_reciprocalLog_integrableOn (b : ℝ) :
    IntegrableOn (deriv reciprocalLog) (Set.Icc 2 b) :=
  (deriv_reciprocalLog_continuousOn b).integrableOn_Icc

theorem hasDerivAt_mainPrimitive {x : ℝ} (hx : 1 < x) :
    HasDerivAt mainPrimitive (x * deriv reciprocalLog x) x := by
  have hx0 : x ≠ 0 := ne_of_gt (lt_trans zero_lt_one hx)
  have hl0 : Real.log x ≠ 0 := ne_of_gt (Real.log_pos hx)
  have hd := ((Real.hasDerivAt_log hx0).inv hl0).sub
    ((Real.hasDerivAt_log hl0).comp x (Real.hasDerivAt_log hx0))
  convert! hd using 1
  · funext u
    simp only [mainPrimitive, one_div, Pi.sub_apply, Pi.inv_apply, Function.comp_apply]
  · rw [deriv_reciprocalLog hx]
    dsimp [reciprocalKernel]
    field_simp [hx0, hl0]
    ring

theorem mainPrimitive_integral (b : ℝ) (hb : 2 ≤ b) :
    (∫ x in (2 : ℝ)..b, x * deriv reciprocalLog x) =
      mainPrimitive b - mainPrimitive 2 := by
  apply intervalIntegral.integral_eq_sub_of_hasDerivAt
  · intro x hx
    have hx2 : 2 ≤ x := (Set.uIcc_of_le hb ▸ hx).1
    exact hasDerivAt_mainPrimitive (by linarith)
  · apply ContinuousOn.intervalIntegrable_of_Icc hb
    exact continuousOn_id.mul (deriv_reciprocalLog_continuousOn b)

end Erdos647Sieve.Analytic
end
