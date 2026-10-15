"""Tests for skills/doc-refresh/scripts/ste_check.py — STE writing-rule scoring."""

import sys
import tempfile
from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / "skills" / "doc-refresh" / "scripts" / "ste_check.py"
spec = spec_from_file_location("ste_check", str(SCRIPT))
mod = module_from_spec(spec)
spec.loader.exec_module(mod)


def check(text):
    return mod.check_text("t.md", text, 20, 25)


def rules(report):
    return [v.rule for v in report.violations]


def test_check_text_short_clean_sentences_score_100():
    report = check("The provider reads the token. It sends one request.\n")
    assert report.sentences == 2
    assert report.score == 100.0


def test_check_text_descriptive_sentence_over_25_words_flagged():
    long_sentence = " ".join(["word"] * 26) + ".\n"
    report = check(long_sentence)
    assert rules(report) == ["descriptive-length"]
    assert report.score == 0.0


def test_check_text_descriptive_sentence_at_25_words_passes():
    report = check(" ".join(["word"] * 25) + ".\n")
    assert report.violations == []


def test_check_text_numbered_step_over_20_words_flagged_as_procedural():
    step = "1. " + " ".join(["word"] * 21) + ".\n"
    report = check(step)
    assert rules(report) == ["procedural-length"]


def test_check_text_bullet_item_uses_descriptive_limit():
    report = check("- " + " ".join(["word"] * 22) + ".\n")
    assert report.violations == []


def test_check_text_modal_verb_flagged():
    report = check("You should set the token.\n")
    assert rules(report) == ["modal-verb"]


def test_check_text_paragraph_over_six_sentences_flagged():
    report = check(" ".join(["Set it."] * 7) + "\n")
    assert "paragraph-length" in rules(report)


def test_check_text_skips_code_tables_headings_frontmatter_and_comments():
    text = (
        "---\npage_title: \"x should be ignored\"\n---\n"
        "<!--\ndoc: readme\nthis should be ignored\n-->\n"
        "# A heading that should be ignored\n"
        "```bash\necho this should be ignored\n```\n"
        "| col | this should be ignored |\n"
        "Set the token.\n"
    )
    report = check(text)
    assert report.sentences == 1
    assert report.violations == []


def test_check_text_inline_code_counts_as_one_word():
    report = check("Set `" + " ".join(["x"] * 40) + "` now.\n")
    assert report.violations == []


def test_check_text_empty_input_scores_100():
    report = check("")
    assert report.sentences == 0
    assert report.score == 100.0


def test_check_file_oversized_input_rejected():
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False) as handle:
        handle.write("a" * (mod.MAX_FILE_BYTES + 1))
    try:
        mod.check_file(Path(handle.name), 20, 25)
        raise AssertionError("expected CheckError")
    except mod.CheckError as err:
        assert "limit" in str(err)
    finally:
        Path(handle.name).unlink()


def test_check_file_missing_file_raises_check_error():
    try:
        mod.check_file(Path("/nonexistent/ste-check.md"), 20, 25)
        raise AssertionError("expected CheckError")
    except mod.CheckError as err:
        assert "cannot read" in str(err)


def test_check_file_non_utf8_rejected():
    with tempfile.NamedTemporaryFile("wb", suffix=".md", delete=False) as handle:
        handle.write(b"\xff\xfe\xfa")
    try:
        mod.check_file(Path(handle.name), 20, 25)
        raise AssertionError("expected CheckError")
    except mod.CheckError as err:
        assert "UTF-8" in str(err)
    finally:
        Path(handle.name).unlink()


def test_main_min_score_below_threshold_exits_1():
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False) as handle:
        handle.write("You should do it.\n")
    try:
        assert mod.main([handle.name, "--min-score", "80"]) == 1
        assert mod.main([handle.name]) == 0
    finally:
        Path(handle.name).unlink()


def test_main_missing_file_exits_2():
    assert mod.main(["/nonexistent/ste-check.md"]) == 2


def test_main_out_of_range_limit_rejected():
    try:
        mod.main(["x.md", "--max-procedural", "1000"])
        raise AssertionError("expected SystemExit")
    except SystemExit as exc:
        assert exc.code == 2


if __name__ == "__main__":
    tests = [v for k, v in sorted(globals().items()) if k.startswith("test_") and callable(v)]
    passed = failed = 0
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
