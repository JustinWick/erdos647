# Proposed PR: Add fixed-coefficient endpoint interface and parameter asymptotics

## Purpose

Start the mathematical branch after the accepted core/research fixes. Connect the
actual protected endpoint parameters to the finite sieve and Mertens interfaces,
retaining the constant log(25/2) needed by the critical budget-gap argument.

## Changes

Adds a fixed-coefficient endpoint statement interface and separate window,
truncation, cutoff and prime-mass parameter modules under
`Erdos647Research.Endpoint`. Their theorem namespace is `Erdos647Sieve.Endpoint`.
The existing 40 mathematical modules, exported finite API and previous audits are
unchanged. There is no toolchain migration or direct PNT+ import in endpoint code.

The final endpoint may use any explicit fixed c>0 at the preserved exponent and
scale. The old 1/1000 statement remains for reference, not as a completion barrier.
The source includes coefficient weakening and legacy equivalence adapters; neither
is an endpoint proof. No fixed coefficient is claimed by this changeset.

## Acceptance checklist

- [ ] All 19 registered gates pass on the PR source revision.
- [ ] New exact types match the protected parameter definitions.
- [ ] The new endpoint definition keeps c>0 fixed outside onset and X quantifiers.
- [ ] All 43 branch theorem axiom reports use only the existing permitted foundations.
- [ ] No warnings, admission-scan failures, blocked gates or mid-run source changes.
- [ ] Review verifies the variable-exponent calculation and retained constant.

The latest v39 run passed **17/19 gates**, covering 168 distinct declarations.
The window and truncation limits are newly accepted; the cutoff build failed at
three sites and the prime-mass gate was blocked. v40 repairs rational-limit
normalization, pointwise function division, and an under-applied cancellation
lemma in that one pending module. No existing mathematical statement changes.

The all-branch acceptance checklist is still outstanding. The completed v36
fixes changeset remains separate and is not reopened by this parameter proof work.
No endpoint bound or fixed positive output coefficient is claimed.

## Not included

The eventual lambda-minus-budget gap, normalized upper bounds, weighted-error
absorption, an actual positive-coefficient endpoint bound, explicit onset, and a resolution of Erdős #647
are not claimed by this PR. See the branch charter for the remaining sequence.

## Coefficient policy

Retain t=1/(1000 log(log X)) and all protected parameter definitions. The final
coefficient is any explicitly proved fixed c>0 at the same exponent and scale.
There is no obligation to attain 1/1000 or 1/2000. Derive the historical claim as
a corollary only if the established coefficient supports it at essentially no cost.
