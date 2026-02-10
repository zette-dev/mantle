# Mantle — Core Plugin

AI-powered development tools for code review, research, and workflow automation. Language-agnostic core that works with any tech stack.

## Components

| Component | Count |
|-----------|-------|
| Agents | 13 |
| Commands | 6 |
| Skills | 11 |
| MCP Servers | 1 |

## Agents

### Review (6)

| Agent | Description |
|-------|-------------|
| `architecture-strategist` | Analyze architectural decisions and compliance |
| `code-simplicity-reviewer` | Final pass for simplicity and minimalism |
| `data-integrity-guardian` | Database migrations and data integrity |
| `pattern-recognition-specialist` | Analyze code for patterns and anti-patterns |
| `performance-oracle` | Performance analysis and optimization |
| `security-sentinel` | Security audits and vulnerability assessments |

### Research (4)

| Agent | Description |
|-------|-------------|
| `best-practices-researcher` | Gather external best practices and examples |
| `framework-docs-researcher` | Research framework documentation and best practices |
| `git-history-analyzer` | Analyze git history and code evolution |
| `repo-research-analyst` | Research repository structure and conventions |

### Workflow (3)

| Agent | Description |
|-------|-------------|
| `bug-reproduction-validator` | Systematically reproduce and validate bug reports |
| `pr-comment-resolver` | Address PR comments and implement fixes |
| `spec-flow-analyzer` | Analyze user flows and identify gaps in specifications |

## Commands

Core workflow commands use `mantle:` prefix to avoid collisions with built-in commands:

| Command | Description |
|---------|-------------|
| `/mantle:plan` | Create implementation plans with research |
| `/mantle:review` | Run comprehensive multi-agent code reviews |
| `/mantle:work` | Execute work items systematically |
| `/mantle:compound` | Document solved problems to compound team knowledge |
| `/lfg` | Full autonomous engineering workflow |
| `/deepen-plan` | Enhance plans with parallel research agents |

## Skills

| Skill | Description |
|-------|-------------|
| `agent-browser` | CLI-based browser automation using agent-browser |
| `agent-native-architecture` | Build AI agents using prompt-native architecture |
| `brainstorming` | Guided ideation for exploring requirements and approaches |
| `compound-docs` | Capture solved problems as categorized documentation |
| `create-agent-skills` | Expert guidance for creating Claude Code skills |
| `file-todos` | File-based todo tracking system |
| `gemini-imagegen` | Generate and edit images using Google's Gemini API |
| `git-worktree` | Manage Git worktrees for parallel development |
| `orchestrating-swarms` | Guide to multi-agent swarm orchestration |
| `rclone` | Upload files to S3, Cloudflare R2, and cloud storage |
| `skill-creator` | Guide for creating effective Claude Code skills |

## MCP Servers

| Server | Description |
|--------|-------------|
| `context7` | Framework documentation lookup via Context7 |

MCP servers start automatically when the plugin is enabled.

## Installation

```bash
claude /plugin install mantle
```

## Stack Plugins

Install framework-specific plugins alongside mantle for stack-aware code review:

| Plugin | Stack |
|--------|-------|
| `mantle-dart` | Dart |
| `mantle-fastapi` | Python / FastAPI |
| `mantle-flutter` | Flutter |
| `mantle-go` | Go |
| `mantle-railway` | Railway deployment |
| `mantle-terraform` | Terraform / IaC |

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## License

MIT
