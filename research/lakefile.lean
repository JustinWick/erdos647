import Lake
open Lake DSL

package «erdos647-research» where
  testDriver := "audit"
  reservoir := false

require «erdos647-sieve» from ".."
require PrimeNumberTheoremAnd from git
  "https://github.com/AlexKontorovich/PrimeNumberTheoremAnd.git" @ "a5154676af9aa3095150ee410cdda80555aa0642"

lean_lib PNTPlusCompat where
  moreLeanArgs := #["-DwarningAsError=true"]
  roots := #[`Erdos647Research.Compat.PNTPlus]

@[default_target]
lean_lib Erdos647Analytic where
  moreLeanArgs := #["-DwarningAsError=true"]
  roots := #[`Erdos647Research.ReciprocalKernel, `Erdos647Research.PrimeReciprocalSummation, `Erdos647Research.AnalyticInputs, `Erdos647Research.CleanMertens, `Erdos647Research.SelectedPrimeReciprocals]

@[default_target]
lean_lib Erdos647Elementary where
  moreLeanArgs := #["-DwarningAsError=true"]
  roots := #[`Erdos647Research.CorrectedBudgetEstimate, `Erdos647Research.EndpointLogBounds, `Erdos647Research.FactorialBounds, `Erdos647Research.FactorialEstimate, `Erdos647Research.LogBudgetFactorial, `Erdos647Research.PrimeReciprocalLower, `Erdos647Research.SmallPrimeDebitEstimate]

@[default_target]
lean_lib Erdos647Endpoint where
  moreLeanArgs := #["-DwarningAsError=true"]
  roots := #[`Erdos647Research.Endpoint.Statement,
    `Erdos647Research.Endpoint.WindowParameters,
    `Erdos647Research.Endpoint.TruncationParameters,
    `Erdos647Research.Endpoint.CutoffParameters,
    `Erdos647Research.Endpoint.PrimeMassParameters,
    `Erdos647Research.Endpoint.PrimeMassGap,
    `Erdos647Research.Endpoint.MassBudgetBounds,
    `Erdos647Research.Endpoint.Amplification,
    `Erdos647Research.Endpoint.MomentTail,
    `Erdos647Research.Endpoint.ErrorScales,
    `Erdos647Research.Endpoint.ArithmeticRemainder,
    `Erdos647Research.Endpoint.CountingReduction,
    `Erdos647Research.Endpoint.AbsorptionScales,
    `Erdos647Research.Endpoint.ErrorAbsorption,
    `Erdos647Research.Endpoint.Main]

/-- Public analytic/endpoint facades and facade-only usage examples. -/
@[default_target]
lean_lib Erdos647PublicResults where
  moreLeanArgs := #["-DwarningAsError=true"]
  roots := #[`Erdos647Research.Endpoint, `Erdos647Research.Analytic,
    `Erdos647Research.Examples.EndpointUsage]

/-- All registered checks for the separate analytic/endpoint package. -/
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
