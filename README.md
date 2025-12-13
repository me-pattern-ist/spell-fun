# spell-fun

A fun game for kids to learn spellings.

## Command not for agent:
/Users/sherakhan/.gemini/antigravity/scratch/spell_learning_game_flutter


flutter clean

flutter build apk --release


cd build/app/outputs/flutter-apk
mv app-release.apk spell-learning.apk

adb devices
adb install build/app/outputs/flutter-apk/spell-learning.apk
