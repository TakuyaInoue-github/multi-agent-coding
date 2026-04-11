# Code Review Skill References

This directory contains detailed reference materials for the code-review skill.

---

## Main Research Report

**Location:** `../../../reference/code_review_research_report.md` (2732 lines)

This comprehensive report synthesizes research from:
- Kent Beck (Tidy First?, Thinking About Code Review)
- Google Engineering Practices
- Microsoft Research (1.5M comment analysis)
- SmartBear (Evidence-based best practices)
- Atlassian, GitHub, ThoughtWorks
- Recent academic research (2020-2025)

**Contents:**
1. Kent Beck's Philosophy
2. Google's Engineering Practices (8 dimensions)
3. Microsoft Research: What Makes Reviews Useful
4. SmartBear's Evidence (200-400 LOC optimal, < 500 LOC/hour, < 60 min session)
5. Industry Best Practices
6. Cognitive Models (Code Review Comprehension Model, Code Review as Decision-Making)
7. Code Review vs Code Reading distinctions
8. Psychological Safety and Team Dynamics
9. Constructive Feedback Techniques (Conventional Comments)
10. Anti-Patterns
11. Metrics and Effectiveness
12. Automated Review and AI Integration
13. Review Patterns and Checklists
14. Recent Research (2020-2025)
15. Design Recommendations for Skills
16. Comprehensive References (industry + academic)

---

## Quick Reference Guides

### Google's 8 Review Dimensions

1. **Design** - Integration, architecture, complexity justification
2. **Functionality** - Correctness, edge cases, user impact
3. **Complexity** - Understandability, simplification opportunities
4. **Tests** - Coverage, quality, maintainability
5. **Naming** - Intent-revealing, consistency
6. **Comments** - WHY not WHAT, accuracy
7. **Style** - Automated formatting (don't block on this)
8. **Documentation** - README, API docs, migration guides

### SmartBear's Evidence-Based Metrics

| Metric | Optimal Range |
|--------|---------------|
| LOC per review | 200-400 lines |
| Review speed | < 500 LOC/hour |
| Session duration | < 60 minutes |
| Turnaround time | < 24 hours |
| Defect detection | Formal review: 60-65%, Testing: 30% |

### Kent Beck's Five Effects

1. **Reduce Behavioral Errors** - Catch bugs
2. **Reduce Structural Errors** - Catch design problems
3. **Improve Team Understanding** - Knowledge transfer
4. **Accelerate Learning** - Teach patterns
5. **Reduce Team Risk** - Multiple people can work anywhere

### Conventional Comments Pattern

```
praise: [Highlight what's good]
question: [Seek clarification, not demanding]
suggestion: [Non-blocking improvement idea]
issue: [Blocking problem that must be fixed]
nitpick: [Minor, non-blocking style point]
thought: [General observation or idea]
```

---

## Key Research Findings

### Microsoft (2018): 1.5 Million Comments Analysis

- **Larger PRs get proportionally less feedback**
- Benefits beyond defect detection: knowledge transfer, team awareness, learning
- Useful feedback characteristics: Actionable, specific, polite, timely

### SmartBear (2010): Cisco Case Study

- **200-400 LOC per review = optimal effectiveness**
- > 500 LOC/hour → defect detection drops
- > 60 min session → fatigue degrades quality
- Formal review catches 60-65% of defects vs. testing's 30%

### Academic Research (2025): Cognitive Models

- **Code Review ≠ Code Reading**
- Review is decision-making process, not just comprehension
- Two phases: Orientation (context building) → Analytical (code inspection)
- Requires comparing expected vs. proposed implementations

### Psychological Safety Research (2024)

- Teams with high psychological safety have **better code quality**
- Starting with positive feedback activates reward centers → more receptive
- I-messages reduce defensiveness vs. you-messages

---

## Anti-Patterns Summary

| Anti-Pattern | Impact | Solution |
|--------------|--------|----------|
| **Incremental Nitpicking** | Never approves, keeps adding comments | Review comprehensively first time |
| **Rubber Stamping** | Instant approval without review | Defer if no time/context |
| **Scope Creep** | "While you're here..." | File separate issues |
| **Aggressive Tone** | Destroys psychological safety | I-messages, review code not person |
| **Style Nitpicking** | Wastes time on formatting | Automate with formatters |
| **Review Ghosting** | Blocks progress | Remove self if can't review < 24h |
| **Perfectionism** | Blocks on minor issues | Approve if code health improves |

---

## Communication Patterns

### Ask Questions, Don't Demand

**Demanding (Ineffective):**
> "This is wrong. Use a Set instead."

**Asking (Effective):**
> "question: Would a Set be more efficient here for membership checks?"

### Be Specific and Actionable

**Vague (Unhelpful):**
> "This is confusing."

**Specific (Helpful):**
> "suggestion: Extract the validation logic (lines 45-62) into `validateOrder()`. This would separate the validation concern from the business logic."

### Use I-Messages

**You-Message (Blaming):**
> "You didn't handle errors properly."

**I-Message (Observing):**
> "I'm concerned this might crash if the API returns a 500 error. Could we add error handling?"

---

## Automation Guidelines

### Automate These (Machines)

- **Formatting:** prettier, black, gofmt, rustfmt
- **Linting:** ESLint, Ruff, golangci-lint, Clippy
- **Security:** Snyk, CodeQL, Bandit, gosec
- **Type Safety:** TypeScript, mypy, Flow
- **Test Coverage:** Istanbul, Coverage.py, JaCoCo
- **Complexity:** SonarQube, Code Climate

**CI should block PRs that fail these checks.**

### Keep for Humans

- **Design decisions** - Requires business context understanding
- **Intent and clarity** - Is code understandable?
- **Architectural fit** - Does this integrate well with system?
- **Trade-off evaluation** - Is added complexity worth benefit?
- **Domain correctness** - Implements business logic correctly?

---

## Review Workflow Integration

### Integration with Code Reading Skill

```
PR Received
  ↓
[code-review] Read PR description
  ↓
[code-reading] Understand existing codebase context
  ↓
[code-review] Review proposed changes (8 dimensions)
  ↓
[code-review] Provide feedback (conventional comments)
  ↓
[code-reading] Suggest refactorings (if applicable)
  ↓
[code-review] Make decision (approve/request changes/comment)
```

### When to Use Which Skill

| Task | Use Code Review | Use Code Reading |
|------|----------------|------------------|
| Reviewing a PR | ✓ Primary | Supporting (for context) |
| Understanding existing code | — | ✓ Primary |
| Evaluating proposed changes | ✓ Primary | — |
| Giving feedback on code | ✓ Primary | — |
| Suggesting refactorings | — | ✓ Primary |
| Deciding to approve/reject | ✓ Primary | — |

---

## Team Retrospective Questions

Use these periodically to improve review process:

1. **Speed:** Are reviews happening < 24 hours?
2. **Size:** Are most PRs < 400 LOC?
3. **Safety:** Do people feel comfortable giving critical feedback?
4. **Quality:** Are we catching defects in review (vs. prod)?
5. **Learning:** Are reviews teaching or just policing?
6. **Improvement:** What's one thing we could improve in review process?

---

## Additional Resources

### Industry Guides

- [Google Engineering Practices](https://google.github.io/eng-practices/)
- [Kent Beck - Thinking About Code Review](https://tidyfirst.substack.com/p/thinking-about-code-review)
- [Microsoft Research - Characteristics of Useful Code Reviews](https://www.microsoft.com/en-us/research/publication/characteristics-of-useful-code-reviews-an-empirical-study-at-microsoft/)
- [SmartBear - Best Practices for Peer Code Review](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)

### Academic Papers (2020-2025)

- [Code Review Comprehension Model (2025)](https://arxiv.org/abs/2503.21455)
- [Code Review as Decision-Making (2025)](https://arxiv.org/abs/2507.09637)
- [Psychological Safety in Software Workplaces (2024)](https://arxiv.org/html/2508.03369)
- [Automated Code Review In Practice (2024)](https://arxiv.org/abs/2412.18531)

---

## For Deeper Understanding

Consult the main research report (`reference/code_review_research_report.md`) for:
- Detailed cognitive models
- Comprehensive anti-pattern descriptions
- Full metrics frameworks
- Extended communication techniques
- AI-assisted review research
- Eye-tracking studies
- Complete reference bibliography (40+ sources)
