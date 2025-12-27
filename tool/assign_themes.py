import csv
import os
import requests
import json

import config

# Configuration
CSV_PATH = config.CSV_PATH
OLLAMA_URL = config.OLLAMA_URL
OLLAMA_MODEL = config.OLLAMA_MODEL
THEMES = config.THEMES

def get_theme_for_word(word, sentence):
    prompt = f"""
    Categorize the following word into ONE of these themes: {', '.join(THEMES)}.
    Word: "{word}"
    Sentence: "{sentence}"
    
    Return ONLY the theme name. Do not explain.
    If it doesn't fit perfectly, pick the closest one.
    """
    
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False
        })
        if response.status_code == 200:
            return response.json().get('response', '').strip()
        else:
            print(f"Error {response.status_code} for word: {word}")
            return "General"
    except Exception as e:
        print(f"Exception for word {word}: {e}")
        return "General"

def main():
    if not os.path.exists(CSV_PATH):
        print(f"Error: {CSV_PATH} not found.")
        return

    print("Reading words...")
    rows = []
    with open(CSV_PATH, 'r') as f:
        reader = csv.reader(f, delimiter='|')
        for row in reader:
            if len(row) >= 2:
                rows.append(row)

    print(f"Found {len(rows)} words. Assigning themes...")
    
    updated_rows = []
    for i, row in enumerate(rows):
        word = row[0].strip()
        sentence = row[1].strip()
        
        # Check if theme already exists (length > 2)
        if len(row) > 2 and row[2].strip():
            theme = row[2].strip()
            print(f"[{i+1}/{len(rows)}] Skipping {word} (Theme: {theme})")
        else:
            theme = get_theme_for_word(word, sentence)
            # Clean up theme string (remove punctuation/extra spaces)
            theme = theme.replace('.', '').strip()
            # Validate against list (optional, but good for consistency)
            # If model returns something else, maybe map it or keep it.
            print(f"[{i+1}/{len(rows)}] {word} -> {theme}")
        
        updated_rows.append([word, sentence, theme])

    print("Writing back to CSV...")
    with open(CSV_PATH, 'w', newline='') as f:
        writer = csv.writer(f, delimiter='|')
        writer.writerows(updated_rows)

    print("Done! Themes assigned.")

if __name__ == "__main__":
    main()
