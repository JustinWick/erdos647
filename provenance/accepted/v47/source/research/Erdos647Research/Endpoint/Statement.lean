/-
Endpoint statements with a fixed, explicit coefficient.
The exponent and scale are unchanged. The historical EndpointClaim remains in
Specification; this interface does not require its coefficient to be attained.
-/
import Erdos647Sieve.Specification

set_option autoImplicit false
open scoped Topology
open Filter Real

noncomputable section
namespace Erdos647Sieve.Endpoint

/-- The required asymptotic saving scale. Its exponent is the protected exponent. -/
def endpointScale (X : ℕ) : ℝ :=
  Real.rpow (Real.log (X : ℝ)) endpointExponent / Real.log (Real.log (X : ℝ))

/-- A coefficient-parametrized bound; c is a real constant, not a function of X. -/
def endpointRHSWith (c : ℝ) (X : ℕ) : ℝ :=
  (X : ℝ) * Real.exp (-(c * endpointScale X))

/-- Eventual candidate-count bound at the explicit fixed coefficient c. -/
def EndpointBound (c : ℝ) : Prop :=
  ∃ X0 : ℕ, 3 ≤ X0 ∧
    ∀ X : ℕ, X0 ≤ X → (candidateCount X : ℝ) ≤ endpointRHSWith c X

/-- The branch goal: one fixed positive coefficient works for all sufficiently
large X. The coefficient is chosen outside both the onset and X quantifiers. -/
def PositiveEndpointClaim : Prop :=
  ∃ c : ℝ, 0 < c ∧ EndpointBound c

/-- Positivity of the required saving scale on the eventual domain. -/
theorem endpointScale_pos (X : ℕ) (hX : 3 ≤ X) : 0 < endpointScale X := by
  have hXR : 0 < (X : ℝ) := by exact_mod_cast (show 0 < X by omega)
  have hlog : 1 < Real.log (X : ℝ) := by
    apply Real.exp_lt_exp.mp
    rw [Real.exp_log hXR]
    exact Real.exp_one_lt_three.trans_le (by exact_mod_cast hX)
  exact div_pos (Real.rpow_pos_of_pos (lt_trans zero_lt_one hlog) _)
    (Real.log_pos hlog)

/-- Larger coefficients give stronger bounds; reducing a fixed coefficient
preserves the exponent and the asymptotic scale. -/
theorem endpointRHSWith_le_of_le (c d : ℝ) (hcd : c ≤ d) (X : ℕ) (hX : 3 ≤ X) :
    endpointRHSWith d X ≤ endpointRHSWith c X := by
  unfold endpointRHSWith
  apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg X)
  exact Real.exp_le_exp.mpr
    (neg_le_neg (mul_le_mul_of_nonneg_right hcd (endpointScale_pos X hX).le))

/-- Filter presentation for use in the eventual error-absorption argument. -/
theorem endpointBound_iff_eventually (c : ℝ) :
    EndpointBound c ↔
      ∀ᶠ X : ℕ in atTop, (candidateCount X : ℝ) ≤ endpointRHSWith c X := by
  constructor
  · rintro ⟨X0, _, h⟩
    exact eventually_atTop.mpr ⟨X0, h⟩
  · intro h
    obtain ⟨N, hN⟩ := eventually_atTop.mp h
    exact ⟨max 3 N, le_max_left _ _, fun X hX =>
      hN X ((le_max_right 3 N).trans hX)⟩

/-- A proved estimate at d entails the same-scale estimate at every c ≤ d.
This implication supplies no endpoint estimate unless its premise is proved. -/
theorem endpointBound_mono (c d : ℝ) (hcd : c ≤ d) (hd : EndpointBound d) :
    EndpointBound c := by
  rcases hd with ⟨X0, h0, h⟩
  exact ⟨X0, h0, fun X hX =>
    (h X hX).trans (endpointRHSWith_le_of_le c d hcd X (h0.trans hX))⟩

/-- The old numerical target is precisely the c=1/1000 specialization. -/
theorem endpointRHSWith_one_div_thousand (X : ℕ) :
    endpointRHSWith ((1 : ℝ) / 1000) X = endpointRHS X := by
  unfold endpointRHSWith endpointScale endpointRHS
  exact congrArg (fun r : ℝ => (X : ℝ) * Real.exp r) (by ring)

/-- Relates the preserved historical specification to the new interface without
asserting that either endpoint statement has been proved. -/
theorem legacyEndpointClaim_iff :
    EndpointClaim ↔ EndpointBound ((1 : ℝ) / 1000) := by
  unfold EndpointClaim EndpointBound
  simp only [endpointRHSWith_one_div_thousand]

/-- Once an explicit coefficient has a proof, it supplies the existential goal.
The coefficient's positivity alone is not a counting theorem. -/
theorem positiveEndpointClaim_of_explicit (c : ℝ) (hc : 0 < c) (h : EndpointBound c) :
    PositiveEndpointClaim :=
  ⟨c, hc, h⟩

end Erdos647Sieve.Endpoint
end
