import "package:xml_object_mapping/xml_object_mapping.dart";

/// A converter for transforming XML string values to [Enum] and vice versa.
class EnumConverter<T extends Enum> extends XmlConverter<T> {
  /// The values of the enum.
  final List<T> values;

  /// Creates a new [EnumConverter] with the given [values].
  const EnumConverter(this.values);

  @override
  T convert(String value) => values.byName(value);

  @override
  String serialize(T value) => value.name;
}
