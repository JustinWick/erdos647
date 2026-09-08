"""Regressions for the v40 cutoff adapters.

Source-shape and exact-rational tests do not replace the checked-in Lean audits.
"""
from fractions import Fraction
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'research/Erdos647Research/Endpoint/CutoffParameters.lean'


def body(name: str) -> str:
    return SOURCE.read_text().split('theorem ' + name, 1)[1].split('\n/--', 1)[0]


class CutoffPresentationRepairs(unittest.TestCase):
    def test_inverse_limit_normalizes_the_fixed_rational(self):
        text = body('log_primeCutoff_scale_ratio_tendsto')
        self.assertIn('convert! (truncationOrder_scale_ratio_tendsto.const_mul 4).inv₀', text)
        self.assertIn('≠ 0) using 1\n    norm_num', text)
        self.assertEqual(1 / (4 * Fraction(1, 50)), Fraction(25, 2))

    def test_quotient_limit_is_explicitly_pointwise(self):
        text = body('log_windowLength_div_log_primeCutoff_tendsto_zero')
        self.assertIn('simpa only [Pi.div_def, zero_div] using', text)
        self.assertIn('log_primeCutoff_scale_ratio_tendsto', text)

    def test_cancellation_supplies_both_numerators(self):
        text = body('log_windowLength_div_log_primeCutoff_tendsto_zero')
        self.assertIn("exact div_div_div_cancel_right₀ (Real.rpow_pos_of_pos hQ (1 - endpointExponent)).ne'\n"
                      '    (Real.log (windowLength X : ℝ)) (Real.log (primeCutoff X))', text)

    def test_cancellation_sanity_including_zero_numerators(self):
        def div(a: Fraction, b: Fraction) -> Fraction:
            return a / b if b else Fraction(0)
        for a in map(Fraction, [-2, -1, 0, 1, 9]):
            for b in map(Fraction, [-3, 0, 1, 7]):
                for scale in [Fraction(1, 3), Fraction(1), Fraction(2), Fraction(100)]:
                    self.assertEqual(div(div(a, scale), div(b, scale)), div(a, b))

    def test_all_cutoff_targets_remain_exactly_audited(self):
        names = re.findall(r'^theorem (\w+)', SOURCE.read_text(), re.M)
        audit = (ROOT/'research/Audit/EndpointCutoffParameters.lean').read_text()
        actual = re.findall(r'^#print axioms (\S+)', audit, re.M)
        self.assertEqual(actual, ['Erdos647Sieve.Endpoint.' + n for n in names])
        self.assertEqual(len(re.findall(r'^example : ', audit, re.M)), len(names))
        self.assertEqual(len(names), 13)


if __name__ == '__main__':
    unittest.main()
