import os
import csv
import json
import requests
from diffusers import StableDiffusionPipeline
import torch

import config

# Configuration
CSV_PATH = config.CSV_PATH
STORIES_DIR = config.STORIES_DIR
OLLAMA_URL = config.OLLAMA_URL
OLLAMA_MODEL = config.OLLAMA_MODEL
SD_MODEL_ID = config.SD_MODEL_ID

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def generate_story_text(words, theme):
    prompt = f"Write a short, simple, and fun story for kids ({config.STORY_SENTENCE_COUNT} sentences) about {theme} using these words: {', '.join(words)}. The story should be engaging and easy to read. Return ONLY the story text. Add one liner moral of thestory at the end."
    
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False
        })
        if response.status_code == 200:
            return response.json().get('response', '').strip()
        else:
            print(f"Ollama Error: {response.status_code}")
            return None
    except Exception as e:
        print(f"Ollama Exception: {e}")
        return None

import argparse

def main():
    parser = argparse.ArgumentParser(description='Generate stories and images.')
    parser.add_argument('--limit', type=int, default=config.MAX_STORIES, help='Number of stories to generate (-1 for all)')
    args = parser.parse_args()

    ensure_dir(STORIES_DIR)

    # Read words and themes
    all_words = [] # List of (word, theme) tuples
    if os.path.exists(CSV_PATH):
        with open(CSV_PATH, 'r') as f:
            reader = csv.reader(f, delimiter='|')
            for row in reader:
                if len(row) >= 1:
                    word = row[0].strip()
                    theme = row[2].strip() if len(row) > 2 else "General"
                    if word and word.lower() != "spell check":
                        all_words.append((word, theme))
    else:
        print(f"Error: {CSV_PATH} not found.")
        return

    # Reverse words to match app logic (Latest -> Oldest)
    all_words.reverse()

    # Chunk words (still chunks of 5, but we pass the theme of the majority or first word)
    chunk_size = config.CHUNK_SIZE
    chunks = [all_words[i:i + chunk_size] for i in range(0, len(all_words), chunk_size)]
    
    # Apply limit
    limit = args.limit
    if limit != -1:
        print(f"Limiting generation to {limit} stories (Total chunks: {len(chunks)})")
        chunks = chunks[:limit]
    else:
        print(f"Generating all {len(chunks)} stories")
    
    print(f"Found {len(all_words)} words. Processing {len(chunks)} chunks...")

    # Load SD Pipeline
    print("Loading Stable Diffusion Pipeline...")
    try:
        pipe = StableDiffusionPipeline.from_pretrained(
            SD_MODEL_ID, 
            torch_dtype=torch.float32, 
            use_safetensors=True, 
            safety_checker=None,
            requires_safety_checker=False
        )
        pipe = pipe.to('mps')
        pipe.enable_attention_slicing()
        print("Pipeline loaded.")
    except Exception as e:
        print(f"Error loading SD pipeline: {e}")
        return

    for i, chunk_tuples in enumerate(chunks):
        words = [t[0] for t in chunk_tuples]
        # Determine dominant theme or just use the first one
        themes = [t[1] for t in chunk_tuples]
        # Simple way: use the most common theme
        main_theme = max(set(themes), key=themes.count)

        story_index = i
        story_file = os.path.join(STORIES_DIR, f"story_{story_index}.txt")
        img1_file = os.path.join(STORIES_DIR, f"story_{story_index}_img_1.png")
        img2_file = os.path.join(STORIES_DIR, f"story_{story_index}_img_2.png")

        print(f"\nProcessing Chunk {story_index}: {words} (Theme: {main_theme})")

        # 1. Generate Story Text
        story_text = ""
        if os.path.exists(story_file):
            print("  Story text exists. Reading...")
            with open(story_file, 'r') as f:
                story_text = f.read()
        else:
            print("  Generating story text...")
            story_text = generate_story_text(words, main_theme)
            if story_text:
                with open(story_file, 'w') as f:
                    f.write(story_text)
                print("  ✅ Story text saved.")
            else:
                print("  ❌ Failed to generate story text. Skipping images.")
                continue

        # 2. Generate Images
        for img_num, img_path in [(1, img1_file), (2, img2_file)]:
            if os.path.exists(img_path):
                print(f"  Image {img_num} exists.")
                continue
            
            print(f"  Generating Image {img_num}...")
            
            prompt = f"cartoon style, cute, for kids, story illustration, theme {main_theme}, {', '.join(words)}"
            
            if img_num == 2:
                 prompt += ", happy ending, celebration"

            try:
                image = pipe(prompt, num_inference_steps=30).images[0]
                image.save(img_path)
                print(f"  ✅ Image {img_num} saved.")
            except Exception as e:
                print(f"  ❌ Failed to generate Image {img_num}: {e}")

    print("\nDone!")

if __name__ == "__main__":
    main()
