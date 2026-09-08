# Source used for the cutoff repair

Mathlib remains pinned at `905b95818eb32af7874a58b427f50c1711a5e96c`.

The file `Mathlib/Algebra/Notation/Pi/Defs.lean` defines

```lean
lemma Pi.div_def (f g : ∀ i, G i) : f / g = fun i => f i / g i := rfl
```

The exact pinned file was read through the GitHub connector. Its Git blob is
`77be7fd2c8ebe0f0e1dce25043113ad5e2303fd7`. It supplies the explicit function
normalization needed at the second reported site.

The actual v39 compiler log prints the remaining explicit arguments of
`div_div_div_cancel_right₀` after its nonzero-denominator argument:
`∀ (a b : ℝ), a / scale / (b / scale) = a / b`.
The repair supplies both a and b, rather than changing that identity or its premise.

The rational limit equality is `(4 * (1/50))^-1 = 25/2`. The Lean repair uses
`convert!` and `norm_num` to align types and establish that equality; it does not
introduce a numeric axiom or alter the limiting coefficient.
