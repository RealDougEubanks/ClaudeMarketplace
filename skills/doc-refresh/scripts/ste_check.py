#!/usr/bin/env python3
"""Heuristic ASD-STE100 writing-rule checker for Markdown.

Scores each file as the share of prose sentences with no rule violation.
It checks only rules a script can test reliably: sentence length,
paragraph length, and modal verbs that STE-lite replaces with can/must.
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

MAX_FILE_BYTES = 2 * 1024 * 1024
MAX_PARAGRAPH_SENTENCES = 6
MODAL_RE = re.compile(r"\b(should|would|could|might|may)\b", re.IGNORECASE)
ORDERED_ITEM_RE = re.compile(r"^\s*\d+[.)]\s+")
BULLET_ITEM_RE = re.compile(r"^\s*[-*+]\s+")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
SENTENCE_END_RE = re.compile(r"(?<=[.!?])\s+(?=[A-Z0-9`\"'(\[])")
ABBREVIATIONS = ("e.g.", "i.e.", "etc.", "vs.", "approx.")


class CheckError(Exception):
    """Raised for input the checker refuses to process."""


@dataclass
class Violation:
    line: int
    rule: str
    detail: str


@dataclass
class FileReport:
    path: str
    sentences: int = 0
    clean_sentences: int = 0
    violations: list = field(default_factory=list)

    @property
    def score(self) -> float:
        if self.sentences == 0:
            return 100.0
        return round(100.0 * self.clean_sentences / self.sentences, 1)


def strip_inline(text: str) -> str:
    text = re.sub(r"`[^`]*`", "CODE", text)
    text = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"<https?://[^>]+>", "URL", text)
    text = re.sub(r"https?://\S+", "URL", text)
    text = re.sub(r"[*_]{1,3}", "", text)
    for abbr in ABBREVIATIONS:
        text = text.replace(abbr, abbr.replace(".", ""))
    return text.strip()


def prose_blocks(lines):
    """Yield (start_line, kind, text) blocks; kind is 'procedural' or 'descriptive'."""
    in_fence = False
    in_comment = False
    in_frontmatter = bool(lines) and lines[0].strip() == "---"
    block, start, kind = [], 0, "descriptive"

    def flush():
        if block:
            yield_value = (start, kind, " ".join(block))
            block.clear()
            return yield_value
        return None

    for number, raw in enumerate(lines, start=1):
        line = raw.rstrip("\n")
        if in_frontmatter:
            if number > 1 and line.strip() == "---":
                in_frontmatter = False
            continue
        if in_comment:
            if "-->" in line:
                in_comment = False
            continue
        if line.lstrip().startswith("<!--"):
            if "-->" not in line:
                in_comment = True
            continue
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        stripped = line.strip()
        if in_fence or stripped.startswith(("|", "#")) or not stripped:
            done = flush()
            if done:
                yield done
            continue
        item_kind = None
        if ORDERED_ITEM_RE.match(line):
            item_kind = "procedural"
        elif BULLET_ITEM_RE.match(line):
            item_kind = "descriptive"
        if item_kind:
            done = flush()
            if done:
                yield done
            kind, start = item_kind, number
            stripped = ORDERED_ITEM_RE.sub("", BULLET_ITEM_RE.sub("", line)).strip()
        elif not block:
            kind, start = "descriptive", number
        stripped = stripped.lstrip("> ").strip()
        if stripped:
            block.append(stripped)
    done = flush()
    if done:
        yield done


def check_text(path: str, text: str, max_procedural: int, max_descriptive: int) -> FileReport:
    report = FileReport(path=path)
    for start, kind, block in prose_blocks(text.splitlines()):
        sentences = [s for s in SENTENCE_END_RE.split(strip_inline(block)) if s.strip()]
        limit = max_procedural if kind == "procedural" else max_descriptive
        if kind == "descriptive" and len(sentences) > MAX_PARAGRAPH_SENTENCES:
            report.violations.append(Violation(start, "paragraph-length",
                                               f"{len(sentences)} sentences (max {MAX_PARAGRAPH_SENTENCES})"))
        for sentence in sentences:
            report.sentences += 1
            problems = []
            words = len(sentence.split())
            if words > limit:
                problems.append(Violation(start, f"{kind}-length", f"{words} words (max {limit})"))
            modal = MODAL_RE.search(sentence)
            if modal:
                problems.append(Violation(start, "modal-verb", f"'{modal.group(0)}' (use can, must, or do not)"))
            if problems:
                report.violations.extend(problems)
            else:
                report.clean_sentences += 1
    return report


def check_file(path: Path, max_procedural: int, max_descriptive: int) -> FileReport:
    try:
        size = path.stat().st_size
    except OSError as err:
        raise CheckError(f"{path}: cannot read file: {err.strerror}") from err
    if size > MAX_FILE_BYTES:
        raise CheckError(f"{path}: file is {size} bytes; the limit is {MAX_FILE_BYTES}")
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError as err:
        raise CheckError(f"{path}: not UTF-8 text") from err
    except OSError as err:
        raise CheckError(f"{path}: cannot read file: {err.strerror}") from err
    return check_text(str(path), text, max_procedural, max_descriptive)


def bounded_int(low: int, high: int):
    def parse(value: str) -> int:
        try:
            number = int(value)
        except ValueError as err:
            raise argparse.ArgumentTypeError(f"{value!r} is not an integer") from err
        if not low <= number <= high:
            raise argparse.ArgumentTypeError(f"must be between {low} and {high}")
        return number
    return parse


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Score Markdown prose against ASD-STE100 writing rules.")
    parser.add_argument("files", nargs="+", type=Path, help="Markdown files to check")
    parser.add_argument("--max-procedural", type=bounded_int(5, 60), default=20)
    parser.add_argument("--max-descriptive", type=bounded_int(5, 60), default=25)
    parser.add_argument("--min-score", type=bounded_int(0, 100), default=0,
                        help="exit 1 when any file scores below this percentage")
    parser.add_argument("--json", action="store_true", help="print a JSON report")
    args = parser.parse_args(argv)

    reports, failed = [], False
    for path in args.files:
        try:
            reports.append(check_file(path, args.max_procedural, args.max_descriptive))
        except CheckError as err:
            print(f"ste_check: error: {err}", file=sys.stderr)
            failed = True

    if args.json:
        print(json.dumps([{"path": r.path, "score": r.score, "sentences": r.sentences,
                           "violations": [v.__dict__ for v in r.violations]} for r in reports], indent=2))
    else:
        for r in reports:
            print(f"{r.score:5.1f}%  {r.clean_sentences}/{r.sentences} sentences clean  {r.path}")
            for v in r.violations:
                print(f"         line {v.line}: {v.rule}: {v.detail}")

    if failed:
        return 2
    return 1 if any(r.score < args.min_score for r in reports) else 0


if __name__ == "__main__":
    sys.exit(main())
