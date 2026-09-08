# Accepted v36 repository-wide local result

Source run: `erdos647_repo_v36_results_20260908T073909Z_c7bbf1b5`

**14/14 registered gates passed.** The final corrected-budget estimate now has a
successful expanded type and transitive-axiom audit. The record covers 140 distinct
declarations (142 audit occurrences), 81 checked-in type examples, 37 successful
commands and 144 passing tooling tests. All 29 build/audit logs are free of warning
and error diagnostics. These numbers describe the submitted local run.

## Contents

- `raw-results.zip`: exact uploaded archive, including its complete source snapshots
  and original `MANIFEST.json`; not a new run or a reconstructed success log.
- `summary.json`, `SUMMARY.md`, `logs/`: verbatim result records for easy review.
- `dependency_closure/pntplus.json`: recorded 14-module retained PNT+ source scan.
- `module_resolution/`: recorded compiled-module ownership checks.
- `REVIEW.json`: read-only consistency review of that evidence and the delivered code.
- `AUDITED_DECLARATIONS.json`: parsed permitted axiom sets indexed by declaration.
- `source-sha256.json`: all 98 recorded checked source/configuration hashes.
- `CHECKED_MATH_SOURCE_SHA256.json`: the 40 current mathematical/facade module hashes.

Original archive SHA-256:

```text
18af0f4a69ca469da3d7493fa1c3f4932feed53ccc9ba41b81fb1dd003829fbd
```

The review matched all 166 manifest entries and all 98 source snapshot hashes,
compared every requested axiom report with the checked-in audit registry, checked
all command return records and module-ownership reports, and matched the 14 distinct
Git dependency revisions. The only returned-source difference from the delivered
v36 package was the user's disabled automatic CI triggers; those settings are
preserved. No checked source changed during the run.

The PNT+ lexical scan was performed by the submitted local runner. This archive
records its result and imports/hashes; it does not embed all upstream source.
The separate Lean axiom reports cover the actual consumed PNT interfaces. Neither
check asserts completion of unimported catalogues such as `ZetaSummary`.

## Scope

This evidence satisfies the fixes PR's local build/type/axiom and warning criteria.
It is not a GitHub CI verdict, a review of a remotely fetched PR diff, independent
kernel replay, an endpoint proof or a novelty determination. The local record is
bound to source hashes; ordinary maintainer review remains separate.

v37 changes documentation and preserves these records. The mathematical, audit,
runner, test and dependency inputs are unchanged. Historical records stay outside
the default source/import graph and do not substitute for future selected audits.
