import Lake
open Lake DSL

package «erdos647-research» where
  testDriver := "audit"
  reservoir := false

require «erdos647-sieve» from ".."
require PrimeNumberTheoremAnd from git
  "https://github.com/AlexKontorovich/PrimeNumberTheoremAnd.git" @ "a5154676af9aa3095150ee410cdda80555aa0642"

lean_lib PNTPlusCompat where
  roots := #[`PrimeNumberTheoremAnd.RosserSchoenfeldPrime]

@[default_target]
lean_lib Erdos647Analytic where
  roots := #[`Erdos647Sieve.ReciprocalKernel, `Erdos647Sieve.PrimeReciprocalSummation, `Erdos647Sieve.AnalyticInputs, `Erdos647Sieve.CleanMertens, `Erdos647Sieve.SelectedPrimeReciprocals]

@[default_target]
lean_lib Erdos647Elementary where
  roots := #[`Erdos647Sieve.CorrectedBudgetEstimate, `Erdos647Sieve.EndpointLogBounds, `Erdos647Sieve.FactorialBounds, `Erdos647Sieve.FactorialEstimate, `Erdos647Sieve.LogBudgetFactorial, `Erdos647Sieve.PrimeReciprocalLower, `Erdos647Sieve.SmallPrimeDebitEstimate]

/-- All current research proof gates, including pending elementary estimates. -/
script audit (args) do
  let child ← IO.Process.spawn {
    cmd := "python3"
    args := #["../scripts/check.py", "research"] ++ args.toArray
    cwd := some (← getRootPackage).dir
    stdin := .null
    stdout := .inherit
    stderr := .inherit
  }
  return ← child.wait
