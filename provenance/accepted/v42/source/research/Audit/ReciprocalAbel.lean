import Erdos647Research.PrimeReciprocalSummation

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

#check Erdos647Sieve.Analytic.primeLogCoefficient_partial_sum
#print axioms Erdos647Sieve.Analytic.primeLogCoefficient_partial_sum

#check Erdos647Sieve.Analytic.reciprocalPrimeSum_eq_weighted_sum
#print axioms Erdos647Sieve.Analytic.reciprocalPrimeSum_eq_weighted_sum

#check Erdos647Sieve.Analytic.reciprocalPrimeSum_abel
#print axioms Erdos647Sieve.Analytic.reciprocalPrimeSum_abel

example : (∀ x : ℝ, 2 ≤ x → Erdos647Sieve.Analytic.reciprocalPrimeSum x = Chebyshev.theta x / (x * Real.log x) + (∫ t in (2 : ℝ)..x, Chebyshev.theta t * (1 + Real.log t) / (t ^ 2 * Real.log t ^ 2))) := Erdos647Sieve.Analytic.reciprocalPrimeSum_partial_summation
#check Erdos647Sieve.Analytic.reciprocalPrimeSum_partial_summation
#print axioms Erdos647Sieve.Analytic.reciprocalPrimeSum_partial_summation

example : (∀ x : ℝ, 2 ≤ x → Erdos647Sieve.Analytic.reciprocalPrimeSum x - Real.log (Real.log x) = (1 / Real.log 2 - Real.log (Real.log 2)) + (Chebyshev.theta x - x) / (x * Real.log x) - (∫ t in (2 : ℝ)..x, (Chebyshev.theta t - t) * deriv Erdos647Sieve.Analytic.reciprocalLog t)) := Erdos647Sieve.Analytic.reciprocalPrimeSum_error_identity
#check Erdos647Sieve.Analytic.reciprocalPrimeSum_error_identity
#print axioms Erdos647Sieve.Analytic.reciprocalPrimeSum_error_identity

