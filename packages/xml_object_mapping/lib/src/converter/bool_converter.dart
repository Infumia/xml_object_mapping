import "package:xml_object_mapping/xml_object_mapping.dart";

/// A converter for transforming XML string values to [bool] and vice versa.
class BoolConverter extends XmlConverter<bool> {
  const BoolConverter();

  @override
  bool convert(String value) => bool.parse(value, caseSensitive: false);

  @override
  String serialize(bool value) => value.toString();
}
