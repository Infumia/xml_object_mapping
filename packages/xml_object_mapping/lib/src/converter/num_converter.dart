import "package:xml_object_mapping/xml_object_mapping.dart";

/// A converter for transforming XML string values to [num] and vice versa.
class NumConverter extends XmlConverter<num> {
  const NumConverter();

  @override
  num convert(String value) => num.parse(value);

  @override
  String serialize(num value) => value.toString();
}
