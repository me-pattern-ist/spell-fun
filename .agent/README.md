# Agentic Configuration

This directory contains standardized rules, skills, and workflows for AI agents working on the `spell-fun` repository.

## Capabilities

- **Workflows**: Scripts in `.agent/workflows/` define automated, multi-step tasks (e.g., generating assets, building the app). Agents can execute these with simple commands like `/generate-assets`.
- **Skills**: Instructions in `.agent/skills/` define core coding standards and project context (like the fact that the target audience is young children). These are automatically loaded to maintain consistency across the codebase.

By observing these files, an Agent knows exactly how to build and expand upon `spell-fun` safely and cohesively.
