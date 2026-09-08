/- Repository setup check: deserialize manifests with the pinned Lake implementation.
This program checks build configuration, not mathematical theorem correctness. -/
import Lake.Load.Manifest

open Lean Lake

def main (args : List String) : IO UInt32 := do
  if args.isEmpty then
    IO.eprintln "No manifest paths supplied"
    return 2
  for arg in args do
    let manifest ← Lake.Manifest.load (System.FilePath.mk arg)
    IO.println s!"MANIFEST_PARSED {arg}: {manifest.name} ({manifest.packages.size} dependencies)"
  return 0
