# Code Review: Comprehensive Research Report

**Research Compilation for Code Review Skill Development**

Research Report — 2026-04-11

---

## Executive Summary

This report compiles comprehensive research on code review best practices, techniques, and recent academic findings to inform the development of a Code Review skill that complements the existing Code Reading skill. The research synthesizes insights from:

- **Industry Leaders**: Kent Beck, Google, Microsoft, Atlassian, GitHub, SmartBear
- **Academic Research**: Code review comprehension models, eye-tracking studies, empirical effectiveness studies (2020-2025)
- **Cognitive Science**: How code review differs from code reading as a cognitive process
- **Team Dynamics**: Psychological safety, feedback techniques, team culture
- **Automation**: AI-assisted review tools, static analysis integration, review bots

**Key Finding**: Code review is fundamentally different from code reading. While code reading focuses on comprehension, code review is a **decision-making process** that involves evaluation, judgment, communication, and social dynamics. A Code Review skill must address these unique cognitive and interpersonal aspects.

---

## Table of Contents

1. [Kent Beck's Philosophy on Code Review](#1-kent-becks-philosophy-on-code-review)
2. [Google's Engineering Practices](#2-googles-engineering-practices)
3. [Microsoft Research: What Makes Reviews Useful](#3-microsoft-research-what-makes-reviews-useful)
4. [SmartBear's Evidence-Based Best Practices](#4-smartbears-evidence-based-best-practices)
5. [Industry Best Practices (Atlassian, GitHub, ThoughtWorks)](#5-industry-best-practices)
6. [Academic Research: Cognitive Models of Code Review](#6-academic-research-cognitive-models-of-code-review)
7. [Code Review vs Code Reading: Key Distinctions](#7-code-review-vs-code-reading-key-distinctions)
8. [Psychological Safety and Team Dynamics](#8-psychological-safety-and-team-dynamics)
9. [Constructive Feedback Techniques](#9-constructive-feedback-techniques)
10. [Code Review Anti-Patterns](#10-code-review-anti-patterns)
11. [Metrics and Effectiveness](#11-metrics-and-effectiveness)
12. [Automated Code Review and AI Integration](#12-automated-code-review-and-ai-integration)
13. [Common Review Patterns and Checklists](#13-common-review-patterns-and-checklists)
14. [Recent Research (2020-2025)](#14-recent-research-2020-2025)
15. [Design Recommendations for Code Review Skill](#15-design-recommendations-for-code-review-skill)
16. [References](#16-references)

---

## 1. Kent Beck's Philosophy on Code Review

**Source**: [Thinking About Code Review](https://tidyfirst.substack.com/p/thinking-about-code-review)

### 1.1 Five Effects Code Review Should Have

Beck identifies five key objectives for code reviews:

| Effect | Description |
|--------|-------------|
| **Reduce Behavioral Errors** | Catch bugs before they reach production |
| **Reduce Structural Errors** | Identify design issues, coupling problems, architectural mismatches |
| **Improve Team Understanding** | Share knowledge about what the code does and why |
| **Accelerate Learning** | Help developers learn patterns, idioms, and domain knowledge |
| **Reduce Team Risk** | Ensure multiple people can work on any part of the codebase |

**Key Insight**: Beck emphasizes that code review serves **multiple purposes beyond defect detection**. Teams should consciously choose which effects they're optimizing for.

### 1.2 Five Guiding Principles for Review Workflows

| Principle | Definition | Implication for Review |
|-----------|------------|----------------------|
| **Flow** | Smaller batches more frequently > larger batches less frequently | Keep PRs small, review quickly |
| **Rowing** | Team velocity > individual speed | Don't block teammates with slow reviews |
| **Overhead** | Balance efficiency with integration costs | Review process shouldn't be heavier than value gained |
| **Alignment** | Match decision authority with consequence responsibility | Reviewers should have context for decisions |
| **Integration** | Account for both process and costs of merging | Review turnaround time affects PR size |

### 1.3 The Incentive Problem

**Critical Feedback Loop**:
```
Large PRs → Long review delays → More time for additional changes → Even larger PRs
```

**Solution**: Reduce review delays to keep PRs smaller. Fast reviews enable better code review culture.

### 1.4 Beck's Core Message

> "Pick the style of review that matches your context. Invent a new one if necessary."

Beck advocates for **experimentation** over dogma. Teams should think about their code-to-production workflow rather than blindly copying others.

### 1.5 Relationship to Tidy First?

Beck's tidying philosophy applies to code review:
- **Review-time tidyings**: Small structural improvements suggested during review
- **Pre-review tidyings**: Author tidies before submitting for review
- **Post-review tidyings**: Follow-up improvements after main change merges

**Connection to Code Reading**: Tidyings make code easier to review by reducing cognitive load for the reviewer.

---

## 2. Google's Engineering Practices

**Sources**:
- [Google Engineering Practices Documentation](https://google.github.io/eng-practices/)
- [What to Look for in a Code Review](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
- [The Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html)

### 2.1 Core Principle: The Standard of Code Review

**Fundamental Guideline**:
> "Reviewers should favor approving a CL once it is in a state where it definitely improves the overall code health of the system."

**Key Philosophy**: Prioritize **continuous improvement** over **perfection**. The goal is code that is "better," not "perfect."

### 2.2 What Reviewers Should Evaluate

Google's review process examines **eight key dimensions**:

#### 1. Design
- Does the overall architecture make sense?
- Does this change belong in the codebase?
- Does it integrate well with existing systems?

#### 2. Functionality
- Does the code accomplish its intended purpose?
- Does it serve both end-users and future developers well?
- Are edge cases, concurrency issues, and user-facing changes handled properly?

#### 3. Complexity
- Is the CL more complex than it should be?
- Check at all levels: individual lines, functions, and classes
- Watch for over-engineering
- Encourage solving immediate problems rather than speculative future needs

#### 4. Tests
- Are there appropriate unit, integration, or end-to-end tests?
- Do tests actually test the code?
- Will tests fail when code breaks?
- Do tests contain meaningful assertions without unnecessary complexity?

#### 5. Naming
- Are names "long enough to fully communicate what the item is or does" without becoming difficult to read?
- Do names follow conventions?

#### 6. Comments
- Comments should explain **why** code exists, not **what** it does
- Are comments clear and useful?

#### 7. Style
- Follow established style guides
- Use "Nit:" prefixes for non-mandatory improvements
- Maintain consistency with surrounding code

#### 8. Documentation
- Is relevant documentation updated for changes affecting how users build, test, or interact with the code?

### 2.3 Handling Imperfect Code

Rather than blocking submissions for minor issues, reviewers should:

- Leave constructive comments while approving solid improvements
- Prefix non-critical feedback with "Nit:" to signal optional refinements
- Balance the need for progress against the significance of suggested changes
- Avoid delaying meaningful improvements due to trivial polish concerns

**Exception**: Reviewers can deny changes that introduce unwanted features or significantly worsen code health.

### 2.4 Reviewer Selection Strategy

**Guideline**: Find "the best reviewers you can who are capable of responding to your review within a reasonable period of time."

- Ideally, code owners provide the most thorough reviews
- When ideal reviewers are unavailable, CC them on changes rather than delay review
- **Pair programming** with qualified developers fulfills review requirements

### 2.5 Key Takeaways from Google

1. **Code health over perfection**: Approve improvements, don't demand flawlessness
2. **Comprehensive evaluation**: Check all 8 dimensions, not just functionality
3. **Context matters**: Edge cases, concurrency, user-facing changes need extra attention
4. **Why over what**: Comments should explain rationale, not mechanics
5. **Balance speed and quality**: Find best available reviewer who can respond promptly

---

## 3. Microsoft Research: What Makes Reviews Useful

**Source**: [Characteristics of Useful Code Reviews: An Empirical Study at Microsoft](https://www.microsoft.com/en-us/research/publication/characteristics-of-useful-code-reviews-an-empirical-study-at-microsoft/)

### 3.1 Study Overview

**Scale**: Analyzed **1.5 million review comments** from five Microsoft projects

**Methodology**: Three-stage mixed methods approach:
1. Qualitative investigation
2. Classification model development
3. Empirical analysis

**Goal**: Identify what makes code reviews useful

### 3.2 Key Findings

#### Reviewer Experience Effects

- **First year impact**: The proportion of useful comments dramatically increases during a reviewer's first year at Microsoft
- **Plateau effect**: After the first year, reviewer comment quality tends to plateau
- **Implication**: Experience helps, but experience alone doesn't guarantee quality reviews

#### Change Complexity Effects

**Critical Finding**:
> "The more files that are in a change, the lower the proportion of comments in the code review that will be of value to the author"

**Implications**:
- Larger changesets receive proportionally less useful feedback
- Breaking changes into smaller PRs improves review quality
- Reviewers struggle with cognitive load when reviewing many files

### 3.3 Benefits Beyond Defect Detection

While finding defects remains the main motivation for review, Microsoft research found additional benefits:

| Benefit | Description |
|---------|-------------|
| **Knowledge Transfer** | Sharing understanding of code, patterns, and domain |
| **Team Awareness** | Keeping team informed about changes across codebase |
| **Alternative Solutions** | Discovering better approaches through discussion |
| **Learning** | Both author and reviewer learn from the process |

### 3.4 Classification Model

**Achievement**: Built model with **86.7% precision** and **93.8% recall** in identifying useful review comments

**Application**: Can be used to:
- Identify characteristics of high-quality feedback
- Train reviewers on effective commenting
- Filter noise from valuable comments

### 3.5 Practical Recommendations

1. **Limit PR size**: Keep changes small to maintain review quality
2. **Experienced reviewers matter**: But only up to a point
3. **Focus on multiple benefits**: Don't optimize solely for defect detection
4. **Measure usefulness**: Track which types of comments provide value

---

## 4. SmartBear's Evidence-Based Best Practices

**Source**: [Best Practices for Code Review](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)

SmartBear's research, particularly their Cisco study, provides **quantitative benchmarks** for effective code review.

### 4.1 The 11 Best Practices

#### 1. Review Fewer Than 200-400 Lines of Code at a Time

**Finding**: Beyond 400 LOC, defect detection ability diminishes significantly

**Research**: Cisco study found most defects are found in the first 200 lines

**Cognitive Reason**: Working memory limits prevent effective inspection of large changes

#### 2. Maintain Inspection Pace Under 500 LOC/Hour

**Finding**: Beyond 500 LOC/hour, defect density drops

**Optimal Rate**: 200-400 LOC over 60-90 minutes yields 70-90% defect discovery

**Implication**: Slower, more thorough reviews find more bugs

#### 3. Limit Review Sessions to 60 Minutes

**Finding**: Concentration degrades beyond 60 minutes

**Reason**: Mental fatigue reduces effectiveness

**Best Practice**: Take breaks between review sessions

#### 4. Establish Metrics and Goals

Track three key metrics:

| Metric | Definition | Purpose |
|--------|------------|---------|
| **Inspection Rate** | LOC divided by inspection hours | Measure review speed |
| **Defect Rate** | Defects found per inspection hour | Measure review thoroughness |
| **Defect Density** | Defects per thousand lines of code | Identify problematic code |

#### 5. Author Annotations Required

**Practice**: Developers should explain changes before peer review

**Benefit**: Provides context, reduces reviewer questions

**Implementation**: Use PR templates, commit messages

#### 6. Use Checklists

**Key Insight**:
> "As soon as you start recording your defects in a checklist, you will start making fewer of them."

**Personal Checklists**: Each developer typically makes the same 15-20 mistakes repeatedly

**Team Checklists**: Capture common team-specific issues

#### 7. Implement Defect-Fixing Process

**Problem**: Many teams don't track whether defects found during review are actually fixed

**Solution**: Establish workflow for:
- Recording defects
- Assigning responsibility
- Verifying fixes
- Closing issues

#### 8. Build Collaborative Culture

**Critical Principle**: Frame defects as **learning opportunities**, never for performance evaluation

**Anti-Pattern**: Using code review feedback in performance reviews creates defensive behavior

**Best Practice**: Psychological safety enables honest, productive reviews

#### 9. Leverage Psychological Incentive

**Finding**: "Spot checking" 20-33% of code drives quality improvements

**Mechanism**: Knowing code *might* be reviewed improves initial quality

**Balance**: Full review of critical code, sampling of less critical code

#### 10. Adopt Lightweight Tool-Assisted Reviews

**Efficiency Comparison**:
- **Formal reviews**: 9 hours per 200 LOC, requiring 6 participants
- **Lightweight reviews**: < 20% of formal review time, finding just as many bugs

**Tools Enable**:
- Asynchronous review
- Conversation threading
- Automated checks
- Metrics collection

#### 11. Foster Feedback Culture

Make review a normal, expected part of development, not a punitive measure

### 4.2 SmartBear Research Data

**Defect Discovery Rates by Method**:
- Formal inspections: **60-65%** (Capers Jones, 12,000+ projects)
- Informal reviews: **< 50%**
- Testing: **30%**

**Implication**: Code review is more effective than testing for finding defects, but formal doesn't necessarily mean better than lightweight.

### 4.3 Key Takeaways from SmartBear

1. **Size matters**: 200-400 LOC optimal, never exceed without splitting
2. **Speed matters**: < 500 LOC/hour for effectiveness
3. **Time matters**: Don't review more than 60 minutes continuously
4. **Checklists work**: Reduce recurring mistakes
5. **Culture matters**: Psychological safety enables quality reviews
6. **Lightweight wins**: Tool-assisted reviews are efficient and effective

---

## 5. Industry Best Practices

### 5.1 Atlassian's Code Review Guide

**Sources**:
- [5 Code Review Best Practices](https://www.atlassian.com/blog/add-ons/code-review-best-practices)
- [What Are Code Reviews](https://www.atlassian.com/agile/software-development/code-reviews)

#### Review Size and Timing

**Finding**: Reviewing more than 400 lines can negatively impact bug detection

**Research**: Cisco found developers' ability to identify defects wanes after reviewing more than 200 lines

**Best Practice**: Most defects are found in the first 200 lines

#### Provide Context in Feedback

**Principle**: Explain **why** the developer should make a change, not just what needs to be fixed

**Example**:
- ❌ "Change this to use flexbox"
- ✅ "Have you considered using flexbox here? It would simplify the layout logic and improve responsive behavior"

**Benefit**: Articulating reasoning helps developers learn

#### Use a Code Review Checklist

**Categories to Check**:
1. **Functionality**: Is the code working as intended?
2. **Organization**: Can you clarify the code for easier maintenance?
3. **Efficiency**: Is the code optimized?
4. **Documentation**: Are there clear comments?

#### Measure with Metrics

Three key measurements:

| Metric | Formula | Purpose |
|--------|---------|---------|
| **Inspection Rate** | LOC ÷ inspection hours | Determine review speed |
| **Defect Rate** | Defects ÷ inspection hours | Measure effectiveness |
| **Defect Density** | Defects per 1000 LOC | Identify vulnerable code |

#### Integration with Workflow

**Timing**: Initiate code reviews after:
- All code has been written
- Automated tests have run and passed
- But **before** code is merged upstream

**Benefit**: Catch issues before integration

### 5.2 GitHub Pull Request Best Practices

**Sources**:
- [Best Practices for Reviewing Pull Requests](https://rewind.com/blog/best-practices-for-reviewing-pull-requests-in-github/)
- [How to Review Code Effectively: A GitHub Staff Engineer's Philosophy](https://github.blog/developer-skills/github/how-to-review-code-effectively-a-github-staff-engineers-philosophy/)

#### For PR Authors

**1. Keep PRs Small and Focused**
- Small PRs are easier and faster to review
- Recommended size: **200-400 lines of code**
- Single purpose per PR
- Clearer history of changes

**2. Self-Review Before Requesting Review**
- Review, build, and test your own PR first
- Catch obvious errors before others see them
- Shows respect for reviewers' time

**3. Provide Clear Context and Descriptions**
- Use PR templates
- Define the goal of the PR
- Specify desired outcome
- Explain non-obvious decisions

**4. Ensure CI/CD Checks Pass**
- All automated tests should pass
- Linting/formatting checks complete
- Build succeeds

#### For Code Reviewers

**1. Prioritize Code Reviews**
**Philosophy**: When a teammate has a PR ready, prefer reviewing their code over continuing your own work

**Reasoning**: Their PR has already passed CI and met the bar for "done"

**2. Ask Questions and Be Constructive**
**Approach**: Pull requests are the beginning of conversation

**Examples**:
- ❌ "This is wrong"
- ✅ "Can you help me understand why you chose this approach?"

**3. Test the Code Locally**
- Check out the branch
- Pull down the code
- Verify it works as described
- Test edge cases

**4. Use PR Templates**
**Benefits**:
- Reminds developers what to specify
- Ensures consistency
- Reduces back-and-forth

**5. Leverage Automation**
- CI/CD for automated tests
- Linters for style checking
- Security scanners
- Code coverage tools

**6. Maintain Respectful Communication**
**Key Principles**:
- **Respect**: Remove all friction
- **Humility**: You might be wrong
- **Clarity**: Dispel doubts about intentions
- **Suggesting**: Create conditions for improvement

### 5.3 ThoughtWorks Perspectives

**Sources**:
- [Agile Overview](https://www.thoughtworks.com/perspectives/edition1-agile)
- [Future of Software Engineering Retreat Findings](https://www.thoughtworks.com/content/dam/thoughtworks/documents/report/tw_future%20_of_software_development_retreat_%20key_takeaways.pdf)

#### Evolving Perspectives on Code Review

**Recent Discussions**: Code review's role is evolving with AI-assisted development

**Observation**: Some practitioners are "moving review efforts entirely to the test suite, treating the generated code as expendable"

**Implication**: The relationship between code review and testing is shifting

#### Pair Programming vs Code Review

**Debate**: "Is pair programming a superior replacement for code review?"

**ThoughtWorks Position**: Both have value:
- **Pair programming**: Real-time collaboration, immediate feedback
- **Code review**: Asynchronous, broader perspectives, documentation

**Technical Practices Foundation**: To make agile work, you need solid technical practices:
- Continuous integration
- Test-driven development (TDD)
- Refactoring
- Pair programming/ensemble development
- Code review

**Key Insight**: These practices work together; they're not mutually exclusive

---

## 6. Academic Research: Cognitive Models of Code Review

### 6.1 Code Review Comprehension Model (2025)

**Source**: [Code Review Comprehension: Reviewing Strategies](https://arxiv.org/abs/2503.21455)

#### Research Methodology

- **Participants**: 10 experienced reviewers
- **Reviews Analyzed**: 25 code reviews
- **Method**: Observational study with interviews
- **Framework**: Theory-driven thematic analysis grounded in Letovsky's comprehension model

#### Key Finding: Code Comprehension is Fundamental

**Core Insight**:
> "Code comprehension is fundamental to code review."

**Distinction**: While comprehension is necessary, review requires **additional cognitive processes** beyond understanding.

#### The Code Review Comprehension Model

Researchers extended Letovsky's code comprehension framework to create the **Code Review Comprehension Model (CRCM)**.

**Process**:
1. **Context-Building Phase**: Establishing understanding of the broader software system
2. **Code Inspection Phase**: Reading, testing, and discussion management
3. **Mental Model Construction**: Developing representations of expected vs. actual implementations

**Opportunistic Strategies**: Reviewers employ opportunistic strategies, jumping between top-down and bottom-up approaches as needed.

#### Mental Model Requirements

Reviewers must "construct a mental model of the change as an extension of their understanding of the overall software system" and actively **contrast multiple representations** to evaluate implementations.

**Difference from Code Reading**: Code reading builds understanding of what exists; code review evaluates proposed changes against what should exist.

#### Practical Recommendations

**For Tool Designers**: "Review tools and practices can better support reviewers in employing their strategies and in forming understanding" by aligning with identified cognitive processes.

**For Reviewers**: Recognize that review requires:
- Understanding the change itself
- Understanding the existing system
- Evaluating how the change fits the system
- Considering alternative implementations

### 6.2 Code Review as Decision-Making (2025)

**Source**: [Code Review as Decision-Making](https://arxiv.org/abs/2507.09637)

#### The CRDM Model Structure

The research presents the **Code Review as Decision-Making (CRDM)** model, describing code review through two sequential phases:

**Phase 1: Orientation Phase**
- Developers establish context
- Understand the rationale behind proposed changes
- Build situational awareness

**Phase 2: Analytical Phase**
- Examine and evaluate changes
- Determine approach for remainder of review
- Make approval decisions

#### Key Cognitive Process

**Finding**: Reviewing code mirrors **recognition-primed decision-making** patterns rather than purely comprehension-based analysis.

**Quote**:
> "The similarities between the cognitive process in code review and decision-making processes, especially recognition-primed decision-making, become apparent."

#### Decision Points Throughout Review

The model identifies multiple decision junctures where reviewers must choose actions:

| Decision Type | Examples |
|---------------|----------|
| **Comment Authoring** | Should I write a comment about this? |
| **Information Gathering** | Do I need more context? |
| **Approval Voting** | Should I approve this change? |
| **Local Execution** | Should I run this code locally? |
| **CI Verification** | Do I need to check continuous integration results? |

#### Research Methodology

- **Participants**: 10 developers
- **Reviews**: 34 code reviews analyzed
- **Method**: Ethnographic think-aloud study
- **Analysis**: Thematic, statistical, temporal, and sequential analysis of transcribed sessions

#### Implications for Review Practice

**Key Distinction**: Rather than automating code review entirely, understanding these cognitive processes can improve **tool support** while preserving interpersonal benefits:
- Knowledge transfer
- Shared ownership
- Learning opportunities

**For Reviewers**: Recognize that review is fundamentally about **making decisions**, not just comprehending code:
- What should I focus on?
- What comments should I make?
- Should I approve this?
- What additional information do I need?

### 6.3 Eye-Tracking Studies on Code Review

**Sources**:
- [Recognizing Eye Tracking Traits for Source Code Review](https://ieeexplore.ieee.org/document/8247637)
- [Collaborative Eye Tracking Based Code Review](https://link.springer.com/article/10.1007/s11704-020-0422-1)

#### Key Aspects of Skilled Reviewers

Eye-tracking research identified characteristics of subjects with programming skills during code review:

| Trait | Description |
|-------|-------------|
| **Better Code Coverage** | Skilled reviewers examine more of the code |
| **Attention Span on Error Lines** | Focus more on problematic areas |
| **Attention to Comments** | Read and process comments more carefully |

#### Reading Behavior Findings

**From 2020 Study**: Experience modulates reading behavior, but the **linearity of source code** has an even stronger effect on reading order than experience

**Implication**: Well-structured, linear code is easier to review regardless of reviewer experience

#### Collaborative Review with Shared Gaze

**Innovation**: Systems that visualize reviewer gaze patterns can:
- Help authors understand what reviewers are focusing on
- Enable better asynchronous collaboration
- Identify confusing code sections (where gaze patterns show uncertainty)

---

## 7. Code Review vs Code Reading: Key Distinctions

### 7.1 Fundamental Differences

| Aspect | Code Reading | Code Review |
|--------|--------------|-------------|
| **Primary Goal** | Comprehension | Evaluation + Decision-Making |
| **Focus** | Understanding what exists | Judging what should exist |
| **Cognitive Process** | Building mental models | Comparing mental models (expected vs. proposed) |
| **Output** | Knowledge | Judgment + Feedback |
| **Context** | Single artifact | Change within larger system |
| **Iteration** | One-time or periodic | Repeated on same artifact |
| **Social Dimension** | Individual or collaborative | Inherently collaborative (author-reviewer) |
| **Responsibility** | Learn | Approve/reject + guide improvement |

### 7.2 Unique Characteristics of Code Review

#### Iterative Comprehension

**From Research**:
> "Reviewers repeatedly comprehend the same artifact"

**Implication**: Review happens in rounds. Understanding evolves through discussion.

#### Incremental Comprehension

**From Research**:
> "Reviewers comprehend a modification of a likely partially known software system"

**Implication**: Reviewers must understand:
1. The existing system (partial knowledge)
2. The proposed change
3. How the change integrates with the system

#### Interactive Comprehension

**From Research**:
> "The comprehension is supported by interactions with the author and other colleagues"

**Implication**: Review is a **conversation**, not just analysis. Questions clarify intent, discussion improves solutions.

### 7.3 Higher-Level Cognitive Processes

**Key Distinction**:
> "Code review requires deeper engagement of higher-level cognitive processes (e.g., decision making and analysis) than code comprehension alone"

**Additional Processes in Review**:
1. **Quality Assessment**: Is this good enough?
2. **Risk Evaluation**: What could go wrong?
3. **Alternative Consideration**: Are there better approaches?
4. **Communication**: How do I convey my concerns constructively?
5. **Approval Decision**: Should this merge?

### 7.4 Review Strategies vs Reading Strategies

#### Common Review Strategies (from CRCM research)

**Context-Building Phase**:
- Read PR description
- Understand the problem being solved
- Review linked issues/tickets
- Check commit history

**Code Inspection Phase**:
- Read changed code
- Test locally or mentally
- Compare with existing patterns
- Check for edge cases

**Decision-Making Phase**:
- Evaluate design choices
- Consider alternatives
- Formulate feedback
- Decide approval status

#### Scoping Strategies

**Finding**: "Full comprehension may not always be the goal, especially when reviewers perform focused, partial, or shallow reviews"

**Scoping Approaches**:
- **Focused review**: Check specific aspects (e.g., security, performance)
- **Partial review**: Review subset of changes (e.g., critical files only)
- **Shallow review**: High-level sanity check without deep dive

**Reason**: "Scoping down the review is a commonly used strategy to deal with review complexity"

### 7.5 When to Use Each

| Use Code Reading When | Use Code Review When |
|-----------------------|----------------------|
| Learning a new codebase | Evaluating proposed changes |
| Understanding existing functionality | Approving/rejecting modifications |
| Debugging issues | Providing feedback to authors |
| Preparing to modify code | Ensuring code quality standards |
| Building domain knowledge | Knowledge transfer through feedback |
| Solo exploration | Collaborative improvement |

### 7.6 How They Complement Each Other

**Code Reading Enables Better Code Review**:
- Deep understanding of existing code improves review quality
- Familiarity with patterns helps spot deviations
- Domain knowledge enables evaluation of business logic

**Code Review Improves Code Reading Skills**:
- Seeing others' approaches expands pattern library
- Review discussions reveal design rationale
- Feedback highlights what matters in code quality

**Best Practice**: Use code reading techniques to understand changes, then apply review-specific decision-making processes.

---

## 8. Psychological Safety and Team Dynamics

**Sources**:
- [Psychological Safety in Software Workplaces: A Systematic Literature Review](https://arxiv.org/html/2508.03369)
- [Build Psychological Safety Through Code Reviews](https://agilesparks.com/build-psychological-safety-in-teams-through-code-reviews/)
- [Code Review Therapy: How to Give Feedback Without Breaking Hearts](https://pullflow.com/blog/psychology-of-code-reviews-feedback-that-helps/)

### 8.1 The Psychological Impact of Code Review

#### Code Reviews as Moments of Intense Scrutiny

**Research Finding**:
> "Code reviews, although essential for maintaining code quality, can become moments of intense scrutiny, where team members fear negative judgment."

**Context**: Practices such as code review, architectural decisions, and task estimation frequently surface as **moments of interpersonal tension**, requiring:
- Critical feedback
- Negotiation
- Error disclosure in front of peers

#### Brain's Threat Response

**Neuroscience Finding**:
> "When a developer receives harsh criticism, their brain's threat detection system activates the same way it would during physical danger, triggering defensive responses that shut down learning and collaboration."

**Implications**:
- Harsh reviews activate fight-or-flight response
- Defensive behavior blocks learning
- Psychological threat reduces cognitive capacity

### 8.2 Impact on Software Quality

**2024 Study Finding** (Empirical Software Engineering):
> "Psychological safety directly impacts software quality by enabling key behaviors like knowledge sharing, open communication, and collaborative problem-solving."

**Mechanism**: When psychological safety is established in agile software teams, it induces enablers of a social nature that advance the teams' ability to pursue software quality.

**Key Behaviors Enabled**:
| Behavior | How Psychological Safety Helps |
|----------|-------------------------------|
| **Knowledge Sharing** | Team members feel safe admitting what they don't know |
| **Open Communication** | Concerns and bugs are reported without fear |
| **Collaborative Problem-Solving** | Multiple perspectives are shared freely |
| **Error Disclosure** | Mistakes are acknowledged early |
| **Constructive Conflict** | Technical disagreements are productive, not personal |

### 8.3 Creating Psychological Safety in Code Review

#### Start with Positive Feedback

**Technique**:
> "Starting by acknowledging what works well in the code activates the brain's reward system and creates psychological safety for receiving constructive feedback."

**Pattern**:
1. Identify something positive in the PR
2. Acknowledge it explicitly
3. Then provide constructive feedback

**Example**:
```
✅ "Great job simplifying the sorting logic! I really like how you extracted
that helper function. Quick question: have we covered this edge case when
the input is empty? Also, could we refactor X into a helper for consistency?"
```

#### Balance Feedback

**Principle**: A well-rounded review includes both **positive and constructive feedback**

**Ratio**: Research on feedback suggests approximately 3:1 ratio of positive to constructive works well

**Benefit**: Keeps review motivational while still addressing issues

#### Use I-Messages

**Technique**: Frame feedback from your perspective, not as absolute truth

**Examples**:
- ❌ "This code is hard to understand"
- ✅ "It's hard for me to understand this code"

**Benefit**: Reduces defensiveness, acknowledges different perspectives

### 8.4 Workplace Practices That Support Psychological Safety

**From APA 2024 Work in America Report**:

Workers experiencing high psychological safety report significantly better:
- Job performance
- Productivity
- Engagement

**Practices Associated with Higher Psychological Safety**:
| Practice | Application to Code Review |
|----------|---------------------------|
| **Opportunities to Give and Receive Feedback** | Regular, normalized code review process |
| **Well-Trained Managers** | Reviewers trained in constructive feedback |
| **Employee Involvement in Decision Making** | Authors involved in resolving review comments |
| **Respect for Time Off** | Reasonable review turnaround expectations |

### 8.5 Best Practices for Psychological Safety

#### Frame Reviews as Learning Opportunities

**Philosophy**: Code review is about improving code and sharing knowledge, not judging people

**Language Shift**:
- ❌ "You made a mistake here"
- ✅ "We could improve this by..."

#### Create Safe Spaces for Questions

**Principle**: No question is stupid in code review

**Practice**: Reviewers should feel safe asking "why?" even when they might be missing context

**Example**:
```
"I might be missing something, but can you help me understand why we're
using approach X instead of Y? I'm curious about the tradeoff."
```

#### Normalize Mistakes

**Practice**: Everyone makes mistakes, including reviewers

**Language**:
- "I was wrong about..."
- "Good point, I hadn't considered..."
- "You're right, my suggestion wouldn't work because..."

**Benefit**: Models learning behavior, reduces fear of being wrong

#### Separate Code from Person

**Critical Distinction**: Critique the code, not the coder

**Language Patterns**:
- ✅ "This function could be simplified"
- ❌ "You over-complicated this function"

**Principle**: Focus on **what** (the code) not **who** (the author)

### 8.6 Anti-Patterns That Harm Psychological Safety

| Anti-Pattern | Harm | Alternative |
|--------------|------|-------------|
| **Aggressive tone** | Triggers defensive response | Collaborative, questioning tone |
| **Public shaming** | Creates fear culture | Private, constructive feedback |
| **Perfectionism** | Blocks progress, demoralizes | Focus on improvement, not perfection |
| **Dismissive language** | Invalidates author's effort | Acknowledge effort, suggest improvements |
| **Know-it-all attitude** | Shuts down discussion | Curious questioning |

### 8.7 Key Takeaway

**Core Principle**:
> "Psychological safety works best when paired with high performance expectations."

**Balance**: Create environment where:
- Standards are high
- Mistakes are learning opportunities
- Feedback is constructive
- People feel safe taking reasonable risks

---

## 9. Constructive Feedback Techniques

**Sources**:
- [Best Practices for Writing Constructive Code Review Feedback](https://blog.pixelfreestudio.com/best-practices-for-writing-constructive-code-review-feedback/)
- [How to Give Respectful and Constructive Code Review Feedback](https://www.michaelagreiler.com/respectful-constructive-code-review-feedback/)
- [Better Feedback with Conventional Comments](https://dev.to/jacobandrewsky/better-feedback-in-code-reviews-with-conventional-comments-2c3k)

### 9.1 Core Communication Principles

#### Ask Questions Instead of Demanding Changes

**Principle**: Questions foster dialogue and respect author's agency

**Examples**:
| Instead of (Command) | Try (Question) |
|---------------------|----------------|
| "Change this to use flexbox" | "Have you considered using flexbox here?" |
| "This is inefficient" | "Would using a Set improve performance here?" |
| "Don't use var" | "Is there a reason we're using var instead of const/let?" |

**Benefit**:
- Opens conversation
- Respects author's knowledge
- Acknowledges neither reviewer nor author is always right

#### Be Specific and Actionable

**Principle**: Vague feedback is not helpful

**Examples**:
| Vague | Specific |
|-------|----------|
| "This needs work" | "This function has a nested loop that could be optimized to O(n) using a hash map" |
| "This is bad" | "Can we replace this loop with a built-in sort? That would simplify the logic and improve readability" |
| "Confusing" | "I'm having trouble understanding the flow here. Could we add a comment explaining why we check X before Y?" |

**Components of Specific Feedback**:
1. **What**: Identify the specific code section
2. **Why**: Explain the concern
3. **How**: Suggest a concrete improvement

#### Use I-Messages

**Technique**: Show feedback comes from your perspective

**Examples**:
| You-Message (Blaming) | I-Message (Perspective) |
|-----------------------|-----------------------|
| "You didn't close the socket" | "This code doesn't close the socket" |
| "You made this too complex" | "I find this logic difficult to follow" |
| "You're using the wrong pattern" | "I'm not familiar with this pattern—could you explain the benefit?" |

**Benefit**: Prevents defensive reactions, acknowledges subjectivity

### 9.2 Conventional Comments Pattern

**Concept**: Standardized keywords for categorizing feedback

**Format**: `<keyword>: <comment text>`

#### Core Keywords

| Keyword | Purpose | Example |
|---------|---------|---------|
| **suggestion:** | Proposes improvement or alternative | `suggestion: Consider using a loop here for better scalability` |
| **question:** | Seeks clarification | `question: Why did you choose this algorithm over binary search?` |
| **issue:** | Highlights bug or problem | `issue: This function does not handle null inputs properly` |
| **nitpick:** (or **nit:**) | Minor stylistic concern | `nitpick: Consider using single quotes for consistency` |
| **praise:** | Recognizes good work | `praise: Great job optimizing this function!` |
| **thought:** | Shares thinking without requiring action | `thought: This pattern might be useful elsewhere in the codebase` |

#### Blocking vs Non-Blocking

**Syntax**: Add `(blocking)` or `(non-blocking)` to clarify urgency

**Examples**:
```
issue (blocking): This function is vulnerable to SQL injection.
Please use parameterized queries.

nitpick (non-blocking): Consider renaming 'data' to 'userData'
for clarity—not required for approval.
```

**Benefit**: Authors immediately understand what must be addressed vs. what's optional

### 9.3 Comment Structure Patterns

#### The "Sandwich" Pattern

**Structure**:
1. **Positive observation** (bread)
2. **Constructive feedback** (filling)
3. **Encouragement or question** (bread)

**Example**:
```
Great job extracting this helper function—it really improves readability!

One thought: this function doesn't handle the case where the array is empty.
Could we add a guard clause at the start?

Otherwise this looks solid. Nice work on the refactoring!
```

#### The "Collaborative We" Pattern

**Technique**: Use "we" language to invite collaboration

**Examples**:
| Instead of | Collaborative |
|-----------|---------------|
| "You should refactor this" | "We could simplify this by extracting a helper. What do you think?" |
| "Your approach is wrong" | "What if we tried approach X? I think it might handle edge cases better." |

**Benefit**: Frames improvement as shared goal, not criticism

#### The "Explain Why" Pattern

**Principle**: Always provide reasoning, not just directives

**Template**: `<observation> + <reason> + <suggestion>`

**Example**:
```
This loop recalculates the same value on each iteration (observation),
which means we're doing O(n²) work instead of O(n) (reason).
Could we move the calculation outside the loop? (suggestion)
```

**Benefit**: Helps author learn the principle, not just fix this instance

### 9.4 Tone and Language

#### Focus on Code, Not Person

**Principle**: Make code the subject, not the author

**Examples**:
| Person-Focused | Code-Focused |
|----------------|--------------|
| "You did this wrong" | "This approach may not handle edge cases" |
| "You forgot to..." | "This code is missing..." |
| "You always..." | "I've noticed this pattern a few times..." |

#### Avoid Absolute Language

**Principle**: Soften directives with suggestions

**Examples**:
| Absolute | Softer |
|----------|--------|
| "This is wrong" | "This approach might have issues" |
| "Always use X" | "In most cases, X is preferred because..." |
| "Never do Y" | "Y can lead to problems when..." |

#### Use Positive Framing

**Technique**: Frame suggestions as opportunities, not criticisms

**Examples**:
| Negative Frame | Positive Frame |
|----------------|----------------|
| "This is inefficient" | "We have an opportunity to optimize this" |
| "This is hard to read" | "We could make this even clearer by..." |
| "This is messy" | "This could benefit from some refactoring" |

### 9.5 Review Comment Templates

#### Bug or Security Issue

```
issue (blocking): [Describe the problem]

Impact: [What could go wrong]
Reproduction: [How to trigger the issue]
Suggestion: [How to fix it]

Example: [Optional code example of the fix]
```

#### Design Concern

```
thought: [Explain the concern]

I'm wondering if [alternative approach] might work better here because
[reasoning].

What do you think? Is there something I'm missing about the current approach?
```

#### Nitpick (Style/Minor)

```
nit (non-blocking): [Observation]

This is purely stylistic and doesn't block approval, but [explanation of
why the style guideline exists].
```

#### Praise

```
praise: [Specific positive observation]

[Optional: Why this is valuable or what made it stand out]
```

### 9.6 Handling Disagreements

#### When You Disagree with a Approach

**Template**:
```
question: Can you help me understand the benefit of approach X?

I was thinking we might use approach Y instead because [reasoning],
but I might be missing context about why X is better here.
```

**Principle**: Assume good intent, seek understanding first

#### When Author Disagrees with Your Suggestion

**Response Template**:
```
Thanks for explaining! That makes sense—I hadn't considered [their point].

[Either:]
- You're right, let's go with your approach.
- I see your point. What if we compromised with [middle ground]?
- I still think [concern] is an issue. Could we discuss this synchronously?
```

**Principle**: Be willing to be wrong, but clarify important concerns

### 9.7 Key Takeaways

**Effective Feedback Is**:
1. **Specific**: Points to exact code and explains clearly
2. **Actionable**: Suggests concrete improvements
3. **Respectful**: Focuses on code, not person
4. **Balanced**: Includes both positive and constructive
5. **Collaborative**: Invites discussion
6. **Educational**: Explains the "why"

**Ineffective Feedback Is**:
1. Vague ("This is bad")
2. Demanding ("Change this")
3. Personal ("You always...")
4. Only negative
5. Dismissive ("This is obviously wrong")
6. Unexplained directives

---

## 10. Code Review Anti-Patterns

**Sources**:
- [Code Review Antipatterns (chiark.greenend.org.uk)](https://www.chiark.greenend.org.uk/~sgtatham/quasiblog/code-review-antipatterns/)
- [Code Review Anti-Patterns - DEV Community](https://dev.to/adam_b/code-review-anti-patterns-2e6a)
- [Anti-patterns for Code Review - AWS DevOps Guidance](https://docs.aws.amazon.com/wellarchitected/latest/devops-guidance/anti-patterns-for-code-review.html)

### 10.1 Process Anti-Patterns

#### 1. Incremental Nitpicking

**Description**: Reviewing code one nitpick at a time, stopping after each comment

**Problem**:
- Causes patch to evolve slowly through multiple iterations
- Author must address comments, re-request review, wait again
- Creates frustration and delays

**Example**:
```
Round 1: "Fix indentation"
Round 2: "Rename this variable"
Round 3: "Add error handling"
[All could have been in one review]
```

**Solution**: Provide comprehensive feedback in one pass, not piecemeal

#### 2. Large Batch Reviews

**Description**: Combining multiple code changes into a single PR

**Problems**:
- Clutters the review
- Longer review cycles
- Difficult to identify issues with individual changes
- Increases cognitive load for reviewers

**Measurement**: PRs over 400 LOC see dramatically reduced review quality

**Solution**: Break large changes into smaller, focused PRs

#### 3. Rubber Stamping (Underdoing It)

**Description**: Approving code without actually reviewing it

**Manifestations**:
- LGTM within seconds of PR submission
- Approving without reading the code
- Treating review as mere formality

**Risk**: Security holes, logical errors, code smells pass through

**Solution**: Establish minimum review standards (time, checklist, required comments)

#### 4. Unidirectional Reviewing

**Description**: Seniors review juniors, but not vice versa

**Problem**:
- Juniors don't learn to review critically
- Seniors miss out on fresh perspectives
- Creates hierarchy rather than shared ownership

**Solution**: Everyone reviews everyone (adjust expectations by experience level)

### 10.2 Behavioral Anti-Patterns

#### 5. Inconsistent Standards

**Description**: Objecting to code patterns you've previously approved

**Example**:
```
PR #42: Author uses pattern X → Reviewer approves
PR #67: Same author uses pattern X → Reviewer objects
```

**Problem**: Author can't predict what will be accepted

**Solution**:
- Document team standards
- If standards change, announce to team
- Apply new standards prospectively, not retroactively

#### 6. Scope Creep

**Description**: Refusing to approve until substantial additional work is done

**Example**:
> "I won't approve this 50-line bug fix until you refactor the entire module
> it touches"

**Problem**:
- Blocks progress
- Discourages contributions
- Confuses "improvement" with "perfection"

**Solution**: Apply Google's standard—approve if it improves code health, even if not perfect

#### 7. Style Nitpicking

**Description**: Spending excessive time on minor formatting issues

**Problem**:
- Distracts from substantive review
- Wastes reviewer and author time
- Creates friction

**Example**:
```
nitpick: Use single quotes
nitpick: Add space after comma
nitpick: Line 47 is 81 characters, should be 80
```

**Solution**: Automate style checking (Prettier, Black, gofmt, etc.)

#### 8. Aggressive or Demeaning Tone

**Description**: Making comments that feel like personal attacks

**Warning**: "The line between 'that's stupid' and 'you're stupid' is thin"

**Examples**:
| Aggressive | Constructive |
|-----------|--------------|
| "This is obviously wrong" | "I think there might be an issue here" |
| "Did you even test this?" | "Have we verified this handles edge case X?" |
| "This is terrible code" | "This could be clearer—what if we..." |

**Impact**: Destroys psychological safety, creates defensive behavior

**Solution**: Review the code, not the person; assume good intent

### 10.3 Review Quality Anti-Patterns

#### 9. Not Doing Code Reviews

**Description**: Skipping code review entirely

**Rationale (Flawed)**:
- "We trust our developers"
- "We're moving too fast"
- "We have tests"

**Risk**: "Errors, problems, and vulnerabilities get spotted early when corrective measures are still inexpensive"

**Solution**: Make review mandatory, but lightweight

#### 10. Rewriting Code During Review

**Description**: Reviewer rewrites author's code instead of suggesting changes

**Problem**:
- Dismisses author's ownership
- Misses opportunity for author to learn
- Simply rude

**Rare Exception**: Pair programming sessions where rewriting is collaborative

**Solution**: Suggest changes, let author implement (unless pair programming)

#### 11. Ignoring Context

**Description**: Reviewing code without understanding the problem it solves

**Example**:
> "Why didn't you use library X?"
> [Because library X doesn't support our use case]

**Solution**: Read PR description, linked issues, commit messages before reviewing code

#### 12. Review Ghosting

**Description**: Requesting changes then never following up

**Problem**:
- Author addresses comments but gets no response
- PR sits in limbo
- Blocks progress

**Solution**: If you request changes, commit to re-reviewing promptly

### 10.4 Organizational Anti-Patterns

#### 13. No Review Standards

**Description**: Every reviewer has different expectations

**Problem**: Authors don't know what "good" looks like

**Solution**: Document team's review criteria and standards

#### 14. Review Metrics Misuse

**Description**: Using review metrics for performance evaluation

**Examples**:
- "You found fewer bugs than teammate X"
- "Your code gets more review comments than others"

**Problem**: Creates gaming behavior and defensive practices

**Solution**: Use metrics for process improvement, never individual evaluation

#### 15. Synchronous Review Requirement

**Description**: Mandating real-time review meetings for all changes

**Problem**:
- Scheduling overhead
- Doesn't scale
- Discourages small, frequent changes

**Solution**: Asynchronous review by default, synchronous only for complex changes

### 10.5 Tool/Process Anti-Patterns

#### 16. Over-Automation Without Human Review

**Description**: Relying solely on automated checks

**Problem**: Automation catches syntax/style, but misses:
- Design issues
- Business logic errors
- Missing edge cases
- Architectural mismatches

**Solution**: Automation + human review

#### 17. Under-Automation (Manual Style Checking)

**Description**: Humans checking what machines should check

**Problem**: Wastes human time on mechanical tasks

**Solution**: Automate formatting, linting, security scanning

### 10.6 Detecting Anti-Patterns

**Warning Signs**:
| Symptom | Likely Anti-Pattern |
|---------|-------------------|
| Authors fear submitting PRs | Aggressive tone, inconsistent standards |
| PRs sit for days without review | Review ghosting, synchronous requirement |
| Extensive back-and-forth on style | Style nitpicking, under-automation |
| Large PRs becoming normal | Large batch reviews, slow review turnaround |
| Only seniors review | Unidirectional reviewing |
| Quick "LGTM" without questions | Rubber stamping |

### 10.7 Key Takeaways

**Healthy Review Culture**:
- ✅ Timely, thorough reviews
- ✅ Constructive, specific feedback
- ✅ Consistent standards
- ✅ Automation for mechanical checks
- ✅ Psychological safety
- ✅ Focus on improvement, not perfection

**Toxic Review Culture**:
- ❌ Delayed or ghost reviews
- ❌ Vague or aggressive feedback
- ❌ Moving goalposts
- ❌ Manual style enforcement
- ❌ Fear of judgment
- ❌ Perfectionism blocking progress

---

## 11. Metrics and Effectiveness

**Sources**:
- [Measuring Code Review Effectiveness](https://www.propelcode.ai/learn/measuring-code-review-effectiveness)
- [Defect Rate Metrics](https://www.minware.com/guide/metrics/defect-rate)
- [Engineering Metrics that Matter](https://www.usehaystack.io/blog/engineering-metrics-that-matter-how-to-evaluate-and-improve-code-reviews)

### 11.1 Why Measure Code Review?

**Core Principle**:
> "Without metrics, teams can't identify bottlenecks, measure improvement, or justify the investment. The right metrics turn code review from a subjective process into a data-driven optimization opportunity."

**Goals of Measurement**:
1. **Identify bottlenecks**: Where are reviews getting stuck?
2. **Measure improvement**: Are we getting better over time?
3. **Justify investment**: Is review providing value?
4. **Guide process changes**: What should we change?

### 11.2 Core Effectiveness Metrics

#### 1. Defect Density

**Definition**: Number of bugs or issues discovered during review, relative to code size

**Formula**:
```
Defect Density = Defects Found / (LOC / 1000)
```

**Interpretation**:
- **Lower defect density** = Review process catching bugs early
- **Higher defect density** = Either poor initial code quality or effective review process

**Benchmarks**:
| Defect Density | Interpretation |
|----------------|----------------|
| < 1 per 1000 LOC | Excellent initial quality or shallow review |
| 1-5 per 1000 LOC | Normal range |
| > 5 per 1000 LOC | Quality issues or very thorough review |

**Caution**: Very low density might indicate rubber-stamping, not quality code

#### 2. Defect Removal Efficiency

**Definition**: Percentage of defects removed during review

**Formula**:
```
DRE = (Defects Found in Review / Total Defects) × 100
```

Where Total Defects = Defects in Review + Defects Escaped to Production

**Research Benchmarks** (from SmartBear):
- **Formal inspections**: 60-65% DRE
- **Informal reviews**: < 50% DRE
- **Testing**: ~30% DRE

**Goal**: Maximize DRE while minimizing review time

#### 3. Escaped Defects

**Definition**: Bugs that were missed during review but found after deployment

**Why Critical**: These represent review failures

**Tracking**:
```
Escaped Defect Rate = Production Bugs / Total Changes Reviewed
```

**Use**: Identify patterns in what review misses (e.g., async bugs, race conditions)

#### 4. Inspection Rate

**Definition**: Speed of code review

**Formula**:
```
Inspection Rate = LOC Reviewed / Inspection Hours
```

**Research Finding** (SmartBear): Beyond **500 LOC/hour**, defect detection drops significantly

**Optimal Range**: 200-400 LOC per 60-90 minutes = ~200-400 LOC/hour

**Use**: Identify reviewers who are rushing (too fast) or over-analyzing (too slow)

#### 5. Defect Rate

**Definition**: Frequency of defect identification

**Formula**:
```
Defect Rate = Defects Found / Inspection Hours
```

**Use**: Measure reviewer effectiveness (but don't use for performance evaluation)

### 11.3 Process Metrics

#### 6. Review Turnaround Time

**Definition**: Time from PR submission to approval

**Measurement**:
```
Turnaround Time = Approval Timestamp - Submission Timestamp
```

**Why Important**: Long turnaround times:
- Block authors
- Encourage larger PRs (batch multiple changes while waiting)
- Reduce flow

**Benchmarks**:
| Turnaround Time | Rating |
|-----------------|--------|
| < 4 hours | Excellent |
| 4-24 hours | Good |
| 1-3 days | Needs improvement |
| > 3 days | Problematic |

**Caution**: Very short times might indicate rubber-stamping

#### 7. Review Iteration Count

**Definition**: Number of review rounds before approval

**Measurement**: Count of "changes requested" → "re-review requested" cycles

**Interpretation**:
| Iterations | Likely Cause |
|------------|--------------|
| 1 | Good initial quality or rubber-stamping |
| 2-3 | Normal |
| 4+ | Unclear requirements, incremental nitpicking, or quality issues |

**Use**: Identify incremental nitpicking anti-pattern

#### 8. PR Size

**Definition**: Lines of code changed per PR

**Measurement**:
```
PR Size = Lines Added + Lines Deleted
```

**Research Benchmarks**:
- **Optimal**: 200-400 LOC
- **Maximum effective**: 400 LOC (Cisco study)

**Correlation**: Larger PRs correlate with:
- Longer review times
- Lower quality feedback (Microsoft research)
- More escaped defects

#### 9. Review Coverage

**Definition**: Percentage of code changes that receive review

**Measurement**:
```
Review Coverage = (Reviewed Changes / Total Changes) × 100
```

**Goal**: 100% for production code

**Acceptable Exceptions**:
- Generated code
- Configuration files
- Documentation-only changes (team decision)

#### 10. Reviewer Participation Rate

**Definition**: Percentage of eligible reviewers who participate

**Measurement**:
```
Participation Rate = Active Reviewers / Total Team Members
```

**Interpretation**:
- **Low participation** (< 50%): Unidirectional reviewing, review burden on few people
- **High participation** (> 80%): Healthy shared ownership

### 11.4 Quality of Feedback Metrics

#### 11. Useful Comment Ratio

**Definition**: Percentage of review comments perceived as useful

**Measurement**: Survey authors periodically:
- "What percentage of review comments helped improve the code?"

**Microsoft Research**: Built classifier with 86.7% precision for identifying useful comments

**Characteristics of Useful Comments** (from research):
- Specific and actionable
- Explain "why," not just "what"
- Focus on design and maintainability
- Suggest alternatives

**Characteristics of Non-Useful Comments**:
- Purely stylistic (should be automated)
- Vague ("This is confusing")
- Personal preference without rationale

#### 12. Comment Type Distribution

**Measurement**: Categorize review comments

**Example Categories**:
| Category | Percentage |
|----------|------------|
| Bug/Logic Error | 30% |
| Design/Architecture | 25% |
| Readability/Maintainability | 20% |
| Style/Formatting | 15% (should be < 10% with automation) |
| Testing | 10% |

**Use**: If style dominates, increase automation

### 11.5 Impact Metrics

#### 13. Post-Release Defect Rate

**Definition**: Bugs found in production per time period

**Measurement**:
```
Post-Release Defects = Production Bugs / Time Period
```

**Use**: Track trend over time; should decrease with effective code review

**Caution**: Many factors affect this beyond code review

#### 14. Knowledge Transfer

**Measurement** (qualitative):
- Survey: "Do you feel you understand areas of the codebase you review?"
- Metric: Number of team members who can work on each module

**Goal**: Code review should reduce bus factor (team risk)

### 11.6 Review Effectiveness Composite Score

**Concept**: Combine multiple metrics into overall effectiveness score

**Example Formula**:
```
Effectiveness Score = (
    0.3 × Defect Removal Efficiency +
    0.2 × (1 - Escaped Defect Rate) +
    0.2 × Review Coverage +
    0.15 × (1 - Normalized Turnaround Time) +
    0.15 × Useful Comment Ratio
) × 100
```

**Use**: Track overall trend, not absolute values

### 11.7 What NOT to Measure

**Anti-Patterns in Metrics**:

| Metric | Why Avoid |
|--------|-----------|
| **Individual defect counts** | Creates gaming, reduces psychological safety |
| **Lines of code reviewed per person** | Encourages shallow review |
| **Number of comments per reviewer** | Rewards nitpicking |
| **Review speed rankings** | Encourages rubber-stamping |

**Principle**: Use metrics for **process improvement**, never for **individual performance evaluation**

### 11.8 Interpreting Metrics: Trade-offs

#### Speed vs Quality

**Observation**: Faster reviews find fewer defects

**Trade-off**: Need to balance:
- Flow (fast feedback)
- Quality (thorough inspection)

**Optimal Point**: Research suggests 200-400 LOC in 60-90 minutes

#### Coverage vs Depth

**Observation**: Reviewing everything shallowly vs. some things deeply

**Strategies**:
- **Critical code**: Deep review (security, core logic)
- **Standard code**: Normal review
- **Low-risk code**: Automated + spot checks

### 11.9 Using Metrics to Improve

**Process**:
1. **Baseline**: Measure current state
2. **Identify Issues**: What metrics are concerning?
3. **Hypothesize**: What might be causing this?
4. **Experiment**: Try a change
5. **Measure**: Did it improve metrics?
6. **Iterate**: Refine or try something else

**Example**:
```
Observation: Turnaround time is 3 days average
Hypothesis: Reviewers aren't notified effectively
Experiment: Implement review reminder bot
Measurement: Turnaround time drops to 1 day
Result: Keep the change
```

### 11.10 Key Takeaways

**Essential Metrics to Track**:
1. **PR Size**: Keep < 400 LOC
2. **Turnaround Time**: Target < 24 hours
3. **Defect Removal Efficiency**: Aim for > 50%
4. **Escaped Defects**: Track trend, should decrease
5. **Review Coverage**: Maintain 100% for production code

**Principles**:
- **Measure to improve**, not to judge individuals
- **Track trends**, not absolute values
- **Balance** speed and quality
- **Automate** what can be automated, measure what matters

---

## 12. Automated Code Review and AI Integration

**Sources**:
- [Automated Code Review in Practice (2024)](https://arxiv.org/abs/2412.18531)
- [AI-powered Code Review with LLMs (2024)](https://arxiv.org/html/2404.18496v2)
- [Does AI Code Review Lead to Code Changes? (2025)](https://arxiv.org/html/2508.18771v1)
- [Automated Code Review Tools 2025 Guide](https://www.propelcode.ai/blog/automated-code-review-tools-and-practices-2025)

### 12.1 Evolution of Code Review Automation

**Timeline**:

| Era | Tools | Capabilities |
|-----|-------|--------------|
| **2000s** | Basic linters | Syntax, style checking |
| **2010s** | Static analyzers | Security scans, complexity metrics |
| **2020s** | AI/LLM-based | Semantic understanding, contextual suggestions |

### 12.2 Layers of Automation

Modern code review automation operates at multiple layers:

#### Layer 1: Baseline Hygiene

**Tools**: Formatters and basic linters
- **Prettier** (JavaScript/TypeScript)
- **Black** (Python)
- **gofmt** (Go)
- **ESLint** (JavaScript)
- **Ruff** (Python)

**What They Catch**:
- Formatting inconsistencies
- Basic style violations
- Unused variables
- Missing semicolons

**Human Impact**: Eliminates 60-80% of trivial review comments

#### Layer 2: Deep Static Analysis

**Tools**: Semantic analyzers
- **SonarQube**: Multi-language, 21 languages
- **CodeQL**: GitHub-native, semantic queries
- **Semgrep**: Pattern-based security scanning
- **DeepSource**: Code quality + security

**What They Catch**:
- Security vulnerabilities (SQL injection, XSS)
- Code smells (high complexity, duplication)
- Performance issues (inefficient algorithms)
- Anti-patterns (god objects, tight coupling)

**False Positive Rate**: 10-30% (SonarQube performs better than AI on this metric)

#### Layer 3: AI-Assisted Review

**Tools**: LLM-powered reviewers
- **GitHub Copilot Code Review**
- **CodeRabbit**: Integrates 40+ linters
- **Qodo (formerly Codium)**: PR Agent
- **Amazon Q Code Reviewer**
- **Propel Code**

**What They Catch**:
- Intent vs. implementation mismatches
- Design issues
- Missing edge cases
- Architectural alignment
- Context-aware suggestions

**Capabilities**:
- Summarize PR intent
- Suggest fixes, not just identify issues
- Explain why changes are needed
- Context from entire codebase

### 12.3 Recent Research Findings (2024-2025)

#### Study 1: Automated Code Review in Practice (2024)

**Context**: 238 practitioners across 10 projects, 4,335 PRs (1,568 with automated reviews)

**Tool**: Qodo PR Agent (based on LLMs)

**Key Findings**:

1. **Adoption Challenge**: Only 1,568 of 4,335 PRs (36%) used automated review despite availability

2. **Human Review Still Dominant**: Automated reviews didn't replace human review; they supplemented it

3. **Comment Types**: AI focused on:
   - Code documentation
   - Testing suggestions
   - Edge case identification

**Conclusion**: AI-assisted review is helpful but not a replacement for human review

#### Study 2: Does AI Code Review Lead to Code Changes? (2025)

**Methodology**: Evaluated 16 AI-driven code review actions from GitHub Marketplace (April-May 2025)

**Key Questions**:
1. Do developers actually act on AI review comments?
2. Which types of AI comments lead to changes?
3. What's the false positive rate?

**Findings**:
- **Action Rate**: Varied widely by tool (10% to 60%)
- **Most Actionable**: Security vulnerabilities, clear bugs
- **Least Actionable**: Stylistic suggestions, vague "improvements"

**Implication**: AI review quality varies significantly by tool

#### Study 3: AI-powered Code Review with LLMs (2024)

**Approach**: Multi-agent system with specialized agents:

1. **Code Review Agent**: General code quality
2. **Bug Report Agent**: Identify defects
3. **Code Smell Agent**: Detect anti-patterns
4. **Code Optimization Agent**: Performance suggestions

**Innovation**: Specialization improves precision vs. single general-purpose reviewer

**Limitation**: Early results, not yet proven at scale

### 12.4 Integration Patterns

#### Pattern 1: Sequential Pipeline

**Workflow**:
```
1. Author submits PR
2. Formatters auto-fix style (Prettier, Black)
3. Linters check syntax (ESLint, Ruff)
4. Static analyzers check security (SonarQube, CodeQL)
5. AI reviewer summarizes + suggests (CodeRabbit)
6. Policy bots check ownership (CODEOWNERS)
7. Human reviewer does final judgment
8. Auto-merge or manual merge
```

**Benefit**: Each layer filters different issues

**Caution**: Too many layers can create noise

#### Pattern 2: Parallel Analysis

**Workflow**:
```
PR submitted → All automated tools run in parallel → Results aggregated → Human review
```

**Benefit**: Faster feedback

**Challenge**: Conflicting suggestions from different tools

#### Pattern 3: Progressive Enhancement

**Workflow**:
```
1. Fast checks first (linters) → immediate feedback
2. Slow checks next (static analysis) → feedback in minutes
3. AI review (requires LLM) → feedback in 1-5 minutes
4. Human review → when available
```

**Benefit**: Authors get quick feedback, can fix obvious issues before human sees it

### 12.5 Best Practices for AI-Assisted Review

#### 1. Use AI for First-Pass, Not Final Decision

**Principle**: AI catches mechanical issues, humans judge design and intent

**Anti-Pattern**: Blindly trusting AI suggestions

**Best Practice**:
- AI identifies candidates for review
- Humans verify and provide context

#### 2. Tune AI to Your Codebase

**Generic AI Problems**:
- Suggests patterns inconsistent with your architecture
- Doesn't understand domain context
- Flags intentional design decisions

**Solution**:
- Configure AI with codebase context
- Provide custom rules
- Build domain-specific prompts

#### 3. Integrate, Don't Replace

**Effective**:
```
Automation handles:
- Formatting (100%)
- Basic style (100%)
- Known vulnerabilities (100%)
- Common smells (80%)

Humans handle:
- Design decisions
- Intent verification
- Context-dependent trade-offs
- Knowledge transfer
```

**Ineffective**: "AI can do all review, we don't need humans"

#### 4. Filter False Positives

**Problem**: AI tools have 10-30% false positive rates

**Solutions**:
- Whitelist known false positives
- Require human verification for blocking issues
- Train team to recognize AI limitations

#### 5. Measure Impact

**Metrics to Track**:
- % of AI comments that lead to code changes
- Escaped defects before and after AI adoption
- Human review time before and after
- Developer satisfaction with AI suggestions

### 12.6 Recommended Tool Stack (2025)

**Baseline (All Projects)**:
- **Formatter**: Language-specific (Prettier, Black, gofmt)
- **Linter**: ESLint, Ruff, golangci-lint, etc.
- **CI Integration**: Run on every commit

**Standard (Most Projects)**:
- **Security Scanner**: Semgrep, Snyk, or CodeQL
- **Code Quality**: SonarQube or DeepSource
- **Dependency Checker**: Dependabot, Renovate

**Advanced (Mature Teams)**:
- **AI Reviewer**: CodeRabbit, GitHub Copilot, or Qodo
- **Custom Rules**: Team-specific patterns
- **Review Automation**: Auto-assign reviewers, auto-merge safe changes

### 12.7 What Automation Can't Replace

**Human Strengths**:

| Capability | Why Humans Win |
|------------|----------------|
| **Intent Understanding** | Requires business context AI doesn't have |
| **Design Trade-offs** | Balancing competing concerns is judgment call |
| **Knowledge Transfer** | Learning happens through discussion |
| **Context Awareness** | Understanding why code exists, not just what it does |
| **Creativity** | Suggesting novel solutions beyond pattern matching |
| **Empathy** | Constructive feedback requires understanding person, not just code |

**Current AI Limitations** (as of 2025):
- Doesn't understand long-term architectural vision
- Can't negotiate trade-offs (performance vs. readability)
- Misses domain-specific constraints
- Generates generic suggestions
- Lacks codebase-specific context (improving, but not there yet)

### 12.8 Future Directions (Research Frontiers)

**Emerging Capabilities**:

1. **Codebase-Aware AI**: LLMs trained on specific repositories
2. **Conversational Review**: AI that can engage in back-and-forth with authors
3. **Automated Fix Generation**: AI that implements its own suggestions
4. **Review Learning**: AI that learns from human reviewer decisions
5. **Multi-Modal Analysis**: Combining code, documentation, issues, PRs, and tests

**Open Questions**:
- How to maintain developer skill as AI handles more routine review?
- What's the right balance of automation vs. human judgment?
- How to preserve knowledge transfer benefits when AI does first-pass review?

### 12.9 Key Takeaways

**Use Automation For**:
- ✅ Formatting and style
- ✅ Known security vulnerabilities
- ✅ Code smells and complexity
- ✅ Test coverage metrics
- ✅ First-pass review

**Keep Humans For**:
- ✅ Design evaluation
- ✅ Intent verification
- ✅ Trade-off decisions
- ✅ Knowledge sharing
- ✅ Final approval

**Implementation Strategy**:
1. Start with linters/formatters (quick wins)
2. Add static security analysis
3. Experiment with AI-assisted review
4. Measure impact
5. Iterate based on team feedback

---

## 13. Common Review Patterns and Checklists

### 13.1 Google's Review Checklist

Based on Google's Engineering Practices, reviewers should check:

**Design Checklist**:
- [ ] Does the CL have appropriate integration with the rest of the system?
- [ ] Is this the right time to add this functionality?
- [ ] Does this solve a real problem, or speculative future need?

**Functionality Checklist**:
- [ ] Does this code do what the developer intended?
- [ ] Are there edge cases that aren't handled?
- [ ] Are there potential concurrency issues?
- [ ] If user-facing, does the UI make sense?

**Complexity Checklist**:
- [ ] Is the code more complex than necessary?
- [ ] Are there simpler approaches?
- [ ] Will future developers understand this easily?
- [ ] Are there over-engineered abstractions?

**Tests Checklist**:
- [ ] Are there appropriate automated tests?
- [ ] Do tests actually test the code?
- [ ] Will tests fail when code breaks?
- [ ] Are tests themselves well-designed?

**Naming Checklist**:
- [ ] Are names descriptive enough?
- [ ] Are names too long?
- [ ] Do names follow conventions?

**Comments Checklist**:
- [ ] Do comments explain WHY, not WHAT?
- [ ] Are comments clear and useful?
- [ ] Are there unnecessary comments?

**Style Checklist**:
- [ ] Does code follow style guide?
- [ ] Are style violations worth blocking for?

**Documentation Checklist**:
- [ ] Is relevant documentation updated?

### 13.2 SmartBear's Defect Checklist

Based on SmartBear research, track defects in these categories:

**Common Defect Types**:
- [ ] Logic errors
- [ ] Null pointer / undefined issues
- [ ] Resource leaks (file handles, connections)
- [ ] Concurrency / race conditions
- [ ] Security vulnerabilities
- [ ] Performance issues
- [ ] Error handling gaps
- [ ] Boundary condition bugs

**Personal Checklist**: Each developer should maintain their own list of "my common mistakes"

### 13.3 Atlassian's Review Categories

**Functionality**:
- [ ] Does code work as intended?
- [ ] Are edge cases handled?
- [ ] Is error handling appropriate?

**Organization/Maintainability**:
- [ ] Can this code be clarified?
- [ ] Is there duplicated code?
- [ ] Are functions/classes appropriately sized?

**Efficiency**:
- [ ] Are there obvious performance issues?
- [ ] Is the algorithm optimal for the use case?

**Documentation**:
- [ ] Are there clear comments where needed?
- [ ] Is public API documented?

### 13.4 Security-Focused Review Checklist

**Input Validation**:
- [ ] Are all inputs validated?
- [ ] Is there protection against injection attacks (SQL, XSS, command)?
- [ ] Are file uploads restricted appropriately?

**Authentication & Authorization**:
- [ ] Are authentication checks present?
- [ ] Are authorization checks correct?
- [ ] Are there privilege escalation risks?

**Data Protection**:
- [ ] Is sensitive data encrypted?
- [ ] Are secrets stored securely (not hardcoded)?
- [ ] Is there appropriate logging (without exposing secrets)?

**Dependencies**:
- [ ] Are third-party dependencies up-to-date?
- [ ] Are there known vulnerabilities in dependencies?

### 13.5 Language-Specific Patterns

#### JavaScript/TypeScript

**Common Patterns to Check**:
- [ ] Proper use of `const`/`let` (avoid `var`)
- [ ] Async/await error handling (`try/catch`)
- [ ] Null/undefined checks (`?.` optional chaining)
- [ ] Type safety (TypeScript types aren't `any`)
- [ ] Closure/scope issues
- [ ] Event listener cleanup

#### Python

**Common Patterns to Check**:
- [ ] Exception handling (catch specific exceptions)
- [ ] Resource cleanup (`with` statements)
- [ ] List comprehensions (not overly complex)
- [ ] Type hints (for public APIs)
- [ ] Mutable default arguments (avoid `def foo(x=[])`)

#### Go

**Common Patterns to Check**:
- [ ] Error handling (not ignoring errors)
- [ ] Goroutine leaks
- [ ] Defer usage (proper cleanup)
- [ ] Pointer vs value receivers
- [ ] Context usage (cancellation, timeouts)

### 13.6 Review Focus by Change Type

#### Bug Fix Review

**Focus On**:
- [ ] Does it actually fix the bug?
- [ ] Are there tests that prevent regression?
- [ ] Are there similar bugs elsewhere?
- [ ] Root cause addressed or just symptom?

#### New Feature Review

**Focus On**:
- [ ] Does design fit architecture?
- [ ] Is it properly tested?
- [ ] Is it documented?
- [ ] Are there edge cases?
- [ ] Is it accessible/usable?

#### Refactoring Review

**Focus On**:
- [ ] Is behavior preserved?
- [ ] Are tests still passing?
- [ ] Is complexity reduced?
- [ ] Is intent clearer?

#### Performance Optimization Review

**Focus On**:
- [ ] Is there benchmark data?
- [ ] Is improvement significant?
- [ ] Are there readability trade-offs?
- [ ] Are edge cases still handled?

### 13.7 Review Prioritization Framework

Not all code deserves the same level of review scrutiny:

| Code Type | Review Depth | Rationale |
|-----------|--------------|-----------|
| **Critical Path** | Deep | Bugs here affect all users |
| **Security-Sensitive** | Deep | Vulnerabilities have serious impact |
| **Public API** | Deep | Changes affect external users |
| **Core Business Logic** | Deep | Errors affect business outcomes |
| **UI/Presentation** | Medium | Issues are visible but usually low-impact |
| **Internal Utilities** | Medium | Limited blast radius |
| **Configuration** | Light | Often reversible |
| **Documentation** | Light | Low risk |

### 13.8 Time-Based Review Strategies

#### Quick Review (< 15 minutes)

**When**: Small PRs (< 100 LOC), low-risk changes

**Check**:
- [ ] Does it work?
- [ ] Are there obvious bugs?
- [ ] Does it follow conventions?

#### Standard Review (30-60 minutes)

**When**: Typical PRs (100-400 LOC)

**Check**: All items in relevant checklists above

#### Deep Review (> 60 minutes, multiple sessions)

**When**: Large features, architectural changes

**Check**: Everything + architectural consistency, long-term maintainability

### 13.9 Key Takeaways

**Effective Checklists**:
- Start with team-wide checklists
- Build personal checklists of your common mistakes
- Customize by language and domain
- Keep checklists short (< 20 items)
- Update based on escaped defects

**Review Prioritization**:
- Not all code needs the same level of scrutiny
- Focus deep review on high-risk, high-impact code
- Light review is okay for low-risk changes

---

## 14. Recent Research (2020-2025)

### 14.1 Microsoft Research: Expectations vs Outcomes

**Study**: "Expectations, Outcomes, and Challenges Of Modern Code Review"

**Method**: Observations, interviews, and surveys across diverse Microsoft development teams

**Key Findings**:

**Top Motivations for Code Review**:
1. Finding defects (primary)
2. Code improvement
3. Alternative solutions
4. Knowledge transfer
5. Team awareness

**Actual Outcomes** (ranked by frequency):
1. **Code improvements** (most common)
2. **Knowledge transfer**
3. **Team awareness**
4. Finding defects (less than expected)

**Insight**: Teams expect defect finding but actually get more value from knowledge transfer and code improvement

### 14.2 Eye-Tracking Research Continued

**2024-2025 Studies**:

**Generative AI Impact Study (2025)**:
- First study examining eye-tracking when students use generative AI for code comprehension
- Finding: Limited research exists on how LLM-generated summaries impact learning

**Remote Eye-Tracking (2024)**:
- Explored using webcams and open-source algorithms for eye-tracking studies
- Makes eye-tracking research more accessible
- Enables remote studies

**Implication for Review**: Eye-tracking could be used to identify confusing code sections during review

### 14.3 Human Factors Research

**Psychological Safety Studies (2024)**:
- Code review identified as frequent source of interpersonal tension
- Teams with higher psychological safety have better software quality
- Key enablers: knowledge sharing, open communication, collaborative problem-solving

**Reviewer Fatigue**:
- Effectiveness drops after 60 minutes of continuous review
- Multiple short sessions better than one long session

### 14.4 Code Review at Scale

**Open Source Code Review Studies**:

**Finding**: Review practices vary significantly between:
- Corporate environments (stricter processes)
- Open source projects (more flexible, varied practices)

**Common Challenges**:
- Reviewer availability
- Maintaining quality with large contributor base
- Balancing thorough review with merge velocity

---

## 15. Design Recommendations for Code Review Skill

### 15.1 How Code Review Skill Differs from Code Reading Skill

**Code Reading Skill** focuses on:
- Building comprehension
- Understanding existing code
- Individual learning process
- Techniques for navigating unfamiliar codebases

**Code Review Skill** should focus on:
- Evaluating proposed changes
- Decision-making processes
- Giving constructive feedback
- Team collaboration and communication
- Balancing quality with velocity

### 15.2 Suggested Skill Structure

```markdown
# Code Review Skill

## Overview
Systematic approach to code review based on cognitive science, industry best practices,
and research on effective feedback and team dynamics.

## When to Use This Skill
- User is reviewing a pull request
- User asks how to give feedback on code
- User mentions "code review," "PR review," "reviewing changes"
- User wants to improve review process or culture

## Core Philosophy
Code review is a decision-making process that:
1. Evaluates whether changes improve code health
2. Provides constructive feedback to authors
3. Transfers knowledge across the team
4. Maintains quality standards
5. Builds team culture and psychological safety
```

### 15.3 Key Sections to Include

#### Section 1: The Review Mindset

**Content**:
- Kent Beck's five effects of code review
- Google's standard: approve if it improves code health
- Focus on improvement, not perfection
- Review is about the code, not the person

#### Section 2: The Review Process

**Content**:
- Two-phase cognitive model (Orientation → Analytical)
- Context-building phase checklist
- Code inspection techniques
- Decision-making framework
- When to approve, request changes, or comment

#### Section 3: What to Look For

**Content**:
- Google's 8 dimensions (Design, Functionality, Complexity, Tests, Naming, Comments, Style, Documentation)
- Language-specific patterns
- Security checklist
- Review prioritization framework

#### Section 4: Giving Constructive Feedback

**Content**:
- Conventional comments pattern
- Ask questions, don't demand
- Be specific and actionable
- Use I-messages
- Balance positive and constructive
- Comment templates and examples

#### Section 5: Review Strategies

**Content**:
- Size matters: 200-400 LOC optimal
- Speed matters: < 500 LOC/hour
- Time matters: < 60 minutes per session
- Focused vs. comprehensive review
- When to review locally vs. reading only

#### Section 6: Team Dynamics

**Content**:
- Building psychological safety
- Handling disagreements
- Giving and receiving feedback
- Unidirectional vs. bidirectional review
- Creating a review culture

#### Section 7: Anti-Patterns to Avoid

**Content**:
- Incremental nitpicking
- Rubber stamping
- Scope creep
- Aggressive tone
- Style nitpicking
- Review ghosting

#### Section 8: Metrics and Continuous Improvement

**Content**:
- Key metrics to track
- Review effectiveness measurement
- Using metrics for process improvement
- What NOT to measure

#### Section 9: Automation and Tooling

**Content**:
- What to automate (formatting, linting, security scanning)
- What to keep human (design, intent, trade-offs)
- Integrating AI-assisted review
- Tool recommendations by language

#### Section 10: Review Scenarios

**Content**:
- Reviewing a bug fix
- Reviewing a new feature
- Reviewing a refactoring
- Reviewing a performance optimization
- Reviewing generated code (AI-written)

### 15.4 Integration with Code Reading Skill

**Cross-References**:

Code Review skill should reference Code Reading skill for:
- Understanding the existing codebase (needed for review context)
- Comprehension techniques (needed before evaluation)
- Code smells and refactoring patterns

Code Reading skill should reference Code Review skill for:
- How reading differs when reviewing
- Using reading techniques to prepare for review
- Writing code that's easier to review

**Workflow Integration**:
```
1. Use Code Reading techniques to understand the change
2. Apply Code Review decision-making processes
3. Provide feedback using Code Review communication patterns
4. Suggest refactorings using Code Reading pattern library
```

### 15.5 Unique Elements for Code Review Skill

**Must Include (Not in Code Reading)**:

1. **Communication Patterns**:
   - How to phrase suggestions
   - Conventional comments
   - Handling disagreements

2. **Decision Framework**:
   - Approve vs. request changes vs. comment
   - Blocking vs. non-blocking feedback
   - When to escalate

3. **Team Dynamics**:
   - Psychological safety
   - Review culture building
   - Bidirectional review

4. **Process Optimization**:
   - Metrics
   - Turnaround time
   - Review workflow

5. **Automation Integration**:
   - What machines should check
   - What humans should check
   - AI-assisted review

### 15.6 Actionable Workflows

**Scenario-Based Workflows**:

#### Workflow 1: Reviewing a Small PR (< 200 LOC)

```
1. Read PR description and linked issue
2. Review changed files in order of importance
3. Check for obvious issues (functionality, bugs)
4. Verify tests exist and are meaningful
5. Provide feedback using conventional comments
6. Approve if improves code health
```

#### Workflow 2: Reviewing a Large PR (> 400 LOC)

```
1. Ask author to split if possible
2. If can't split:
   a. Request architectural overview
   b. Review in multiple sessions
   c. Focus on different aspects each session
   d. Use more focused review strategies
```

#### Workflow 3: Your First Review as a Junior Developer

```
1. Read code using Code Reading techniques
2. Ask questions, don't make demands
3. Focus on understanding, not judging
4. Flag things you find confusing (valuable signal!)
5. Acknowledge you're learning
```

### 15.7 Cognitive Models Unique to Review

**Include**:
- Code Review Comprehension Model (CRCM)
- Code Review as Decision-Making (CRDM)
- Comparison with code reading comprehension models
- Recognition-primed decision-making in review context

### 15.8 Research Foundations

**Key References to Include**:
- Kent Beck: "Thinking About Code Review"
- Google Engineering Practices
- Microsoft Research: "Characteristics of Useful Code Reviews"
- SmartBear: 11 Best Practices
- Academic: CRCM and CRDM models (2025)
- Psychological Safety in Software Teams (2024)

### 15.9 Practical Tools and Templates

**Include**:
- PR description template
- Review comment templates
- Review checklist (customizable by language)
- Team retrospective questions for review process

### 15.10 Success Metrics

**How to Measure If Skill Is Effective**:

For Users:
- Reduced review turnaround time
- Improved PR description quality
- More constructive feedback
- Better team relationships

For Teams:
- Higher review participation
- Fewer escaped defects
- Improved code quality metrics
- Better psychological safety scores

---

## 16. References

### Industry Sources

**Kent Beck**:
- [Thinking About Code Review](https://tidyfirst.substack.com/p/thinking-about-code-review) - tidyfirst.substack.com

**Google**:
- [Engineering Practices Documentation](https://google.github.io/eng-practices/)
- [What to Look for in a Code Review](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
- [The Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html)
- [GitHub: google/eng-practices](https://github.com/google/eng-practices)

**Microsoft Research**:
- [Characteristics of Useful Code Reviews: An Empirical Study at Microsoft](https://www.microsoft.com/en-us/research/publication/characteristics-of-useful-code-reviews-an-empirical-study-at-microsoft/)
- [Expectations, Outcomes, and Challenges Of Modern Code Review (PDF)](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/ICSE202013-codereview.pdf)

**SmartBear**:
- [Best Practices for Code Review](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)
- [The 10 Best Practices For Peer Code Review](https://smartbear.com/blog/the-10-best-practices-for-peer-code-review/)
- [11 Best Practices for Peer Code Review (PDF)](http://viewer.media.bitpipe.com/1253203751_753/1284482743_310/11_Best_Practices_for_Peer_Code_Review.pdf)

**Atlassian**:
- [5 Code Review Best Practices](https://www.atlassian.com/blog/add-ons/code-review-best-practices)
- [What Are Code Reviews](https://www.atlassian.com/agile/software-development/code-reviews)

**GitHub**:
- [Best Practices for Reviewing Pull Requests](https://rewind.com/blog/best-practices-for-reviewing-pull-requests-in-github/)
- [How to Review Code Effectively: A GitHub Staff Engineer's Philosophy](https://github.blog/developer-skills/github/how-to-review-code-effectively-a-github-staff-engineers-philosophy/)

**ThoughtWorks**:
- [Agile Overview](https://www.thoughtworks.com/perspectives/edition1-agile)

### Academic Research (2020-2025)

**Cognitive Models**:
- [Code Review Comprehension: Reviewing Strategies](https://arxiv.org/abs/2503.21455) - arXiv, 2025
- [Code Review as Decision-Making](https://arxiv.org/abs/2507.09637) - arXiv, 2025

**AI-Assisted Review**:
- [Automated Code Review In Practice](https://arxiv.org/abs/2412.18531) - arXiv, December 2024
- [AI-powered Code Review with LLMs: Early Results](https://arxiv.org/html/2404.18496v2) - arXiv, 2024
- [Does AI Code Review Lead to Code Changes? A Case Study of GitHub Actions](https://arxiv.org/html/2508.18771v1) - arXiv, 2025
- [A Review of Research on AI-Assisted Code Generation and AI-Driven Code Review](https://drpress.org/ojs/index.php/ajst/article/view/32600) - Academic Journal of Science and Technology, 2025

**Eye-Tracking Studies**:
- [Recognizing Eye Tracking Traits for Source Code Review](https://ieeexplore.ieee.org/document/8247637) - IEEE
- [Collaborative Eye Tracking Based Code Review](https://link.springer.com/article/10.1007/s11704-020-0422-1) - Frontiers of Computer Science, 2020
- [Design of An Eye-Tracking Study on Generative AI Use](https://dl.acm.org/doi/10.1145/3715669.3725868) - ACM, 2025

**Psychological Safety**:
- [Psychological Safety in Software Workplaces: A Systematic Literature Review](https://arxiv.org/html/2508.03369) - arXiv, 2024
- [The Role of Psychological Safety in Promoting Software Quality](https://link.springer.com/article/10.1007/s10664-024-10512-1) - Empirical Software Engineering, 2024

### Tools and Practices

**Feedback Techniques**:
- [Best Practices for Writing Constructive Code Review Feedback](https://blog.pixelfreestudio.com/best-practices-for-writing-constructive-code-review-feedback/)
- [How to Give Respectful and Constructive Code Review Feedback](https://www.michaelagreiler.com/respectful-constructive-code-review-feedback/)
- [Better Feedback with Conventional Comments](https://dev.to/jacobandrewsky/better-feedback-in-code-reviews-with-conventional-comments-2c3k)
- [Code Review Therapy: Psychology of Feedback](https://pullflow.com/blog/psychology-of-code-reviews-feedback-that-helps/)

**Anti-Patterns**:
- [Code Review Antipatterns](https://www.chiark.greenend.org.uk/~sgtatham/quasiblog/code-review-antipatterns/)
- [Code Review Anti-Patterns - DEV Community](https://dev.to/adam_b/code-review-anti-patterns-2e6a)
- [Anti-patterns for Code Review - AWS](https://docs.aws.amazon.com/wellarchitected/latest/devops-guidance/anti-patterns-for-code-review.html)

**Metrics and Effectiveness**:
- [Measuring Code Review Effectiveness](https://www.propelcode.ai/learn/measuring-code-review-effectiveness)
- [Defect Rate Metrics](https://www.minware.com/guide/metrics/defect-rate)
- [Engineering Metrics that Matter](https://www.usehaystack.io/blog/engineering-metrics-that-matter-how-to-evaluate-and-improve-code-reviews)

**Automated Review**:
- [Automated Code Review Tools 2025 Guide](https://www.propelcode.ai/blog/automated-code-review-tools-and-practices-2025)
- [The 6 Best AI Code Review Tools for 2025](https://dev.to/heraldofsolace/the-6-best-ai-code-review-tools-for-pull-requests-in-2025-4n43)
- [13 Best Static Code Analysis Tools](https://www.qodo.ai/blog/best-static-code-analysis-tools/)

---

**End of Report**
