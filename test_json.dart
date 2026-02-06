import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/questions.json');
  try {
    final String content = file.readAsStringSync();
    final List<dynamic> json = jsonDecode(content);
    print('JSON is valid. Found ${json.length} questions.');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
