import Lake
open Lake DSL

package «erdos647-sieve» where
  version := v!"0.1.0"
  description := "Finite sieve and counting inequalities motivated by Erdos problem 647"
  testDriver := "audit"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "905b95818eb32af7874a58b427f50c1711a5e96c"

@[default_target]
lean_lib Erdos647Sieve where
  moreLeanArgs := #["-DwarningAsError=true"]
  globs := #[.one `Erdos647Sieve, .submodules `Erdos647Sieve]

lean_lib Examples where
  moreLeanArgs := #["-DwarningAsError=true"]
  roots := #[`Examples.BasicUsage, `Examples.MomentSpecialization, `Examples.ElementaryUsage]

/-- Check the public package, examples, exact theorem types, and transitive axioms. -/
script audit (args) do
  let child ← IO.Process.spawn {
    cmd := "python3"
    args := #["scripts/check.py", "core"] ++ args.toArray
    cwd := some (← getRootPackage).dir
    stdin := .null
    stdout := .inherit
    stderr := .inherit
  }
  return ← child.wait
