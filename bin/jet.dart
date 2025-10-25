// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/args.dart';
import 'package:json_extension_type/generator.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('generate')
    ..addCommand('help')
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the package version',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this help',
    );

  try {
    final results = parser.parse(arguments);

    if (results['version'] as bool) {
      print('JSON Extension Type Generator v1.1.1');
      return;
    }

    if (results['help'] as bool || results.command == null) {
      printHelp();
      return;
    }

    switch (results.command?.name) {
      case 'generate':
        handleGenerate(results.command!);
        break;
      case 'help':
        printHelp();
        break;
      default:
        print('Unknown command. Use "jet help" to see available commands.');
        exit(1);
    }
  } catch (e) {
    print('❌ Error: $e');
    print('Use "jet help" to see available commands.');
    exit(1);
  }
}

void handleGenerate(ArgResults command) {
  final args = command.arguments;
  final path = args.isNotEmpty ? args[0] : 'lib';

  print('🚀 Generating JSON extensions...\n');
  
  try {
    final generator = JsonExtensionGenerator();
    generator.generate(path);
    
    print('\n✨ Generation completed successfully!');
  } catch (e) {
    print('\n❌ Error during generation: $e');
    exit(1);
  }
}

void printHelp() {
  print('''
JSON Extension Type Generator (JET)

Usage: jet <command> [arguments]

Available commands:
  generate [path]    Generate JSON extensions for models
                     path: Path to directory containing *_model.dart files
                           (default: lib)

  help              Show this help message

Options:
  -h, --help        Show this help message
  -v, --version     Show version

Examples:
  jet generate                    # Generate extensions for lib/
  jet generate lib/models         # Generate extensions for lib/models/
  jet help                        # Show help

Features:
  ✅ Primitive types (String, int, double, bool)
  ✅ Nullable types (?)
  ✅ Lists (List<T>)
  ✅ Enums
  ✅ Custom types (nested records)
  ✅ Custom annotations:
     //#key:name      Customize JSON key
     //#default:val   Set custom default value

For more information: https://github.com/your-repo/json_extension_type
''');
}

