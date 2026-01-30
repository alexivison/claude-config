# Plan Review Reference

Detailed checklists and quality criteria for reviewing planning documents.

---

## Document Checklists

### SPEC.md

**Required sections:**
- [ ] **Goal/Objective** - One sentence describing what this achieves
- [ ] **User Stories / Requirements** - What users need to accomplish
- [ ] **Acceptance Criteria** - Measurable, verifiable conditions
- [ ] **Out of Scope** - What this explicitly does NOT cover

**Quality checks:**
- [ ] Acceptance criteria are testable (not vague like "should be fast")
- [ ] No implementation details (that belongs in DESIGN.md)
- [ ] Clear success metrics or exit conditions
- [ ] Each requirement has at least one acceptance criterion
- [ ] Requirements are prioritized (must-have vs nice-to-have)

**Common issues:**
| Issue | Severity | Example |
|-------|----------|---------|
| Missing acceptance criteria | `[must]` | "Support user login" without success conditions |
| Vague requirements | `[must]` | "System should be performant" |
| Implementation in spec | `[nit]` | "Use Redis for caching" in SPEC |
| Scope creep | `[q]` | Unrelated features bundled together |

---

### DESIGN.md

**Required sections:**
- [ ] **Architecture Overview** - High-level approach (2-3 paragraphs)
- [ ] **Key Components** - Major modules/services involved
- [ ] **Data Flow** - How data moves through the system
- [ ] **API/Interface Design** - Public interfaces if applicable
- [ ] **File Structure** - What files will be created/modified

**Quality checks:**
- [ ] References SPEC.md for requirements traceability
- [ ] Patterns match existing codebase conventions
- [ ] Dependencies identified and reasonable
- [ ] No over-engineering (matches scope of SPEC)
- [ ] Error handling strategy defined
- [ ] Security considerations addressed (if applicable)

**Common issues:**
| Issue | Severity | Example |
|-------|----------|---------|
| No SPEC reference | `[must]` | Design without requirements traceability |
| Pattern mismatch | `[must]` | Using Redux in a Zustand codebase |
| Missing data flow | `[must]` | Components without clear data sources |
| Over-engineering | `[q]` | Microservices for a simple feature |

---

### PLAN.md

**Required header:**
```markdown
# <Feature Name> Implementation Plan

> **Goal:** [One sentence — what this achieves]
>
> **Architecture:** [2-3 sentences — key technical approach]
>
> **Tech Stack:** [Relevant technologies]
>
> **Specification:** [SPEC.md](./SPEC.md) | **Design:** [DESIGN.md](./DESIGN.md)
```

**Required sections:**
- [ ] **Plan Header** - As specified above
- [ ] **Task List** - Links to TASK*.md files with status checkboxes
- [ ] **Dependencies** - Order and blockers between tasks
- [ ] **Critical Path** - Which tasks block others

**Quality checks:**
- [ ] Each task has clear deliverable
- [ ] No circular dependencies
- [ ] Critical path identified
- [ ] Tasks are ordered logically (dependencies first)
- [ ] Total scope matches SPEC (no missing/extra work)

**Common issues:**
| Issue | Severity | Example |
|-------|----------|---------|
| Missing header | `[must]` | No goal/architecture summary |
| Circular deps | `[must]` | TASK1 needs TASK2, TASK2 needs TASK1 |
| Missing tasks | `[must]` | SPEC requirement not covered by any task |
| Unclear order | `[q]` | No dependency information |

---

### TASK*.md

**Required sections:**
- [ ] **Issue** - Link to issue tracker or descriptive slug
- [ ] **Goal** - What this specific task accomplishes
- [ ] **Required Context** - Files to read first
- [ ] **Files to Modify** - Exact paths with actions
- [ ] **Steps** - Checkbox list of implementation steps
- [ ] **Verification** - Commands to run for validation
- [ ] **Acceptance Criteria** - How to know task is complete

**Quality checks:**
- [ ] Steps are atomic (one action per checkbox)
- [ ] No implicit assumptions about previous tasks
- [ ] Verification commands are runnable
- [ ] ~200 lines implementation code (tests excluded)
- [ ] Touches <= 5 files (or split the task)
- [ ] All file paths are absolute or project-relative
- [ ] Test requirements included in same task

**Common issues:**
| Issue | Severity | Example |
|-------|----------|---------|
| Missing verification | `[must]` | No way to confirm completion |
| Too large | `[must]` | 500+ lines, 10+ files |
| Implicit deps | `[must]` | "Assumes auth is set up" without listing |
| Vague steps | `[q]` | "Implement the feature" |
| Missing context | `[nit]` | No files listed to read first |

---

## Quality Criteria

### Measurability

Every requirement must have verifiable acceptance criteria:

| Bad | Good |
|-----|------|
| "System should be responsive" | "API response time < 200ms p95" |
| "Easy to use" | "User can complete checkout in < 3 clicks" |
| "Secure" | "All inputs sanitized, auth required for /api/*" |

### No Circular Dependencies

Tasks cannot depend on each other cyclically:

```
# Bad: Circular
TASK1 (auth) → needs TASK2 (user model)
TASK2 (user model) → needs TASK1 (auth)

# Good: Linear
TASK1 (user model) → foundation
TASK2 (auth) → depends on TASK1
```

### Agent-Executability

Each TASK*.md must be independently executable by an agent:

| Requirement | Why |
|-------------|-----|
| All file paths explicit | Agent can't guess locations |
| Context files listed | Agent doesn't remember previous tasks |
| Verification commands provided | Agent needs to confirm completion |
| No "see previous task" | Each task is standalone |

### Appropriate Scope

| Document | Contains | Does NOT Contain |
|----------|----------|------------------|
| SPEC.md | Requirements, user stories | Implementation code |
| DESIGN.md | Architecture, patterns | Detailed code examples |
| PLAN.md | Task order, dependencies | Implementation details |
| TASK*.md | Implementation guidance | Consumer integration examples |

---

## Review Labels

| Label | Meaning | Blocks Approval |
|-------|---------|-----------------|
| `[must]` | Missing sections, circular deps, ambiguous reqs | Yes |
| `[q]` | Questions needing clarification | Yes (until answered) |
| `[nit]` | Minor improvements, formatting | No |

---

## Verdict Criteria

| Verdict | Condition |
|---------|-----------|
| **APPROVE** | No `[must]` issues, all required sections present, tasks are agent-executable |
| **REQUEST_CHANGES** | Has `[must]` issues that can be fixed by updating documents |
| **NEEDS_DISCUSSION** | Ambiguous requirements, conflicting constraints, fundamental scope concerns |
