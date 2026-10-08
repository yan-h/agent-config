#!/usr/bin/env python3
"""Tests for ask-api's model resolution, price assumption and cost guard.
They need neither the SDK nor a network: the SDK is imported only in main()."""

from __future__ import annotations

import importlib.machinery
import importlib.util
import unittest
from pathlib import Path

PATH = Path(__file__).with_name("ask-api")
loader = importlib.machinery.SourceFileLoader("ask_api", str(PATH))
spec = importlib.util.spec_from_loader("ask_api", loader)
ask_api = importlib.util.module_from_spec(spec)
loader.exec_module(ask_api)


def model(id, line, created, lifecycle="active"):
    return {"id": id, "line": line, "lifecycle": lifecycle, "created_at": created}


class Resolution(unittest.TestCase):
    def test_newest_active_model_of_the_line_wins(self):
        models = [
            model("claude-fable-5", "fable", "2026-05-01T00:00:00+00:00"),
            model("claude-fable-5-1", "fable", "2026-08-01T00:00:00+00:00"),
            model("claude-fable-5-2", "fable", "2026-11-01T00:00:00+00:00", "deprecated"),
            model("claude-opus-5-5", "opus", "2026-12-01T00:00:00+00:00"),
            model("claude-preview", None, "2026-12-02T00:00:00+00:00"),
        ]
        self.assertEqual(ask_api.newest_in_line(models, "fable"), "claude-fable-5-1")
        self.assertEqual(ask_api.resolve("fable", models), "claude-fable-5-1")
        self.assertEqual(ask_api.resolve("claude-fable-5", models), "claude-fable-5")


class Price(unittest.TestCase):
    def test_only_a_model_newer_than_its_lines_priced_row_borrows_that_price(self):
        models = [
            model("claude-opus-5", "opus", "2026-03-01T00:00:00+00:00"),
            model("claude-opus-5-5", "opus", "2026-09-01T00:00:00+00:00"),
            model("claude-opus-6", "opus", "2026-12-01T00:00:00+00:00"),
            model("claude-fable-5-1", "fable", "2026-08-01T00:00:00+00:00"),
            model("claude-fable-6", "fable", "2026-12-01T00:00:00+00:00"),
            model("claude-preview", None, "2026-12-02T00:00:00+00:00"),
        ]
        self.assertEqual(ask_api.price_for("claude-fable-5-1", models), (10.0, 50.0, None))
        self.assertEqual(
            ask_api.price_for("claude-fable-6", models), (10.0, 50.0, "claude-fable-5-1")
        )
        self.assertEqual(
            ask_api.price_for("claude-opus-6", models), (4.0, 20.0, "claude-opus-5-5")
        )
        self.assertIsNone(ask_api.price_for("claude-opus-5", models))  # older, dearer
        self.assertIsNone(ask_api.price_for("claude-preview", models))
        self.assertIsNone(ask_api.price_for("claude-unlisted", models))


class Guard(unittest.TestCase):
    def test_unknown_price_or_a_worst_case_over_the_limit_refuses_unless_confirmed(self):
        price = (10.0, 50.0, None)
        worst, refusal = ask_api.guard(price, 40_000, 32_000, 3.0, False)
        self.assertAlmostEqual(worst, 2.0)
        self.assertIsNone(refusal)
        worst, refusal = ask_api.guard(price, 140_000, 32_000, 3.0, False)
        self.assertAlmostEqual(worst, 3.0)
        self.assertIsNone(refusal)
        _, refusal = ask_api.guard(price, 140_001, 32_000, 3.0, False)
        self.assertIn("over the $3.00 limit", refusal)
        self.assertIsNone(ask_api.guard(price, 140_001, 32_000, 3.0, True)[1])
        self.assertIsNotNone(ask_api.guard(None, 10, 10, 3.0, False)[1])
        self.assertIsNone(ask_api.guard(None, 10, 10, 3.0, True)[1])


if __name__ == "__main__":
    unittest.main()
