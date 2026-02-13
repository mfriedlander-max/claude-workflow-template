#!/bin/bash
set -euo pipefail

# Claude Code Workflow Setup Script
# Copies agents, commands, skills, rules, and settings into ~/.claude/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.claude-config"
TARGET_DIR="$HOME/.claude"

echo "=== Claude Code Workflow Setup ==="
echo ""
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Check source exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: .claude-config directory not found at $SOURCE_DIR"
  exit 1
fi

# Warn if target already has config
if [ -d "$TARGET_DIR/agents" ] || [ -d "$TARGET_DIR/commands" ] || [ -d "$TARGET_DIR/skills" ] || [ -d "$TARGET_DIR/rules" ]; then
  echo "WARNING: Existing Claude Code config detected at $TARGET_DIR"
  echo "This script will MERGE files (existing files with same names will be overwritten)."
  echo ""
  read -p "Continue? (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# Create target directories
echo "Creating directories..."
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/commands"
mkdir -p "$TARGET_DIR/skills"
mkdir -p "$TARGET_DIR/skills/learned"
mkdir -p "$TARGET_DIR/rules"

# Copy agents
echo "Copying agents..."
cp "$SOURCE_DIR"/agents/*.md "$TARGET_DIR/agents/"
AGENT_COUNT=$(ls "$SOURCE_DIR"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "  -> $AGENT_COUNT agents copied"

# Copy commands
echo "Copying commands..."
cp "$SOURCE_DIR"/commands/*.md "$TARGET_DIR/commands/"
CMD_COUNT=$(ls "$SOURCE_DIR"/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "  -> $CMD_COUNT commands copied"

# Copy skills (recursive)
echo "Copying skills..."
cp -R "$SOURCE_DIR"/skills/* "$TARGET_DIR/skills/"
SKILL_COUNT=$(ls -d "$SOURCE_DIR"/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
echo "  -> $SKILL_COUNT skill modules copied"

# Copy rules
echo "Copying rules..."
cp "$SOURCE_DIR"/rules/*.md "$TARGET_DIR/rules/"
RULE_COUNT=$(ls "$SOURCE_DIR"/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "  -> $RULE_COUNT rules copied"

# Copy settings.json (with backup)
if [ -f "$TARGET_DIR/settings.json" ]; then
  echo "Backing up existing settings.json -> settings.json.backup"
  cp "$TARGET_DIR/settings.json" "$TARGET_DIR/settings.json.backup"
fi
echo "Copying settings.json..."
cp "$SOURCE_DIR/settings.json" "$TARGET_DIR/settings.json"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Installed:"
echo "  Agents:   $AGENT_COUNT"
echo "  Commands: $CMD_COUNT"
echo "  Skills:   $SKILL_COUNT"
echo "  Rules:    $RULE_COUNT"
echo "  Settings: settings.json"
echo ""
echo "IMPORTANT: You also need the superpowers plugin."
echo "Install it by running in Claude Code: /install-plugin superpowers@superpowers-marketplace"
echo ""
echo "Next steps:"
echo "  1. Open this project in Claude Code"
echo "  2. CLAUDE.md at the project root defines the workflow"
echo "  3. Start as master architect or paste the system prompt template into a new window for architects"
echo ""

# Verification
echo "=== Verification ==="
ERRORS=0

# Check agents
for agent in architect build-error-resolver code-reviewer database-reviewer doc-updater e2e-runner explorer planner refactor-cleaner security-reviewer tdd-guide; do
  if [ ! -f "$TARGET_DIR/agents/$agent.md" ]; then
    echo "MISSING: agents/$agent.md"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check critical commands
for cmd in orchestrate verify build-fix code-review e2e eval learn plan refactor-clean tdd test-coverage; do
  if [ ! -f "$TARGET_DIR/commands/$cmd.md" ]; then
    echo "MISSING: commands/$cmd.md"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check settings
if [ ! -f "$TARGET_DIR/settings.json" ]; then
  echo "MISSING: settings.json"
  ERRORS=$((ERRORS + 1))
fi

# Check CLAUDE.md in project
if [ ! -f "$SCRIPT_DIR/CLAUDE.md" ]; then
  echo "MISSING: CLAUDE.md (project root)"
  ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -eq 0 ]; then
  echo "All files verified successfully."
else
  echo "WARNING: $ERRORS files missing! Check the output above."
  exit 1
fi
