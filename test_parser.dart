import 'lib/parser.dart';
import 'dart:io';

void main() {
  final content = File('../lib/layers/data/models/person_model.dart').readAsStringSync();
  final parser = ModelParser();
  
  print('Parsing classes...');
  final classes = parser.parseClasses(content);
  print('Found ${classes.length} classes');
  
  for (final c in classes) {
    print('Class: ${c.name}');
    print('Fields: ${c.fields.map((f) => '${f.type} ${f.name}').join(', ')}');
  }
}
