# Configuration for Python Tools

# Paths
CSV_PATH = 'assets/all_words.csv'
STORIES_DIR = 'assets/stories'
ASSETS_DIR = 'assets'

# Ollama Settings
OLLAMA_URL = 'http://localhost:11434/api/generate'
OLLAMA_MODEL = 'llama3.2:latest'

# Stable Diffusion Settings
SD_MODEL_ID = 'runwayml/stable-diffusion-v1-5'

# Generation Settings
CHUNK_SIZE = 5
STORY_SENTENCE_COUNT = "4-6"
MAX_STORIES = 5

# Themes
THEMES = [
    "Nature", "Animals", "Space", "School", "Home", "Fantasy", 
    "Adventure", "Emotions", "Food", "Action", "Family", "Colors"
]
