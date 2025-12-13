import 'dart:convert';
import 'dart:io';

const String csvPath = 'assets/all_words.csv';
const String ollamaUrl = 'http://localhost:11434/api/generate';
const String modelName = 'llama3.2:latest'; // Default model, can be changed

void main() async {
  final file = File(csvPath);
  if (!await file.exists()) {
    print('Error: $csvPath not found.');
    exit(1);
  }

  final lines = await file.readAsLines();
  final List<String> newLines = [];
  final client = HttpClient();

  print('Processing words...');

  for (var line in lines) {
    if (line.trim().isEmpty) continue;

    final parts = line.split('|');
    final word = parts[0].trim();
    String sentence = parts.length > 1 ? parts[1].trim() : '';

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
    }

    newLines.add('$word|$sentence');
  }

  await file.writeAsString(newLines.join('\n'));
  print('Done! Updated $csvPath');
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
