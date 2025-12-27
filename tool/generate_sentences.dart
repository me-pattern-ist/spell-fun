import 'dart:convert';
import 'dart:io';

const String rawCsvPath = 'assets/raw.csv';
const String outputCsvPath = 'assets/all_words.csv';
const String ollamaUrl = 'http://localhost:11434/api/generate';
const String modelName = 'llama3.2:latest'; // Default model, can be changed

void main() async {
  final rawFile = File(rawCsvPath);
  if (!await rawFile.exists()) {
    print('Error: $rawCsvPath not found.');
    exit(1);
  }

  // Read raw words
  final rawLines = await rawFile.readAsLines();
  final List<String> rawWords = [];
  for (var line in rawLines) {
    if (line.trim().isEmpty || line.toLowerCase().contains('spell check')) continue;
    rawWords.add(line.trim());
  }

  // Read existing sentences to cache them
  final outputFile = File(outputCsvPath);
  final Map<String, String> existingSentences = {};
  if (await outputFile.exists()) {
    final outputLines = await outputFile.readAsLines();
    for (var line in outputLines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|');
      if (parts.length > 1) {
        existingSentences[parts[0].trim()] = parts[1].trim();
      }
    }
  }

  final List<String> newLines = [];
  final client = HttpClient();

  print('Processing ${rawWords.length} words...');

  for (var word in rawWords) {
    String sentence = existingSentences[word] ?? '';

    if (sentence.isEmpty || sentence == "This is a word.") {
      print('Generating sentence for: $word');
      try {
        final generatedSentence = await generateSentence(client, word);
        if (generatedSentence != null) {
          sentence = generatedSentence;
          print('  -> $sentence');
        } else {
          print('  -> Failed to generate.');
        }
      } catch (e) {
        print('  -> Error: $e');
      }
    } else {
      print('Skipping generation for: $word (already exists)');
    }

    newLines.add('$word|$sentence');
  }

  await outputFile.writeAsString(newLines.join('\n'));
  print('Done! Updated $outputCsvPath');
  client.close();
}

Future<String?> generateSentence(HttpClient client, String word) async {
  final request = await client.postUrl(Uri.parse(ollamaUrl));
  request.headers.contentType = ContentType.json;
  
  final prompt = "Generate a simple, fun, and emotional sentence for a child using the word: $word. The sentence should be easy to read. Return ONLY the sentence, no quotes or extra text.";
  
  final body = jsonEncode({
    "model": modelName,
    "prompt": prompt,
    "stream": false,
  });

  request.write(body);
  final response = await request.close();

  if (response.statusCode == 200) {
    final responseBody = await response.transform(utf8.decoder).join();
    final jsonResponse = jsonDecode(responseBody);
    return jsonResponse['response']?.toString().trim();
  } else {
    print('Ollama API error: ${response.statusCode}');
    return null;
  }
}
