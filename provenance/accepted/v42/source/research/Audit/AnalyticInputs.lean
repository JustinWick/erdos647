import Erdos647Research.AnalyticInputs

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

#check RS_prime.pnt
#print axioms RS_prime.pnt

#check RS_prime.integrableOn_deriv_inv_div_log
#print axioms RS_prime.integrableOn_deriv_inv_div_log

example : (∃ C : ℝ, 0 ≤ C ∧ ∀ x : ℝ, 2 ≤ x → |Chebyshev.theta x - x| ≤ C * x / Real.log x ^ 2) := Erdos647Sieve.Analytic.theta_pnt_bound
#check Erdos647Sieve.Analytic.theta_pnt_bound
#print axioms Erdos647Sieve.Analytic.theta_pnt_bound

example : (MeasureTheory.IntegrableOn (fun t : ℝ => (Chebyshev.theta t - t) * deriv Erdos647Sieve.Analytic.reciprocalLog t) (Set.Ioi 2) MeasureTheory.volume) := Erdos647Sieve.Analytic.theta_error_deriv_integrable
#check Erdos647Sieve.Analytic.theta_error_deriv_integrable
#print axioms Erdos647Sieve.Analytic.theta_error_deriv_integrable

example : (Filter.Tendsto (fun x : ℝ => (Chebyshev.theta x - x) / (x * Real.log x)) Filter.atTop (nhds 0)) := Erdos647Sieve.Analytic.theta_error_boundary_tendsto_zero
#check Erdos647Sieve.Analytic.theta_error_boundary_tendsto_zero
#print axioms Erdos647Sieve.Analytic.theta_error_boundary_tendsto_zero

