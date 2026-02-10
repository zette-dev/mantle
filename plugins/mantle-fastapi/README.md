# mantle-fastapi

FastAPI framework plugin for mantle. Includes 3 specialized agents and 1 skill for FastAPI code review, async patterns, Python linting, and best practices.

## Components

### Agents

#### Review Agents

| Agent | Model | Description |
|-------|-------|-------------|
| [fastapi-reviewer](agents/review/fastapi-reviewer.md) | inherit | Reviews FastAPI code for quality standards including Pydantic models, route organization, dependency injection, response models, error handling, OpenAPI docs, security patterns, and database session management. Outputs PASS/FAIL. |
| [fastapi-async](agents/review/fastapi-async.md) | inherit | Reviews async/await usage, blocking operations in async context, BackgroundTasks, dependency lifecycle, database async patterns, connection pool management, concurrent request handling, and startup/shutdown events. |
| [python-lint](agents/review/python-lint.md) | haiku | Runs ruff check, ruff format, and mypy to report linting errors, formatting issues, and type errors. |

### Skills

| Skill | Description |
|-------|-------------|
| [fastapi-best-practices](skills/fastapi-best-practices/SKILL.md) | Provides FastAPI best practices guidance covering async-first design, Pydantic validation, dependency injection, OpenAPI documentation, and type safety with mypy. |

#### Reference Material

The fastapi-best-practices skill includes detailed references on:

- **[Pydantic](skills/fastapi-best-practices/references/pydantic.md)** - BaseModel, validators, field types, computed fields, model_config, nested models, serialization
- **[Dependency Injection](skills/fastapi-best-practices/references/dependency-injection.md)** - Depends(), sub-dependencies, request-scoped vs singleton, database sessions, auth dependencies
- **[Async Patterns](skills/fastapi-best-practices/references/async-patterns.md)** - async/await, run_in_executor, BackgroundTasks, asyncio patterns, avoiding deadlocks
- **[Alembic](skills/fastapi-best-practices/references/alembic.md)** - Migration creation, autogenerate, upgrade/downgrade, multi-database, migration testing, data migrations
- **[Testing](skills/fastapi-best-practices/references/testing.md)** - TestClient, pytest fixtures, async test patterns, database testing, mocking dependencies, factory patterns

## Installation

```bash
claude /install mantle-fastapi
```

## Usage

### Agents

```bash
# Run the FastAPI quality reviewer on your code
claude agent fastapi-reviewer "Review my FastAPI application"

# Check async patterns
claude agent fastapi-async "Review async usage in my routes"

# Run Python linting
claude agent python-lint "Lint the project"
```

### Skills

```bash
# Get FastAPI best practices guidance
claude skill fastapi-best-practices
```

## Version

1.0.0
