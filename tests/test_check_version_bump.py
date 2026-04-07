"""Tests for scripts/check-version-bump.py — version tuple parsing and comparison."""

import sys
from pathlib import Path

# Add scripts directory to import path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

# Import the functions we want to test
from importlib.util import spec_from_file_location, module_from_spec

spec = spec_from_file_location(
    "check_version_bump",
    str(Path(__file__).resolve().parent.parent / "scripts" / "check-version-bump.py"),
)
mod = module_from_spec(spec)
spec.loader.exec_module(mod)

version_tuple = mod.version_tuple


def test_version_tuple_basic():
    assert version_tuple("1.0.0") == (1, 0, 0)


def test_version_tuple_multi_digit():
    assert version_tuple("1.12.3") == (1, 12, 3)


def test_version_tuple_zero():
    assert version_tuple("0.0.0") == (0, 0, 0)


def test_version_comparison_patch_bump():
    assert version_tuple("1.0.1") > version_tuple("1.0.0")


def test_version_comparison_minor_bump():
    assert version_tuple("1.1.0") > version_tuple("1.0.9")


def test_version_comparison_major_bump():
    assert version_tuple("2.0.0") > version_tuple("1.99.99")


def test_version_comparison_equal():
    assert version_tuple("1.2.3") == version_tuple("1.2.3")


def test_version_comparison_no_bump():
    assert not (version_tuple("1.0.0") > version_tuple("1.0.0"))


if __name__ == "__main__":
    tests = [v for k, v in globals().items() if k.startswith("test_")]
    passed = 0
    failed = 0
    for test in tests:
        try:
            test()
            print(f"  PASS: {test.__name__}")
            passed += 1
        except AssertionError as e:
            print(f"  FAIL: {test.__name__}: {e}")
            failed += 1
    print(f"\nResults: {passed} passed, {failed} failed, {passed + failed} total")
    sys.exit(1 if failed else 0)
