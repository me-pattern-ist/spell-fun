# Product Requirements Document: Spell Fun

## 1. Product Overview
**Name:** Spell Fun (App title: "Magic Spells" / "My Spell Book")
**Target Audience:** Young children, specifically ages 6-8.
**Description:** An educational desktop/mobile application designed to help children learn spelling, vocabulary, reading, and foundational math through interactive, AI-generated content and gamified experiences.

## 2. Core Objectives
- Provide a safe, offline-first, engaging learning environment for kids without external distractions.
- Leverage local AI (Ollama) to dynamically generate endless unique and themed reading content to keep the learning experience fresh.
- Develop fine motor skills via on-screen tracing (with finger or stylus).
- Offer core foundational courses spanning reading, vocabulary, and arithmetic.

## 3. Key Features
### 3.1. Literacy & Vocabulary
- **Word Tracing:** Kids learn spelling by tracing letters over guided paths. Supports both Print and Cursive fonts.
- **Sensory Feedback:** Includes Text-to-Speech (TTS) pronunciation of words and their usage in sentences at pacing appropriate for kids.
- **Word Search Puzzles:** Reinforces word recognition after tracing exercises.

### 3.2. AI-Generated Story Mode
- **Themed Content:** Words are categorized by themes (e.g., Animals, Space) using LLMs.
- **Story Generation:** Uses local LLMs (Llama 3.2 via Ollama) to craft short, 4-6 sentence stories incorporating target vocabulary.
- **Visuals:** Uses local image generation (Stable Diffusion via MPS) to create complementary story illustrations.
- **Story Watch:** A reading mode where kids listen to TTS narrate the generated story while looking at the generated images.

### 3.3. Math Fun
- **Arithmetic:** Generates endless Addition and Subtraction problems with difficulty configurable centrally (e.g., max sum of 20).
- **Fractions:** Uses LLM-generated fraction word problems (e.g., "1/4 + 2/4") to teach basic concepts.
- **Interaction Model:** Uses a multiple-choice selection interface with immediate auditory and visual feedback.

### 3.4. Offline AI Asset Pipeline
- Python-based scripts residing in `tool/` interact with local AI models to pre-compute and store all needed assets (sentences, themes, stories, images, math problems) into the `assets/` directory before app compilation. 

## 4. Technical Specifications
- **Framework:** Flutter (Targeting macOS desktop, cross-platform extensible).
- **Core Packages:** `flutter_tts` (for vocalization), `google_fonts` (for child-friendly typography like Comic Neue).
- **AI Tooling Stack:** Python 3, `requests`, Ollama (`llama3.2`), diffusers pipeline (Stable Diffusion 1.5).
- **Data Storage:** Flat CSV files (`assets/all_words.csv`, `assets/math_fractions.csv`) for fast, local data hydration.

## 5. Design Guidelines
- **Visuals:** Rich violets, vibrant button colors, large interactive elements.
- **Accessibility:** Text must be large, high-contrast, and supplemented with slow-paced TTS audio.
- **Inputs:** Inputs must lean toward simple taps (Multiple Choice) or continuous drawing (Tracing) rather than keyboard typing.
