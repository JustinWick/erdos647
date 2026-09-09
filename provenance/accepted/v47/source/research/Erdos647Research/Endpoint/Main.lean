/-
Final fixed-coefficient endpoint assembly from the accepted all-sign counting
reduction. The old 1/1000 constant is a free specialization of the strict range;
no parameter is retuned and no accepted proof is reopened.
-/
import Erdos647Research.Endpoint.CountingReduction
import Erdos647Research.Endpoint.ErrorAbsorption

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- Every fixed coefficient strictly below the established principal rate works.
For the requested saving theorem take any positive c in this interval. -/
theorem endpointBound_of_lt_principal_rate
    (c : ℝ) (hc : c < (1499 / 1000000 : ℝ)) : EndpointBound c := by
  apply (endpointBound_iff_eventually c).mpr
  filter_upwards [eventually_candidateCount_le_amplified_errors,
    eventually_amplifiedErrorMajorant_le_endpointRHSWith c hc] with X hcount habsorb
  have hmajorant : (candidateCount X : ℝ) ≤ amplifiedErrorMajorant X := hcount
  exact hmajorant.trans habsorb

/-- Explicit fixed coefficient. Its strict margin is rational arithmetic only. -/
theorem endpointBound_one_div_thousand : EndpointBound ((1 : ℝ) / 1000) :=
  endpointBound_of_lt_principal_rate ((1 : ℝ) / 1000) (by norm_num)

/-- The requested positive-coefficient theorem with an explicit constant witness. -/
theorem positiveEndpoint : PositiveEndpointClaim :=
  positiveEndpointClaim_of_explicit ((1 : ℝ) / 1000) (by norm_num)
    endpointBound_one_div_thousand

end Erdos647Sieve.Endpoint

namespace Erdos647Sieve

/-- Historical endpoint target, now obtained as a corollary at no new analytic cost. -/
theorem endpoint : EndpointClaim :=
  Endpoint.legacyEndpointClaim_iff.mpr Endpoint.endpointBound_one_div_thousand

end Erdos647Sieve
end
