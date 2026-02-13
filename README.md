# Claude Code Workflow Template

Master Architect / Architect workflow for parallel feature development with Claude Code.

## What This Is

A multi-window orchestration system where:
- A **master architect** (main window) plans, assigns, and coordinates
- **Architect windows** implement features in parallel using `/orchestrate`
- A shared **status doc** tracks progress across all windows
- Git **worktrees** provide file isolation per feature

## Quick Start

```bash
# 1. Clone this template into your project
git clone https://github.com/mfriedlander-max/claude-workflow-template.git
cd claude-workflow-template

# 2. Run setup to install agents, commands, skills, and rules into ~/.claude/
./setup.sh

# 3. Install the superpowers plugin (run inside Claude Code)
/install-plugin superpowers@superpowers-marketplace

# 4. Copy CLAUDE.md to your project root
cp CLAUDE.md /path/to/your/project/CLAUDE.md

# 5. Open your project in Claude Code — you're the master architect
```

## What Gets Installed

| Directory | Count | Purpose |
|-----------|-------|---------|
| `~/.claude/agents/` | 11 | Specialized sub-agents (explorer, tdd-guide, code-reviewer, etc.) |
| `~/.claude/commands/` | 15 | Slash commands (/orchestrate, /verify, /tdd, etc.) |
| `~/.claude/skills/` | 15 | Skills (TDD workflow, security review, strategic compact, etc.) |
| `~/.claude/rules/` | 8 | Global rules (coding style, git workflow, testing, security, etc.) |
| `~/.claude/settings.json` | 1 | Hooks (prettier, TypeScript check, doc blocker, etc.) |

## Workflow

```
Master Architect (main window)
├── /brainstorming → design the feature set
├── /write-plan → create master plan in docs/plans/
├── Create docs/STATUS.md
├── Create git worktrees per feature
├── Paste system prompt into architect windows
│
├── Architect Window 1 → /orchestrate custom "tdd-guide,code-reviewer,security-reviewer" "Feature A"
├── Architect Window 2 → /orchestrate custom "tdd-guide,code-reviewer,security-reviewer" "Feature B"
│
├── Monitor docs/STATUS.md for progress
├── Merge branches when all ✅
├── /verify full → build, types, lint, tests
├── /e2e → end-to-end tests
├── /verify pre-pr → final security scan
└── Ship
```

## Key Files

- **CLAUDE.md** — Project-level workflow definition (copy to your project root)
- **setup.sh** — Installs everything into `~/.claude/`
- **.claude-config/** — All agents, commands, skills, rules, and settings

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- Git (for worktrees)
- Node.js (for hooks)
