# I Made Claude Code Think Before It Codes. Here's the Prompt.

Claude Code is the fastest coder I've ever worked with. It can scaffold a feature, write tests, and open a PR in minutes. But I kept running into the same problem: the code *worked*, and then it *didn't*.

A race condition in a status transition. A hard-coded string that should have been a constant. A transaction that rolled back an audit record it was supposed to keep. Tests that asserted `true` instead of asserting the *right* value.

The fixes were always fast too. But each one came with a side quest: the incident, the regression, the "why didn't we catch this?" retro. The velocity was high. The *net* velocity — after accounting for the bugs — wasn't.

So I tried something different. Instead of fixing Claude's output, I changed how Claude *thinks*.

## The problem isn't intelligence. It's process.

Watch a junior developer work: they read the ticket, open the file, start typing. They're fast. They're also the ones who forget to check if the method they're calling actually exists, or whether the database column they're referencing was renamed three weeks ago.

Now watch a senior developer: they read the ticket, read the code around it, read the tests, check the git history, *then* start typing. They're slower to start but faster to finish — because they don't have to go back and fix what they broke.

Claude Code defaults to the junior mode. Not because it lacks knowledge, but because it lacks *process*. It has no internal checklist telling it to verify assumptions, write tests first, or think about what happens when two requests hit the same endpoint at the same time.

I built that checklist.

## Introducing `/wizard`

`/wizard` is a Claude Code skill — a markdown file that lives in your project and activates when you type `/wizard` in the CLI. It transforms Claude from a fast coder into a methodical software architect.

Here's what changes when you invoke it:

### Claude reads before it writes

Without `/wizard`, Claude might reference `user.clientProfile.accounts` — a relationship chain it hallucinated. With `/wizard`, Phase 2 requires grep verification of every method, relationship, and constant *before* it's used in code.

This alone eliminated an entire class of bugs in my project.

### Tests come first

Phase 3 enforces TDD. Claude writes a failing test, runs it (it must fail), implements the minimum code to make it pass, then verifies.

But here's the key part: it uses a **mutation testing mindset**. Instead of `assert($result)`, it writes `assertEquals('completed', $result->status)`. Instead of checking that a function runs without errors, it checks that *every* side effect actually happened — the timestamp was set, the notification was sent, the counter was incremented.

The difference matters. `assert(true)` passes if the code does nothing. Mutation-resistant assertions catch real bugs.

### The adversarial review

Phase 7 is where `/wizard` earns its keep. Before every commit, Claude runs through an adversarial checklist:

- What happens if this runs twice concurrently?
- What if the input is null? Empty? Negative?
- What assumptions am I making that could be wrong?
- Would I be embarrassed if this broke in production?

This isn't theoretical. In my codebase, this phase caught:
- A status transition service that lacked database locking — two concurrent API calls could apply conflicting transitions
- A Blade template calling `->format()` on a nullable datetime — a crash on any page load where the field was null
- Notification payloads using hard-coded category strings instead of the enum that was *literally created in the same PR*

None of these would have been caught by tests alone. They required thinking about the code in a different mode — as an attacker, not an author.

### The quality gate cycle

Phase 8 handles the PR lifecycle. If your repo has automated code review (Bug Bot, CodeRabbit, etc.), `/wizard` doesn't just open the PR and walk away. It monitors the bot status, reads every finding, fixes valid issues, replies to false positives, and repeats until the status is clean.

This is the phase I used to do manually — and frequently forgot, leaving PRs in limbo with unresolved findings. Now it's part of the process.

## A real example

Here's what `/wizard` looks like on a real task — implementing ACAT transfer status tracking with notifications:

**Phase 1**: Claude reads the project docs, finds the related epic, creates a todo list. It assesses this as "Complex" (7+ files, architectural impact).

**Phase 2**: Claude greps for the `AcatTransfer` model, verifies the `VALID_TRANSITIONS` constant exists, checks that `ClientProfile` has the right relationships, and confirms the `NotificationCategory` enum.

**Phase 3**: Claude writes 23 failing tests covering status transitions, notifications, command behavior, and dashboard rendering. Runs them — all fail. Good.

**Phase 4**: Claude implements the service, command, 5 notification classes, controller changes, and Blade template. Runs tests — all pass.

**Phase 5**: Runs the full related test suite (49 tests). Zero regressions.

**Phase 7**: Adversarial review catches that `initiated_at->format()` could NPE if the field is null. Fixes it.

**Phase 8**: Opens PR. Bug Bot finds 4 issues:
1. Hard-coded category strings (should use enum) — fixed
2. Missing database locking on status transitions — fixed with `lockForUpdate()`
3. Nullable `initiated_at` in Blade template — fixed with null-safe operator
4. Wrong notification tone for completion events — fixed

After 3 fix cycles, Bug Bot returns `success`. PR ready.

**Total**: 49 tests, 108 assertions, 4 bugs caught that would have shipped otherwise.

## How to install it

It's one command:

```bash
curl -sL https://raw.githubusercontent.com/vlad-ko/claude-wizard/main/install.sh | bash
```

This drops three files into `.claude/skills/wizard/`:
- `SKILL.md` — The core 8-phase methodology
- `CHECKLISTS.md` — Quick-reference checklists
- `PATTERNS.md` — Common patterns and anti-patterns

Then type `/wizard` in Claude Code to activate it.

## Making it yours

The skill is framework-agnostic by design. It doesn't know if you're writing Laravel, Rails, Next.js, or Rust. The methodology — read, explore, test, implement, verify, review — is universal.

But it gets *more* powerful when you customize it. In my project, I added:
- Laravel-specific test commands (`./vendor/bin/sail test`)
- Our logging service patterns (`LoggingService::logPortfolioEvent()`)
- Database locking conventions for our ORM
- Bug Bot thread resolution commands (GraphQL mutations)
- Alpine.js requirements for UI components

The more project-specific context you add, the less Claude has to guess — and the fewer bugs slip through.

## What it's not

`/wizard` is not a replacement for code review. It's not a testing framework. It's not a CI pipeline.

It's a **process prompt** — a way to encode senior engineering habits into Claude's workflow so those habits happen consistently, on every task, even at 2am when you're tired and just want the feature to ship.

The prompt is ~500 lines of markdown. There's no magic. It's the same checklist a good tech lead would run through, made explicit and repeatable.

## The source

The full skill is open-source at [github.com/vlad-ko/claude-wizard](https://github.com/vlad-ko/claude-wizard). MIT licensed. Fork it, customize it, make it better.

It came out of building [wealthbot.io](https://wealthbot.io) — a fintech platform where "it mostly works" isn't an option. The patterns were refined over hundreds of PRs and real production incidents. The framework-specific parts have been stripped, but the methodology is battle-tested.

If you try it, I'd love to hear what it catches for you.
