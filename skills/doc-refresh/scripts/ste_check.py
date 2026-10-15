#!/usr/bin/env python3
"""Heuristic ASD-STE100 writing-rule checker for Markdown.

Scores each file as the share of prose sentences with no rule violation.
Tier "always" checks sentence and paragraph length and glossary terms in all
prose, and the procedural rules only inside numbered steps. Tier "full"
applies the procedural rules (modal verbs, -ing phrases, likely passive
voice) to all prose. Passive and -ing checks are heuristics.
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

MAX_FILE_BYTES = 2 * 1024 * 1024
MAX_PARAGRAPH_SENTENCES = 6
MAX_GLOSSARY_ENTRIES = 200
MAX_GLOSSARY_LINE = 300
MODAL_RE = re.compile(r"\b(should|would|could|might|may)\b", re.IGNORECASE)
PASSIVE_RE = re.compile(
    r"\b(?:am|is|are|was|were|be|been|being)\s+(?:\w+ly\s+)?"
    r"(\w+ed|built|done|made|known|given|taken|shown|seen|written|sent|kept|found|held|run|set)\b",
    re.IGNORECASE)
ING_PHRASE_RE = re.compile(r"\b(?:by|when|before|after|while|without|on)\s+(\w{3,}ing)\b", re.IGNORECASE)
ING_EXEMPT = {"thing", "things", "string", "nothing", "something", "anything", "everything",
              "during", "morning", "ring", "spring", "king", "logging", "monitoring", "tracing",
              "caching", "routing", "pricing", "staging", "testing", "scheduling", "existing"}
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


def parse_glossary(text: str) -> list:
    """Parse 'preferred: avoid, avoid' lines into (preferred, compiled-avoid-regex) pairs."""
    entries = []
    for number, raw in enumerate(text.splitlines(), start=1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if len(line) > MAX_GLOSSARY_LINE:
            raise CheckError(f"glossary line {number}: longer than {MAX_GLOSSARY_LINE} characters")
        preferred, sep, avoid = line.partition(":")
        avoid_terms = [t.strip() for t in avoid.split(",") if t.strip()]
        if not sep or not preferred.strip() or not avoid_terms:
            raise CheckError(f"glossary line {number}: expected 'preferred: avoid, avoid'")
        for term in avoid_terms:
            entries.append((preferred.strip(),
                            re.compile(r"(?<!\w)" + re.escape(term) + r"(?!\w)", re.IGNORECASE)))
        if len(entries) > MAX_GLOSSARY_ENTRIES:
            raise CheckError(f"glossary: more than {MAX_GLOSSARY_ENTRIES} terms")
    return entries


def procedural_problems(sentence: str, line: int) -> list:
    problems = []
    modal = MODAL_RE.search(sentence)
    if modal:
        problems.append(Violation(line, "modal-verb", f"'{modal.group(0)}' (use can, must, or do not)"))
    ing = next((m for m in ING_PHRASE_RE.finditer(sentence) if m.group(1).lower() not in ING_EXEMPT), None)
    if ing:
        problems.append(Violation(line, "ing-phrase", f"'{ing.group(0)}' (heuristic; use a verb clause)"))
    passive = PASSIVE_RE.search(sentence)
    if passive:
        problems.append(Violation(line, "passive-voice", f"'{passive.group(0)}' (heuristic; prefer active)"))
    return problems


def check_text(path: str, text: str, max_procedural: int, max_descriptive: int,
               tier: str = "full", glossary=()) -> FileReport:
    if tier not in ("always", "full"):
        raise CheckError(f"unknown tier {tier!r}")
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
            if tier == "full" or kind == "procedural":
                problems.extend(procedural_problems(sentence, start))
            for preferred, avoid_re in glossary:
                hit = avoid_re.search(sentence)
                if hit:
                    problems.append(Violation(start, "glossary", f"'{hit.group(0)}' (use '{preferred}')"))
            if problems:
                report.violations.extend(problems)
            else:
                report.clean_sentences += 1
    return report


def read_bounded(path: Path) -> str:
    try:
        size = path.stat().st_size
    except OSError as err:
        raise CheckError(f"{path}: cannot read file: {err.strerror}") from err
    if size > MAX_FILE_BYTES:
        raise CheckError(f"{path}: file is {size} bytes; the limit is {MAX_FILE_BYTES}")
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError as err:
        raise CheckError(f"{path}: not UTF-8 text") from err
    except OSError as err:
        raise CheckError(f"{path}: cannot read file: {err.strerror}") from err


def check_file(path: Path, max_procedural: int, max_descriptive: int,
               tier: str = "full", glossary=()) -> FileReport:
    return check_text(str(path), read_bounded(path), max_procedural, max_descriptive, tier, glossary)


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
    parser.add_argument("--tier", choices=("always", "full"), default="full",
                        help="always: procedural rules only in numbered steps; full: everywhere")
    parser.add_argument("--glossary", type=Path, help="file of 'preferred: avoid, avoid' lines")
    parser.add_argument("--min-score", type=bounded_int(0, 100), default=0,
                        help="exit 1 when any file scores below this percentage")
    parser.add_argument("--json", action="store_true", help="print a JSON report")
    args = parser.parse_args(argv)

    reports, failed, glossary = [], False, ()
    if args.glossary:
        try:
            glossary = parse_glossary(read_bounded(args.glossary))
        except CheckError as err:
            print(f"ste_check: error: {err}", file=sys.stderr)
            return 2
    for path in args.files:
        try:
            reports.append(check_file(path, args.max_procedural, args.max_descriptive,
                                      args.tier, glossary))
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
