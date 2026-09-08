/-
Adapted from the work of the PrimeNumberTheoremAnd contributors.
Released under Apache 2.0 license as described in the file LICENSE.

Project-local extraction from PrimeNumberTheoremAnd commit
  a5154676af9aa3095150ee410cdda80555aa0642
  PrimeNumberTheoremAnd/IEANTN/RosserSchoenfeld/RosserSchoenfeldPrime.lean
  Git blob 0533123764856ac5bc38f95b18b56551747d380a.

Modified for Erdős647: retain only the seven proved PNT/integrability declarations
below, replace the broad IEANTN imports by MediumPNT, and omit blueprint metadata.
The finite library never imports this module. The original repository is not
claimed to be a completed catalogue of explicit zeta results.

All retained upstream module sources are checked by scripts/pntplus_closure.py.
The audit checks MediumPNT and every declaration below transitively.
-/
import Mathlib
import PrimeNumberTheoremAnd.MediumPNT

noncomputable section
namespace RS_prime

open scoped Topology
open Chebyshev Finset Nat Real MeasureTheory Filter Asymptotics

/-- The medium PNT implies the theta error bound required by the sieve. -/
theorem pntBigO : (θ - id) =O[atTop] fun (x : ℝ) ↦ x / log x ^ 2 := by
  obtain ⟨c, hc⟩ := MediumPNT
  have hl : (ψ - id) =O[atTop] fun (x : ℝ) ↦ x / log x ^ 2 := by
    have h_exp : (fun x : ℝ => exp (-c * (log x) ^ (1 / 10 : ℝ))) =O[atTop]
      (fun x : ℝ => (log x) ^ (-2 : ℝ)) := by
      -- This lemma is autoformalized by Aristotle in the upstream source.
      have h_exp : Tendsto (fun x : ℝ => exp (-c * (log x) ^ (1 / 10 : ℝ)) * (log x) ^ 2)
        atTop (𝓝 0) := by
        suffices h_y : Tendsto (fun y : ℝ => exp (-c * y) * y ^ 20) atTop (nhds 0) by
          have h_subst : Tendsto (fun x : ℝ => exp (-c * (log x) ^ (1 / 10 : ℝ)) *
          ((log x) ^ (1 / 10 : ℝ)) ^ 20) atTop (𝓝 0) :=
          h_y.comp (tendsto_rpow_atTop (by norm_num) |> Tendsto.comp <| tendsto_log_atTop)
          refine h_subst.congr' ?_
          filter_upwards [eventually_gt_atTop 1] with x hx
          rw [← rpow_natCast, ← rpow_mul (log_nonneg hx.le)]
          norm_num
        suffices h_z : Tendsto (fun z : ℝ => exp (-z) * (z / c) ^ 20) atTop (nhds 0) by
          convert h_z.comp (tendsto_id.const_mul_atTop hc.1) using 2
          norm_num [hc.1.ne']
        convert (tendsto_pow_mul_exp_neg_atTop_nhds_zero 20).div_const (c ^ 20) using 2 <;> ring
      rw [isBigO_iff]
      obtain ⟨M, hM⟩ := eventually_atTop.mp (h_exp.eventually (Metric.ball_mem_nhds _ zero_lt_one))
      norm_cast
      norm_num
      refine ⟨1, Max.max M 2, fun x hx => ?_⟩
      rw [← div_eq_mul_inv, le_div_iff₀ (sq_pos_of_pos <| log_pos <| by grind [le_max_right M 2])]
      have := abs_lt.mp (hM x <| le_trans (le_max_left M 2) hx)
      norm_num at *
      nlinarith
    refine hc.2.trans ?_
    convert! (isBigO_refl (fun x : ℝ => x) atTop).mul h_exp using 2
    simp [field]
  have : θ - id = (ψ - id) + (θ - ψ) := by ring
  refine this ▸ hl.add (isBigO_iff.2 ⟨432, ?_⟩)
  filter_upwards [Ioi_mem_atTop 1] with x hx
  simp only [Pi.sub_apply, norm_eq_abs, norm_div, norm_pow, sq_abs, mul_div]
  have nonnegx : 0 ≤ x := by grind
  calc
  _ ≤ 2 * √x * log x := by rw [← neg_sub, abs_neg]; exact abs_psi_sub_theta_le_sqrt_mul_log hx.le
  _ ≤ _ := by
    rw [le_div_iff₀ (sq_pos_of_pos (log_pos hx)), mul_assoc, ← pow_succ' _ 2]
    simp only [reduceAdd]
    have : log x ^ 3 ≤ 216 * x ^ (1 / 2 : ℝ) := by
      have := rpow_le_rpow (log_nonneg hx.le) (log_le_rpow_div nonnegx
        (by grind : 0 < 1 / (6 : ℝ))) (by grind : 0 ≤ (3 : ℝ))
      simp only [rpow_ofNat, one_div, div_inv_eq_mul, mul_comm,
        mul_rpow (by grind : 0 ≤ (6 : ℝ)) (rpow_nonneg nonnegx _), ← rpow_mul nonnegx] at this
      norm_num at this
      exact this
    have := mul_le_mul_of_nonneg_left this (mul_nonneg (by simp : 0 ≤ (2 : ℝ)) (by simp : 0 ≤ √x))
    rw [← sqrt_eq_rpow, mul_comm 216 √x, ← mul_assoc, mul_assoc 2 √x √x, mul_self_sqrt nonnegx,
      ← mul_comm 216, ← mul_assoc] at this
    nth_rewrite 3 [← abs_of_nonneg nonnegx] at this
    norm_num at this
    exact this

/-- A nonnegative constant controls the theta error for every real x ≥ 2. -/
theorem pnt : ∃ C ≥ 0, ∀ x ≥ 2, |θ x - x| ≤ C * x / log x ^ 2 := by
  obtain ⟨c, hc⟩ := isBigO_iff'.1 pntBigO
  obtain ⟨N, hN⟩ := eventually_atTop.1 hc.2
  by_cases! hn : 2 ≤ N
  · refine ⟨max c (4 * (θ N + N)), le_max_of_le_left hc.1.le, fun x hx => ?_⟩
    by_cases! h : x ≤ N
    · suffices |θ x - x| * log x ^ 2 / x ≤ 4 * (θ N + N) from by
        rw [le_div_iff₀ (sq_pos_of_pos (log_pos (by linarith))), ← div_le_iff₀ (by linarith)]
        exact this.trans (le_max_right c (4 * (θ N + N)))
      have : |θ x - x| ≤ θ N + N := calc
        _ ≤ |θ x| + |x| := abs_sub _ _
        _ = θ x + x := by rw [abs_of_nonneg (theta_nonneg _), abs_of_nonneg (by linarith)]
        _ ≤ _ := by gcongr
      calc
      _ ≤ (θ N + N) * log x ^ 2 / x := by gcongr
      _ ≤ (θ N + N) * (x ^ (1 / 2 : ℝ) / (1 / 2)) ^ 2 / x := by
        gcongr
        · exact log_nonneg (by linarith)
        · exact log_le_rpow_div (by linarith) (by linarith)
      _ = _ := by rw [← sqrt_eq_rpow, div_pow, sq_sqrt (by linarith)]; field_simp; ring
    · simpa [abs_of_nonneg (by grind : 0 ≤ x), mul_div] using (hN x h.le).trans <|
        mul_le_mul_of_nonneg_right (le_max_left c (4 * (θ N + N))) (norm_nonneg _)
  · refine ⟨c, hc.1.le, fun x hx => ?_⟩
    simpa [abs_of_nonneg (by grind : 0 ≤ x), mul_div] using hN x (hn.le.trans hx)

theorem intervalIntegrable_inv_log_pow (n : ℕ) (m : ℕ) {x : ℝ} (hx : 1 < x) (y : ℝ) :
    IntegrableOn (fun t ↦ 1 / (t ^ n * Real.log t ^ m)) (Set.Ioc x y) volume := by
  by_cases h : x < y
  · refine (ContinuousOn.integrableOn_Icc ?_).mono_set Set.Ioc_subset_Icc_self
    refine ContinuousOn.div₀ (by fun_prop) (ContinuousOn.mul (by fun_prop) ?_) ?_
    · exact (continuousOn_log.mono (by grind)).pow m
    · simp_all; grind
  · simp_all

theorem ioiIntegrable_inv_log_pow {n : ℕ} (hn : 1 < n) {x : ℝ} (hx : 1 < x) :
    IntegrableOn (fun t ↦ 1 / (t * Real.log t ^ n)) (Set.Ioi x) volume := by
  refine integrableOn_Ioi_of_intervalIntegral_norm_tendsto (log x ^ (1 - (n : ℝ)) / (n - 1)) x
    (fun k => ?_) tendsto_natCast_atTop_atTop ?_
  · simpa using intervalIntegrable_inv_log_pow 1 n hx k
  · have : 0 < (n : ℝ) - 1 := by linarith [(one_lt_cast (α := ℝ)).2 hn]
    refine Tendsto.congr' (f₁ := fun i : ℕ => (log i : ℝ) ^ (1 - (n : ℝ)) / (1 - (n : ℝ)) -
      (log x) ^ (1 - (n : ℝ)) / (1 - (n : ℝ))) ?_ ?_
    · have := tendsto_def.1 tendsto_natCast_atTop_atTop (Set.Ici x) (Ici_mem_atTop x)
      filter_upwards [this] with i hi
      refine (intervalIntegral.integral_eq_sub_of_hasDerivAt
        (f := fun r => log r ^ (1 - (n : ℝ)) / (1 - (n : ℝ))) (fun z hz => ?_) ?_).symm
      · simp_all only [preimage_Ici, Set.mem_Ici, ceil_le, Set.uIcc_of_le, Set.mem_Icc]
        have := Real.log_pos (by linarith)
        rw [norm_of_nonneg <| one_div_nonneg.2 (mul_nonneg (by grind) (pow_nonneg this.le n))]
        refine (((hasDerivAt_log (by grind)).rpow_const (by grind)).div_const _).congr_deriv ?_
        have : 1 - (n : ℝ) ≠ 0 := by linarith
        simp [field]
      · apply IntervalIntegrable.norm
        simpa using (intervalIntegrable_iff_integrableOn_Ioc_of_le hi).2
          (intervalIntegrable_inv_log_pow 1 n hx i)
    · suffices h : Tendsto (fun i : ℕ ↦ Real.log i ^ (1 - (n : ℝ)) / (1 - n)) atTop (𝓝 0) from by
        have : (log x ^ (1 - (n : ℝ)) / (n - 1)) = 0 - (log x ^ (1 - (n : ℝ)) / (1 - n)) := by grind
        exact this ▸ h.sub_const (log x ^ (1 - (n : ℝ)) / (1 - n))
      simpa using (((tendsto_rpow_neg_atTop this).comp tendsto_log_atTop).comp
        tendsto_natCast_atTop_atTop).div_const (1 - (n : ℝ))

theorem bound_deriv {f : ℝ → ℝ} (hf : DifferentiableOn ℝ f (Set.Ici 2)) {C : ℝ}
    (hC : ∀ x ∈ Set.Ici 2, |f x| ≤ C / x ∧ |deriv f x| ≤ C / x ^ 2) :
    ∀ᵐ (a : ℝ) ∂volume.restrict (Set.Ioi 2), ‖deriv (fun t ↦ f t / log t) a‖ ≤
    C * (1 / (a ^ 2 * log a) + 1 / (a ^ 2 * log a ^ 2)) := by
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with a ha
  calc
  _ = ‖deriv f a / log a - f a / (a * log a ^ 2)‖ := by
    congr
    rw [deriv_fun_div, deriv_log]
    · field_simp
    · exact hf.differentiableAt (mem_nhds_iff.2 ⟨Set.Ioi 2, Set.Ioi_subset_Ici_self,
        ⟨isOpen_Ioi, ha⟩⟩)
    · exact differentiableAt_log_iff.2 (by grind)
    · simp_all; grind
  _ ≤ ‖deriv f a‖ / ‖log a‖ + ‖f a‖ / ‖a * log a ^ 2‖ := by rw [← norm_div, ← norm_div]; bound
  _ = |deriv f a| / ‖log a‖ + |f a| / ‖a * log a ^ 2‖ := by simp
  _ ≤ C / a ^ 2 / ‖log a‖ + C / a / ‖a * log a ^ 2‖ := by
    gcongr
    exacts [(hC a (Set.Ioi_subset_Ici_self ha)).2, (hC a (Set.Ioi_subset_Ici_self ha)).1]
  _ = C / a ^ 2 / log a + C / a / (a * log a ^ 2) := by
    congr <;> rw [norm_of_nonneg]
    · exact log_nonneg (by grind)
    · exact mul_nonneg (by grind) (pow_nonneg (log_nonneg (by grind)) 2)
  _ = _ := by field_simp

theorem integrableOn_deriv {f : ℝ → ℝ} (hf : DifferentiableOn ℝ f (Set.Ici 2)) {C : ℝ}
    (hC : ∀ x ∈ Set.Ici 2, |f x| ≤ C / x ∧ |deriv f x| ≤ C / x ^ 2) :
    IntegrableOn (fun y ↦ (θ y - y) * deriv (fun t ↦ f t / log t) y) (Set.Ioi 2) volume
    ∧ ∀ x ≥ 2, IntervalIntegrable (fun t ↦ deriv (fun s ↦ f s / Real.log s) t) volume 2 x := by
  obtain ⟨A, hA⟩ := pnt
  refine ⟨Integrable.mono' (g := fun t => (A * C) * (1 / (t * log t ^ 3) + 1 / (t * log t ^ 4)))
    ?_ ?_ ?_, fun x hx => ?_⟩
  · refine ((ioiIntegrable_inv_log_pow ?_ ?_).add (ioiIntegrable_inv_log_pow ?_ ?_)).const_mul
      (A * C) <;> linarith
  · exact (theta_mono.measurable.aestronglyMeasurable.sub (by fun_prop)).mul
      (aestronglyMeasurable_deriv _ _)
  · filter_upwards [bound_deriv hf hC, ae_restrict_mem measurableSet_Ioi] with a ha ho
    calc
    _ = |(θ a - a)| * ‖deriv (fun t ↦ f t / log t) a‖ := by simp
    _ ≤ A * a / log a ^ 2 * (C * (1 / (a ^ 2 * log a) + 1 / (a ^ 2 * log a ^ 2))) := by
      gcongr
      · exact div_nonneg (mul_nonneg hA.1 (by grind)) (pow_nonneg (log_nonneg (by grind)) 2)
      · exact hA.2 a (Set.mem_Ioi.1 ho).le
    _ = _ := by field_simp
  · refine (intervalIntegrable_iff_integrableOn_Ioc_of_le hx).2 (Integrable.mono'
      (Integrable.const_mul (Integrable.add ?_ ?_) C) (aestronglyMeasurable_deriv _ _)
      (ae_restrict_of_ae_restrict_of_subset Set.Ioc_subset_Ioi_self (bound_deriv hf hC)))
    · simpa using! intervalIntegrable_inv_log_pow 2 1 (by linarith : 1 < (2 : ℝ)) x
    · simpa using! intervalIntegrable_inv_log_pow 2 2 (by linarith : 1 < (2 : ℝ)) x

/-- The improper integrability input used by CleanMertens. -/
theorem integrableOn_deriv_inv_div_log : IntegrableOn (fun y ↦ (θ y - y) *
    deriv (fun t ↦ 1 / t / Real.log t) y) (Set.Ioi 2) volume ∧
    ∀ x ≥ 2, IntervalIntegrable (fun t ↦ deriv (fun s ↦ 1 / s / Real.log s) t) volume 2 x := by
  refine integrableOn_deriv (C := 1) (by fun_prop (disch := grind)) (fun x hx => ⟨?_, ?_⟩)
  · rw [abs_of_nonneg (one_div_nonneg.2 (by grind))]
  · rw [deriv_fun_div (differentiableAt_const 1) differentiableAt_id (by grind), abs_div]
    simp

end RS_prime
end
