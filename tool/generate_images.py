import os
import csv
from diffusers import StableDiffusionPipeline
import torch

import config

# Configuration
CSV_PATH = config.CSV_PATH
ASSETS_DIR = config.ASSETS_DIR
MODEL_ID = config.SD_MODEL_ID

def main():
    # Check if assets directory exists
    if not os.path.exists(ASSETS_DIR):
        print(f"Error: Directory '{ASSETS_DIR}' not found.")
        return

    # Check if CSV file exists
    if not os.path.exists(CSV_PATH):
        print(f"Error: File '{CSV_PATH}' not found.")
        return

    print("Loading Stable Diffusion Pipeline...")
    try:
        pipe = StableDiffusionPipeline.from_pretrained(
            MODEL_ID, 
            torch_dtype=torch.float32, 
            use_safetensors=True, 
            safety_checker=None,
            requires_safety_checker=False
        )
        pipe = pipe.to('mps')
        # Recommended for MPS to avoid memory issues
        pipe.enable_attention_slicing() 
    except Exception as e:
        print(f"Error loading pipeline: {e}")
        return

    print("Pipeline loaded successfully.")

    # Read words and sentences
    words_to_process = []
    with open(CSV_PATH, 'r') as f:
        reader = csv.reader(f, delimiter='|')
        for row in reader:
            if len(row) >= 1:
                word = row[0].strip()
                sentence = row[1].strip() if len(row) > 1 else ""
                theme = row[2].strip() if len(row) > 2 else ""
                if word and word.lower() != "spell check":
                    words_to_process.append((word, sentence, theme))

    print(f"Found {len(words_to_process)} words to process.")

    for word, sentence, theme in words_to_process:
        image_filename = f"{word.lower()}.png"
        image_path = os.path.join(ASSETS_DIR, image_filename)

        if os.path.exists(image_path):
            print(f"Skipping '{word}': Image already exists.")
            continue

        print(f"Generating image for '{word}'...")
        
        # Construct prompt
        base_prompt = f"A cute illustration for a children's story"
        if theme:
            base_prompt += f", theme {theme}"
        
        prompt = f"{base_prompt}- {sentence}" if sentence else f"{base_prompt}- {word}"
        print(f"  Prompt: {prompt}")
        
        try:
            image = pipe(prompt, num_inference_steps=30).images[0]
            image.save(image_path)
            print(f"✅ Generated {image_filename}")
        except Exception as e:
            print(f"❌ Failed to generate image for '{word}': {e}")

    print("Done!")

if __name__ == "__main__":
    main()
