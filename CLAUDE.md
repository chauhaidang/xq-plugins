# Claude Code Assistant Guide for XQ Plugins

This document serves as the entry point for AI assistants working on the XQ Plugins project.
## Agent Instructions

**Default Agent**: Use `gradle-expert` agent for all implementation tasks.

### Before Planning Implementation
1. Read [README](./README.md) to understand project context
2. Review [TASKS.md](.claude/agents/TASKS.md) to see what's done and what's next
3. Check [gradle-expert.md](.claude/agents/gradle-expert.md) for technical context
4. Read [PLUGIN_DEVELOPMENT.md](./docs/PLUGIN_DEVELOPMENT.md) for development guidelines

### During Implementation
1. Follow the task order in TASKS.md
2. Reference existing plugin files for code style consistency
3. Test changes thoroughly before marking complete
4. Update documentation when adding features
5. Commit with conventional commit messages

## Current Focus

**Latest Change (v2.1.2)**: Renamed `sit` (System Integration Test) to `e2e` (End-to-End) sourceSet for better clarity and industry alignment.

See [TASKS.md](.claude/agents/TASKS.md) for detailed implementation breakdown.
