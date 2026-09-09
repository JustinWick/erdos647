/-
Project-facing adapters to the source-restricted PNT+ compatibility module.
The required source import closure and the theorem axioms are checked separately.
-/
import Erdos647Research.ReciprocalKernel
import Erdos647Research.Compat.PNTPlus

set_option autoImplicit false
open scoped Topology
open MeasureTheory Filter

noncomputable section
namespace Erdos647Sieve.Analytic

/-- Re-audit the PNT estimate actually consumed by this route. -/
theorem theta_pnt_bound :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ x : ℝ, 2 ≤ x →
      |Chebyshev.theta x - x| ≤ C * x / Real.log x ^ 2 :=
  RS_prime.pnt

/-- Integrable derivative-weighted error, upstream of the rejected identity chain. -/
theorem theta_error_deriv_integrable :
    IntegrableOn (fun t : ℝ => (Chebyshev.theta t - t) * deriv reciprocalLog t)
      (Set.Ioi 2) volume := by
  -- v26: rewrite the function argument under `deriv` explicitly.
  have hweight : reciprocalLog = (fun t : ℝ => 1 / t / Real.log t) := rfl
  rw [hweight]
  exact RS_prime.integrableOn_deriv_inv_div_log.1

/-- The boundary term tends to zero, not merely to an unknown bounded interval. -/
theorem theta_error_boundary_tendsto_zero :
    Tendsto (fun x : ℝ => (Chebyshev.theta x - x) / (x * Real.log x))
      atTop (nhds 0) := by
  obtain ⟨C, hC0, hC⟩ := theta_pnt_bound
  apply squeeze_zero_norm' (a := fun x : ℝ => C / Real.log x ^ 3)
  · filter_upwards [eventually_ge_atTop (2 : ℝ)] with x hx
    have hx0 : 0 < x := by linarith
    have hl0 : 0 < Real.log x := Real.log_pos (by linarith)
    calc
      ‖(Chebyshev.theta x - x) / (x * Real.log x)‖ =
          |Chebyshev.theta x - x| / (x * Real.log x) := by
            rw [Real.norm_eq_abs, abs_div, abs_of_pos (mul_pos hx0 hl0)]
      _ ≤ (C * x / Real.log x ^ 2) / (x * Real.log x) :=
        div_le_div_of_nonneg_right (hC x hx) (le_of_lt (mul_pos hx0 hl0))
      _ = C / Real.log x ^ 3 := by
        field_simp [hx0.ne', hl0.ne']
  · exact ((tendsto_pow_atTop (by norm_num : (3 : ℕ) ≠ 0)).comp
      Real.tendsto_log_atTop).const_div_atTop C

end Erdos647Sieve.Analytic
end
