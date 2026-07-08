## Best Practices Report — <Project Name> — <Date>

### Stack Detected

| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5.x |
| Framework | Next.js 14 (App Router) |
| ORM | Prisma |
| Testing | Jest + React Testing Library |
| CI/CD | GitHub Actions |

### Summary
**Total findings:** X

| Priority | Count |
|----------|-------|
| P1 Critical | X |
| P2 High | X |
| P3 Medium | X |
| P4 Low | X |

**Estimated total effort to address all findings:** X–Y days

---

### Improvement Roadmap

#### P1 — Critical (fix immediately)

---

**[P1] No error handling middleware — unhandled errors crash the server**
- **Location:** `src/app.ts` — no global error handler registered
- **Why it matters:** Any unhandled exception in a route kills the Node process. Users see a 502 with no useful error message. This is a reliability blocker.
- **Effort:** XS (< 1 hour)
- **Fix:**
  ```typescript
  // Add as the last middleware in app.ts
  app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
    logger.error({ err, path: req.path }, 'Unhandled error');
    res.status(500).json({ error: 'Internal server error' });
  });
  ```

---

**[P1] 14 source files have zero test coverage**
- **Location:** `src/services/`, `src/lib/`
- **Why it matters:** Business logic with no tests means any change can silently break behaviour. Identified files: [list them]
- **Effort:** L (3–5 days to add meaningful coverage)
- **Fix:** Run `/test-writer` on each untested file. Start with `src/services/billing.ts` — highest business risk.

---

#### P2 — High (address this sprint or next)

---

**[P2] TypeScript `strict` mode disabled — 47 implicit `any` types found**
- **Location:** `tsconfig.json:8`
- **Why it matters:** Without strict mode, TypeScript's safety guarantees are significantly weakened. Runtime errors that TypeScript would catch are silently allowed through.
- **Effort:** M (1–2 days to enable strict and fix resulting errors)
- **Fix:**
  ```diff
  // tsconfig.json
  - "strict": false
  + "strict": true
  ```

---

#### P3 — Medium (plan for next quarter)

#### P4 — Low (address opportunistically)

---

### Quick Wins (P1–P2, Effort XS or S)
A condensed list of the highest-impact, lowest-effort items — tackle these first:

| # | Finding | Priority | Effort |
|---|---------|----------|--------|
| 1 | Add global error handler | P1 | XS |
| 2 | Add `.env.example` | P2 | XS |
| 3 | Enable ESLint | P2 | S |

---

### Suggested Next Steps
1. Run `/full-security-review` for a dedicated security audit (complements this report).
2. Run `/test-writer` on the untested service files.
3. Run `/dependency-audit` to check for CVEs and outdated packages.
4. Schedule a 1-hour "quick wins" session to knock out all XS items.
