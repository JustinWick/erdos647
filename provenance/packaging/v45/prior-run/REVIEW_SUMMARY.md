# v44 results review

**Result:** 21 gates passed, 2 failed, 3 were blocked. The complete previously
accepted baseline passed again. The new amplified-error branch is not yet ready
for its all-gates PR checkpoint.

## Failures

Both `Erdos647Research.Endpoint.Amplification` and
`Erdos647Research.Endpoint.ErrorScales` built successfully. Their exact-type audit
commands then exited 1 with ten unused hypothesis-name lint errors:
seven in `EndpointAmplification.lean` and three in `EndpointErrorScales.lean`.

The audit logs printed permitted axiom sets for six amplification declarations
and seven scale declarations, but the commands failed. These printed reports do
not turn the two gates into passes. The moment-tail, arithmetic-remainder, and
counting-reduction gates were blocked.

## v45 repair scope

Only unused binder names are changed to `_`, not their hypotheses. The same
pattern is fixed proactively in the blocked moment-tail and arithmetic-remainder
audits. In total the repair anonymizes 22 proof names in seven examples across
four audit files. All 31 error-layer expanded checks and all 25 theorem/axiom
targets are retained. No mathematical proof source changes.

The result label changes to v45; warning-as-error, the axiom allowlist, the full
26-gate registry, and the Lean/Mathlib 4.32.2 pins are unchanged.

## Evidence checked

The archive's 240 manifest entries and 145 source snapshot entries match their
hashes. Before/after snapshots are identical. The source matches the delivered
v44 tree, including the user's CI configuration. All 55 recorded command exit
codes agree with their logs; exactly two commands failed. The 21 passing gates
cover 195 distinct declarations, all with permitted transitive axioms and no
warning/error diagnostics. The uploaded runner log records 229 passing tests.

The original gap-and-size PR remains supported by its accepted checkpoint. Final
same-scale absorption and an explicit positive endpoint coefficient remain
outstanding; no endpoint coefficient is claimed by this run or repair.
