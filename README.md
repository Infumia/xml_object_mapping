# xml_object_mapping

[![Pub Version](https://img.shields.io/pub/v/xml_object_mapping)](https://pub.dev/packages/xml_object_mapping)

A Dart library for mapping XML data to Dart objects using annotations. Inspired by JSON serialization patterns, this package eliminates boilerplate XML parsing code.

## Features

- Declarative annotations for XML elements and attributes
- Automatic type conversion and validation
- Support for nested objects and collections
- Custom type converters
- Null safety support

## Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  xml: ^6.0.0
  xml_object_mapping: ^1.0.0
```

### Basic Usage

Define your model class with annotations:

```dart
import "package:xml_object_mapping/xml_object_mapping.dart";

part "user.g.dart";

class User {
  @XmlAttribute()
  final String id;

  final String name;

  final String email;

  User({required this.id, required this.name, required this.email});
}
```

Run the build runner to generate the mapper:

```bash
dart run build_runner build
```

This generates `XmlUserMapper`. Use it to parse XML from various sources:

```dart
// Parse from file path
final user1 = await XmlUserMapper.parse(path: 'data/user.xml');

// Parse from File object
final user2 = await XmlUserMapper.parse(file: File('data/user.xml'));

// Parse from XML string
final user3 = await XmlUserMapper.parse(text: xmlText);

// Parse from XElement
final user4 = await XmlUserMapper.parse(xmlElement: xmlElement);
```

## Annotations

| Annotation                      | Description                             |
|---------------------------------|-----------------------------------------|
| `@XmlElement({String? overrideName, XmlConverter? converter})`   | Maps an XML element to a field          |
| `@XmlAttribute({String? overrideName, XmlConverter? converter})` | Maps an XML attribute to a field        |
| `@XmlList({String? overrideName, String? childName, XmlConverter? converter})` | Maps repeated elements to a `List` field |
| `@XmlIgnore()`                  | Excludes a field from mapping           |

## Advanced Usage

### Nested Objects

```xml
<company>
  <name>...</name>
  <address>
    <street>...</street>
    <city>...</city>
  </address>
</company>
```
```dart
class Company {
  final String name;

  final Address address;

  Company({required this.name, required this.address});
}

class Address {
  final String street;

  final String city;

  Address({required this.street, required this.city});
}
```

### Collections

```xml
<library>
  <books>
    <bookName>...</bookName>
    <bookName>...</bookName>
  </books>
</library>
```
```dart
class Library {
  @XmlList(childName: 'bookName')
  final List<String> books;

  Library({required this.books});
}
```

### Custom Converters

```dart
class Product {
  @XmlElement(converter: PriceConverter())
  final double price;

  Product({required this.price});
}

class PriceConverter implements XmlConverter<double> {
  const PriceConverter();

  @override
  double convert(String value) => double.parse(value.replaceAll('\$', ''));
}
```
