import Erdos647Sieve.ReciprocalKernel

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ x : ℝ, 1 < x → HasDerivAt Erdos647Sieve.Analytic.reciprocalLog (-Erdos647Sieve.Analytic.reciprocalKernel x) x) := Erdos647Sieve.Analytic.hasDerivAt_reciprocalLog
#check Erdos647Sieve.Analytic.hasDerivAt_reciprocalLog
#print axioms Erdos647Sieve.Analytic.hasDerivAt_reciprocalLog

example : (∀ b : ℝ, MeasureTheory.IntegrableOn (deriv Erdos647Sieve.Analytic.reciprocalLog) (Set.Icc 2 b) MeasureTheory.volume) := Erdos647Sieve.Analytic.deriv_reciprocalLog_integrableOn
#check Erdos647Sieve.Analytic.deriv_reciprocalLog_integrableOn
#print axioms Erdos647Sieve.Analytic.deriv_reciprocalLog_integrableOn

example : (∀ b : ℝ, 2 ≤ b → (∫ x in (2 : ℝ)..b, x * deriv Erdos647Sieve.Analytic.reciprocalLog x) = Erdos647Sieve.Analytic.mainPrimitive b - Erdos647Sieve.Analytic.mainPrimitive 2) := Erdos647Sieve.Analytic.mainPrimitive_integral
#check Erdos647Sieve.Analytic.mainPrimitive_integral
#print axioms Erdos647Sieve.Analytic.mainPrimitive_integral

