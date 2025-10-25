import 'package:json_extension_type/models.dart';

class CodeGenerator {
  /// Generates the extension type for a typedef or class
  String generateExtensionType(
    TypedefInfo model,
    List<String> enums,
    Map<String, String> enumsWithValues,
  ) {
    final buffer = StringBuffer();
    final typeName = model.name;

    buffer.writeln('extension type ${typeName}Json(dynamic data) {');
    buffer.writeln('  $typeName toModel() {');
    
    if (model.isClass) {
      // For classes, use constructor
      buffer.writeln('    return $typeName(');
      
      for (final field in model.fields) {
        final line = _generateFieldMapping(field, model, enums, enumsWithValues);
        buffer.writeln('      $line');
      }
      
      buffer.writeln('    );');
    } else {
      // For typedefs, use record syntax
      buffer.writeln('    return (');
      
      for (final field in model.fields) {
        final line = _generateFieldMapping(field, model, enums, enumsWithValues);
        buffer.writeln('      $line');
      }
      
      buffer.writeln('    );');
    }
    
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  List<$typeName> toList() {');
    buffer.writeln('    final data = this.data as List;');
    buffer.writeln('    return data.map((e) => ${typeName}Json(e).toModel()).toList();');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generates the mapping for a field
  String _generateFieldMapping(
    FieldInfo field,
    TypedefInfo model,
    List<String> enums,
    Map<String, String> enumsWithValues,
  ) {
    final fieldName = field.name;
    final fieldType = field.type;
    final jsonKey = field.jsonKey ?? fieldName;

    if (field.isEnum) {
      // Enum type
      final firstEnumValue = enumsWithValues[fieldType] ?? 'pending';
      if (field.isNullable) {
        return "$fieldName: data['$jsonKey'] != null ? $fieldType.values.byName(data['$jsonKey'] as String) : null,";
      } else {
        return "$fieldName: $fieldType.values.byName(data['$jsonKey'] as String? ?? '$firstEnumValue'),";
      }
    } else if (field.isCustomType) {
      // Custom type (e.g. Category)
      if (field.isNullable) {
        return "$fieldName: data['$jsonKey'] != null ? ${fieldType}Json(data['$jsonKey'] as Map<String, Object?>?).toModel() : null,";
      } else {
        return "$fieldName: ${fieldType}Json(data['$jsonKey'] as Map<String, Object?>?).toModel(),";
      }
    } else if (field.isList) {
      // List type
      if (fieldType.contains('String')) {
        return "$fieldName: (data['$jsonKey'] as List?)?.cast<String>() ?? [],";
      } else if (fieldType.contains('int')) {
        return "$fieldName: (data['$jsonKey'] as List?)?.cast<int>() ?? [],";
      } else if (fieldType.contains('double')) {
        return "$fieldName: (data['$jsonKey'] as List?)?.cast<double>() ?? [],";
      } else {
        // List of custom types
        final innerType = fieldType.replaceAll(RegExp(r'List<|>'), '');
        return "$fieldName: ((data['$jsonKey'] as List?)?.map((e) => ${innerType}Json(e).toModel()).toList()) ?? [],";
      }
    } else {
      // Primitive type
      final defaultValue = field.defaultValue ?? _getDefaultValue(fieldType);

      if (fieldType == 'double') {
        return "$fieldName: (data['$jsonKey'] as num?)?.toDouble() ?? $defaultValue,";
      } else if (field.isNullable) {
        return "$fieldName: data['$jsonKey'] as $fieldType?,";
      } else {
        return "$fieldName: data['$jsonKey'] as $fieldType? ?? $defaultValue,";
      }
    }
  }

  /// Returns the default value for a type
  String _getDefaultValue(String type) {
    switch (type) {
      case 'String':
        return "''";
      case 'int':
        return '0';
      case 'double':
        return '0.0';
      case 'bool':
        return 'false';
      default:
        return "''";
    }
  }
}

