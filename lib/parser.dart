import 'package:json_extension_type/models.dart';

class ModelParser {
  /// Parses classes from a file
  List<TypedefInfo> parseClasses(String content) {
    final classes = <TypedefInfo>[];
    final enums = parseEnums(content);
    
    // Find class declarations and extract their content manually
    final lines = content.split('\n');
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Match class declaration
      final classMatch = RegExp(r'^class\s+(\w+)\s*\{').firstMatch(line);
      if (classMatch != null) {
        final className = classMatch.group(1)!;
        
        // Find the class body (from current line to closing brace)
        var braceCount = 1;
        final classBodyLines = <String>[];
        
        for (var j = i + 1; j < lines.length && braceCount > 0; j++) {
          final bodyLine = lines[j];
          classBodyLines.add(bodyLine);
          
          // Count braces to find the end of class
          braceCount += '{'.allMatches(bodyLine).length;
          braceCount -= '}'.allMatches(bodyLine).length;
        }
        
        // Remove the last line (closing brace)
        if (classBodyLines.isNotEmpty) {
          classBodyLines.removeLast();
        }
        
        final classBody = classBodyLines.join('\n');
        
        // Parse fields from class body
        final fields = _parseClassFields(classBody, enums);
        
        if (fields.isNotEmpty) {
          classes.add(TypedefInfo(
            name: className,
            fields: fields,
            isClass: true,
          ));
        }
      }
    }

    return classes;
  }

  /// Parses enums from a file
  List<String> parseEnums(String content) {
    final enums = <String>[];
    final enumRegex = RegExp(
      r'enum\s+(\w+)\s*\{',
      multiLine: true,
    );

    final matches = enumRegex.allMatches(content);

    for (final match in matches) {
      final enumName = match.group(1)!;
      enums.add(enumName);
    }

    return enums;
  }

  /// Parses enums with their values
  Map<String, String> parseEnumsWithValues(String content) {
    final enumsWithValues = <String, String>{};
    final enumRegex = RegExp(
      r'enum\s+(\w+)\s*\{([^}]+)\}',
      multiLine: true,
      dotAll: true,
    );

    final matches = enumRegex.allMatches(content);

    for (final match in matches) {
      final enumName = match.group(1)!;
      final enumBody = match.group(2)!;

      // Extract first value
      final values = enumBody
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !e.startsWith('//'))
          .toList();

      if (values.isNotEmpty) {
        final firstValue = values.first.split('//')[0].trim();
        enumsWithValues[enumName] = firstValue;
      }
    }

    return enumsWithValues;
  }

  /// Parses typedefs from a file
  List<TypedefInfo> parseTypedefs(String content) {
    final typedefs = <TypedefInfo>[];
    final enums = parseEnums(content);
    final typedefRegex = RegExp(
      r'typedef\s+(\w+)\s*=\s*\(\{([^}]+)\}\);',
      multiLine: true,
      dotAll: true,
    );

    final matches = typedefRegex.allMatches(content);

    for (final match in matches) {
      final typeName = match.group(1)!;
      final fieldsString = match.group(2)!;
      final fields = _parseFields(fieldsString, enums);

      typedefs.add(TypedefInfo(
        name: typeName,
        fields: fields,
        isClass: false,
      ));
    }

    return typedefs;
  }
  
  /// Parses all models (typedefs + classes) from a file
  List<TypedefInfo> parseAllModels(String content) {
    final models = <TypedefInfo>[];
    
    // Parse typedefs
    models.addAll(parseTypedefs(content));
    
    // Parse classes
    models.addAll(parseClasses(content));
    
    return models;
  }

  /// Parses fields of a typedef
  List<FieldInfo> _parseFields(String fieldsString, [List<String> enums = const []]) {
    final fields = <FieldInfo>[];
    final lines = fieldsString.split('\n');

    String? currentAnnotation;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) continue;

      // Detect annotations in comments
      if (line.startsWith('//')) {
        if (line.contains('#')) {
          currentAnnotation = line;
        }
        continue;
      }

      // Pattern: Type name, or Type? name,
      final fieldMatch = RegExp(r'(\w+(?:<[^>]+>)?)\??(\s+\w+),?').firstMatch(line);
      if (fieldMatch != null) {
        final fullType = line.split(RegExp(r'\s+'))[0]; // Type with ? if present
        final fieldName = fieldMatch.group(2)!.trim();

        final isNullable = fullType.contains('?');
        final baseType = fullType.replaceAll('?', '').replaceAll(',', '');
        final isList = baseType.startsWith('List<');
        final isEnum = enums.contains(baseType);
        final isCustomType = !_isPrimitiveType(baseType) && !isList && !isEnum;

        // Parse annotations
        final annotations = _parseAnnotations(currentAnnotation);

        fields.add(FieldInfo(
          name: fieldName,
          type: baseType,
          isNullable: isNullable,
          isList: isList,
          isCustomType: isCustomType,
          isEnum: isEnum,
          jsonKey: annotations['key'],
          defaultValue: annotations['default'],
        ));

        currentAnnotation = null;
      }
    }

    return fields;
  }

  /// Parses annotations from a comment
  Map<String, String?> _parseAnnotations(String? annotationLine) {
    final annotations = <String, String?>{};

    if (annotationLine == null) return annotations;

    // Extract all annotations #key:value
    final annotationPattern = RegExp(r'#(\w+):([^\s#]+)');
    final matches = annotationPattern.allMatches(annotationLine);

    for (final match in matches) {
      final key = match.group(1);
      final value = match.group(2);
      if (key != null && value != null) {
        annotations[key] = value;
      }
    }

    return annotations;
  }

  /// Parses fields from a class body
  List<FieldInfo> _parseClassFields(String classBody, [List<String> enums = const []]) {
    final fields = <FieldInfo>[];
    final lines = classBody.split('\n');
    
    String? currentAnnotation;
    var inConstructor = false;
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;
      
      // Detect constructor start
      if (line.contains(RegExp(r'\w+\s*\('))) {
        inConstructor = true;
      }
      
      // Detect constructor end
      if (inConstructor && line.contains(');')) {
        inConstructor = false;
        continue;
      }
      
      // Skip if inside constructor or method
      if (inConstructor || line.contains('(') && !line.endsWith(';')) {
        continue;
      }
      
      // Detect annotations in comments
      if (line.startsWith('//') && line.contains('#')) {
        currentAnnotation = line;
        continue;
      }
      
      // Skip regular comments
      if (line.startsWith('//')) {
        continue;
      }
      
      // Match field declarations: final Type name; or Type name;
      final fieldMatch = RegExp(
        r'(?:final\s+)?(\w+(?:<[^>]+>)?)\??(\s+\w+);',
      ).firstMatch(line);
      
      if (fieldMatch != null) {
        final fullType = fieldMatch.group(1)!;
        final fieldName = fieldMatch.group(2)!.trim();
        
        final isNullable = line.contains('$fullType?') || line.contains('? ');
        final baseType = fullType.replaceAll('?', '');
        final isList = baseType.startsWith('List<');
        final isEnum = enums.contains(baseType);
        final isCustomType = !_isPrimitiveType(baseType) && !isList && !isEnum;
        
        // Parse annotations
        final annotations = _parseAnnotations(currentAnnotation);
        
        fields.add(FieldInfo(
          name: fieldName,
          type: baseType,
          isNullable: isNullable,
          isList: isList,
          isCustomType: isCustomType,
          isEnum: isEnum,
          jsonKey: annotations['key'],
          defaultValue: annotations['default'],
        ));
        
        currentAnnotation = null;
      }
    }
    
    return fields;
  }

  /// Checks if a type is primitive
  bool _isPrimitiveType(String type) {
    return ['String', 'int', 'double', 'bool', 'num'].contains(type) ||
        type.startsWith('List<');
  }
}

