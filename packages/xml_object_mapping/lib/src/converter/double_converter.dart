import "package:xml_object_mapping/xml_object_mapping.dart";

/// A converter for transforming XML string values to [double] and vice versa.
class DoubleConverter extends XmlConverter<double> {
  const DoubleConverter();

  @override
  double convert(String value) => double.parse(value);

  @override
  String serialize(double value) => value.toString();
}
