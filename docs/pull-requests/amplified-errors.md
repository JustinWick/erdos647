# Proposed next PR title

Bound all amplified sieve errors and reduce endpoint counting

## Scope

This is the NEXT mathematical changeset after the locally accepted prime-mass/
budget-gap PR. It is not covered by that PR's 21/21 evidence.

Add bounds for the principal exponential contribution, the factorial tail with
its growing numerator, the full amplified arithmetic remainder, and the initial
exceptional window. Combine these with the accepted finite counting theorem,
explicitly splitting on the signed corrected budget.

The new target is, eventually,

$$
C(X)\le X\exp\!\left[-\frac{1499}{10^6}\frac{H}{\log\log X}\right]
+X\exp(-H/30)+2\exp(\log X/2).
$$

The actual protected parameter definitions, critical exponent, and saving scale
are unchanged. No final coefficient c or `PositiveEndpointClaim` is claimed by
this changeset; final same-scale absorption is the remaining step.

## Validation threshold

Five new gates require warning-free build/type/transitive-axiom acceptance, with
25 new theorem targets and 31 expanded statement/definition checks. The complete
suite is now 26 gates. Current status: new source implemented; new acceptance
pending. Do not substitute the older 21/21 record for these five new checks.

## Preservation

No edits to the 47 accepted mathematical modules, 22 accepted audit files,
existing gate definitions, compiler and dependency pins, core API, or CI files.
