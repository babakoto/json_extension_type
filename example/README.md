# JSON Extension Type (JET) - Examples

This directory contains practical examples demonstrating how to use JSON Extension Type (JET) for JSON to Dart conversion.

## Running the Examples

Each example is a standalone Dart file that can be run directly:

```bash
# Basic example
dart run example/basic_example.dart

# Nested types example
dart run example/nested_types_example.dart

# Custom annotations example
dart run example/custom_annotations_example.dart

# API simulation example
dart run example/api_simulation_example.dart
```

## Examples Overview

### 1. `basic_example.dart`
**What it demonstrates:**
- Simple typedef record definitions
- Basic JSON to model conversion
- Working with enums
- Converting lists of objects
- Type-safe field access

**Use case:** Perfect starting point for beginners learning JET basics.

### 2. `nested_types_example.dart`
**What it demonstrates:**
- Nested typedef records (objects within objects)
- Complex data structures
- Optional nested types
- Lists of custom types
- Real-world e-commerce product model

**Use case:** Building applications with complex, hierarchical data structures like products, orders, or user profiles.

### 3. `custom_annotations_example.dart`
**What it demonstrates:**
- `#key` annotation for mapping JSON keys
- `#default` annotation for custom default values
- Working with snake_case API responses
- Handling missing fields gracefully
- Multiple payment and status enums

**Use case:** Integrating with external APIs that use different naming conventions (snake_case, camelCase, etc.).

### 4. `api_simulation_example.dart`
**What it demonstrates:**
- Simulating real API responses
- Async/await with JSON parsing
- API response wrapper types
- Nested author information in posts
- Computing statistics from parsed data
- Working with timestamps and optional fields

**Use case:** Building API clients, data fetching services, and backend integrations.

## Learning Path

We recommend going through the examples in this order:

1. **Start with** `basic_example.dart` to understand the fundamentals
2. **Move to** `nested_types_example.dart` to learn about complex structures
3. **Then try** `custom_annotations_example.dart` to master API integration
4. **Finally explore** `api_simulation_example.dart` for real-world patterns

## Key Concepts Demonstrated

### Type Safety
All examples show how JET maintains type safety throughout the conversion process, preventing common runtime errors.

### Zero Boilerplate
Notice how clean the models are - no manual parsing code needed! JET generates all the extension types automatically.

### Real-World Patterns
Examples are based on actual use cases:
- User management systems
- E-commerce platforms
- Content management systems
- API integrations

## Extending the Examples

Feel free to modify these examples:

1. **Add new fields** to the typedef records
2. **Run** `jet generate example/` to regenerate extensions
3. **See** how JET handles your changes automatically

## Common Patterns

### Pattern 1: API Response Wrapper
```dart
typedef ApiResponse = ({
  bool success,
  String message,
  List<YourModel>? data,
});
```

### Pattern 2: Optional Nested Types
```dart
typedef User = ({
  String name,
  Address? mailingAddress,  // Can be null
});
```

### Pattern 3: Lists with Custom Types
```dart
typedef Order = ({
  List<Product> items,      // List of custom objects
  List<String> tags,        // List of primitives
});
```

## Need Help?

- Check the main [README.md](../README.md) for complete documentation
- See [example.md](example.md) for more code snippets
- Visit the [GitHub issues](https://github.com/your-repo/json_extension_type/issues) for questions

## Contributing

Have a great example to share? PRs are welcome! Please ensure:
- Example is well-commented
- Demonstrates a specific use case
- Includes sample output
- Follows Dart style guidelines

