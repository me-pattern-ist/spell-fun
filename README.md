# spell-fun

A fun game for kids to learn spellings.

## Command not for agent:

Update raw.csv with new words.

run `dart run tool/generate_sentences.dart` will generate new sentences for all words in all_words.csv

Run this command to categorize your words `python3 tool/assign_themes.py`

Default: Generates 5 stories.
All Stories: Run python3 tool/generate_stories.py --limit -1
Custom Limit: Run python3 tool/generate_stories.py --limit 10


Generate stories and images: `python3 tool/generate_stories.py`

Generate New Images (Optional): `python3 tool/generate_images.py`

## Image Generation
To generate images, you need Python installed with the following packages:
```bash
pip install diffusers transformers torch accelerate
```
Then run:
```bash
python3 tool/generate_images.py
```

## Story Generation
To generate stories and illustrations for the puzzle rewards, run:
```bash
python3 tool/generate_stories.py
```
This requires Ollama running locally with `llama3.2:latest`.

flutter clean

flutter build apk --release


cd build/app/outputs/flutter-apk
mv app-release.apk spell-learning.apk

adb devices
adb install build/app/outputs/flutter-apk/spell-learning.apk
