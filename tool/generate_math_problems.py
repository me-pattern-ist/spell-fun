import requests
import csv
import os
import config

# Configuration
OUTPUT_FILE = os.path.join(config.ASSETS_DIR, 'math_fractions.csv')
PROMPT = """
You are a math problem generator for kids.
Generate 20 lines. Each line must contain a word problem and its answer separated by a pipe symbol (|).
Format: Question|Answer
The problems should be about simple fraction addition (e.g., 1/4 + 2/4).
Each problem MUST end with a question like "How much did they eat in total?" or "What fraction is it now?".
Example:
I ate 1/4 of a pizza and Tom ate 2/4. How much pizza did we eat in total?|3/4
Mom used 1/5 of the milk for cake and 2/5 for pancakes. How much milk did she use?|3/5
Output ONLY the raw lines. No intro.
"""

def generate_problems():
    print(f"Requesting math problems from Ollama ({config.OLLAMA_MODEL})...")
    
    try:
        response = requests.post(
            f"{config.OLLAMA_URL}",
            json={
                "model": config.OLLAMA_MODEL,
                "prompt": PROMPT,
                "stream": False
            }
        )
        
        if response.status_code == 200:
            content = response.json().get('response', '').strip()
            lines = content.split('\n')
            
            valid_problems = []
            for line in lines:
                if '|' in line:
                    parts = line.split('|')
                    if len(parts) == 2:
                        # Clean question (remove leading numbers like "1. ")
                        import re
                        q = re.sub(r'^\d+\.\s*', '', parts[0].strip())
                        a = parts[1].strip()
                        
                        # Strict validation: Answer must be simple fraction (num/den)
                        if re.match(r'^\d+/\d+$', a):
                            valid_problems.append((q, a))
            
            print(f"Generated {len(valid_problems)} valid problems.")
            
            # Save to CSV
            with open(OUTPUT_FILE, 'w', newline='') as f:
                writer = csv.writer(f, delimiter='|')
                writer.writerows(valid_problems)
                
            print(f"Saved to {OUTPUT_FILE}")
            
        else:
            print(f"Error: Ollama API returned {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"Exception: {e}")

if __name__ == "__main__":
    generate_problems()
