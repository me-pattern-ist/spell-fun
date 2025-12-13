# spell-fun

A fun game for kids to learn spellings.

## Command not for agent:

dart run tool/generate_sentences.dart will generate new sentences for all words in all_words.csv

flutter clean

flutter build apk --release


cd build/app/outputs/flutter-apk
mv app-release.apk spell-learning.apk

adb devices
adb install build/app/outputs/flutter-apk/spell-learning.apk
