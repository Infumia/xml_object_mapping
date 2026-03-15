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

dev_dependencies:
  xml_object_mapping_generator: ^1.0.0
```

### Basic Usage

Define your model class with annotations:

```xml
<user id="123">
  <nameSurname>...</nameSurname>
  <email>...</email>
</user>
```
```dart
import "package:xml_object_mapping/xml_object_mapping.dart";

part "user.g.dart";

class User {
  @XmlAttribute()
  final int id;

  @XmlElement(overrideName: "nameSurname")
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

| Annotation                                                                     | Description                              |
|--------------------------------------------------------------------------------|------------------------------------------|
| `@XmlElement({String? overrideName, XmlConverter? converter})`                 | Maps an XML element to a field           |
| `@XmlAttribute({String? overrideName, XmlConverter? converter})`               | Maps an XML attribute to a field         |
| `@XmlList({String? overrideName, String? childName, XmlConverter? converter})` | Maps repeated elements to a `List` field |
| `@XmlIgnore()`                                                                 | Excludes a field from mapping            |

## Supported Types

The following built-in types are supported out of the box:

| Type       | Description                     |
|------------|---------------------------------|
| `String`   | Text content                    |
| `int`      | Integer numbers                 |
| `double`   | Floating-point numbers          |
| `num`      | Any numeric type                |
| `bool`     | Boolean values (`true`/`false`) |
| `DateTime` | ISO 8601 date-time strings      |

For other types, use custom converters (see below).

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

### Collections of Nested Objects

```xml
<bookstore>
  <books>
    <book>
      <title>...</title>
      <author>...</author>
      <price>...</price>
    </book>
    <book>
      <title>...</title>
      <author>...</author>
      <price>...</price>
    </book>
  </books>
</bookstore>
```
```dart
class Bookstore {
  @XmlList(childName: 'book')
  final List<Book> books;

  Bookstore({required this.books});
}

class Book {
  final String title;

  final String author;

  final double price;

  Book({required this.title, required this.author, required this.price});
}
```

### Custom Converters

```xml
<product>
  <price>$19.99</price>
</product>
```
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
