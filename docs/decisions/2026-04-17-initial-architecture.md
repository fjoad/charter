# Decision: Initial Charter Architecture

**Date:** 2026-04-17

---

## Decision

Charter is a Claude Code plugin that layers on top of superpowers, uses AGENTS.md as the canonical doc, enforces checkpoint-based autonomy, and classifies requests into four tiers (trivial/small/medium/major) with matching ritual depth.

---

## What Was Considered

**1. Fork superpowers vs. layer on top**  
Considered forking superpowers and adding Charter's features inline. Rejected: superpowers has its own development velocity and community. A fork diverges and requires maintenance. Charter as a consumer of superpowers gets updates for free.

**2. CLAUDE.md vs. AGENTS.md as canonical doc**  
CLAUDE.md is Claude Code-specific. AGENTS.md is an emerging multi-tool standard co-created by Google, OpenAI, Cursor, Factory, and Sourcegraph — 60k+ repos already use it. Codex CLI auto-discovers AGENTS.md. Chose AGENTS.md as canonical with CLAUDE.md as a one-line pointer.

**3. Strict enforcement vs. trust-based rituals**  
Could enforce rituals through hooks that block progress until checklist is complete. Rejected for v1: too rigid, would cause friction in legitimate edge cases, no real-use data yet on where drift actually occurs. Chose rule-based enforcement (auto-loaded turn-ritual.md + 20-token nudge) with `/charter-off` escape hatch.

**4. Flat ritual vs. tiered ritual**  
Single ritual applied to all requests (like a monolithic CLAUDE.md workflow). Rejected: a typo fix shouldn't trigger a full TDD cycle; an architecture change shouldn't skip planning. Tiered ritual (trivial/small/medium/major) prevents both over- and under-discipline.

**5. Session-start hook content**  
Considered injecting full ARCHITECTURE.md + VISION.md at session start. Rejected: too many tokens, most sessions don't need it. Chose STATUS.md + active plan only (~200-800 tokens). Other docs available on-demand.

---

## Why This Choice

The core insight: AI-assisted projects drift because context resets, not because the AI is bad at code. The fix is a lightweight memory + orientation layer, not a heavier coding assistant. Charter minimizes its own footprint (< 2% of context window) while maximizing session-to-session coherence.

The "manager/dev-team" framing drove the checkpoint model: the manager (user) should be in control at decision boundaries, not micromanaging every line. Between checkpoints, the team (AI) runs autonomously. At checkpoints, the manager reviews and redirects.

---

## Impact

- superpowers dependency: teams must install both. README notes this clearly.
- AGENTS.md canonical: future Cursor/Copilot adapters point to AGENTS.md (not tool-specific files)
- Checkpoint model: plans must include `## CHECKPOINT:` markers for major work
- Template scope: template/ is what Charter copies into user projects; docs/ is Charter's own docs. Two parallel trees. Non-overlapping.
- Dogfood: Charter is built in its own repo using Charter's own templates. Any friction is diagnostic data.
