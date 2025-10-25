/// Represents a typedef record or class
class TypedefInfo {
  final String name;
  final List<FieldInfo> fields;
  final bool isClass;

  TypedefInfo({
    required this.name,
    required this.fields,
    this.isClass = false,
  });
}

/// Represents a field of a typedef
class FieldInfo {
  final String name;
  final String type;
  final bool isNullable;
  final bool isList;
  final bool isCustomType;
  final bool isEnum;
  final String? jsonKey;
  final String? defaultValue;

  FieldInfo({
    required this.name,
    required this.type,
    required this.isNullable,
    required this.isList,
    required this.isCustomType,
    this.isEnum = false,
    this.jsonKey,
    this.defaultValue,
  });
}

