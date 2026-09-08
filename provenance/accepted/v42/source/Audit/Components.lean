import Erdos647Sieve

set_option autoImplicit false
set_option warningAsError true
open scoped BigOperators Topology

example : (∀ (s a : ℝ), 0 ≤ s → 0 ≤ a → ∀ q : ℕ, s ^ (q + 1) + ((q : ℝ) + 1) * a * s ^ q ≤ (s + a) ^ (q + 1)) := Erdos647Sieve.Bonferroni.pow_add_linear_le
#check Erdos647Sieve.Bonferroni.pow_add_linear_le
#print axioms Erdos647Sieve.Bonferroni.pow_add_linear_le

example : (∀ xs : List ℝ, (∀ a ∈ xs, 0 ≤ a) → ∀ q : ℕ, (Nat.factorial q : ℝ) * Erdos647Sieve.Bonferroni.elementary xs q ≤ xs.sum ^ q) := Erdos647Sieve.Bonferroni.factorial_mul_elementary_le_pow_sum
#check Erdos647Sieve.Bonferroni.factorial_mul_elementary_le_pow_sum
#print axioms Erdos647Sieve.Bonferroni.factorial_mul_elementary_le_pow_sum

example : (∀ xs : List ℝ, (∀ a ∈ xs, 0 ≤ a) → ∀ q : ℕ, Erdos647Sieve.Bonferroni.elementary xs q ≤ xs.sum ^ q / (Nat.factorial q : ℝ)) := Erdos647Sieve.Bonferroni.elementary_le_pow_sum_div_factorial
#check Erdos647Sieve.Bonferroni.elementary_le_pow_sum_div_factorial
#print axioms Erdos647Sieve.Bonferroni.elementary_le_pow_sum_div_factorial

example : (∀ xs : List ℝ, (∀ a ∈ xs, 0 ≤ a ∧ a ≤ 1) → Erdos647Sieve.Bonferroni.avoidProduct xs ≤ Real.exp (-xs.sum)) := Erdos647Sieve.Bonferroni.avoidProduct_le_exp_neg_sum
#check Erdos647Sieve.Bonferroni.avoidProduct_le_exp_neg_sum
#print axioms Erdos647Sieve.Bonferroni.avoidProduct_le_exp_neg_sum

example : (∀ xs : List ℝ, (∀ a ∈ xs, 0 ≤ a ∧ a ≤ 1) → ∀ J : ℕ, Even J → Erdos647Sieve.Bonferroni.truncation xs J ≤ Real.exp (-xs.sum) + xs.sum ^ (J + 1) / (Nat.factorial (J + 1) : ℝ)) := Erdos647Sieve.Bonferroni.even_truncation_le_exp_add_tail
#check Erdos647Sieve.Bonferroni.even_truncation_le_exp_add_tail
#print axioms Erdos647Sieve.Bonferroni.even_truncation_le_exp_add_tail

example : (∀ xs : List ℝ, (∀ a ∈ xs, 0 ≤ a ∧ a ≤ 1) → ∀ J : ℕ, Even J → (∑ j ∈ Finset.range (J + 1), (-1 : ℝ) ^ j * Erdos647Sieve.Bonferroni.elementary xs j) ≤ Real.exp (-xs.sum) + xs.sum ^ (J + 1) / (Nat.factorial (J + 1) : ℝ)) := Erdos647Sieve.Bonferroni.even_sum_le_exp_add_tail
#check Erdos647Sieve.Bonferroni.even_sum_le_exp_add_tail
#print axioms Erdos647Sieve.Bonferroni.even_sum_le_exp_add_tail

#check Erdos647Sieve.sum_map_toList_eq_sum
#print axioms Erdos647Sieve.sum_map_toList_eq_sum

#check Erdos647Sieve.prod_map_toList_eq_prod
#print axioms Erdos647Sieve.prod_map_toList_eq_prod

#check Erdos647Sieve.avoidProduct_map_toList
#print axioms Erdos647Sieve.avoidProduct_map_toList

#check Erdos647Sieve.prod_ite_eq_pow_card_filter
#print axioms Erdos647Sieve.prod_ite_eq_pow_card_filter

#check Erdos647Sieve.hitWeights_bounds
#print axioms Erdos647Sieve.hitWeights_bounds

example : (∀ (H : ℕ) (y z : ℝ) (n : ℤ), Erdos647Sieve.Bonferroni.avoidProduct (Erdos647Sieve.hitWeights H y z n) = z ^ Erdos647Sieve.hitCount H y n) := Erdos647Sieve.avoidProduct_hitWeights
#check Erdos647Sieve.avoidProduct_hitWeights
#print axioms Erdos647Sieve.avoidProduct_hitWeights

example : (∀ (H : ℕ) (y z : ℝ), (Erdos647Sieve.meanWeights H y z).sum = (1 - z) * Erdos647Sieve.primeMass H y) := Erdos647Sieve.meanWeights_sum
#check Erdos647Sieve.meanWeights_sum
#print axioms Erdos647Sieve.meanWeights_sum

#check Erdos647Sieve.meanWeights_bounds
#print axioms Erdos647Sieve.meanWeights_bounds

example : (∀ (H : ℕ) (y z : ℝ) (n : ℤ), 0 < z → z < 1 → ∀ J : ℕ, Even J → z ^ Erdos647Sieve.hitCount H y n ≤ ∑ j ∈ Finset.range (J + 1), (-1 : ℝ) ^ j * Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.hitWeights H y z n) j) := Erdos647Sieve.hitWeight_pointwise_upper
#check Erdos647Sieve.hitWeight_pointwise_upper
#print axioms Erdos647Sieve.hitWeight_pointwise_upper

example : (∀ (A : ℤ) (X H : ℕ) (y z : ℝ), 0 < z → z < 1 → ∀ J : ℕ, Even J → (∑ n ∈ Finset.Icc (A + 1) (A + (X : ℤ)), z ^ Erdos647Sieve.hitCount H y n) ≤ ∑ j ∈ Finset.range (J + 1), (-1 : ℝ) ^ j * (∑ n ∈ Finset.Icc (A + 1) (A + (X : ℤ)), Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.hitWeights H y z n) j)) := Erdos647Sieve.hitWeight_interval_upper
#check Erdos647Sieve.hitWeight_interval_upper
#print axioms Erdos647Sieve.hitWeight_interval_upper

example : (∀ (H : ℕ) (y z : ℝ), 0 < z → z < 1 → ∀ J : ℕ, Even J → (∑ j ∈ Finset.range (J + 1), (-1 : ℝ) ^ j * Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.meanWeights H y z) j) ≤ Real.exp (-((1 - z) * Erdos647Sieve.primeMass H y)) + ((1 - z) * Erdos647Sieve.primeMass H y) ^ (J + 1) / (Nat.factorial (J + 1) : ℝ)) := Erdos647Sieve.meanWeight_truncation_upper
#check Erdos647Sieve.meanWeight_truncation_upper
#print axioms Erdos647Sieve.meanWeight_truncation_upper

#check Erdos647Sieve.card_filter_natCast_image
#print axioms Erdos647Sieve.card_filter_natCast_image

example : (∀ (H : ℕ) (y : ℝ) (n : ℤ), Erdos647Sieve.hitCount H y n = ((Erdos647Sieve.selectedPrimes H y).filter (fun p : ℕ => (p : ℤ) ∣ Erdos647Sieve.windowPolynomial H n)).card) := Erdos647Sieve.hitCount_eq_nat_filter_card
#check Erdos647Sieve.hitCount_eq_nat_filter_card
#print axioms Erdos647Sieve.hitCount_eq_nat_filter_card

#check Erdos647Sieve.two_pow_primeFactors_card_le_tau
#print axioms Erdos647Sieve.two_pow_primeFactors_card_le_tau

#check Erdos647Sieve.primeFactors_card_le_log_floor
#print axioms Erdos647Sieve.primeFactors_card_le_log_floor

#check Erdos647Sieve.prefix_primeFactor_sum_le_logBudget
#print axioms Erdos647Sieve.prefix_primeFactor_sum_le_logBudget

#check Erdos647Sieve.div_le_divisorOccurrences
#print axioms Erdos647Sieve.div_le_divisorOccurrences

#check Erdos647Sieve.sum_divisorOccurrences_eq
#print axioms Erdos647Sieve.sum_divisorOccurrences_eq

#check Erdos647Sieve.windowPolynomial_eq_nat_product
#print axioms Erdos647Sieve.windowPolynomial_eq_nat_product

#check Erdos647Sieve.prime_dvd_nat_product_iff
#print axioms Erdos647Sieve.prime_dvd_nat_product_iff

#check Erdos647Sieve.prime_dvd_window_iff
#print axioms Erdos647Sieve.prime_dvd_window_iff

#check Erdos647Sieve.one_le_divisorOccurrences_of_hit
#print axioms Erdos647Sieve.one_le_divisorOccurrences_of_hit

#check Erdos647Sieve.smallPrimes_disjoint_selectedPrimes
#print axioms Erdos647Sieve.smallPrimes_disjoint_selectedPrimes

#check Erdos647Sieve.smallPrimeDebit_add_hitCount_le_primeFactor_sum
#print axioms Erdos647Sieve.smallPrimeDebit_add_hitCount_le_primeFactor_sum

#check Erdos647Sieve.no_prefix_of_negative_correctedBudget
#print axioms Erdos647Sieve.no_prefix_of_negative_correctedBudget

example : (Erdos647Sieve.FiniteMomentClaim → Erdos647Sieve.FiniteCountingClaim) := Erdos647Sieve.finiteCounting_of_finiteMoment
#check Erdos647Sieve.finiteCounting_of_finiteMoment
#print axioms Erdos647Sieve.finiteCounting_of_finiteMoment

#check Erdos647Sieve.candidateCount_le_window_of_negative_correctedBudget
#print axioms Erdos647Sieve.candidateCount_le_window_of_negative_correctedBudget

#check Erdos647Sieve.count_le_exceptions_add_weight
#print axioms Erdos647Sieve.count_le_exceptions_add_weight

#check Erdos647Sieve.one_le_budget_weight
#print axioms Erdos647Sieve.one_le_budget_weight

#check Erdos647Sieve.Bonferroni.signedError_nonneg
#print axioms Erdos647Sieve.Bonferroni.signedError_nonneg

#check Erdos647Sieve.Bonferroni.even_sum_bounds
#print axioms Erdos647Sieve.Bonferroni.even_sum_bounds

#check Erdos647Sieve.candidate_prefix
#print axioms Erdos647Sieve.candidate_prefix

#check Erdos647Sieve.candidateCount_eq_filter_Icc
#print axioms Erdos647Sieve.candidateCount_eq_filter_Icc

#check Erdos647Sieve.sum_nat_Icc_eq_int
#print axioms Erdos647Sieve.sum_nat_Icc_eq_int

#check Erdos647Sieve.no_prefix_of_negative_budget
#print axioms Erdos647Sieve.no_prefix_of_negative_budget

example : (Erdos647Sieve.BudgetDebitClaim → Erdos647Sieve.FiniteMomentClaim → Erdos647Sieve.FiniteCountingClaim) := Erdos647Sieve.finiteCounting_of_budgetDebit_of_finiteMoment
#check Erdos647Sieve.finiteCounting_of_budgetDebit_of_finiteMoment
#print axioms Erdos647Sieve.finiteCounting_of_budgetDebit_of_finiteMoment

#check Erdos647Sieve.candidateCount_le_window_of_negative_budget
#print axioms Erdos647Sieve.candidateCount_le_window_of_negative_budget

#check Erdos647Sieve.sum_powersetCard_succ_insert
#print axioms Erdos647Sieve.sum_powersetCard_succ_insert

example : (∀ (l : List ℕ), l.Nodup → ∀ (w : ℕ → ℝ) (q : ℕ), Erdos647Sieve.Bonferroni.elementary (l.map w) q = ∑ S ∈ l.toFinset.powersetCard q, ∏ p ∈ S, w p) := Erdos647Sieve.elementary_map_eq_sum_powersetCard
#check Erdos647Sieve.elementary_map_eq_sum_powersetCard
#print axioms Erdos647Sieve.elementary_map_eq_sum_powersetCard

example : (∀ (s : Finset ℕ) (w : ℕ → ℝ) (q : ℕ), Erdos647Sieve.Bonferroni.elementary (s.toList.map w) q = ∑ S ∈ s.powersetCard q, ∏ p ∈ S, w p) := Erdos647Sieve.elementary_toList_eq_sum_powersetCard
#check Erdos647Sieve.elementary_toList_eq_sum_powersetCard
#print axioms Erdos647Sieve.elementary_toList_eq_sum_powersetCard

#check Erdos647Sieve.elementary_map_eq_of_toFinset_eq
#print axioms Erdos647Sieve.elementary_map_eq_of_toFinset_eq

example : (∀ S : Finset ℕ, (∀ p ∈ S, p.Prime) → 0 < Erdos647Sieve.primeSubsetProduct S) := Erdos647Sieve.primeSubsetProduct_pos
#check Erdos647Sieve.primeSubsetProduct_pos
#print axioms Erdos647Sieve.primeSubsetProduct_pos

#check Erdos647Sieve.selected_subset_product_pos
#print axioms Erdos647Sieve.selected_subset_product_pos

#check Erdos647Sieve.prime_dvd_primeSubsetProduct_iff_mem
#print axioms Erdos647Sieve.prime_dvd_primeSubsetProduct_iff_mem

example : (∀ S T : Finset ℕ, (∀ p ∈ S, p.Prime) → (∀ p ∈ T, p.Prime) → Erdos647Sieve.primeSubsetProduct S = Erdos647Sieve.primeSubsetProduct T → S = T) := Erdos647Sieve.primeSubsetProduct_injective
#check Erdos647Sieve.primeSubsetProduct_injective
#print axioms Erdos647Sieve.primeSubsetProduct_injective

example : (∀ S : Finset ℕ, (∀ p ∈ S, p.Prime) → ∀ m : ℤ, (Erdos647Sieve.primeSubsetProduct S : ℤ) ∣ m ↔ ∀ p ∈ S, (p : ℤ) ∣ m) := Erdos647Sieve.primeSubsetProduct_int_dvd_iff
#check Erdos647Sieve.primeSubsetProduct_int_dvd_iff
#print axioms Erdos647Sieve.primeSubsetProduct_int_dvd_iff

example : (∀ P : Finset ℕ, (∀ p ∈ P, p.Prime) → ∀ F : Finset (Finset ℕ), (∀ S ∈ F, S ⊆ P) → ∀ M : ℕ, (∀ S ∈ F, Erdos647Sieve.primeSubsetProduct S ≤ M) → F.card ≤ M) := Erdos647Sieve.card_primeSubsetFamily_le
#check Erdos647Sieve.card_primeSubsetFamily_le
#print axioms Erdos647Sieve.card_primeSubsetFamily_le

example : (∀ (H p : ℕ) (n : ℤ), p.Prime → ((p : ℤ) ∣ Erdos647Sieve.windowPolynomial H n ↔ ∃ k ∈ Finset.Icc 1 H, (p : ℤ) ∣ n - (k : ℤ))) := Erdos647Sieve.prime_dvd_window_iff_int
#check Erdos647Sieve.prime_dvd_window_iff_int
#print axioms Erdos647Sieve.prime_dvd_window_iff_int

example : (∀ (H p : ℕ) (n : ℤ), p.Prime → ((p : ℤ) ∣ Erdos647Sieve.windowPolynomial H n ↔ (n : ZMod p) ∈ Erdos647Sieve.primeWindowResidues H p)) := Erdos647Sieve.prime_dvd_window_iff_mem_residues
#check Erdos647Sieve.prime_dvd_window_iff_mem_residues
#print axioms Erdos647Sieve.prime_dvd_window_iff_mem_residues

example : (∀ H p : ℕ, H < p → (Erdos647Sieve.primeWindowResidues H p).card = H) := Erdos647Sieve.card_primeWindowResidues
#check Erdos647Sieve.card_primeWindowResidues
#print axioms Erdos647Sieve.card_primeWindowResidues

#check Erdos647Sieve.subsetHitCount_empty
#print axioms Erdos647Sieve.subsetHitCount_empty

#check Erdos647Sieve.subsetHitCount_eq_modulus_count
#print axioms Erdos647Sieve.subsetHitCount_eq_modulus_count

#check Erdos647Sieve.prod_ite_zero_eq_pow_card
#print axioms Erdos647Sieve.prod_ite_zero_eq_pow_card

#check Erdos647Sieve.hitWeights_elementary_eq_subset_sum
#print axioms Erdos647Sieve.hitWeights_elementary_eq_subset_sum

example : (∀ (I : Finset ℤ) (H : ℕ) (y z : ℝ) (q : ℕ), (∑ n ∈ I, Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.hitWeights H y z n) q) = (1 - z) ^ q * (∑ S ∈ (Erdos647Sieve.selectedPrimes H y).powersetCard q, (Erdos647Sieve.subsetHitCount I H S : ℝ))) := Erdos647Sieve.sum_hitWeights_elementary_eq_subset_counts
#check Erdos647Sieve.sum_hitWeights_elementary_eq_subset_counts
#print axioms Erdos647Sieve.sum_hitWeights_elementary_eq_subset_counts

example : (∀ (A : ℤ) (X H : ℕ) (y z : ℝ) (q : ℕ), (∑ n ∈ Finset.Icc (A + 1) (A + (X : ℤ)), Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.hitWeights H y z n) q) = (1 - z) ^ q * (∑ S ∈ (Erdos647Sieve.selectedPrimes H y).powersetCard q, (Erdos647Sieve.subsetHitCount (Finset.Icc (A + 1) (A + (X : ℤ))) H S : ℝ))) := Erdos647Sieve.interval_hitWeights_elementary_eq_subset_counts
#check Erdos647Sieve.interval_hitWeights_elementary_eq_subset_counts
#print axioms Erdos647Sieve.interval_hitWeights_elementary_eq_subset_counts

example : (∀ (H : ℕ) (y z : ℝ) (q : ℕ), Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.meanWeights H y z) q = (1 - z) ^ q * (∑ S ∈ (Erdos647Sieve.selectedPrimes H y).powersetCard q, ((H : ℝ) ^ q / (Erdos647Sieve.primeSubsetProduct S : ℝ)))) := Erdos647Sieve.meanWeights_elementary_eq_subset_sum
#check Erdos647Sieve.meanWeights_elementary_eq_subset_sum
#print axioms Erdos647Sieve.meanWeights_elementary_eq_subset_sum

#check Erdos647Sieve.coefficient_discrepancy_eq_subset_errors
#print axioms Erdos647Sieve.coefficient_discrepancy_eq_subset_errors

example : (∀ (I : Finset ℤ) (X H : ℕ) (y z : ℝ) (J : ℕ), (∑ j ∈ Finset.range (J + 1), (-1 : ℝ) ^ j * ((∑ n ∈ I, Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.hitWeights H y z n) j) - (X : ℝ) * Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.meanWeights H y z) j)) = ∑ j ∈ Finset.range (J + 1), (-(1 - z)) ^ j * (∑ S ∈ (Erdos647Sieve.selectedPrimes H y).powersetCard j, ((Erdos647Sieve.subsetHitCount I H S : ℝ) - (X : ℝ) * ((H : ℝ) ^ j / (Erdos647Sieve.primeSubsetProduct S : ℝ))))) := Erdos647Sieve.signed_discrepancy_eq_subset_errors
#check Erdos647Sieve.signed_discrepancy_eq_subset_errors
#print axioms Erdos647Sieve.signed_discrepancy_eq_subset_errors

#check Erdos647Sieve.mul_le_iff_le_euclideanQuotient
#print axioms Erdos647Sieve.mul_le_iff_le_euclideanQuotient

example : (∀ (A : ℤ) (X d : ℕ) (r : ℤ), 0 < d → (Erdos647Sieve.progressionCount A X d r : ℤ) = (A + (X : ℤ) - r) / (d : ℤ) - (A - r) / (d : ℤ)) := Erdos647Sieve.progressionCount_eq_quotient_difference
#check Erdos647Sieve.progressionCount_eq_quotient_difference
#print axioms Erdos647Sieve.progressionCount_eq_quotient_difference

#check Erdos647Sieve.euclideanQuotient_real_bounds
#print axioms Erdos647Sieve.euclideanQuotient_real_bounds

example : (∀ (A : ℤ) (X d : ℕ) (r : ℤ), 0 < d → |(Erdos647Sieve.progressionCount A X d r : ℝ) - (X : ℝ) / (d : ℝ)| ≤ 1) := Erdos647Sieve.progressionCount_error_le_one
#check Erdos647Sieve.progressionCount_error_le_one
#print axioms Erdos647Sieve.progressionCount_error_le_one

#check Erdos647Sieve.residueClassCount_eq_progressionCount
#print axioms Erdos647Sieve.residueClassCount_eq_progressionCount

example : (∀ (A : ℤ) (X d : ℕ) (r : ZMod d), 0 < d → |(Erdos647Sieve.residueClassCount A X d r : ℝ) - (X : ℝ) / (d : ℝ)| ≤ 1) := Erdos647Sieve.residueClassCount_error_le_one
#check Erdos647Sieve.residueClassCount_error_le_one
#print axioms Erdos647Sieve.residueClassCount_error_le_one

example : (∀ (A : ℤ) (X d : ℕ) (R : Finset (ZMod d)), 0 < d → |(((Finset.Icc (A + 1) (A + (X : ℤ))).filter (fun n : ℤ => (n : ZMod d) ∈ R)).card : ℝ) - (X : ℝ) * ((R.card : ℝ) / (d : ℝ))| ≤ (R.card : ℝ)) := Erdos647Sieve.residueSetCount_error_le_card
#check Erdos647Sieve.residueSetCount_error_le_card
#print axioms Erdos647Sieve.residueSetCount_error_le_card

#check Erdos647Sieve.map_windowEvaluation
#print axioms Erdos647Sieve.map_windowEvaluation

#check Erdos647Sieve.windowEvaluation_intCast
#print axioms Erdos647Sieve.windowEvaluation_intCast

#check Erdos647Sieve.mem_windowRootResidues
#print axioms Erdos647Sieve.mem_windowRootResidues

example : (∀ (H d : ℕ), 0 < d → ∀ n : ℤ, (n : ZMod d) ∈ Erdos647Sieve.windowRootResidues H d ↔ (d : ℤ) ∣ Erdos647Sieve.windowPolynomial H n) := Erdos647Sieve.intCast_mem_windowRootResidues_iff
#check Erdos647Sieve.intCast_mem_windowRootResidues_iff
#print axioms Erdos647Sieve.intCast_mem_windowRootResidues_iff

#check Erdos647Sieve.windowRootResidues_eq_primeWindowResidues
#print axioms Erdos647Sieve.windowRootResidues_eq_primeWindowResidues

#check Erdos647Sieve.card_windowRootResidues_prime
#print axioms Erdos647Sieve.card_windowRootResidues_prime

example : (∀ H : ℕ, (Erdos647Sieve.windowRootResidues H 1).card = 1) := Erdos647Sieve.card_windowRootResidues_one
#check Erdos647Sieve.card_windowRootResidues_one
#print axioms Erdos647Sieve.card_windowRootResidues_one

example : (∀ H m d : ℕ, 0 < m → 0 < d → Nat.Coprime m d → (Erdos647Sieve.windowRootResidues H (m * d)).card = (Erdos647Sieve.windowRootResidues H m).card * (Erdos647Sieve.windowRootResidues H d).card) := Erdos647Sieve.card_windowRootResidues_mul
#check Erdos647Sieve.card_windowRootResidues_mul
#print axioms Erdos647Sieve.card_windowRootResidues_mul

example : (∀ (H : ℕ) (S : Finset ℕ), (∀ p ∈ S, p.Prime ∧ H < p) → (Erdos647Sieve.windowRootResidues H (Erdos647Sieve.primeSubsetProduct S)).card = H ^ S.card) := Erdos647Sieve.card_windowRootResidues_primeSubsetProduct
#check Erdos647Sieve.card_windowRootResidues_primeSubsetProduct
#print axioms Erdos647Sieve.card_windowRootResidues_primeSubsetProduct

#check Erdos647Sieve.subsetHitCount_eq_windowRootResidues_count
#print axioms Erdos647Sieve.subsetHitCount_eq_windowRootResidues_count

example : (∀ (A : ℤ) (X H : ℕ) (S : Finset ℕ), (∀ p ∈ S, p.Prime ∧ H < p) → |(Erdos647Sieve.subsetHitCount (Finset.Icc (A + 1) (A + (X : ℤ))) H S : ℝ) - (X : ℝ) * ((H : ℝ) ^ S.card / (Erdos647Sieve.primeSubsetProduct S : ℝ))| ≤ (H : ℝ) ^ S.card) := Erdos647Sieve.subsetHitCount_error_le
#check Erdos647Sieve.subsetHitCount_error_le
#print axioms Erdos647Sieve.subsetHitCount_error_le

example : (∀ (A : ℤ) (X H : ℕ) (y : ℝ) (S : Finset ℕ), S ⊆ Erdos647Sieve.selectedPrimes H y → |(Erdos647Sieve.subsetHitCount (Finset.Icc (A + 1) (A + (X : ℤ))) H S : ℝ) - (X : ℝ) * ((H : ℝ) ^ S.card / (Erdos647Sieve.primeSubsetProduct S : ℝ))| ≤ (H : ℝ) ^ S.card) := Erdos647Sieve.selected_subsetHitCount_error_le
#check Erdos647Sieve.selected_subsetHitCount_error_le
#print axioms Erdos647Sieve.selected_subsetHitCount_error_le

#check Erdos647Sieve.mem_retainedSubsets
#print axioms Erdos647Sieve.mem_retainedSubsets

example : (∀ (P : Finset ℕ) (J : ℕ) (f : Finset ℕ → ℝ), (∑ j ∈ Finset.range (J + 1), ∑ S ∈ P.powersetCard j, f S) = ∑ S ∈ Erdos647Sieve.retainedSubsets P J, f S) := Erdos647Sieve.sum_powersetCard_le_eq_retained
#check Erdos647Sieve.sum_powersetCard_le_eq_retained
#print axioms Erdos647Sieve.sum_powersetCard_le_eq_retained

#check Erdos647Sieve.real_pow_mono_of_one_le
#print axioms Erdos647Sieve.real_pow_mono_of_one_le

#check Erdos647Sieve.retained_primeSubsetProduct_le
#print axioms Erdos647Sieve.retained_primeSubsetProduct_le

example : (∀ (H : ℕ) (y : ℝ) (J : ℕ), 1 ≤ H → (H : ℝ) < y → (Erdos647Sieve.retainedSubsets (Erdos647Sieve.selectedPrimes H y) J).card ≤ Nat.floor (y ^ J)) := Erdos647Sieve.card_retainedSubsets_le_floor
#check Erdos647Sieve.card_retainedSubsets_le_floor
#print axioms Erdos647Sieve.card_retainedSubsets_le_floor

#check Erdos647Sieve.card_retainedSubsets_cast_le
#print axioms Erdos647Sieve.card_retainedSubsets_cast_le

#check Erdos647Sieve.retained_weighted_subset_error_le
#print axioms Erdos647Sieve.retained_weighted_subset_error_le

example : (∀ (A : ℤ) (X H : ℕ) (y z : ℝ) (J : ℕ), 1 ≤ H → (H : ℝ) < y → 0 < z → z < 1 → |∑ j ∈ Finset.range (J + 1), (-1 : ℝ) ^ j * ((∑ n ∈ Finset.Icc (A + 1) (A + (X : ℤ)), Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.hitWeights H y z n) j) - (X : ℝ) * Erdos647Sieve.Bonferroni.elementary (Erdos647Sieve.meanWeights H y z) j)| ≤ ((H : ℝ) * y) ^ J) := Erdos647Sieve.arithmetic_discrepancy_le
#check Erdos647Sieve.arithmetic_discrepancy_le
#print axioms Erdos647Sieve.arithmetic_discrepancy_le

