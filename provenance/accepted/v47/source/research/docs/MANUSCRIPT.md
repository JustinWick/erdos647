# A small-prime-corrected logarithmic-budget sieve for Erdős #647

**Version 2 — September 5, 2026 (America/New_York).**

**Status:** A complete proposed paper argument, reconstructed and extended in the same assistant session. It has not received an external independent mathematical review and has not been Lean-verified. Finite exact checks accompany the argument but do not establish its asymptotics. Novelty is unresolved. This note does not solve Erdős #647 or prove finiteness.

## 1. The proposed result and what changed

Let \(\tau(m)\) be the number of positive divisors of the positive integer \(m\), and let \(\omega(m)\) count its distinct prime factors. Write
\[
 C(X)=\#\{24<n\le X:\ \tau(n-k)\le k+2\text{ for all }1\le k<n\}.
\]
All logarithms below are natural unless a base is explicitly displayed.

Set
\[
 a=\frac{\log 2}{1+\log 2}=0.409383890850\ldots.
\]

**Proposed theorem.** For all sufficiently large integers \(X\),
\[
 \boxed{C(X)\le X\exp\left\{-\frac1{1000}
                  \frac{(\log X)^a}{\log\log X}\right\}.}
 \tag{T}
\]
The numerical coefficient is intentionally conservative, not optimized. No explicit onset \(X_0\) is asserted.

A stronger formulation bounds the number of length-\(H\) prefix survivors in any interval of \(X\) consecutive positive integers, uniformly in the interval's location, where
\(H=\lfloor(\log X)^a\rfloor\); see Section 8.

The original note established a proposed quarter-power estimate and an extension to every fixed exponent below \(a\). Reconstructing its finite moment proof revealed no invalid inference. The present extension makes three changes:

1. Debit the contribution that primes at most \(H\) must make in every interval of \(H\) consecutive integers.
2. Use a moment weight tending to one: \(z=1-1/(1000\log\log X)\), rather than a fixed weight.
3. Truncate at degree proportional to \(H\), rather than \(H\log\log X\).

Together these changes reach the critical exponent \(a\), with a reciprocal \(\log\log X\) factor in the saving. The result asymptotically strengthens every fixed-subcritical estimate in version 1, since for each fixed \(\alpha<a\),
\[
 \frac{(\log X)^a/\log\log X}
      {(\log X)^\alpha\log\log X}
 =\frac{(\log X)^{a-\alpha}}{(\log\log X)^2}\longrightarrow\infty.
\]

This is an extension of the argument, not a correction of a false original theorem.

## 2. A finite interval moment lemma

Let \(I=\{A+1,\ldots,A+X\}\), where \(A\) is an integer and \(X\ge1\) an integer. Let \(H\ge1\) be an integer, \(y>H\), \(0<z<1\), and let \(J\ge0\) be even. Define
\[
 \mathcal P=\{p\text{ prime}:H<p\le y\},\qquad t=1-z,
\]
\[
 T(n)=\#\left\{p\in\mathcal P:p\mid\prod_{k=1}^H(n-k)\right\},
 \quad \lambda=H\sum_{H<p\le y}\frac1p,
 \quad \mu=t\lambda.
\]
The polynomial is evaluated over the integers. In particular \(T(n)\) is a finite count even when the polynomial is zero. No value of \(\omega(0)\) or \(\tau(0)\) is used.

**Lemma 1.** Uniformly in \(A\),
\[
 \boxed{\sum_{n\in I}z^{T(n)}
 \le X\left(e^{-\mu}+\frac{\mu^{J+1}}{(J+1)!}\right)+(Hy)^J.}
 \tag{1}
\]

### Proof

For a nonnegative integer \(T\), even Taylor truncation gives
\[
 (1-t)^T\le\sum_{j=0}^{\min(J,T)}(-t)^j\binom Tj.
 \tag{2}
\]
If the expansion has not terminated, the derivative of odd order \(J+1\) is nonpositive on \([0,t]\), establishing the sign of the remainder. This is a polynomial inequality, not a stochastic assumption about the integers.

For \(S\subseteq\mathcal P\), put \(d_S=\prod_{p\in S}p\). Expanding (2) over subsets and summing over \(I\) gives
\[
 \sum_{n\in I}z^{T(n)}
 \le \sum_{|S|\le J}(-t)^{|S|}N_S,
 \quad N_S=\#\{n\in I:d_S\mid\prod_{k=1}^H(n-k)\}.
\]
Modulo a prime \(p>H\), the polynomial has the \(H\) distinct roots \(1,\ldots,H\). The Chinese remainder theorem therefore gives exactly \(H^{|S|}\) roots modulo \(d_S\), including the usual one residue modulo \(d_\varnothing=1\). Counting each root's progression over any interval of length \(X\),
\[
 N_S=\frac{XH^{|S|}}{d_S}+E_S,
 \qquad |E_S|\le H^{|S|}.
 \tag{3}
\]
The empty subset has zero error.

Every retained \(d_S\le y^J\), and different subsets have different products. Thus there are at most \(\lfloor y^J\rfloor\) such subsets. Since \(t^{|S|}H^{|S|}\le H^J\), the total absolute error is at most \((Hy)^J\). This remains valid for \(J=0\).

Let \(a_p=tH/p\in(0,1)\), and let \(e_j\) be their elementary symmetric sums, with \(e_j=0\) above the number of primes. The main term divided by \(X\) is
\(S_J=\sum_{j=0}^J(-1)^je_j\).
For \(f(s)=\prod_p(1-sa_p)\), every odd-order derivative is nonpositive and every even-order derivative nonnegative on \([0,1]\): each derivative is a sum of products of nonnegative factors with the indicated sign. Taylor bounds at orders \(J\) and \(J+1\) yield
\[
 \prod_p(1-a_p)\le S_J\le\prod_p(1-a_p)+e_{J+1}.
\]
Finally,
\[
 \prod_p(1-a_p)\le e^{-\mu},\qquad
 e_{J+1}\le\frac{\mu^{J+1}}{(J+1)!}.
\]
For the latter inequality, expand \((\sum_p a_p)^{J+1}\); every distinct-index product appears \((J+1)!\) times, and all other terms are nonnegative. This proves (1). No constants depend implicitly on \(H,J,A\), or \(y\). \(\square\)

## 3. The corrected deterministic budget

Define the integers
\[
 Q_H=\sum_{k=1}^H\left\lfloor\frac{\log(k+2)}{\log2}\right\rfloor,
 \quad D_H=\sum_{p\le H}\left\lfloor\frac Hp\right\rfloor,
 \quad B_H=Q_H-D_H.
 \tag{4}
\]

**Lemma 2.** If \(n>H\) and \(\tau(n-k)\le k+2\) for \(1\le k\le H\), then
\[
 T(n)\le B_H.
 \tag{5}
\]

### Proof

The inequality \(2^{\omega(m)}\le\tau(m)\) gives
\(\sum_{k=1}^H\omega(n-k)\le Q_H\).
For each prime \(p\le H\), every block of \(H\) consecutive integers contains at least \(\lfloor H/p\rfloor\) multiples of \(p\). Consequently these small primes contribute at least \(D_H\) to that sum.

Each prime \(p>H\) divides at most one member of the block, since it cannot divide a nonzero difference of magnitude below \(H\). Primes counted by \(T(n)\) therefore contribute exactly \(T(n)\) additional incidences, disjoint from the small-prime contribution. Primes larger than \(y\) contribute nonnegatively. Thus
\[
 D_H+T(n)\le\sum_{k=1}^H\omega(n-k)\le Q_H,
\]
which proves (5). \(\square\)

This proof does not multiply noncoprime divisor counts or transfer an incorrectly peeled cofactor budget. It counts distinct-prime incidences in the full positive values \(n-k\).

**Finite counting consequence.** If \(B_H<0\), there are no length-\(H\) prefix survivors above \(H\). Otherwise write \(\eta=-\log z>0\). For any interval \(I\) as in Lemma 1, the number of its prefix survivors with \(n>H\) is at most
\[
 e^{\eta B_H}\left[
 X\left(e^{-\mu}+\frac{\mu^{J+1}}{(J+1)!}\right)+(Hy)^J
 \right].
 \tag{6}
\]
Indeed \(T(n)\le B_H\) implies \(1\le z^{T(n)-B_H}\). The moment includes all \(n\in I\), so it majorizes the surviving subset's moment.

In particular,
\[
 C(X)\le H+e^{\eta B_H}\left[
 X\left(e^{-\mu}+\frac{\mu^{J+1}}{(J+1)!}\right)+(Hy)^J
 \right].
 \tag{7}
\]
The initial \(H\) accounts only for candidates below the window length.

## 4. A constant-controlled estimate for the small-prime debit

For every integer \(H\ge2\),
\[
 D_H\ge H(\log\log H-2).
 \tag{8}
\]
Here is an elementary proof, avoiding any numerical assumption about the Mertens constant.
The Euler product over \(p\le H\) includes the reciprocals of all positive integers at most \(H\), hence
\[
 \prod_{p\le H}(1-1/p)^{-1}\ge\sum_{m=1}^H\frac1m\ge\log H.
\]
Taking logarithms, and using
\[
 \sum_{p\le H}\sum_{r\ge2}\frac1{r p^r}
 \le\sum_{p\le H}\frac1{p(p-1)}
 \le\sum_{m=2}^\infty\frac1{m(m-1)}=1,
\]
we get \(\sum_{p\le H}1/p\ge\log\log H-1\). Since
\(D_H\ge H\sum_{p\le H}1/p-\pi(H)\) and \(\pi(H)\le H\), (8) follows.

The elementary integral estimate for the factorial gives
\[
 \log((H+2)!/2)=H\log H-H+O(\log H).
\]
For example, sandwich \(\sum_{j=1}^{N}\log j\) between the adjacent integrals of \(\log u\) to obtain \(N\log N-N+O(\log N)\), then take \(N=H+2\).
As \(Q_H\le\log((H+2)!/2)/\log2\), (8) implies
\[
 \frac{B_H}{H}\le
 \frac{\log H}{\log2}-\log\log H+2-\frac1{\log2}
 +O\left(\frac{\log H}{H}\right).
 \tag{9}
\]
For sufficiently large \(H\), \(B_H\ge0\): rounding the \(H\) logarithms loses at most \(H\), whereas \(D_H=O(H\log\log H)\) by Mertens' estimate. If \(B_H<0\) at any finite choice, the preceding zero-survivor case already applies.

## 5. Endpoint parameter choice and the decisive gap

Let
\[
 Q=\log X,\qquad L=\log\log X,\qquad
 H=\lfloor Q^a\rfloor,
\]
\[
 J=2\left\lceil\frac H{100}\right\rceil,\qquad
 y=X^{1/(4J)},\qquad
 t=\frac1{1000L},\qquad z=1-t.
 \tag{10}
\]
For large \(X\), these satisfy all finite-lemma hypotheses. In particular,
\(\log y\asymp Q^{1-a}\), whereas \(\log H\asymp L\), so \(y>H\).

We use the classical estimate
\[
 \sum_{p\le u}\frac1p=\log\log u+M+O(1/\log u).
 \tag{11}
\]
Since both \(H,y\) tend to infinity, its constants cancel in the difference:
\[
 \frac\lambda H=\log\log y-\log\log H+o(1).
\]
The choices in (10) give
\[
 \log H=aL+o(1),\qquad
 J/H\longrightarrow1/50,
\]
\[
 \log\log y=L-\log(4J)
 =(1-a)L+\log(25/2)+o(1).
 \tag{12}
\]
Consequently
\[
 \frac\lambda H=(1-a)L-\log\log H+\log(25/2)+o(1),
 \quad \frac\lambda{HL}\longrightarrow1-a<1.
 \tag{13}
\]
The critical identity \(a/\log2=1-a\), combined with (9) and (13), gives
\[
 \liminf_{X\to\infty}\frac{\lambda-B_H}{H}
 \ge\log(25/2)+\frac1{\log2}-2
 =1.968423685\ldots>\frac32.
 \tag{14}
\]
The exact checks certify an even larger margin, greater than \(19/10\), with rational bounds for the logarithms. Only \(3/2\) is used below.

**This cancellation is the new step:** both \(\lambda/H\) and the corrected budget contain \(-\log\log H\). Ignoring the mandatory small-prime contribution loses that cancellation. Without it, the same endpoint parameters would give a gap tending to negative infinity per shift.

In addition to (14), for sufficiently large \(X\),
\[
 0\le B_H\le HL,\qquad 0\le\lambda\le HL,\qquad 0<t\le1/2.
 \tag{15}
\]
The budget upper bound follows directly from (9) and \(a/\log2=1-a<1\).

## 6. All three weighted terms

The multiplier in (7) must be included in every error estimate.

### Principal term

For \(0\le t\le1/2\), the logarithm series yields
\[
 \eta=-\log(1-t)\le t+t^2.
\]
Indeed \(\sum_{r\ge2}t^r/r\le t^2/[2(1-t)]\le t^2\). Therefore (14) and (15) give
\[
 \eta B_H-t\lambda
 \le-t(\lambda-B_H)+t^2B_H
 \le-\frac{1499}{10^6}\frac HL.
 \tag{16}
\]
Thus the principal contribution is at most
\[
 X\exp\left(-\frac{1499}{10^6}\frac HL\right).
 \tag{17}
\]

### Truncation tail

Put \(q=J+1\). From (10) and (15),
\[
 \mu\le H/1000,\qquad q\ge H/50,
 \qquad\eta B_H\le2tB_H\le H/500.
\]
Using \(q!\ge(q/e)^q\),
\[
 e^{\eta B_H}\frac{\mu^q}{q!}
 \le\exp(H/500)(e/20)^q
 \le\exp\left[-\left(\frac{\log20-1}{50}-\frac1{500}\right)H\right]
 \le e^{-H/30}.
 \tag{18}
\]
The constant inequality is checked by rational logarithm bounds, not floating-point comparison. Since \(L\to\infty\), the \(Xe^{-H/30}\) tail is negligible relative to (17).

### Arithmetic-progression remainder

Exactly \(y^J=X^{1/4}\), so
\[
 e^{\eta B_H}(Hy)^J
 =X^{1/4}\exp(J\log H+\eta B_H)
 =X^{1/4+o(1)},
 \tag{19}
\]
because
\[
 J\log H+\eta B_H=O(HL)
 =O(Q^a\log Q)=o(Q),\qquad a<1.
\]
This term is negligible relative to (17), whose logarithm is \(Q-o(Q)\). The initial \(H\) is negligible too.

## 7. Conclusion

Combining (7), (17), (18), and (19),
\[
 C(X)\le H+
 X\exp\left(-\frac{1499}{10^6}\frac HL\right)
 +Xe^{-H/30}+X^{1/4+o(1)}.
 \tag{20}
\]
Since \(H/Q^a\to1\), the strict coefficient margin between \(1499/10^6\) and \(1/1000\) absorbs rounding, the sum of the terms, and the remaining eventual inequalities. This proves the proposed theorem (T).

The argument is unconditional in the usual mathematical sense: it assumes only proved classical results such as (11), not a prime-tuples conjecture or a project-level open axiom. That description of its dependencies does not substitute for independent review of the argument itself.

The result still has
\[
 \log\left[X\exp\{-Q^a/(1000L)\}\right]
 =Q-o(Q)\longrightarrow\infty.
\]
It is neither a proof of finiteness nor an exclusion of a last counterexample.

## 8. Uniform translated-interval consequence

Lemma 1 and its error term are independent of \(A\). All other estimates depend only on \(X,H,y,z,J\). Consequently, for all sufficiently large \(X\), uniformly over integers \(A\ge H\),
\[
 \#\{A<n\le A+X:\ \tau(n-k)\le k+2\ (1\le k\le H)\}
 \le X\exp\left\{-\frac1{1000}\frac{(\log X)^a}{\log\log X}\right\},
 \quad H=\lfloor(\log X)^a\rfloor.
 \tag{21}
\]
This statement concerns surviving a growing finite prefix, not satisfying every shift below \(n\). It also bounds genuine candidates in these intervals. For \(A\ge0\) with \(A<H\), handle the at most \(H\) exceptional small \(n\) as in (20); the same eventual coefficient still follows for genuine candidates.

This does not contradict possible arbitrarily deep finite-window near-misses. It bounds their frequency at a window length tied to the interval length, and its numerical upper bound still grows.

## 9. Source comparison and claim limits

The inspected Hughes consolidation states
\(C(X)\le X\exp\{-(\log\log X)^{2-o(1)}\}\), using an \(\Omega\)-budget and attributing the density proofs to companion manuscripts. The current `paper/main.tex` blob remains `c1a0570e10c6f3bd7b0549a138637c3023ed4cd2`. Its paper directory exposed the consolidation and an archive; neither companion manuscript was retrieved. This note's proposed theorem is asymptotically stronger than that stated estimate; no comparison against every unpublished or published result is established.

Tao–Teräväinen's introductory inequality \(\omega(m)\le\log\tau(m)/\log2\) is standard. Their Remark 1.2 explains a different, existence-direction obstruction at the small shifts of #647. Lau's Theorem 1.3 constructs infinitely many integers with \(\Omega(n-k)\le C\log k\), \(1<k<n\), for an unspecified constant. These statements do not themselves supply or refute the counting conclusion here.

The direct problem-page and forum opens returned HTTP 403. A search-index excerpt of the forum was retrieved and repeated Hughes's stated density bound; this is not a review of the complete current discussion. Exact-title and topic searches did not establish novelty. See `SOURCES.md` for the inspected scope and URLs.

## 10. Verification boundary

The original version's complete result JSON was reproduced exactly: 396 finite moment cases, 1,824 subset-specific CRT checks, and its other recorded checks.

The separately implemented version-2 script passed 2,340 finite moment cases, 5,526 translated CRT subset checks, 8,626 full-window budget-debit checks, 1,560 corrected counting checks, and additional pointwise, occupancy, transfer, and constant checks recorded in `v2_checks.json`. Weights include `1/1000`, `1/2`, `9/10`, and `999/1000`. Translations include an offset near `10^18`, but this is only a finite congruence check, not a frontier exclusion or factorization claim.

No external reviewer has checked this manuscript. The computations were run by the same assistant; they are not independent research replications. No Lean or lake executable was present, and no Lean proof, build, or axiom audit was performed. No explicit asymptotic onset has been calculated. No cloud/GPU work or public repository modification occurred.

The next gate is an adversarial review of (8)–(20) and a novelty check, not further coefficient optimization or a large formalization of an unreviewed result.
