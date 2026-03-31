---
name: Flutter Development Rules
description: Core conventions, target audience context, and constant definitions for spell-fun.
---
# Development Rules

## Target Audience
The `spell-fun` app is built specifically for **young children (ages 6-8)**.
- **UI:** Must use large, legible fonts (like `GoogleFonts.comicNeue`).
- **Pacing:** Text-to-Speech (TTS) must use `kTtsSpeechRate` so it speaks slowly and clearly.
- **Input:** Prefer multiple-choice selections or interactive tracing games over complex text input.

## Architecture & Configuration
- **Constants:** All universally configurable values MUST be placed in `lib/constants.dart`. Do not hardcode values like TTS speed, max math sums, or layout padding if they apply app-wide.
- **Service Layer:** Use service classes (like `MathService` and `WordService`) to handle data generation or loading, keeping screen logic clean.
- **Text-to-Speech:** Use the `flutter_tts` package. Ensure TTS states are properly managed and disposed if necessary.

## State Management
- Currently using standard `setState`. Keep widget trees as modular as possible to prevent excessive rebuilding.
