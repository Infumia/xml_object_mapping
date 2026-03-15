/// Base exception for XML mapping errors.
class XmlMappingException implements Exception {
  /// The error message.
  final String message;

  const XmlMappingException(this.message);

  @override
  String toString() => "XmlMappingException: $message";
}

/// Exception thrown when XML format is invalid.
class XmlFormatException implements Exception {
  /// The error message.
  final String message;

  const XmlFormatException(this.message);

  @override
  String toString() => "XmlFormatException: $message";
}

/// Exception thrown when XML parsing fails.
class XmlParserException implements Exception {
  /// The error message.
  final String message;

  const XmlParserException(this.message);

  @override
  String toString() => "XmlParserException: $message";
}

/// Exception thrown when a required XML element or attribute is missing.
class XmlMissingElementException implements Exception {
  /// The name of the missing element or attribute.
  final String name;

  /// The class name where the element is expected.
  final String className;

  const XmlMissingElementException(this.name, this.className);

  String get message =>
      'Missing required element/attribute "$name" in class "$className"';

  @override
  String toString() => "XmlMissingElementException: $message";
}

/// Exception thrown when a type conversion fails.
class XmlTypeConversionException implements Exception {
  /// The value that failed to convert.
  final String value;

  /// The target type.
  final String targetType;

  /// The optional error message.
  final String? reason;

  const XmlTypeConversionException(this.value, this.targetType, {this.reason});

  String get message =>
      'Failed to convert "$value" to $targetType${reason != null ? ": $reason" : ""}';

  @override
  String toString() => "XmlTypeConversionException: $message";
}
