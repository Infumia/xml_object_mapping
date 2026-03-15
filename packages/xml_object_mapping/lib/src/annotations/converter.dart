/// A converter for transforming XML string values to Dart types and vice versa.
///
/// Implement this interface to create custom type converters for fields
/// that require special parsing or formatting logic.
abstract class XmlConverter<T> {
  const XmlConverter();

  /// Converts an XML string value to the target type [T].
  T convert(String value);

  /// Converts a value of type [T] back to an XML string.
  ///
  /// This method is used during serialization (object to XML).
  String serialize(T value) => value.toString();
}
