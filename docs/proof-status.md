# Proof status

## Accepted mathematical checkpoint: v47

The supplied run `erdos647_repo_v47_results_20260908T205250Z_0078dcb7` passed
**29/29 gates**, **235 distinct transitive-axiom audits**, **194 exact-type and
definition examples**, and **284 runner tests**, with no build/audit warnings.
Checked sources were stable. See [the preserved record](../provenance/accepted/v47/README.md).

The finite sieve, restricted PNT+/Mertens bridge, elementary estimates, exact
parameter asymptotics, positive mass–budget gap, amplified errors, and final
absorption are all covered by that checkpoint.

The final result is `EndpointBound c` for every fixed real c < 1499/10^6. The
meaningful saving range is **0 < c < 1499/10^6**. The explicit **1/1000**
specialization, `PositiveEndpointClaim`, and historical `EndpointClaim` passed.
The endpoint of the coefficient interval is not attained by this proof.
The onset is existential and can depend on c.

## Pending architectural checkpoint: v48

Seven accepted elementary implementations move to the Mathlib-only core with
old-path forwarders. New public research facades expose the accepted endpoint
and analytic bridge. The original proof statements/bodies and all 30 original
audits are retained. The core audit and a new facade gate exercise the new
layout. **The 30-gate layout is not recorded as accepted by the v47 result.**

This cleanup does not strengthen the theorem. Static historical acceptance in
documentation never substitutes for a current successful runner invocation.

## Limits

The theorem does not settle the existence question in #647 or prove finiteness.
No novelty determination, explicit numerical onset, or independent-kernel
implementation replay is claimed. The restricted 14-module PNT+ subtree is
not a certification of every declaration in upstream's excluded catalogues.
