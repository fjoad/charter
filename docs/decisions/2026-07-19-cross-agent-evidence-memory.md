# Decision: Shared agent bootstrap and opt-in causal evidence memory

**Date:** 2026-07-19

## Decision

Charter uses `AGENTS.md` as the single agent-neutral project bootstrap. `CLAUDE.md` explicitly imports it;
Codex discovers it directly. Claude-only rules and hooks may automate the shared contract but may not hold
unique project truth.

Charter also adds an opt-in `/charter-adopt evidence` convention that creates a durable
`docs/EVIDENCE-AND-LEARNINGS.md` alongside compact `CONTEXT.md`.

## What was considered

1. **Keep a Markdown link from CLAUDE.md to AGENTS.md.** Rejected because a human-readable pointer is
   weaker than Claude Code's explicit `@AGENTS.md` import and makes shared loading less deterministic.
2. **Duplicate instructions in CLAUDE.md and AGENTS.md.** Rejected because the two copies inevitably drift;
   Codex and Claude could then act on different project truth.
3. **Put all causal history in CONTEXT.md.** Rejected because CONTEXT is intentionally capped/pruned around
   200 lines and represents active memory, not a permanent correction log.
4. **Scaffold evidence into every project and auto-inject it.** Rejected because many projects do not need
   it, and a growing history would become permanent context overhead.
5. **Chosen:** canonical AGENTS + explicit Claude import; optional durable evidence, read on demand.

## Why this choice

AraClawBench provided the discriminating real-world case: ordinary docs captured current facts, but raw
chat history still carried why apparently reasonable conclusions were overturned. A compact CONTEXT file
could not safely preserve all those causal chains forever. The useful abstraction is a separate durable
layer with evidence labels and supersession preserved.

Backward compatibility remains load-bearing. Existing projects keep working unchanged. New templates are
evidence-aware but tolerate the file being absent; existing projects opt in idempotently.

## Why no new command

The existing `/charter-adopt` command already owns optional conventions, and `/charter-preview` already
previews them. Adding `/charter-evidence` would duplicate setup semantics and violate Charter's
surface-growth guardrail. The feature is therefore `/charter-adopt evidence`.

## Impact

- Claude and Codex consume the same canonical instructions without duplicate maintenance.
- Claude keeps automatic hooks; Codex uses the file-based reading contract. Cross-agent support does not
  imply identical runtime integration.
- STATUS, CONTEXT, evidence, and ADRs have explicit distinct lifecycles.
- Recovery reads durable evidence only when cited or relevant, preserving the token budget.
- Projects that do not need causal evidence incur no new file or session-start overhead.
