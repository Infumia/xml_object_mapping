# xml_object_mapping

[![Pub Version](https://img.shields.io/pub/v/xml_object_mapping)](https://pub.dev/packages/xml_object_mapping)

A Dart library for mapping XML data to Dart objects using annotations. Inspired by JSON serialization patterns,
this package eliminates boilerplate XML parsing code.

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
    <maxItems>9</maxItems>
    <status>PROCESSING</status>
</user>
```

```dart
import "package:xml_object_mapping/xml_object_mapping.dart";

part "user.g.dart";

@xmlMap
class User {
  @XmlMapAttribute()
  final int id;

  @XmlMapElement(overrideName: "nameSurname")
  final String name;

  final String email;

  final String? phone;

  final int maxItems;

  final OrderStatus status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.phone,
    this.maxItems = 10,
  });
}

enum OrderStatus { PENDING, PROCESSING, SHIPPED, DELIVERED }
```

Run the build runner to generate the mapper:

```bash
dart run build_runner build
```

This generates `XmlUserMapper`. Use it to parse XML from various sources:

```dart
void main() {
    var user = XmlUserMapper.parse(path: 'data/user.xml');
    user = XmlUserMapper.parse(file: File('data/user.xml'));
    user = XmlUserMapper.parse(text: "<user>...<user/>");
    user = XmlUserMapper.parse(xmlElement: xmlElement);
}
```

## Annotations

| Annotation                                                                        | Description                                   |
|-----------------------------------------------------------------------------------|-----------------------------------------------|
| `@XmlMap`                                                                         | Marks a class for XML mapping code generation |
| `@XmlMapValue({XmlConverter? converter})`                                         | Maps the content of an XML element to a field |
| `@XmlMapElement({String? overrideName, XmlConverter? converter})`                 | Maps an XML element to a field                |
| `@XmlMapAttribute({String? overrideName, XmlConverter? converter})`               | Maps an XML attribute to a field              |
| `@XmlMapList({String? overrideName, String? childName, XmlConverter? converter})` | Maps repeated elements to a `List` field      |
| `@XmlMapIgnore()`                                                                 | Excludes a field from mapping                 |

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
@xmlMap
class Company {
  final String name;

  final Address address;

  Company({required this.name, required this.address});
}

@xmlMap
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
@xmlMap
class Library {
  @XmlMapList(childName: 'bookName')
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
@xmlMap
class Bookstore {
  @XmlMapList(childName: 'book')
  final List<Book> books;

  Bookstore({required this.books});
}

@xmlMap
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
@xmlMap
class Product {
  @XmlMapElement(converter: PriceConverter())
  final double price;

  Product({required this.price});
}

class PriceConverter implements XmlConverter<double> {
  const PriceConverter();

  @override
  double convert(String value) => double.parse(value.replaceAll(r"$", ""));
}
```

### Map Types

Use `@XmlMapList` with a map-like structure for key-value pairs:

```xml
<config>
    <properties>
        <entry key="timeout">30</entry>
        <entry key="retries">3</entry>
    </properties>
</config>
```

```dart
@xmlMap
class Config {
  @XmlMapList(childName: 'entry')
  final List<PropertyEntry> properties;

  Config({required this.properties});
}

@xmlMap
class PropertyEntry {
  @XmlMapAttribute()
  final String key;

  @XmlMapValue()
  final int value;

  PropertyEntry({required this.key, required this.value});
}

void main() {
    final config = XmlConfigMapper.parse(text: xml);
    final map = {for (var e in config.properties) e.key: e.value};
}
```

### Serialization (Objects → XML)

Convert objects back to XML:

```dart
void main() {
    final user = User(id: '123', name: 'John Doe', email: 'john@example.com');

    final xmlElement = XmlUserMapper.toXml(user);
}
```

### Error Handling

The mapper throws specific exceptions for common errors:

```dart
void main() {
    try {
        final user = XmlUserMapper.parse(text: xmlString);
    } on XmlMappingException catch (e) {
        print('Mapping error: ${e.message}');
    } on XmlFormatException catch (e) {
        print('Format error: ${e.message}');
    } on XmlParserException catch (e) {
        print('Parse error: ${e.message}');
    }
}
```
