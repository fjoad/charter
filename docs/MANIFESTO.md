# The Charter Manifesto

---

## The Problem with AI-Assisted Development Today

You start a session. You explain the project. You explain where you left off. You explain which decisions were already made and why. You approve the same patterns you approved last week. You watch the AI skip the finish checklist because context pressure is high and it wants to appear done. You fix the docs that didn't get updated. You re-derive what should have been written down.

Then you do it again next session.

This is not a prompt engineering problem. It's a project management problem.

---

## The Model

**You're the manager. The AI is your dev team. Charter is your PMO.**

Your dev team is brilliant and fast. But they arrive at the office every morning with no memory of yesterday. They don't know the project vision unless you tell them. They don't know which step you're on unless they check the board. They don't know your team's rituals unless those rituals are written down and enforced.

Without structure, a smart team becomes chaotic. With structure, they become unstoppable.

Charter provides the structure.

---

## What Charter Does

**At session start:** Reads your STATUS.md and tells your dev team where they left off. Zero re-explanation required.

**On every request:** Classifies the size of what you're asking. Small request? Execute directly. Architecture change? Full plan, checkpoint, verify, report. The discipline scales to the work.

**At step completion:** Enforces the finish checklist. Tests run. Docs updated. Status recorded. Standard report to you. No skipped steps.

**Checkpoint-based autonomy:** Your dev team runs autonomously between checkpoints. At each checkpoint, they pause and report. You decide whether to continue, redirect, or stop. You stay in control without micromanaging.

---

## What Charter Is NOT

**Not a code generator.** Charter doesn't write your code. It disciplines the process of writing code.

**Not spec-driven.** You don't need to write a 50-page spec before you can start. Charter works with whatever docs exist and grows them as you go.

**Not a new framework.** Charter doesn't change how you write Python, TypeScript, or Go. It adds discipline on top of whatever stack you're using.

**Not a replacement for superpowers.** Charter routes to superpowers skills at the right moment. It needs superpowers to function well.

---

## The Three Rituals

Charter operates at three scopes:

**Session ritual (~200 tokens, once per session)**  
Your dev team reads the board before starting work. STATUS.md, current plan, what's next. Costs less than a paragraph of context. Buys you a fully oriented team.

**Turn ritual (~20 tokens, every request)**  
Before responding to anything, your dev team classifies the work: trivial, small, medium, or major. Each tier has a ritual. A typo fix gets direct execution. A refactor gets a plan, tests, verification, and a report. The discipline matches the risk.

**Finish ritual (~500 tokens, per step)**  
No step is done until the finish checklist passes. Tests green. Status updated. Docs current. Commit pushed. Report to manager. This is what it means to finish.

---

## The Whisper Not Shout Principle

Charter's hooks are quiet. The session-start orient block is ~200 tokens in a 200k context window — less than 0.1%. The per-turn nudge is 20 tokens. Charter doesn't shout. It whispers at the right moments.

The rituals are enforced through rules loaded into Claude's context, not through aggressive prompting. The hooks are reminders, not walls. The escape hatch (`/charter-off`) exists for when you genuinely don't want the overhead.

---

## Why Now

The Claude Code plugin system makes this possible. Hooks fire on session start and prompt submit. Skills provide reusable instruction modules. Commands give you one-word invocations of complex workflows. The infrastructure exists. Charter uses it.

Superpowers proved that layered workflow disciplines work in practice. Charter takes that discipline and adds session continuity — the piece superpowers doesn't provide.

---

## The Charter Promise

Install Charter. Run `/charter-init`. Start your project. Come back tomorrow. Your AI dev team will know exactly where you left off.

That's it. That's Charter.
