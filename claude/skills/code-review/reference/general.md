# Code Review Reference

Rules for reviewing code changes. Use `[must]`, `[q]`, `[nit]` labels.

---

## MANDATORY: Test Coverage Verification

**Before ANY verdict**, you MUST check test coverage:

1. **List new code files** — components, functions, hooks, utilities added
2. **List corresponding test files** — `.spec.ts`, `.test.ts`, `_test.go`, etc.
3. **Verify coverage**:
   - New component → needs component test
   - New function → needs unit test
   - New hook → needs test via component or dedicated hook test
   - Bug fix → needs regression test

**If new code has no tests:**
```
[must] Tests missing for new code: {file.tsx}
```

This is an automatic `[must]` that BLOCKS approval. No exceptions.

**Include in output:**
```
### Test Coverage
- New code: LegalonAssistantForCaseDetail.tsx
- Tests: ✗ None found
- Verdict impact: [must] Tests missing → REQUEST_CHANGES
```

---

## Severity Labels

| Label | Meaning | Blocks |
|-------|---------|--------|
| `[must]` | Bugs, security, maintainability violations | Yes |
| `[q]` | Needs clarification or justification | Yes (until answered) |
| `[nit]` | Style, minor suggestions | No |

---

## Maintainability Thresholds

### Blocking `[must]`

| Issue | Threshold |
|-------|-----------|
| Function length | >50 lines |
| Nesting depth | >4 levels |
| Parameters | >5 |
| Duplicate code | >10 lines repeated |

### Warning `[q]`

| Issue | Threshold |
|-------|-----------|
| Function length | >30 lines |
| Nesting depth | >3 levels |
| Parameters | >4 |

### Complexity Delta Rule

Any change that **degrades** maintainability is `[must]`:
- Readable function becomes hard to follow
- Nesting increases significantly
- New code smell introduced

Regressions block even if absolute values are acceptable.

---

## Quality Checklist

| Check | Severity if violated |
|-------|---------------------|
| Naming: unclear or misleading | `[q]` |
| Naming: single letters (except loop index) | `[q]` |
| Tests missing for new code | `[must]` |
| Tests missing for bug fix | `[must]` |
| Comments: outdated or misleading | `[must]` |
| Comments: missing on non-obvious logic | `[q]` |
| YAGNI: unnecessary features/complexity | `[q]` |
| Style guide violation | `[nit]` |

---

## Feature Flags

| Check | Severity |
|-------|----------|
| Flag OFF breaks existing behavior | `[must]` |
| Only one path tested | `[must]` |
| Dead code after rollout | `[q]` |

---

## Verdicts

| Verdict | Condition |
|---------|-----------|
| **APPROVE** | No `[must]`, no unanswered `[q]`, AND tests exist for new code |
| **REQUEST_CHANGES** | Has `[must]` OR unanswered `[q]` OR missing tests |
| **NEEDS_DISCUSSION** | Architectural concerns, unclear requirements |

**Remember:** Missing tests for new code = automatic `[must]` = cannot APPROVE.
