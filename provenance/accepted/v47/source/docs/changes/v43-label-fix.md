# v43 output-label correction

The v43 checkpoint overlay updated documentation, accepted evidence, and a status
regression test, but deliberately did not update `scripts/check.py`. That runner
still constructed every new run identifier with the hardcoded prefix
`erdos647_repo_v42_results_`. Consequently, a run after applying v43 could correctly
use the v43 repository contents and still produce a v42-labeled results archive.

This correction changes only that prefix to `erdos647_repo_v43_results_`. The same
run identifier already controls the output directory, ZIP filename, internal ZIP
root, JSON summary, Markdown summary, and latest-result pointer, so they now agree.

This is a label-only repair, not a mathematical changeset. No Lean file, audit,
gate definition, dependency pin, cache setting, CI workflow, or historical result
is replaced. Historical v42 evidence remains labeled v42. The old label alone does
not indicate stale proofs or a failed overlay, and does not invalidate a run.

The package is a supplemental v43 overlay, not a new endpoint-proof milestone.
The accepted gap-and-size checkpoint and its PR scope are unchanged. The next
mathematical obligation remains amplified-error bounds and endpoint assembly.
