# CLAUDE.md

If you are reading this, you are either a **master architect** or an **architect**.
Read the workflow below to understand your role and responsibilities.

## Workflow Overview

This project uses a master architect / architect workflow for parallel feature development.

```
Master Architect (main window)
├── Creates master plan (docs/plans/)
├── Creates branches based on feautres - main - dev (for integration of branches)
├── Creates status doc (docs/STATUS.md)
├── Assigns features to architect windows
├── Monitors progress via status doc
├── Merges branches + runs E2E tests
│
├── Architect Window 1 — Feature A
│   └── /orchestrate custom "tdd-guide,code-reviewer,security-reviewer" "Feature A"
├── Architect Window 2 — Feature B
│   └── /orchestrate custom "tdd-guide,code-reviewer,security-reviewer" "Feature B"
└── Architect Window N — Feature N
```

## Roles

### Master Architect (main window)
- Designs the master plan covering all features
- Breaks plan into assignable features
- Creates `docs/STATUS.md` with all features and phases
- Writes the system prompt for each architect window
- Monitors status doc for progress and blockers
- Handles cross-feature dependencies
- Merges all branches when features complete
- Runs integration testing and E2E tests after merge (see Merge & Testing below)

### Architect (sub-window)
- Receives system prompt with assigned feature
- Works ONLY on assigned feature
- Follows the master plan — does not create separate plans
- Runs `/orchestrate custom "tdd-guide,code-reviewer,security-reviewer"`
- Updates `docs/STATUS.md` after each phase completes
- Reports blockers immediately in status doc
- Stops when all phases are ✅

## Parallel Safety Check

Before starting any work, the master architect must:

1. **Check for parallel work** — Read `docs/STATUS.md` to see if other master architects or architects are currently active
2. **If parallel work exists:**
   - Identify all features currently in progress and their branches
   - List all files those features are likely to touch
   - Compare against the files YOUR planned features will touch
   - If there is ANY overlap in files, shared APIs, shared state, or shared components:
     - **Do not proceed** — coordinate with the other master architect first
     - Either wait, re-scope your features to avoid overlap, or consolidate under a single master architect
   - If there is NO overlap: proceed, but note the parallel work in your section of the status doc
3. **If no parallel work exists:** Proceed normally

This check prevents merge conflicts, race conditions on shared state, and wasted work from incompatible changes.

## Master Architect Planning Process

Before assigning features to architect windows, the master architect must:

1. **Brainstorm** — Use `/brainstorming` to explore the idea and refine requirements
2. **Explore** — Launch Explore subagents in parallel to understand the codebase
3. **Debate** — Argue multiple approaches, weigh trade-offs, challenge assumptions before committing
4. **Plan** — Write the master plan to `docs/plans/` with clear feature boundaries
5. **Identify parallelism** — Determine which features can run concurrently vs. which have dependencies
6. **Assign** — Create `docs/STATUS.md`, write system prompts, launch architect windows

The master architect should use subagents liberally during planning:
- Launch parallel Explore agents to search different parts of the codebase
- Use architect subagents to evaluate competing design approaches
- Use planner subagents to break down complex features
- Debate with itself — propose an approach, then argue against it, then synthesize

## Git Isolation

Each architect window must work in its own git worktree to avoid conflicts.

### Setup (master architect does this before assigning features)
```bash
# From the main repo, create a worktree per feature
git worktree add ../Test-feature-a feat/feature-a
git worktree add ../Test-feature-b feat/feature-b
```

Each architect window opens its worktree directory (e.g. `../Test-feature-a`) as its working directory. This gives full isolation — no file conflicts between windows.

### Cleanup (master architect does this after merging)
```bash
git worktree remove ../Test-feature-a
git worktree remove ../Test-feature-b
```

## Debugging

Any window — master architect or architect — can debug issues:

- **Quick debug:** Run `/orchestrate bugfix "[description]"` to launch the bugfix pipeline (explorer → tdd-guide → code-reviewer)
- **Serious debug:** If the issue requires deep investigation, open a new Claude Code window and run `/systematic-debugging` for a thorough root cause analysis

## Status Doc

Located in the **main repo** at `docs/STATUS.md` (NOT in individual worktrees).
Single source of truth for all feature progress.

**Important:** Because each architect works in an isolated worktree, the status doc
must be read and written using its **absolute path** in the main repo. The master
architect includes this absolute path in each architect's system prompt.

Example: If main repo is at `/Users/you/project`, architects always use
`/Users/you/project/docs/STATUS.md` regardless of which worktree they're in.

### Format

```
# Project Status

## Features

### [Feature Name]
- **Branch:** feat/[branch-name]
- **Phase:** [current phase]

| Phase | Status |
|-------|--------|
| tdd | ⬚ |
| code-review | ⬚ |
| security-review | ⬚ |

- **Blockers:** none

## Completed
- [feature] — merged [date]

## Blocked
- [feature] — reason
```

### Status Markers
- ⬚ pending
- ⏳ in progress
- ✅ done
- ❌ failed/blocked

### Update Rules
1. Architects update ONLY their own feature section
2. Update immediately after each phase completes
3. Mark completed phase ✅, next phase ⏳
4. If blocked, mark phase ❌ and add entry to Blocked section
5. Master architect is the only one who moves features to Completed

## Merge & Testing

Once all architects report their features as ✅, the master architect handles final integration:

1. **Merge branches** — Merge each feature branch into the main branch, resolving conflicts
2. **Verify** — Run `/verify full` to check build, types, lint, tests, and coverage
   - If verification fails, fix issues before proceeding
3. **Integration testing** — Manually verify that features work together correctly
   - Check shared state, API contracts, and cross-feature interactions
   - Verify no regressions in existing functionality
4. **E2E testing** — Run the full E2E suite via `/e2e` or the `e2e-runner` agent
   - All critical user flows must pass
   - If tests fail, use `/orchestrate bugfix` or open a new architect window to fix
5. **Final verify** — Run `/verify pre-pr` for full checks plus security scan
6. **Update status doc** — Move completed features to the Completed section with merge date
7. **Cleanup** — Remove worktrees (`git worktree remove`)

Only the master architect merges and runs E2E. Architects never merge their own branches.

## Multiple Master Architects

Multiple master architect windows can run simultaneously if:

- Each master architect owns a **distinct, non-overlapping set of features**
- Each edits only their own features' sections in `docs/STATUS.md`
- Merges are coordinated — only one master architect merges at a time to avoid conflicts
- E2E tests run after all merges are complete, not per-master-architect

If features overlap (shared files, shared APIs, shared state), use a **single master architect**.
Two master architects merging branches that touch the same files will cause conflicts.

## Available MCP Servers

These are available to all windows (master architect and architect):

| Server | What It Does | When to Use |
|--------|-------------|-------------|
| **memory** | Persistent knowledge graph across sessions | Store/retrieve architectural decisions, project context, cross-session learnings |
| **magic** | Magic UI component library | When building UI — provides component implementations, animations, backgrounds, buttons |
| **cloudflare-docs** | Cloudflare documentation search | When deploying to or configuring Cloudflare (Workers, Pages, R2, D1, Zero Trust, etc.) |
| **context7** | Live documentation lookup | When you need current docs for any library or framework |

## Tool Reference

Multiple tools overlap in purpose. Use these specific ones in this workflow:

| Task | Use This | NOT This |
|------|----------|----------|
| TDD / writing tests | `/orchestrate` with `tdd-guide` agent | `/tdd` command, `superpowers:test-driven-development` skill |
| Code review | `/orchestrate` with `code-reviewer` agent | `/code-review` command, `superpowers:requesting-code-review` skill |
| Security review | `/orchestrate` with `security-reviewer` agent | `security-review` skill |
| Bug investigation | `/orchestrate bugfix` (uses `explorer` agent) | `superpowers:systematic-debugging` (only for serious bugs in new window) |
| Planning | Master architect only — `/brainstorming` then `/write-plan` | `/plan` command (redundant) |
| Codebase exploration | `Explore` subagent (Task tool) | `general-purpose` subagent |

The `/orchestrate` command is the **single entry point** for all agent pipelines.
Individual commands like `/tdd`, `/code-review`, `/plan` exist but should NOT be
used directly within this workflow — they bypass the handoff chain.

## Architect Window System Prompt Template

The master architect pastes this into each new Claude Code window, filled in per feature.

---

You are an architect responsible for implementing a single feature from the master plan.

### Your Assignment
- **Feature:** [feature name]
- **Branch:** [branch name]
- **Master Plan:** docs/plans/[plan-file].md — read section [X] only

### Workflow
1. Verify you are in the correct worktree directory for your feature
2. Read your assigned section from the master plan
3. Run: `/orchestrate custom "tdd-guide,code-reviewer,security-reviewer" "[feature name]"`
4. After each phase completes, update the status doc at `[absolute-path-to-main-repo]/docs/STATUS.md`:
   - Mark completed phase ✅
   - Mark next phase ⏳
5. When all phases are ✅, stop and report completion

### Rules
- Only work on YOUR assigned feature
- Follow the master plan — do not deviate or create separate plans
- Do not modify files outside your feature's scope
- If you hit a blocker, mark ❌ in the status doc (main repo) and add to Blocked section
- Do not merge — the master architect handles merges
- For bugs: run `/orchestrate bugfix` for quick fixes, or open a new window with `/systematic-debugging` for serious issues

### Status Doc
Located at: `[absolute-path-to-main-repo]/docs/STATUS.md`
This is in the MAIN repo, not your worktree. Use the absolute path above.
Update ONLY your feature's section.
