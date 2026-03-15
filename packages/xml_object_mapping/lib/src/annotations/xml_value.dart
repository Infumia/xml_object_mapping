import "package:xml_object_mapping/src/annotations/xml_converter.dart";

/// The constant annotation.
const xmlValue = XmlValue();

/// Maps the content of an XML element to a field.
class XmlValue {
  /// Optional custom converter for this field.
  final XmlConverter<dynamic>? converter;

  const XmlValue({this.converter});
}
