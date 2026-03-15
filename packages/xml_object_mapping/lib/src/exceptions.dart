/// Base exception for XML mapping errors.
class XmlMappingException implements Exception {
  /// The error message.
  final String message;

  const XmlMappingException(this.message);

  @override
  String toString() => "XmlMappingException: $message";
}

/// Exception thrown when XML format is invalid.
class XmlMappingFormatException implements Exception {
  /// The error message.
  final String message;

  const XmlMappingFormatException(this.message);

  @override
  String toString() => "XmlMappingFormatException: $message";
}

/// Exception thrown when XML parsing fails.
class XmlMappingParserException implements Exception {
  /// The error message.
  final String message;

  const XmlMappingParserException(this.message);

  @override
  String toString() => "XmlMappingParserException: $message";
}

/// Exception thrown when a required XML element or attribute is missing.
class XmlMappingMissingElementException implements Exception {
  /// The name of the missing element or attribute.
  final String name;

  /// The class name where the element is expected.
  final String className;

  const XmlMappingMissingElementException(this.name, this.className);

  String get message =>
      'Missing required element/attribute "$name" in class "$className"';

  @override
  String toString() => "XmlMappingMissingElementException: $message";
}

/// Exception thrown when a type conversion fails.
class XmlMappingTypeConversionException implements Exception {
  /// The value that failed to convert.
  final String value;

  /// The target type.
  final String targetType;

  /// The optional error message.
  final String? reason;

  const XmlMappingTypeConversionException(
    this.value,
    this.targetType, {
    this.reason,
  });

  String get message =>
      'Failed to convert "$value" to $targetType${reason != null ? ": $reason" : ""}';

  @override
  String toString() => "XmlMappingTypeConversionException: $message";
}
