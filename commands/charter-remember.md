---
description: "Capture something to docs/CONTEXT.md so it survives /compact. Use for explicit emphases the AI might otherwise miss."
argument-hint: "<thing to remember>"
---

The user wants you to capture context to working memory.

$ARGUMENTS

Process:

1. **Check `docs/CONTEXT.md` exists.** If not, tell the user: "No CONTEXT.md in this project — run `/charter-adopt context` to scaffold it." Do not create the file yourself.

2. **Categorize the content.** Choose the best-fit section:
   - **Environment Quirks** — non-obvious facts about runtime, OS, tools, services
   - **Working Patterns** — code snippets / commands that work, with a one-line "why"
   - **Don't Repeat** — things tried that fail, with symptom + the right alternative
   - **Open Questions** — mid-stream threads not yet captured in a plan or decision
   - **User Emphases** — direct quotes or paraphrased emphasis from the user

3. **Append to that section.** Keep it terse: 1-2 lines max per entry. Format as a bullet.

4. **Update "Last updated"** date in CONTEXT.md.

5. **Commit** if on main and the working tree is otherwise clean. On a feature branch, just save the change (it'll roll up with the branch's work).

6. **Confirm** with one line: `Captured to CONTEXT.md § [section]: "[first 60 chars]"`

Do not duplicate existing entries. If the captured content paraphrases something already in CONTEXT.md, merge rather than append.
