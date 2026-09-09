import Erdos647Research.Compat.PNTPlus

set_option autoImplicit false
set_option warningAsError true
open scoped Topology

#check MediumPNT
#print axioms MediumPNT
#check RS_prime.pntBigO
#print axioms RS_prime.pntBigO

example : (∃ C : ℝ, 0 ≤ C ∧ ∀ x : ℝ, 2 ≤ x →
    |Chebyshev.theta x - x| ≤ C * x / Real.log x ^ 2) := RS_prime.pnt
#check RS_prime.pnt
#print axioms RS_prime.pnt

#check RS_prime.intervalIntegrable_inv_log_pow
#print axioms RS_prime.intervalIntegrable_inv_log_pow
#check RS_prime.ioiIntegrable_inv_log_pow
#print axioms RS_prime.ioiIntegrable_inv_log_pow
#check RS_prime.bound_deriv
#print axioms RS_prime.bound_deriv
#check RS_prime.integrableOn_deriv
#print axioms RS_prime.integrableOn_deriv

example : (MeasureTheory.IntegrableOn
    (fun y : ℝ => (Chebyshev.theta y - y) * deriv (fun t : ℝ => 1 / t / Real.log t) y)
    (Set.Ioi 2) MeasureTheory.volume ∧
    ∀ x : ℝ, 2 ≤ x → IntervalIntegrable (fun t : ℝ => deriv
      (fun s : ℝ => 1 / s / Real.log s) t) MeasureTheory.volume 2 x) :=
  RS_prime.integrableOn_deriv_inv_div_log
#check RS_prime.integrableOn_deriv_inv_div_log
#print axioms RS_prime.integrableOn_deriv_inv_div_log
