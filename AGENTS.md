# AGENTS.md

## Project Overview
This repository contains a streamlined application designed with a focused, minimal scope.
Refer to this file for guidance on architectural decisions, coding style, and debugging standards.

## Business Requirements & MVP Scope
* Focus strictly on delivering core functionality defined in the MVP task.
* Do not build speculation features, premature extensions, or unrequested options.
* Keep user interactions smooth, direct, and intentional.

## Technical Decisions
* **Package Manager:** Use `uv` for Python environment and dependency management (`uv add`, `uv run`).
* **Backend:** Python / FastAPI.
* **Frontend:** Clean, modern frontend framework (e.g., Next.js or Flutter depending on module target).
* **Environment:** Containerized execution with Docker and local runtime compatibility.
* **Database:** Lightweight local database (SQLite / PostgreSQL container).
* **AI / API Integrations:** Managed via unified API routers (e.g., OpenRouter / OpenAI SDK).

## Core Coding Standards
* Use latest versions of libraries and idiomatic approaches as of today
* **Keep it Simple:** NEVER over-engineer. ALWAYS simplify. Avoid unnecessary defensive programming or speculative abstraction layers.
* **Clarity over Verbosity:** Keep documentation, READMEs, and inline comments brief and readable.
* **No Emojis:** Do not include emojis in code comments, commit messages, or user-facing logs.
* **Modern Idiomatic Practices:** Utilize the latest language features, type hints, and framework-recommended idioms.
* When hitting issues, always identify root cause before trying a fix. Do not guess. Prove with evidence, then fix the root cause.

## Debugging & Problem Solving Strategy
* **Root Cause First:** When encountering errors or test failures, investigate and identify the root cause before attempting a fix.
* **No Guesswork:** Do not guess solutions or throw speculative patches at broken code. Prove the issue with logs, traces, or reproduction steps first, then apply the minimal correct fix.

## UI & Design Guidelines (If Applicable)
* Maintain clean visual hierarchy with consistent spacing and typography.
* Ensure clear state feedback (loading, error, empty state) for user-facing workflows.

## VERY IMPORTANT
- Be simple. Approach tasks in a simple, incremental way.
- Work incrementally ALWAYS. Small, simple steps. Validate and check each increment before moving on.
- Use LATEST apis as of NOW

## MANDATORY Code Style
- Do not overengineer. Do not program defensively. Use exception managers only when needed.
- Identify root cause before fixing issues. Prove with evidence, then fix.
- Work incrementally with small steps. Validate each increment.
- Use latest library APIs.
- Use `uv` as Python package manager. Always `uv run xxx` never `python3 xxx` , always `uv add xxx` never `pip install xxx`
- Favor clear, concise docstring comments. Be sparing with comments outside docstrings.
- Favor short modules, short methods and functions. Name things clearly.
- Never use emojis in code or in print statements or logging
- Keep README.md concise

## Important - debugging and fixing
- When troubleshooting problems, ALWAYS identify root cause BEFORE fixing
- Reproduce consistently
- PROVE THE PROBLEM FIRST – don't guess.
- Try one test at a time. Be methodical.
- Don't jump to conclusions. Don't apply workarounds.

https://github.com/ed-donner/pm/blob/main/AGENTS.md     