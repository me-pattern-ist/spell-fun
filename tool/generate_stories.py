import os
import csv
import random
import argparse
import requests
import torch
from diffusers import StableDiffusionPipeline

import config

# ── Paths ──────────────────────────────────────────────────────────────────────
CSV_PATH   = config.CSV_PATH
STORIES_DIR = config.STORIES_DIR
OLLAMA_URL  = config.OLLAMA_URL
OLLAMA_MODEL = config.OLLAMA_MODEL
SD_MODEL_ID  = config.SD_MODEL_ID

# SD image style constants
SD_STYLE_PREFIX = (
    "Children's book illustration, vibrant colors, whimsical, "
    "cute cartoon style, safe for kids, 4k, soft lighting"
)
SD_NEGATIVE_PROMPT = (
    "realistic, dark, scary, violence, blurry, adult, text, "
    "watermark, nsfw, horror, weapon"
)


def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)


def next_story_index(stories_dir):
    """Return the next available story index based on existing files."""
    existing = [
        f for f in os.listdir(stories_dir)
        if f.startswith("story_") and f.endswith(".txt")
    ]
    indices = []
    for name in existing:
        try:
            idx = int(name.replace("story_", "").replace(".txt", ""))
            indices.append(idx)
        except ValueError:
            pass
    return max(indices) + 1 if indices else 0


# ── LLM helpers ───────────────────────────────────────────────────────────────

def ollama_call(prompt):
    """Make a call to the local Ollama API and return the text response."""
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False
        })
        if response.status_code == 200:
            return response.json().get("response", "").strip()
        else:
            print(f"  Ollama error: {response.status_code}")
            return None
    except Exception as e:
        print(f"  Ollama exception: {e}")
        return None


def derive_theme(words, fallback_themes):
    """Ask llama to pick a single best theme for the story from the word list."""
    allowed = ", ".join(config.THEMES)
    prompt = (
        f"Given these words: {', '.join(words)}\n"
        f"Pick the single best theme for a children's story from this list ONLY: {allowed}.\n"
        f"Reply with ONE word only. No explanation."
    )
    theme = ollama_call(prompt)

    # Validate the returned theme
    if theme:
        # Normalize – llama may add punctuation or change case
        theme_clean = theme.strip().strip(".").strip(",").title()
        if theme_clean in config.THEMES:
            return theme_clean

    # Fallback: use most-frequent theme from CSV tags
    print("  ⚠️  LLaMA theme derivation failed. Falling back to CSV tag majority.")
    return max(set(fallback_themes), key=fallback_themes.count) if fallback_themes else "Fantasy"


def generate_story_text(words, theme):
    """Ask llama to write an 80-100 word kids story using all the given words."""
    word_list = ", ".join(words)
    prompt = (
        f"Write a fun and easy-to-read children's story between {config.STORY_WORD_COUNT} words.\n"
        f"Theme: {theme}\n"
        f"You MUST naturally include ALL of these words in the story: {word_list}\n"
        f"Use simple language suitable for ages 5-8.\n"
        f"End with a one-line moral lesson starting with 'Moral:'.\n"
        f"Return ONLY the story text. No title. No extra explanation."
    )
    return ollama_call(prompt)


# ── Stable Diffusion ───────────────────────────────────────────────────────────

def load_sd_pipeline():
    """Load the Stable Diffusion pipeline (MPS for Apple Silicon)."""
    print("Loading Stable Diffusion pipeline...")
    try:
        pipe = StableDiffusionPipeline.from_pretrained(
            SD_MODEL_ID,
            torch_dtype=torch.float32,
            use_safetensors=True,
            safety_checker=None,
            requires_safety_checker=False
        )
        pipe = pipe.to("mps")
        pipe.enable_attention_slicing()
        print("✅ Pipeline loaded.\n")
        return pipe
    except Exception as e:
        print(f"❌ Error loading SD pipeline: {e}")
        return None


def generate_image(pipe, story_index, theme, words, img_path, img_num=1):
    """Generate a kid-friendly illustration for the story."""
    prompt = (
        f"{SD_STYLE_PREFIX}, theme: {theme}, "
        f"scene featuring: {', '.join(words[:8])}"
    )
    if img_num == 2:
        prompt += ", happy ending, celebration, joyful"
    try:
        generator = torch.Generator().manual_seed(story_index * 42)
        image = pipe(
            prompt,
            negative_prompt=SD_NEGATIVE_PROMPT,
            num_inference_steps=40,
            guidance_scale=8.5,
            generator=generator
        ).images[0]
        image.save(img_path)
        print(f"  ✅ Image saved → {img_path}")
    except Exception as e:
        print(f"  ❌ Failed to generate image: {e}")


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Generate kids stories with SD images.")
    parser.add_argument("--limit", type=int, default=config.MAX_STORIES,
                        help="Number of stories to generate (-1 for unlimited)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print words/theme/story only, no images or file writes")
    args = parser.parse_args()

    ensure_dir(STORIES_DIR)

    # ── 1. Load all words from CSV ────────────────────────────────────────────
    all_words = []  # List of (word, csv_theme) tuples
    if not os.path.exists(CSV_PATH):
        print(f"Error: {CSV_PATH} not found.")
        return

    with open(CSV_PATH, "r") as f:
        reader = csv.reader(f, delimiter="|")
        for row in reader:
            if len(row) >= 1:
                word = row[0].strip()
                csv_theme = row[2].strip() if len(row) > 2 else "General"
                if word and word.lower() not in ("spell check", ""):
                    all_words.append((word, csv_theme))

    if len(all_words) < config.CHUNK_SIZE:
        print(f"Not enough words. Need {config.CHUNK_SIZE}, found {len(all_words)}.")
        return

    print(f"Loaded {len(all_words)} words from CSV.")

    # ── 2. Load SD pipeline (skip in dry-run) ─────────────────────────────────
    pipe = None
    if not args.dry_run:
        pipe = load_sd_pipeline()
        if pipe is None:
            return

    # ── 3. Generate stories ────────────────────────────────────────────────────
    limit = args.limit if args.limit != -1 else float("inf")
    stories_generated = 0
    story_index = next_story_index(STORIES_DIR)

    while stories_generated < limit:
        print(f"\n{'='*60}")
        print(f"Story #{story_index}")

        # Randomly pick CHUNK_SIZE unique words
        selected = random.sample(all_words, config.CHUNK_SIZE)
        words       = [t[0] for t in selected]
        csv_themes  = [t[1] for t in selected]

        print(f"  Selected words: {', '.join(words)}")

        # Derive theme via llama
        print("  Deriving theme via LLaMA...")
        theme = derive_theme(words, csv_themes)
        print(f"  Theme: {theme}")

        story_file = os.path.join(STORIES_DIR, f"story_{story_index}.txt")
        img_file   = os.path.join(STORIES_DIR, f"story_{story_index}_img_1.png")

        # ── Generate story text ───────────────────────────────────────────────
        print("  Generating story text...")
        story_text = generate_story_text(words, theme)
        if not story_text:
            print("  ❌ Failed to generate story. Skipping.")
            story_index += 1
            continue

        word_count = len(story_text.split())
        print(f"  ✅ Story generated ({word_count} words).")

        if args.dry_run:
            print(f"\n--- STORY PREVIEW ---\n{story_text}\n---------------------")
        else:
            with open(story_file, "w") as f:
                f.write(f"Theme: {theme}\n")
                f.write(f"Words: {', '.join(words)}\n\n")
                f.write(story_text)
            print(f"  📄 Saved → {story_file}")

            # ── Generate images ───────────────────────────────────────────────
            for img_num in range(1, config.NUM_IMAGES_PER_STORY + 1):
                img_file = os.path.join(STORIES_DIR, f"story_{story_index}_img_{img_num}.png")
                print(f"  Generating image {img_num}...")
                generate_image(pipe, story_index, theme, words, img_file, img_num)

        stories_generated += 1
        story_index += 1

    print(f"\n✅ Done! Generated {stories_generated} story/stories.")


if __name__ == "__main__":
    main()
