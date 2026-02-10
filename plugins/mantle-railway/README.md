# mantle-railway

Railway deployment plugin for mantle. Provides deployment configuration review and best practices guidance for applications deployed on [Railway](https://railway.app).

This is a deployment platform plugin, not a language or framework plugin. It focuses on Railway-specific configuration, infrastructure, and operational best practices.

## Components

### Agents (1)

| Agent | Category | Description |
|-------|----------|-------------|
| railway-reviewer | Review | Reviews Railway deployment configurations for correctness, security, and best practices. Produces PASS/FAIL output. |

### Skills (1)

| Skill | Description |
|-------|-------------|
| railway-best-practices | Provides Railway deployment best practices including Nixpacks configuration, environment management, networking, and deployment strategies. |

## Agent Details

### railway-reviewer

A deployment configuration reviewer that audits the following areas:

- Nixpacks configuration (runtime, packages, phases)
- Environment variable management (no secrets in code)
- Health check configuration
- Service scaling settings
- Volume mounts and persistent storage
- Custom start commands
- Build and deploy settings
- Service networking (private networking, TCP proxy)
- Railway.toml configuration
- Dockerfile optimization (if using custom Dockerfile)

Outputs a **PASS** or **FAIL** verdict with detailed findings and remediation steps.

## Skill Details

### railway-best-practices

Reference material covering Railway deployment topics:

- **Nixpacks** - Auto-detection, custom config, build phases, runtime selection
- **Environments** - Production/staging/development isolation, variable management, PR environments
- **Networking** - Private networking, TCP proxy, custom domains, HTTPS, internal DNS
- **Deployment** - Deploy triggers, rollbacks, scaling, health checks, zero-downtime deploys, cron jobs

## Installation

Install via the mantle marketplace:

```bash
claude /install mantle-railway
```

## Usage

### Review a Railway Configuration

```bash
claude agent railway-reviewer "Review my Railway deployment configuration"
```

### Get Deployment Guidance

```bash
claude skill railway-best-practices
```

## License

MIT
