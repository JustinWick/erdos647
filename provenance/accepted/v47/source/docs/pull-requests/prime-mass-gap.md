# PR title

Prove the prime-mass/budget gap and supporting size bounds

## Summary

Connect the accepted parameter asymptotics and corrected-budget estimate to a
fixed positive gap for the actual sieve parameters. Add two research modules and
their exact-type/transitive-axiom audits. Preserve the existing finite, PNT+,
Mertens, factorial, debit and parameter proof bodies, the public finite API, and
the pinned Lean/Mathlib 4.32.2 environment.

## Mathematical results

For H=windowLength(X), y=primeCutoff(X), lambda=primeMass(H,y),
B=correctedBudget(H), L=log(log X), and a=log 2/(1+log 2), prove

$$
\lambda-B\ge\frac32 H\quad\text{eventually},\qquad
\frac{\lambda}{HL}\longrightarrow 1-a,
$$

and the supporting eventual bounds

$$
0\le\lambda\le HL,\qquad B\le HL.
$$

The general gap theorem supplies every fixed delta<K, where
K=log(25/2)+1/log 2-2. Delta is fixed before X; the onset may depend on delta.
The fixed 3/2 theorem has no assumed distribution, cutoff-growth or budget gap.
The signed budget is neither truncated nor assumed nonnegative.

Do not infer an asymptotic equality for the budget: the proof uses its one-sided
upper estimate. The 3/2 gap margin is not the final endpoint coefficient c.

## Validation

- The newer v42 run passed **21/21** gates, with no failed or blocked checks.
- **195 distinct declarations** passed transitive-axiom checks using only
  `propext`, `Classical.choice`, and `Quot.sound`.
- **140 expanded type/definition checks** across 22 audit files, including
  13 checks for the two new modules and their 12 theorem targets.
- **Zero build/audit warnings or errors**; **203 runner tests passed**.
- All 51 recorded commands exited successfully; checked input hashes were stable,
  and both package caches were reused.
- Evidence: `provenance/accepted/v42/`, run `erdos647_repo_v42_results_20260908T111052Z_81bd3ce5`.

The earlier v42 diagnostic stopped on missing parameter source files. The newer
complete source snapshot supersedes that diagnostic for current acceptance.

## Evidence closeout

The v43 overlay records the passing evidence and updates documentation. It changes
no mathematical module, theorem statement, audit, runner, gate registry, toolchain
pin, lockfile or CI workflow. One status-regression test now accepts a recorded
successful gap checkpoint only when its evidence backs that status, instead of
requiring the gap to remain pending forever.

## Scope

The local acceptance condition for this PR is satisfied. Review of the actual PR
diff and repository CI remain normal separate requirements. This PR does not
prove the final asymptotic endpoint or claim a saving coefficient.

The next mathematical changeset bounds every amplified contribution and then
assembles `EndpointBound c` for an explicit fixed c>0 at the unchanged exponent
and scale. The old 1/1000 coefficient remains optional, not a completion condition.
