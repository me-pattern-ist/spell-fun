---
name: Python Generation Tools
description: Rules and prerequisites for the Python tooling in the tool/ directory.
---
# Python Generation Tools

The `spell-fun` project relies on local AI inference for generating its educational content.

## Prerequisites
- **Ollama:** A local Ollama server must be running on `http://localhost:11434`.
- **Model:** The default text model is `llama3.2:latest`. Ensure this is pulled (`ollama pull llama3.2`) before generating themes, stories, or math problems.
- **Dependencies:** Python dependencies (like `requests`) must be installed in the environment.

## Configuration
- All Python scripts share configuration from `tool/config.py`. 
- If adding a new script, import `config` and use paths like `config.ASSETS_DIR` to ensure output files go exactly where the Flutter app expects them (`assets/`).

## Execution
Scripts should be run from the root of the project using `python3 tool/<script_name>.py`.
