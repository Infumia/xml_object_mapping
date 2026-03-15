import "package:xml_object_mapping/xml_object_mapping.dart";

/// A converter for transforming XML string values to [int] and vice versa.
class IntConverter extends XmlConverter<int> {
  const IntConverter();

  @override
  int convert(String value) => int.parse(value);

  @override
  String serialize(int value) => value.toString();
}
