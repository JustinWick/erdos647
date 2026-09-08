# Proposed title

Prove the fixed prime-mass/budget gap and supporting size bounds

## Summary

Implement the next endpoint comparison using the accepted parameter asymptotics,
corrected-budget upper estimate, and numerical logarithm gap. Preserve all existing
mathematical modules, audits, dependency pins, and the Mathlib-only public core.

For the actual protected H(X), y(X), lambda=primeMass(H,y), B=correctedBudget(H),
and L=log log X, the new targets are

$$
\lambda-B\ge\tfrac32 H\quad\text{eventually},\qquad
\lambda/(HL)\to1-a,\qquad 0\le\lambda\le HL,\quad B\le HL.
$$

The gap implementation also supplies every fixed delta<K, where
K=log(25/2)+1/log 2-2. No budget-positivity, cutoff-growth, prime-distribution, or
unproved gap premise remains in the fixed 3/2 declaration. The budget remains signed.

## Validation status

- Baseline: v40 passed 19/19 gates. Its existing proof and audit source is unchanged.
- New checks: `endpoint_prime_mass_gap` and `endpoint_mass_budget_bounds` are pending.
- Twelve new theorem targets receive expanded type checks and transitive axiom audits;
  the gap constant has an additional definition check.
- Local acceptance requires a warning-free **21/21** result for this changeset.

Do not relabel the old 19/19 result as acceptance of these new proofs.

## Scope

This is not the final endpoint theorem. The amplified principal, factorial-tail,
arithmetic, and exceptional-window contributions remain for the next changeset.
No endpoint coefficient c is claimed. The goal still preserves the critical exponent
and scale, with any explicit fixed positive c that the full argument comfortably gives.
