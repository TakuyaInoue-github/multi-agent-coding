---
name: code-reading
description: |
  Systematic code reading and comprehension techniques based on cognitive science and expert practices.
  Use this skill when:
  - User needs to understand unfamiliar code or large codebases
  - User asks how to read, analyze, or comprehend code
  - User wants to review or explore existing code structure
  - User mentions "understanding", "exploring", "analyzing" code
  - User is preparing to modify or refactor existing code
  Even if they don't explicitly say "code reading", use this skill when comprehension is the primary goal.
---

# Code Reading: Systematic Comprehension Techniques

**Purpose:** Guide systematic code reading using cognitive science-backed techniques and expert practices.

**Foundation:** This skill integrates research from:
- Hermans (*The Programmer's Brain*) - Cognitive models
- Feathers (*Working Effectively with Legacy Code*) - Legacy code techniques
- Fowler (*Refactoring*) - Comprehension refactoring
- Beck (*Implementation Patterns*, *Tidy First?*) - Communication values and tidyings
- McConnell (*Code Complete*) - Self-documenting code
- Martin (*Clean Code*) - Readability principles
- Spinellis (*Code Reading*) - Pattern recognition
- Recent academic research (2020-2025) - Eye-tracking, chunking, beacons

---

## Quick Diagnostic: Why Is This Code Hard to Read?

Before applying techniques, diagnose the root cause using **Hermans' Three-Cause Framework**:

| Cause | Symptoms | Solution Category |
|-------|----------|-------------------|
| **Knowledge Deficit (LTM)** | Unfamiliar syntax, unknown idioms, foreign domain concepts | Learn first: read docs, study domain, review language features |
| **Information Deficit** | Can't find definitions, unknown call sites, unclear dependencies | Navigate: use IDE tools (go-to-definition, find-usages), cross-reference |
| **Working Memory Overload** | Too many variables, deep nesting, complex state tracking | Externalize: create state tables, diagrams, scratch annotations |

**Action:** Identify which cause applies, then select appropriate techniques below.

---

## Reading Strategy Selection

Choose strategy based on **your knowledge** × **code characteristics**:

### When You Know the Domain (Top-Down)
- **Approach:** Hypothesis → Verification
- **Technique:** Beacon-driven reading (look for familiar patterns)
- **Start with:** Architecture diagrams, module boundaries, high-level function names

### When Domain Is Unfamiliar (Bottom-Up)
- **Approach:** Build understanding from primitives up
- **Technique:** Stepwise abstraction, state tables
- **Start with:** Individual functions, data structures, control flow

### Mixed Knowledge (Opportunistic - Most Common)
- **Approach:** Switch between top-down and bottom-up as clues emerge
- **Technique:** Combine all techniques flexibly
- **Start with:** Entry points, then follow curiosity

---

## Core Reading Techniques

### 1. Structural Reading (First Pass)

**Goal:** Build spatial mental model before diving into details.

**Steps:**
1. **Survey file/directory structure**
   - Notice naming patterns (verb for functions, noun for classes)
   - Identify abstraction layers (utils/, core/, services/)
   - Check for consistency violations (signals potential problems)

2. **Read function/class names before bodies**
   - Function names should reveal **intention** (what/why)
   - Bodies contain **implementation** (how)
   - If name is unclear → mark as "Mysterious Name" smell

3. **Use white space as guide**
   - Blank lines = conceptual boundaries
   - Indentation = scope/ownership hierarchy
   - Tight clusters = related operations

**Cognitive Benefit:** Respects working memory limits by building overview before details.

---

### 2. Beacon-Driven Reading (Pattern Recognition)

**Definition:** Beacons are code elements that signal familiar patterns (variable names, idioms, structures).

**How Experts Use Beacons:**
- **Simple beacons:** Meaningful variable names (`customerCount`), familiar operators (`forEach`)
- **Compound beacons:** Common patterns (guard clauses, builder pattern, singleton)

**Reading Process:**
1. **Identify beacons** while scanning code
2. **Infer plans** from beacons (e.g., `max` variable → "finding maximum" plan)
3. **Predict related code** (max → likely has comparison loop)
4. **Verify predictions** (builds understanding confidence)

**Research Finding:** Expert programmers recall beacons **far more easily** than non-beacon code. Missing beacons = harder comprehension.

---

### 3. Chunking (Working Memory Management)

**Principle:** Working memory holds **5-7 items**. Break code into chunks matching this limit.

**Chunking Strategies:**

**A. Functional Chunking**
- Group related operations together
- Each function should be one "chunk"
- Ideal function size: **< 20 lines** (Uncle Bob), **< 6 lines ideal** (Fowler)

**B. Variable Role Classification**
Classify each variable into one of 11 roles (Sajaniemi):
- **Fixed Value:** Constants (`MAX_SIZE`)
- **Stepper:** Loop counters (`i`, `index`)
- **Gatherer:** Accumulators (`sum`, `result`)
- **Most-Wanted Holder:** Max/min tracking (`bestScore`)
- **Flag:** State indicators (`isValid`, `hasError`)
- **Temporary:** Short-lived intermediates (`temp`)

**Why This Helps:** Knowing a variable's role reduces cognitive load—you instantly understand its purpose.

**C. Visual Chunking**
- Use blank lines to separate logical sections
- Beck's **Cohesion Order** tidying: group related code together
- McConnell's optimal indentation: **4 spaces per level**

---

### 4. The Three Questions (Letovsky's Gap Analysis)

When comprehension stalls, ask which question you can't answer:

| Question | What's Missing | Next Action |
|----------|----------------|-------------|
| **Why?** | Purpose, rationale, business rule | Read domain docs, ask author, check commit messages |
| **How?** | Mechanism, algorithm, execution flow | Trace execution (debugger, state table), diagram control flow |
| **What?** | Actual behavior, side effects | Write characterization test, run code, inspect outputs |

**Technique:** Explicitly name the gap type. "I don't understand **why** this validation happens here" is more actionable than "I'm confused."

---

### 5. Tidy-First Reading (Beck's 15 Signals)

Each "tidying" is both a **reading signal** (what makes code hard) and an **improvement opportunity**.

**Key Signals to Notice:**

| Signal | What It Reveals | Reading Difficulty |
|--------|-----------------|-------------------|
| **Deep Nesting** | Multiple concerns in one function | Hard to follow main logic |
| **Dead Code** | Commented-out code, unused variables | Mental noise, unclear intent |
| **Non-Symmetric Code** | Same logic expressed differently | Forces re-learning same concept |
| **Complex Expressions** | No explaining variables | Hidden sub-intentions |
| **Magic Numbers** | Unexplained constants | Numbers without context |
| **Far Declarations** | Variables declared far from use | Working memory tracking burden |
| **Reading Order Mismatch** | Code order ≠ execution order | Jumpy mental model |

**Reading Workflow:**
1. Notice signal while reading
2. Understand what it's hiding
3. **Mentally apply tidying** (or actually apply it—"Comprehension Refactoring")
4. Gain insight
5. Continue reading with new understanding

**Example:** See complex condition → mentally extract to explaining variable → now you understand sub-conditions.

---

### 6. Intent-Revealing Code (Fowler's Separation)

**Principle:** Distinguish **intention** (what) from **implementation** (how).

**When Reading:**

**Good Code Structure:**
```
function processOrder(order) {        // Intention clear
    validateOrder(order);
    calculateTotal(order);
    applyDiscounts(order);
    submitPayment(order);
}
```
→ **Reading strategy:** Read function names only for high-level understanding. Dive into bodies only if needed.

**Poor Code Structure:**
```
function processOrder(order) {
    if (order.amount < 0 || ...) { throw ... }  // What is this doing?
    let total = 0;
    for (let item of order.items) { ... }       // And this?
    // ... 50 more lines
}
```
→ **Reading strategy:** Must parse all implementation details to understand intention. High cognitive load.

**Reading Technique:**
- **Trust well-named functions** (skip implementation if name is clear)
- **Question function size** (if > 20 lines, likely doing multiple things)
- **Check abstraction level** (all statements in function should be at same level)

---

### 7. Active Reading Techniques

#### A. Scratch Refactoring (Feathers)
**When:** Code is confusing and you have version control.

**Process:**
1. Create new branch
2. Refactor freely to understand (rename, extract, inline)
3. Don't worry about tests (you'll discard changes)
4. Gain understanding
5. **Discard branch** or **commit select improvements** as "Comprehension Refactoring"

**Why Safe:** You're not shipping changes, just exploring structure.

#### B. Characterization Testing (Feathers)
**When:** Need to understand behavior, especially legacy code without tests.

**Process:**
1. Write test that captures **current behavior** (not desired behavior)
2. Make assertion guesses, run test, let failures tell you actual behavior
3. Update assertions to match reality
4. Repeat for different inputs
5. Result: Executable specification of what code **actually does**

**Benefit:** Turns reading into testable hypotheses.

#### C. Inline Annotation
**When:** Reading complex code sections.

**Process:**
1. Add comments explaining your understanding as you read
2. Write in your own words: "This converts X to Y", "This flag indicates Z"
3. Use annotations as thinking scratchpad
4. Delete or refine before committing

**Why Effective:** Forces articulation, reveals gaps in understanding.

---

### 8. Telling the Story (Comprehension Verification)

**Technique:** Explain code out loud (or in writing) as if teaching someone.

**Process:**
1. Start with: "This code does..."
2. Describe flow without looking at implementation
3. **Notice where you can't explain** → those are comprehension gaps
4. Fill gaps (re-read, ask questions, experiment)
5. Repeat until story flows naturally

**Use Cases:**
- Solo: Rubber duck debugging
- Team: Code reading clubs, pair programming
- Review: Explaining changes in PR descriptions

**Research Finding:** Inability to articulate = incomplete understanding (Feathers).

---

## Scenario-Specific Workflows

### Scenario 1: Reading Large Unfamiliar Codebase

| Stage | Technique | Purpose |
|-------|-----------|---------|
| **1. Set Goal** | Decide: Learning (literature) or Solving Problem (exemplar) | Prevents aimless wandering |
| **2. Architecture** | Read docs, README, directory structure | Top-down mental model |
| **3. Entry Points** | Find main(), API endpoints, test files | Understand boundaries |
| **4. Beacon Hunt** | Look for familiar patterns, libraries, idioms | Activate prior knowledge |
| **5. Chunk & Navigate** | Break into 5-7 module groups, use IDE navigation | Manage information overload |
| **6. Deep Dive** | Pick one module, apply techniques 1-7 | Build detailed understanding |

**Spinellis's Wisdom:** "Don't read aimlessly. Ask specific questions: Where does X happen? How is Y implemented?"

---

### Scenario 2: Understanding Complex Function

| Check | Question | Action If Problem |
|-------|----------|-------------------|
| **Name** | Does name reveal intention? | Mentally rename, note "Mysterious Name" |
| **Length** | Is it < 20 lines? | If longer → likely multiple responsibilities |
| **Arguments** | Are there < 3 parameters? | Many parameters → consider parameter object |
| **Abstraction** | Single level of abstraction? | Mixed levels → hard to follow |
| **Nesting** | Deep conditionals? | Apply guard clauses mentally |
| **Variables** | Complex expressions? | Extract explaining variables mentally |
| **Flow** | Can you trace execution? | Create state table |

**Output:** List of code smells found, mental refactoring opportunities.

---

### Scenario 3: Preparing to Modify Code

**Workflow (Beck's "Tidy First?"):**

1. **Read & Understand** (use techniques above)
2. **Write Characterization Tests** (lock in current behavior)
3. **Identify Smells** (what makes change hard?)
4. **Tidy First** (make small structural improvements)
   - Apply guard clauses, extract functions, explaining variables
   - Each tidying should take < 5 minutes
5. **Verify Tests Still Pass** (ensure behavior unchanged)
6. **Now Make Your Change** (in cleaner code)

**Key Insight:** Time spent tidying is repaid immediately through easier modification.

---

## Code Smells as Reading Signals

When reading, these smells indicate comprehension obstacles:

### Naming & Intent
- **Mysterious Name:** Can't infer purpose from name
- **Magic Numbers:** Unexplained constants

### Structure & Size
- **Long Function:** > 20 lines, doing too much
- **Long Parameter List:** > 3 parameters
- **Deep Nesting:** > 3 levels of conditionals

### Duplication & Consistency
- **Duplicated Code:** Same structure in multiple places
- **Non-Symmetric Code:** Similar operations look different

### Dependencies & Coupling
- **Feature Envy:** Function uses another class's data heavily
- **Message Chains:** `a.b().c().d()` — tight coupling
- **Global Data:** Mutable global state

**Reading Strategy:** Treat smells as **comprehension debt**. Each smell increases reading difficulty. Consider tidying as you read.

---

## Research-Backed Best Practices

### From Eye-Tracking Studies (2020-2025)
- **Extract Method reduces comprehension time by 70-79%**
- **Clarified code reduces reading time by 38.6%**
- **Well-named functions reduce gaze jumps** (less WM load)

### From Variable Naming Research
- **snake_case is 13% faster to read** than camelCase
- **Consistency > convention** (either style works if consistent)
- **Optimal name length: 10-16 characters** (McConnell)

### From Chunking Research
- **5-7 items per chunk** matches working memory capacity
- **Dual coding (visual + verbal)** improves comprehension
- **Experts use multi-layer mental models** (architecture + data flow + control flow)

---

## Integration with Other Workflows

### With Refactoring (Fowler)
- **Comprehension Refactoring:** Read → understand → refactor to make understanding explicit → commit
- **Preparatory Refactoring:** Read → identify change difficulty → tidy → then change

### With Legacy Code Work (Feathers)
- **Scratch Refactoring:** Temporary changes for understanding
- **Characterization Tests:** Make behavior explicit before changing
- **Seam Finding:** While reading, identify injection points

### With Code Review
- Apply same techniques to understand PR changes
- "Telling the Story" = writing review comments that explain your understanding
- Suggest tidyings if code is hard to read

---

## Anti-Patterns to Avoid

❌ **Reading without purpose** → Set specific goal before starting
❌ **Reading linearly from top to bottom** → Use navigation (go-to-definition, find-usages)
❌ **Trying to understand everything at once** → Start with high-level, drill down as needed
❌ **Skipping tests** → Tests reveal intended behavior
❌ **Ignoring commit history** → `git blame` explains why code exists
❌ **Reading alone when stuck** → Ask colleagues, use pair reading

---

## Practical Checklist

When approaching unfamiliar code:

**Before Reading:**
- [ ] Set specific goal (what do I need to understand?)
- [ ] Identify knowledge gaps (what domain/language concepts do I need to learn first?)
- [ ] Choose reading mode (literature or exemplar?)

**During Reading:**
- [ ] Notice beacons (familiar patterns)
- [ ] Chunk into 5-7 item groups
- [ ] Mark "mysterious" names and code smells
- [ ] Use IDE navigation (don't read linearly)
- [ ] Externalize complex state (diagrams, tables)
- [ ] Ask Why/How/What when stuck

**After Reading:**
- [ ] Can you "tell the story" of the code?
- [ ] Apply Boy Scout Rule (leave code cleaner than found)
- [ ] Write tests if missing (characterization tests)
- [ ] Document non-obvious insights (commit messages, comments)

---

## Advanced: Team Code Reading Practices

### Code Reading Club (Hermans)
**Structure (60 min):**
1. **First Glance (5 min):** Silent reading, share first impressions
2. **Beacon Hunting (10 min):** Identify and discuss hand-holds
3. **Why/How/What (10 min):** List comprehension gaps
4. **Hands-On (20 min):** Scratch refactoring or state table exercise
5. **Story Telling (10 min):** Each person explains in own words
6. **Reflection (5 min):** What did we learn?

**Key Principle:** No judgment, focus on understanding (not critiquing author).

---

## References for Deep Dive

For detailed techniques and theory, see:
- `references/cognitive_models.md` - Hermans' cognitive science framework
- `references/expert_practices.md` - Beck, Fowler, Martin techniques
- `references/research_findings.md` - Academic studies 2020-2025

---

## Summary: The Code Reading Loop

```
┌─ Encounter Code
│
├─ Diagnose: Knowledge / Information / WM issue?
│
├─ Select Strategy: Top-down / Bottom-up / Opportunistic
│
├─ Apply Techniques:
│  ├─ Structural reading (overview)
│  ├─ Beacon hunting (patterns)
│  ├─ Chunking (manage WM)
│  ├─ Three questions (fill gaps)
│  ├─ Tidying signals (spot obstacles)
│  └─ Active reading (refactor/test/annotate)
│
├─ Verify: Can you tell the story?
│
└─ Embed Understanding:
   ├─ Comprehension refactoring (improve code)
   ├─ Tests (lock in behavior)
   └─ Documentation (explain non-obvious)
```

**Core Philosophy:** Code reading is not passive—it's an active learning process that improves both your understanding AND the code itself.
