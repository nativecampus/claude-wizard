# claude-wizard

**Turn Claude Code from a fast coder into a disciplined software engineer.**

Claude Code is brilliant at writing code quickly. But speed without structure leads to bugs, race conditions, and regressions that eat the time you saved — and then some. `/wizard` changes the operating mode: Claude reads before writing, tests before implementing, refactors before moving on, and verifies adversarial test coverage before committing.

## The ingredients

`/wizard` isn't just a prompt — it's a workflow built on specific ingredients that work together:

1. **`CLAUDE.md`** — Your project's rules file. This is where you define coding standards, naming conventions, architecture decisions, and anything Claude should always know. `/wizard` reads this first, every time.

2. **GitHub Issues** — Every feature or bug gets a GitHub issue (or epic) *before* coding starts. `/wizard` creates these for you with acceptance criteria, tracks progress by checking off boxes as it works, and references the issue in every commit. The issue is the source of truth.

3. **Codebase-first exploration** — Before writing a single line, `/wizard` reads the existing code, greps for methods and relationships, and verifies assumptions. No hallucinated function calls. No invented APIs.

4. **Strict Red-Green-Refactor TDD** — Failing test first, then minimal implementation, then refactor before moving on. Every cycle. Adversarial cases (null, concurrent, boundary) are written as test cases during the RED phase, not reflected on at commit time. The tests use a mutation-testing mindset — they assert specific values that would break if the code changed, not just `assertTrue(worked)`.

5. **Feature branch to main** — Clean branch, focused PR, one concern at a time. No stacked branches, no tangled dependencies.

6. **Design heuristics** — Concrete constraints applied during every refactor step: methods under 5–8 lines, classes under 100 lines, one level of abstraction per function, no more than 4 parameters, dependencies pointing inward toward business logic, interfaces designed from the caller's perspective.

7. **Bug Bot cycle** — After opening the PR, `/wizard` monitors your automated code review bot (Bug Bot, CodeRabbit, etc.), reads every finding, fixes valid issues, replies to false positives, and repeats until the status is clean. No unresolved findings, ever.

8. **CI (your setup)** — Your test suite, your pipeline, your rules. `/wizard` runs the full test suite locally before every commit — no tiered strategy, no scoping down to save time. The full CI suite depends on your project.

Each phase has a checkpoint. Claude won't rush ahead.

## The difference

**Without `/wizard`:**
> You: "Add a transfer status tracking feature"
>
> Claude: *immediately writes 400 lines of code, misses a race condition, hard-codes a string that should be a constant, skips tests*

**With `/wizard`:**
> You: *creates GitHub issue #164 with acceptance criteria*
>
> You: `/wizard implement #164 — transfer status tracking`
>
> Claude: *reads the codebase, writes a failing test, implements the minimum to pass it, refactors before moving on, repeats for each behaviour, runs the full test suite, verifies adversarial test coverage, opens a PR, resolves all bot findings, checks off acceptance criteria*

The output is the same — working code. But the `/wizard` code ships without the 2am "why is this broken in production" follow-up.

## Contributing

This project is small, opinionated, and hungry for fresh ideas. PRs are welcome and encouraged :heart:

**Ways to contribute:**

- **Framework overlays** — Add a `frameworks/rails/`, `frameworks/nextjs/`, or `frameworks/rust/` directory with framework-specific Phase 2/4 additions that people can merge into their SKILL.md
- **New patterns** — Found a bug pattern that `/wizard` should catch? Add it to PATTERNS.md
- **Phase improvements** — Battle-tested a refinement to one of the 7 phases? Open a PR with a before/after example
- **Bug reports** — If `/wizard` missed something it should have caught, that's a bug in the prompt. File an issue with the scenario.
- **Translations** — Port the skill to other languages so non-English teams can use it

**How to contribute:**

1. Fork the repo
2. Make your changes
3. Open a PR with a clear description of *what changed* and *why*
4. Bonus points if you use `/wizard` to make the PR :wink:

No contribution is too small. A single-line fix to a checklist item that saved you from a bug is just as valuable as a new framework overlay.

## Install

**One command** from your project root:

```bash
curl -sL https://raw.githubusercontent.com/nativecampus/claude-wizard/main/install.sh | bash
```

Or manually:

```bash
mkdir -p .claude/skills/wizard
curl -sL https://raw.githubusercontent.com/nativecampus/claude-wizard/main/skill/SKILL.md -o .claude/skills/wizard/SKILL.md
curl -sL https://raw.githubusercontent.com/nativecampus/claude-wizard/main/skill/CHECKLISTS.md -o .claude/skills/wizard/CHECKLISTS.md
curl -sL https://raw.githubusercontent.com/nativecampus/claude-wizard/main/skill/PATTERNS.md -o .claude/skills/wizard/PATTERNS.md
```

## Usage

In Claude Code, type:

```
/wizard implement the user authentication flow as described in GH issue #164
```

Claude will respond with `## [WIZARD MODE]` and begin the phased approach. You'll see phase transitions as it works:

```
## [WIZARD MODE] Phase 1: Understanding & Planning
...
## [WIZARD MODE] Phase 3: Implementation (Test-Driven)
...
```

You can also invoke it mid-conversation:

```
/wizard this is getting complex — let's be more systematic about this
```

## What's included

| File | Purpose |
|------|---------|
| `SKILL.md` | The core skill — 7-phase development methodology with Red-Green-Refactor TDD and design heuristics |
| `CHECKLISTS.md` | Quick-reference checklists for each phase |
| `PATTERNS.md` | Common patterns and anti-patterns with examples (favours duplication over the wrong abstraction) |

## Customization

The skill is designed to be extended. Add your project-specific patterns:

**Framework conventions** — Add your framework's testing commands, directory structure, and coding standards to Phase 2 and Phase 3.

**Logging patterns** — Replace the generic logging guidance with your project's specific logging approach.

**CI/CD integration** — Customize Phase 7 with your specific CI bot names and quality gate requirements.

**Team conventions** — Add commit message formats, PR templates, and review processes.

Edit `.claude/skills/wizard/SKILL.md` directly — it's your copy.

## How it works

Claude Code [skills](https://docs.anthropic.com/en/docs/claude-code/skills) are markdown files that activate when invoked with `/skillname`. They inject additional context and instructions into Claude's prompt, changing its behavior for the duration of the task.

`/wizard` works by wiring the ingredients above into an enforced sequence:

1. **Read `CLAUDE.md`** and project docs — understand the rules before touching anything
2. **Find or create a GitHub issue** — define what "done" looks like with acceptance criteria
3. **Explore the codebase** — grep, search, verify. Never assume a method or relationship exists
4. **Implement via Red-Green-Refactor** — write a failing test, implement the minimum, refactor before moving on, repeat for each behaviour. Adversarial cases are test cases, not afterthoughts
5. **Run the full test suite** — every time, no exceptions. Fix regressions before moving on
6. **Update documentation** — keep docs and GitHub issues in sync with code
7. **Pre-commit review with adversarial test coverage** — verify tests exist for concurrent execution, boundary inputs, race conditions, and partial failures. Then open a PR and run the Bug Bot cycle until clean

There's no magic. It's a well-structured prompt that encodes disciplined development habits into a repeatable process. The methodology draws on ideas from Sandi Metz (small objects, clear interfaces, duplication over the wrong abstraction), Robert C. Martin (Red-Green-Refactor TDD, single responsibility, clean code heuristics), and Martin Fowler (refactoring as a continuous practice, not a separate phase). The key insight is that Claude doesn't lack the *ability* to do these things — it lacks the *process* to do them consistently. `/wizard` is that process.

## Origin

This skill was developed over months of production use on a fintech platform ([wealthbot.io](https://wealthbot.io)) — a Laravel application managing investment portfolios, ACAT transfers, and regulatory compliance. The patterns were refined through hundreds of PRs, real race conditions caught by the adversarial review phase, and Bug Bot findings that would have reached production without the quality gate cycle.

The framework-specific details have been stripped to make it universal. The methodology works with any language, framework, or stack.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- A git repository (the skill uses `gh` CLI for GitHub integration)
- An automated code review bot for Phase 7 — [Bug Bot](https://docs.cursor.com/features/bug-bot) (Cursor), [CodeRabbit](https://coderabbit.ai/), or similar. Phase 7 works without one, but the quality gate cycle is where `/wizard` really shines.

## License

MIT
