---
description: Run the full asset generation pipeline for new words
---
# Asset Generation Workflow

This workflow automatically runs the complete data generation pipeline for `spell-fun`. It expects `assets/raw.csv` or `assets/all_words.csv` to be updated with new words.

1. Generate sentences for raw words.
// turbo
`dart tool/generate_sentences.dart`

2. Assign themes to words using Ollama.
// turbo
`python3 tool/assign_themes.py`

3. Generate short stories for themed word chunks using Ollama.
// turbo
`python3 tool/generate_stories.py`

4. Generate stable diffusion images based on story chunks.
// turbo
`python3 tool/generate_images.py`
