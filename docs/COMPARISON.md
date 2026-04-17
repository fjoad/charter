# Charter vs Alternatives

How Charter relates to other tools in the space.

---

## Charter vs superpowers

**superpowers** provides reusable workflow skills: writing plans, TDD, verification, debugging, subagent dispatch. It's a skills library.

**Charter** provides project discipline: living docs, session continuity, ritual tiering, finish checklists. It's a project management layer.

**Relationship:** Charter layers on top of superpowers. Charter's `turn-ritual.md` routes to superpowers skills at the right moment. superpowers skills are the execution engine; Charter is the routing layer and the memory layer.

**Use both.** Charter without superpowers is a living-docs scaffold with no execution discipline. superpowers without Charter is strong execution skills with no session continuity.

---

## Charter vs spec-kit / kiro / spec-driven tools

**Spec-driven tools** (Kiro, OpenSpec, spec-kit) require upfront specification before any code is written. The spec is the contract; implementation follows the spec.

**Charter** is discipline-first, not spec-first. You can start with a paragraph-length vision. Charter grows the docs as you build. STATUS.md is the living spec — it reflects what was actually decided and built, not an upfront plan.

**When to use spec-driven:** You have a well-defined system to implement and want the AI to stay within strict contracts.

**When to use Charter:** You're exploring, building iteratively, or want AI discipline without upfront spec overhead.

---

## Charter vs bootstrap frameworks (create-react-app, etc.)

**Bootstrap frameworks** scaffold code. They give you a starting codebase with sensible defaults for a particular stack.

**Charter** scaffolds discipline. It gives you living docs and rules, not code. Stack-agnostic.

**Relationship:** Use a bootstrap framework for your code, Charter for your AI-assisted development workflow. They're orthogonal.

---

## Charter vs CLAUDE.md / AGENTS.md by hand

You can write your own `CLAUDE.md` or `AGENTS.md` without Charter. Many teams do.

**Without Charter:** You write the docs yourself, update them manually, hope the AI reads them, and repeat orientation manually when you forget something.

**With Charter:** The docs are templated correctly from the start, the hooks orient Claude automatically, rituals are enforced, and `/charter-finish` forces the docs to stay current.

Charter is the difference between having a `CLAUDE.md` that exists and having one that actually works.

---

## Charter vs workflow prompt templates

Some developers use shared system prompts or workflow templates that tell Claude how to behave.

**Prompt templates:** Applied once at session start. Static. Can't reflect project state. Don't update as the project evolves.

**Charter:** Hook-driven, state-aware, project-specific. The session-start orient block reads your actual STATUS.md. Rules evolve with your project.

---

## Charter vs Cursor's CURSOR.md / OpenAI's CODEX.md

These are per-editor equivalents of CLAUDE.md — a static instruction file that tells the editor's AI how to behave.

**Charter is AGENTS.md + a plugin.** AGENTS.md works across Claude Code, Codex CLI, and (via adapter) Cursor and Copilot. The plugin layer adds session-start orientation and turn-nudge hooks that a static file can't provide.

Charter is AGENTS.md done right: templated correctly, kept current, hooked into the tool.
