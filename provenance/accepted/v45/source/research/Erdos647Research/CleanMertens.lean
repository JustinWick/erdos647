/-
New v15 source: a replacement reciprocal-prime limit using a newly proved Abel
identity and separately audited growth/integrability inputs. The old rejected
MertensProbe is preserved and is not imported. No endpoint is claimed here.
-/
import Erdos647Research.PrimeReciprocalSummation
import Erdos647Research.AnalyticInputs

set_option autoImplicit false
open scoped BigOperators Topology
open MeasureTheory Filter

noncomputable section
namespace Erdos647Sieve.Analytic

/-- A local constant defined independently of the rejected upstream Mertens identity. -/
def reciprocalPrimeConstant : ℝ :=
  mainPrimitive 2 -
    ∫ t in Set.Ioi (2 : ℝ), (Chebyshev.theta t - t) * deriv reciprocalLog t

/-- Mertens convergence via the clean summation route. No analytic hypothesis is a parameter. -/
theorem reciprocalPrimeSum_tendsto :
    Tendsto (fun x : ℝ => reciprocalPrimeSum x - Real.log (Real.log x))
      atTop (nhds reciprocalPrimeConstant) := by
  have hInt : Tendsto
      (fun x : ℝ => ∫ t in (2 : ℝ)..x,
        (Chebyshev.theta t - t) * deriv reciprocalLog t)
      atTop
      (nhds (∫ t in Set.Ioi (2 : ℝ),
        (Chebyshev.theta t - t) * deriv reciprocalLog t)) :=
    intervalIntegral_tendsto_integral_Ioi 2 theta_error_deriv_integrable tendsto_id
  have hConst : Tendsto (fun _ : ℝ => mainPrimitive 2) atTop
      (nhds (mainPrimitive 2)) := tendsto_const_nhds
  have h := (hConst.add theta_error_boundary_tendsto_zero).sub hInt
  have h' : Tendsto
      (fun x : ℝ => mainPrimitive 2 +
        (Chebyshev.theta x - x) / (x * Real.log x) -
        ∫ t in (2 : ℝ)..x, (Chebyshev.theta t - t) * deriv reciprocalLog t)
      atTop (nhds reciprocalPrimeConstant) := by
    simpa only [add_zero, reciprocalPrimeConstant] using h
  apply h'.congr'
  filter_upwards [eventually_ge_atTop (2 : ℝ)] with x hx
  exact (reciprocalPrimeSum_error_identity x hx).symm

/-- The bare existential limit, with the sum expanded in the statement. -/
theorem reciprocalPrimeLimit_exists :
    ∃ B : ℝ, Tendsto
      (fun x : ℝ =>
        (∑ p ∈ (Finset.Iic (Nat.floor x)).filter Nat.Prime, (1 : ℝ) / (p : ℝ)) -
          Real.log (Real.log x)) atTop (nhds B) := by
  exact ⟨reciprocalPrimeConstant, reciprocalPrimeSum_tendsto⟩

/-- Composing at two diverging cutoffs cancels the limit constant. -/
theorem reciprocalPrime_difference_tendsto_zero {ι : Type*} {l : Filter ι}
    (u v : ι → ℝ) (hu : Tendsto u l atTop) (hv : Tendsto v l atTop) :
    Tendsto
      (fun i => (reciprocalPrimeSum (v i) - reciprocalPrimeSum (u i)) -
        (Real.log (Real.log (v i)) - Real.log (Real.log (u i))))
      l (nhds 0) := by
  have h := (reciprocalPrimeSum_tendsto.comp hv).sub
    (reciprocalPrimeSum_tendsto.comp hu)
  have h' : Tendsto
      (fun i => (reciprocalPrimeSum (v i) - Real.log (Real.log (v i))) -
        (reciprocalPrimeSum (u i) - Real.log (Real.log (u i)))) l (nhds 0) := by
    simpa only [Function.comp_def, sub_self] using h
  apply h'.congr
  intro i
  ring

end Erdos647Sieve.Analytic
end
