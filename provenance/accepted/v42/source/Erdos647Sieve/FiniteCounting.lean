/-
Unconditional finite counting, using the accepted budget transfer and the new
finite moment implementation. New source, not compiled in the assistant environment.
No claim of an asymptotic endpoint or a resolution of Erdős #647 is made.
-/
import Erdos647Sieve.FiniteMoment
import Erdos647Sieve.BudgetConsequences

set_option autoImplicit false

namespace Erdos647Sieve

theorem finiteCounting : FiniteCountingClaim :=
  finiteCounting_of_finiteMoment finiteMoment

end Erdos647Sieve
