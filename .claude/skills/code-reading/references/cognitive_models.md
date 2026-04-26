# Cognitive Models of Program Comprehension

**Source:** Hermans' *The Programmer's Brain* and academic research (1977-2025)

This document details the cognitive science foundation of code reading techniques.

---

## Table of Contents

1. [Mental Models Framework](#mental-models-framework)
2. [The Three Memory Systems](#the-three-memory-systems)
3. [Reading Comprehension Models](#reading-comprehension-models)
4. [Chunking and Beacons](#chunking-and-beacons)
5. [Cognitive Dimensions of Codebases](#cognitive-dimensions-of-codebases)

---

## Mental Models Framework

### von Mayrhauser & Vans Integrated Metamodel

The current standard framework for program comprehension shows programmers operate across 3 mental model levels:

| Model Level | Focus | Example |
|-------------|-------|---------|
| **Top-Down (Domain Model)** | Business concepts, requirements | "This processes customer orders" |
| **Situation Model** | Problem-solution mapping | "This validates orders before payment" |
| **Program Model** | Code structures, control flow | "This loop iterates over order items" |

**Key Insight:** Experts **fluidly switch** between levels (opportunistic strategy). Novices get stuck at program model level.

### Mental Model Components

| Component | Type | Description |
|-----------|------|-------------|
| **Text Structure** | Static | Control flow, variables, call hierarchy |
| **Chunks** | Static | Grouped meaningful units (5-7 statements) |
| **Plans** | Static | Stereotypical action sequences (e.g., "find max") |
| **Hypotheses** | Static | Conjectures about intent |
| **Chunking** | Dynamic | Bottom-up grouping process |
| **Cross-Referencing** | Dynamic | Connecting control flow ↔ data flow ↔ domain |
| **Beacons** | Support | Surface cues signaling patterns |
| **Rules of Discourse** | Support | Conventions (e.g., `i` for loop counter) |

---

## The Three Memory Systems

### Hermans' Framework for Code Confusion

| Memory System | Capacity | Duration | Code Reading Role |
|---------------|----------|----------|-------------------|
| **Short-Term Memory (STM)** | 2-6 items | Seconds | Hold code tokens while parsing syntax |
| **Working Memory (WM)** | 2-6 chunks | Minutes | Process relationships, maintain context |
| **Long-Term Memory (LTM)** | Unlimited | Years | Store patterns, domain knowledge, language syntax |

### Confusion Diagnosis

| Confusion Type | Root Cause | Symptoms | Solution |
|----------------|------------|----------|----------|
| **Knowledge Deficit** | Missing LTM schemas | "What does `async/await` mean?" | Learn concept before reading code |
| **Information Deficit** | Can't access needed info | "Where is this function called?" | Use IDE navigation, grep |
| **Processing Overload** | WM capacity exceeded | "Too many variables to track" | Externalize (diagrams, tables) |

**Critical Distinction:** These have DIFFERENT solutions. Misdiagnosing wastes time.

---

## Reading Comprehension Models

### Brooks' Top-Down Model (1983)

**Process:**
1. Form hypothesis about code purpose (from domain knowledge)
2. Decompose into sub-hypotheses
3. Match hypotheses to code fragments
4. Verify or revise hypotheses

**When Effective:** Expert + familiar domain
**Limitation:** Fails when domain knowledge is wrong or incomplete

### Pennington's Bottom-Up Model (1987)

**Process:**
1. Build **program model** (read code line-by-line, trace control flow)
2. Perform **cross-referencing** (connect data flow to control flow)
3. Form **domain model** (infer business purpose from program structure)

**When Effective:** Novice or unfamiliar domain
**Limitation:** Slow for large codebases

**Key Finding:** Program model MUST precede domain model. You can't skip to "what it means" without first understanding "what it does."

### Letovsky's Opportunistic Model (1986)

**Assimilation Process:**

Programmers maintain a knowledge base and mental model, filling gaps through three types of conjectures:

| Conjecture Type | Question | Example |
|-----------------|----------|---------|
| **Why** | Why does this code exist? | "Why validate email twice?" |
| **How** | How does this mechanism work? | "How does this cache synchronize?" |
| **What** | What does this actually do? | "What does this regex match?" |

**Strategy:** Jump between top-down and bottom-up opportunistically based on available cues.

### Littman's Systematic vs. As-Needed (1986)

| Strategy | Approach | Pros | Cons |
|----------|----------|------|------|
| **Systematic** | Read entire codebase before changing | Catches delocalized plans | Doesn't scale to large systems |
| **As-Needed** | Read only what's needed for change | Fast for small changes | Miss non-local dependencies → bugs |

**Delocalized Plans:** Logic split across non-contiguous code (e.g., initialization in constructor, validation in setter, cleanup in destructor). As-needed readers often miss these interactions.

---

## Chunking and Beacons

### Chunking Theory (Miller 1956, Modern Updates)

**Working Memory Limit:** 2-6 chunks (modern research revised Miller's "7±2" downward)

**Chunk Formation:**
- **Novices:** Individual tokens (keywords, operators) are chunks
- **Experts:** Entire patterns (idioms, design patterns) are chunks

**Example:**
```javascript
for (let i = 0; i < arr.length; i++) {
    if (arr[i] > max) max = arr[i];
}
```

- **Novice chunks:** `for`, `let`, `i`, `0`, `<`, `arr.length` (6+ chunks, WM overload)
- **Expert chunks:** "find max in array" (1 chunk, plenty of WM left)

### Beacon Theory (Soloway & Ehrlich 1984)

**Definition:** Code features that suggest the presence of certain structures or operations.

**Beacon Types:**

| Type | Examples | What They Signal |
|------|----------|------------------|
| **Simple Beacons** | Variable names (`total`, `count`), operators (`+=`), keywords (`break`) | Elementary operations |
| **Compound Beacons** | Guard clause pattern, builder pattern, visitor pattern | Complex structures |

**Expert Advantage:**
- **Attention:** Experts focus on beacons; novices focus uniformly
- **Recall:** Experts recall beacon code far better than non-beacon code
- **Speed:** Beacons enable rapid plan recognition

**Reading Implication:** Poor variable names eliminate beacons → force novice-like reading even for experts.

### Research: Eye-Tracking Validation (2020-2025)

**Key Findings:**
- **Clarified code (better beacons) reduced reading time by 38.6%**
- **Extract Method refactoring reduced task time by 70-79%**
- **First-pass reading is critical** (readers form quick judgments; bad names hurt immediately)
- **Gaze jumps correlate with WM load** (well-extracted methods reduce jumps)

---

## Cognitive Dimensions of Codebases

**Framework:** Green & Petre (1996), applied to code by Hermans

Dimensions that affect code comprehension difficulty:

| Dimension | Definition | High Cognitive Load Example |
|-----------|------------|----------------------------|
| **Viscosity** | Resistance to change | One change requires touching 10 files |
| **Hidden Dependencies** | Non-obvious relationships | Global state, action-at-a-distance |
| **Premature Commitment** | Forced ordering of actions | Must read file A before B makes sense |
| **Hard Mental Operations** | Complex reasoning required | Deep nesting, type gymnastics |
| **Error-Proneness** | Easy to make mistakes | Confusing API, similar-looking names |
| **Closeness of Mapping** | How well code matches domain | Business logic buried in technical plumbing |
| **Progressive Evaluation** | Can test incrementally | Can run partial code vs. must complete everything |

**Reading Strategy:** When code feels hard, diagnose which dimension is problematic. Different dimensions require different approaches:

- **High Viscosity** → Use cross-referencing tools, draw dependency graphs
- **Hidden Dependencies** → Write characterization tests to expose behavior
- **Hard Mental Operations** → Externalize (state tables, diagrams)

---

## Seven Reading Comprehension Strategies (Hermans)

Adapted from text comprehension research to code:

| Strategy | Text Reading | Code Reading |
|----------|--------------|--------------|
| **1. Activating** | Recall related knowledge | Think of similar code you've seen |
| **2. Monitoring** | Check understanding | Ask "Does this make sense?" |
| **3. Determining Importance** | Identify key ideas | Find critical functions (hot paths) |
| **4. Inferring** | Read between lines | Infer intent from incomplete info |
| **5. Visualizing** | Create mental images | Draw diagrams, architecture |
| **6. Questioning** | Ask about content | Why/How/What conjectures |
| **7. Summarizing** | Restate main ideas | "Tell the story" of code |

**Meta-Strategy:** Expert readers **consciously apply** these strategies. Novices hope comprehension happens passively.

---

## Practical Application Examples

### Example 1: Diagnosing Confusion

**Scenario:** You're confused reading a payment processing function.

**Diagnosis Process:**
1. **Which confusion type?**
   - Knowledge? (Do I understand payment systems?)
   - Information? (Can I find where `PaymentGateway` is defined?)
   - WM Overload? (Too many state variables to track?)

2. **If Knowledge:** Stop reading code. Read payment processing documentation first.
3. **If Information:** Use `go-to-definition` on `PaymentGateway`, check call sites.
4. **If WM Overload:** Create state table tracking `status`, `amount`, `attempts`.

### Example 2: Choosing Reading Strategy

**Scenario:** 50,000-line unfamiliar codebase.

**Decision Tree:**
```
Do you know the domain?
├─ YES → Top-down: Start with architecture docs, find domain concepts
└─ NO → Bottom-up: Find entry point (main, tests), trace execution

Is your goal specific?
├─ YES (fix bug) → As-needed: Find bug location, read locally
└─ NO (learn system) → Systematic: Read key modules completely

Are there beacons?
├─ YES (familiar patterns) → Beacon-driven: Follow patterns you recognize
└─ NO (alien patterns) → Stepwise: Start with smallest units, build up
```

### Example 3: Applying Chunking

**Before Chunking:**
```python
def process(data):
    result = []
    for item in data:
        if item['status'] == 'active':
            if item['priority'] > 5:
                if item['category'] in ['urgent', 'critical']:
                    result.append(transform(item))
    return result
```
**Chunks to track:** `data`, `result`, `item`, `status`, `priority`, `category`, nested conditions = 7+ items (WM overload)

**After Chunking (Extract Function):**
```python
def process(data):
    active_items = filter_active(data)
    high_priority = filter_high_priority(active_items)
    urgent = filter_urgent_or_critical(high_priority)
    return [transform(item) for item in urgent]
```
**Chunks to track:** One pipeline, 4 transformation steps = 5 items (within WM capacity)

---

## References

- Brooks, R. (1983). "Towards a Theory of the Comprehension of Computer Programs." *International Journal of Man-Machine Studies*.
- Hermans, F. (2021). *The Programmer's Brain*. Manning.
- Letovsky, S. (1986). "Cognitive Processes in Program Comprehension." *Empirical Studies of Programmers*.
- Pennington, N. (1987). "Stimulus Structures and Mental Representations in Expert Comprehension of Computer Programs." *Cognitive Psychology*.
- Soloway, E. & Ehrlich, K. (1984). "Empirical Studies of Programming Knowledge." *IEEE Transactions on Software Engineering*.
- von Mayrhauser, A. & Vans, A.M. (1995). "Program Comprehension During Software Maintenance and Evolution." *IEEE Computer*.
- Synthesizing Research on Programmers' Mental Models (2022). [arXiv:2212.07763](https://arxiv.org/pdf/2212.07763)
- Cognitive Factors in Process Model Comprehension (2025). [MDPI](https://www.mdpi.com/2076-3425/15/5/505)
