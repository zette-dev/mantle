# Changelog

All notable changes to the mantle plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-05-17

### Changed
- `/mantle:work` subagent prompt template now explicitly forbids plan-derived source comments (task IDs, phase references, restated requirements, "added for X" notes). Plan context belongs in checkpoints and the PR description, not in source files — eliminating the need for `/simplify` to strip them out after the fact.

## [1.0.1] - 2026-05-01

### Changed
- `/mantle:plan` template now requires numbered task IDs and explicit `- [ ]` checkboxes for every task.
- `/mantle:work` task loop now mandates flipping `- [ ]` → `- [x]` on completion, paired with the checkpoint note.
- `work-templates.md` clarifies checkbox + checkpoint are a single edit, with explicit guidance for partial/blocked tasks.

### Fixed
- Plans were being written with checkboxes but `/mantle:work` was skipping the check-off step, leaving completed tasks visually unchecked.