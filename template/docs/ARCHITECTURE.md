# [Project Name] — Architecture

<!-- GUIDANCE: This doc answers "how does it work?" at a structural level. Not line-by-line code explanation — that belongs in code comments. Focus on: what are the major components, how do they fit together, what are the key interfaces between them. Update when architecture changes. -->

**Last updated:** [DATE]

---

## Overview

<!-- GUIDANCE: 2-3 sentences. What is the overall shape of this system? "A CLI tool that reads X, transforms it via Y, and outputs Z." Include a one-paragraph description of the major pieces and how they connect. -->

---

## Structure

<!-- GUIDANCE: File/directory tree showing the major components. Add a one-line description of each. Don't list every file — just the structural pieces that matter. -->

```
[project-root]/
  [component-1]/    # [What it does]
  [component-2]/    # [What it does]
  [shared]/         # [What it does]
```

---

## Key Interfaces

<!-- GUIDANCE: What are the contracts between components? If two modules interact, what does the caller pass in and what does it get back? This is the most valuable section — it's what the AI needs to know when implementing a component that connects to another. -->

### [Interface 1]

```
[signature or schema]
```

[One-sentence description of what this does and what callers can expect.]

---

## Data Flow

<!-- GUIDANCE: Walk through the main use case from input to output. "User runs X → system does Y → returns Z." Diagrams are great if you want them, but prose is fine too. -->

1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## Key Design Decisions

<!-- GUIDANCE: List 2-3 architectural decisions that would surprise someone reading the code. These are the "why X instead of Y" things. Full ADRs go in docs/decisions/ — this section just calls attention to the most important ones. -->

- **[Decision]:** [Why this choice was made]

---

## How to Extend

<!-- GUIDANCE: Fill this in as the project grows. What's the intended extension point? Where should new features go? What shouldn't be touched? This section exists to prevent well-intentioned changes from breaking the architecture. -->

- To add [thing]: [where it goes and what it needs to implement]
