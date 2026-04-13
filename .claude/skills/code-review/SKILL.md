---
name: code-review
description: |
  Systematic code review and pull request feedback based on industry best practices and research.
  Use this skill when:
  - User is reviewing a pull request, merge request, or code changes
  - User asks how to give feedback, write review comments, or evaluate code
  - User mentions "code review", "PR review", "reviewing", "pull request", "feedback"
  - User needs help deciding whether to approve, request changes, or comment
  - User wants to improve review process, review quality, or review culture
  - User asks about review checklists, what to look for, or review best practices
  Even if they don't explicitly say "code review", use this skill when the goal is evaluating and providing constructive feedback on proposed code changes.
---

# Code Review: Decision-Making and Constructive Feedback

**Purpose:** Guide effective code review using evidence-based practices and constructive communication.

**Key Distinction:**
- **Code Reading** = Comprehension (understanding existing code)
- **Code Review** = Decision-Making (evaluating changes + providing feedback)

**Cross-Reference:** For comprehension techniques, see `code-reading` skill.

**Foundation:** Google Engineering Practices, Microsoft Research (1.5M comments), SmartBear evidence (200-400 LOC optimal), Kent Beck (Tidy First?), recent academic research (2020-2025).

---

## Quick Decision Framework

| Decision | When | Signal |
|----------|------|--------|
| **Approve** | Change improves code health | Net positive, even if not perfect |
| **Request Changes** | Blocking issues must be fixed | Code would degrade |
| **Comment** | Non-blocking feedback | Worth discussing, not blocking |

**Google's Standard:** Approve if PR **improves overall code health**, even if not perfect.

**Principle:** Progress > Perfection

---

## The Review Mindset

### Kent Beck's Five Effects

Choose what to optimize for based on team context:

| Effect | Focus |
|--------|-------|
| **Reduce Behavioral Errors** | Functionality, edge cases, error handling |
| **Reduce Structural Errors** | Architecture, coupling, complexity |
| **Improve Team Understanding** | Knowledge sharing |
| **Accelerate Learning** | Patterns, best practices |
| **Reduce Team Risk** | Readability, maintainability |

---

## Two-Phase Review Process

### Phase 1: Orientation (Context)

**Goal:** Understand WHAT and WHY

1. Read PR description and linked issue
2. Check PR size (< 200 ideal, 200-400 okay, > 400 ask to split)
3. Review commit history
4. Identify scope

**Research:** Large PRs get proportionally less feedback (Microsoft).

### Phase 2: Analytical (Inspection)

**Goal:** Evaluate HOW well implemented

**Cognitive Model:** Compare expected vs. proposed implementation.

1. Review in importance order (core → tests → peripheral)
2. Check Google's 8 dimensions (below)
3. Formulate feedback (specific, actionable, constructive)
4. Decide (approve / request changes / comment)

---

## What to Look For: Google's 8 Dimensions

### 1. Design (Highest Priority)

**Questions:**
- Integrates well with existing system?
- Right place for this change?
- Complexity justified?

**Red Flags:** God classes, tight coupling, overengineering (YAGNI violations)

### 2. Functionality

**Questions:**
- Does what author intended?
- Works for end users?
- Edge cases handled?

**Technique:** Think like a user. Check edge cases (null, empty, large, negative).

**Research:** Formal reviews catch **60-65% of defects** vs. testing's 30%.

### 3. Complexity

**Questions:**
- Can others understand quickly?
- Simpler without losing functionality?

**Guidelines:**
- Functions: < 20 lines ideal
- Nesting: < 3 levels
- Abstraction: Consistent levels

**Action:** If confuses you → request simplification

### 4. Tests

**Checklist:**
- [ ] Tests exist for new code
- [ ] Cover edge cases, not just happy path
- [ ] Names explain WHAT is tested
- [ ] Readable (AAA: Arrange, Act, Assert)
- [ ] No flaky tests

### 5. Naming

**Uncle Bob's 3 Questions:**
1. Why does it exist?
2. What does it do?
3. How is it used?

If name doesn't answer all three → suggest improvement.

### 6. Comments

**Good:** Explain WHY (non-obvious decisions, consequences, constraints)
**Bad:** Restate WHAT code does, outdated, apologetic

**Research (2026):** Accurate comments improve AI bug-fixing by 41%.

### 7. Style

**Rule:** Don't block on style. Automate with formatters.

**Exception:** Comment only if violates readability (not preference).

### 8. Documentation

**Check:** README, API docs, migration guides updated for changes.

---

## Review Size & Speed: Evidence-Based

### Optimal Parameters (SmartBear)

| Metric | Optimal |
|--------|---------|
| **LOC per review** | 200-400 |
| **Review speed** | < 500 LOC/hour |
| **Duration** | < 60 min/session |
| **Turnaround** | < 24 hours |

**Large PR (> 400 LOC)?**
- Ask to split, OR
- Review in focused sessions (design → logic → tests)

### Kent Beck's Flow Principle

**Vicious Cycle:** Large PRs → Delays → More changes → Larger PRs
**Virtuous Cycle:** Fast reviews → Small PRs → Quick feedback

**Action:** Prioritize review speed.

---

## Giving Constructive Feedback

### Conventional Comments

Prefix feedback for clarity:

| Prefix | Meaning | Example |
|--------|---------|---------|
| **praise:** | Highlight good | `praise: Nice use of early returns` |
| **question:** | Seek clarification | `question: Why 1 hour cache vs 5 min?` |
| **suggestion:** | Non-blocking | `suggestion: Extract to helper function` |
| **issue:** | Blocking | `issue: Doesn't handle null user` |
| **nitpick:** | Minor | `nitpick: More descriptive variable name` |

### Ask, Don't Demand

**Demanding:**
> "Use a Set instead of array."

**Asking:**
> "question: Would Set be more efficient for membership checks?"

**Why:** Opens dialogue, reduces defensiveness.

### Be Specific and Actionable

**Vague:** "This is hard to read."

**Specific:**
> "suggestion: Extract validation logic (lines 45-62) into `validateOrder()`. Separates concerns."

**Pattern:** [Observation] + [Action] + [Benefit]

### Use I-Messages

**You-Message (Blaming):**
> "You didn't handle errors."

**I-Message (Observing):**
> "I'm concerned this might crash on API 500 error. Add error handling?"

### Balance Positive and Constructive

**Research:** Starting with positive activates reward centers → more receptive.

**Pattern:**
```
praise: Nice refactoring, cleaner than before.
question: How does this handle timeout?
suggestion: Add test for error path.
```

**Warning:** Don't fake praise.

---

## Review Scenarios: Quick Workflows

### Small PR (< 200 LOC)

**Time:** 10-20 min

1. Read description (2 min)
2. Review files in priority order (10 min)
3. Check obvious issues (5 min)
4. Provide feedback (3 min)
5. Decide

### Large PR (> 400 LOC)

1. Ask to split
2. If can't: Request overview, review in sessions, focus per dimension

### Junior Reviewer

1. Use code-reading techniques
2. Ask questions: `question: Why this approach?`
3. Flag confusion: `This variable name doesn't convey purpose to me.`
4. Acknowledge learning: "I'll defer to others on design."

**Your Value:** Fresh eyes catch hidden assumptions.

### Bug Fix

**Checklist:**
- [ ] Fixes root cause, not symptom
- [ ] Test reproduces original bug
- [ ] Test passes with fix, fails without
- [ ] Similar bugs checked elsewhere

### Refactoring

**If Pure:** Tests pass without modification?
**If Mixed:** Request split (refactor → then feature)

**Check:** Worth the churn?

### AI-Generated Code

**Extra Checks:**
- Verify logic (don't assume AI correct)
- Security issues
- Test quality (AI tests often shallow)
- Project consistency

**Research (2024):** AI review tools have 10-30% false positives.

---

## Team Dynamics

### Psychological Safety

**Why:** Teams with high safety have better quality, faster learning, higher participation.

**How to Build:**

| Practice | Example |
|----------|---------|
| **Model vulnerability** | "I don't understand. Explain?" |
| **Praise publicly** | Good code in team chat |
| **Welcome questions** | "Great question!" not "Obvious..." |
| **Admit mistakes** | "You're right, I was wrong" |

### Handling Disagreements

**Ineffective:** "I have more experience. Do it my way."

**Effective:** "I see your point. Explain your reasoning? I might miss context."

**Resolution:**
1. Author convinces you → Withdraw
2. You convince author → Change
3. No consensus → Escalate (async, pair, or lead)

**Principle:** No one owns right answer. Dialogue finds best solution.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Solution |
|--------------|----------|
| **Incremental Nitpicking** | Review comprehensively first time |
| **Rubber Stamping** | If no time/context, defer explicitly |
| **Scope Creep** | File separate issue for future work |
| **Aggressive Tone** | Review code, not person. I-messages |
| **Style Nitpicking** | Automate with formatters |
| **Review Ghosting** | If can't review < 24h, remove yourself |
| **Perfectionism** | Separate blocking (issue:) from non-blocking (suggestion:) |

---

## Automation: Machine vs Human

### Automate (Don't Waste Human Time)

| Category | Tools |
|----------|-------|
| **Formatting** | Prettier, Black, gofmt |
| **Linting** | ESLint, Ruff, Clippy |
| **Security** | Snyk, CodeQL, Bandit |
| **Type Safety** | TypeScript, mypy |
| **Coverage** | Istanbul, Coverage.py |

**Setup CI to block on failures.**

### Keep for Humans

- Design decisions (business context, trade-offs)
- Intent and clarity
- Architectural fit
- Domain correctness

**Principle:** Automate objective checks. Humans for judgment.

---

## Metrics

### Track These

| Metric | Target |
|--------|--------|
| **Turnaround Time** | < 24 hours |
| **PR Size** | 200-400 LOC median |
| **Escaped Defects** | Bugs in prod that passed review |
| **Review Participation** | % of team reviewing |

### Don't Track

- LOC/hour (encourages speed > quality)
- Comment count (encourages nitpicking)
- Individual review counts (creates competition)

**Principle:** Measure **outcomes**, not **activities**.

---

## Integration with Code Reading

### When to Use Which

| Situation | Use |
|-----------|-----|
| Reviewing PR | **code-review** + code-reading (context) |
| Understanding code | code-reading |
| Deciding to approve | **code-review** |
| Giving feedback | **code-review** |
| Suggesting refactorings | code-reading (catalog) |

### Workflow

```
1. Read PR description (code-review)
2. Understand context (code-reading)
3. Review changes (code-review)
4. Provide feedback (code-review communication)
5. Suggest refactorings (code-reading catalog)
```

---

## Quick Checklist

Before approving:

- [ ] Code does what it claims
- [ ] Edge cases handled
- [ ] Tests exist and meaningful
- [ ] Names reveal intent
- [ ] Functions < 20 lines
- [ ] No duplicated code
- [ ] Comments explain "why"
- [ ] Automated checks pass
- [ ] Documentation updated
- [ ] **Overall code health improves** ✓

**Decision:**
- Improves health → **Approve**
- Degrades health → **Request Changes**
- Uncertain or suggestions → **Comment**

---

## Key Takeaways

1. **Approve if code health improves** (not perfect)
2. **Small PRs reviewed quickly** > large PRs slow
3. **Ask questions** instead of demanding
4. **Focus on high-impact** (design, functionality)
5. **Automate style**, humans for judgment
6. **Build psychological safety**
7. **Review code, not person**
8. **Use conventional comments**
9. **Balance positive and constructive**
10. **Speed matters** (< 24h turnaround)

---

## References

For detailed techniques and research:
- `references/review_philosophy.md` - Beck, Google, Microsoft
- `references/review_scenarios.md` - Detailed workflows
- `references/review_communication.md` - Feedback patterns, safety
- `references/review_research.md` - Academic studies 2020-2025

---

## Summary

```
Review Request
  ↓
Orientation (PR description, size, context)
  ↓
Analytical (8 dimensions, priority order)
  ↓
Feedback (conventional comments, specific, I-messages)
  ↓
Decision (approve if improves health)
```

**Philosophy:** Code review is **collaborative decision-making** balancing quality, velocity, learning, and team culture. Goal: continuous improvement, not perfection.
