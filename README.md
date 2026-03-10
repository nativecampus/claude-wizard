# claude-wizard

**Turn Claude Code from a fast coder into a senior software architect.**

Claude Code is brilliant at writing code quickly. But speed without structure leads to bugs, race conditions, and regressions that eat the time you saved — and then some. `/wizard` changes the operating mode: Claude reads before writing, tests before implementing, and attacks its own code before committing.

## What it does

`/wizard` is a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills) that transforms how Claude approaches complex tasks. Instead of jumping straight to code, it follows an 8-phase development cycle:

1. **Understand** — Read project docs, assess complexity, create a plan
2. **Explore** — Search the codebase, verify assumptions, identify patterns
3. **Test first** — Write failing tests before any implementation (TDD)
4. **Implement** — Minimal code to pass tests, following existing conventions
5. **Verify** — Run the appropriate test suite, fix regressions
6. **Document** — Update docs and GitHub issues
7. **Self-review** — Adversarial checklist: race conditions, edge cases, security
8. **PR quality gate** — Monitor automated review bots, resolve all findings

Each phase has a checkpoint. Claude won't rush ahead.

## The difference

**Without `/wizard`:**
> You: "Add a transfer status tracking feature"
>
> Claude: *immediately writes 400 lines of code, misses a race condition, hard-codes a string that should be a constant, skips tests*

**With `/wizard`:**
> You: `/wizard Add a transfer status tracking feature`
>
> Claude: *reads the codebase, creates a GitHub issue, writes failing tests, implements with locking to prevent concurrent conflicts, runs the test suite, self-reviews for edge cases, opens a PR, resolves all bot findings*

The output is the same — working code. But the `/wizard` code ships without the 2am "why is this broken in production" follow-up.

## Install

**One command** from your project root:

```bash
curl -sL https://raw.githubusercontent.com/vlad-ko/claude-wizard/main/install.sh | bash
```

Or manually:

```bash
mkdir -p .claude/skills/wizard
curl -sL https://raw.githubusercontent.com/vlad-ko/claude-wizard/main/skill/SKILL.md -o .claude/skills/wizard/SKILL.md
curl -sL https://raw.githubusercontent.com/vlad-ko/claude-wizard/main/skill/CHECKLISTS.md -o .claude/skills/wizard/CHECKLISTS.md
curl -sL https://raw.githubusercontent.com/vlad-ko/claude-wizard/main/skill/PATTERNS.md -o .claude/skills/wizard/PATTERNS.md
```

## Usage

In Claude Code, type:

```
/wizard implement the user authentication flow
```

Claude will respond with `## [WIZARD MODE]` and begin the phased approach. You'll see phase transitions as it works:

```
## [WIZARD MODE] Phase 1: Understanding & Planning
...
## [WIZARD MODE] Phase 3: Test-Driven Development
...
```

You can also invoke it mid-conversation:

```
/wizard this is getting complex — let's be more systematic about this
```

## What's included

| File | Purpose |
|------|---------|
| `SKILL.md` | The core skill — 8-phase development methodology |
| `CHECKLISTS.md` | Quick-reference checklists for each phase |
| `PATTERNS.md` | Common patterns and anti-patterns with examples |

## Customization

The skill is designed to be extended. Add your project-specific patterns:

**Framework conventions** — Add your framework's testing commands, directory structure, and coding standards to Phase 2 and Phase 4.

**Logging patterns** — Replace the generic logging guidance with your project's specific logging approach.

**CI/CD integration** — Customize Phase 8 with your specific CI bot names and quality gate requirements.

**Team conventions** — Add commit message formats, PR templates, and review processes.

Edit `.claude/skills/wizard/SKILL.md` directly — it's your copy.

## How it works

Claude Code [skills](https://docs.anthropic.com/en/docs/claude-code/skills) are markdown files that activate when invoked with `/skillname`. They inject additional context and instructions into Claude's prompt, changing its behavior for the duration of the task.

`/wizard` works by:
1. Shifting Claude's identity from "coder" to "architect"
2. Enforcing a phased workflow with explicit checkpoints
3. Requiring TDD — tests before implementation
4. Adding adversarial self-review before every commit
5. Ensuring automated review findings are resolved, not ignored

There's no magic. It's a well-structured prompt that encodes the habits of senior engineers into a repeatable process.

## Origin

This skill was developed over months of production use on a fintech platform ([wealthbot.io](https://wealthbot.io)) — a Laravel application managing investment portfolios, ACAT transfers, and regulatory compliance. The patterns were refined through hundreds of PRs, real race conditions caught by the adversarial review phase, and Bug Bot findings that would have reached production without the quality gate cycle.

The framework-specific details have been stripped to make it universal. The methodology works with any language, framework, or stack.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- A git repository (the skill uses `gh` CLI for GitHub integration)

## License

MIT
