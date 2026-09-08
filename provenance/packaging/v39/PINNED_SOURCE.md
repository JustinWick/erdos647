# Inspected library identity

Repository: leanprover-community/mathlib4
Revision: 905b95818eb32af7874a58b427f50c1711a5e96c
File: Mathlib/Analysis/SpecialFunctions/Pow/Real.lean
Git blob: 4fa7722f332deb748b54c7b0bda553bb1b979ad0

The pinned source defines real powers and the normalization identity:

```lean
@[simp]
theorem rpow_eq_pow (x y : ℝ) : rpow x y = x ^ y := rfl
```

v39 uses this existing identity before applying the library's logarithm rules.
It does not replace the protected real-power parameter definition or relax the
rewrite/checking settings.
