import "package:xml_object_mapping/xml_object_mapping.dart";

/// A constant annotation instance for mapping XML element content to fields.
const xmlValue = XmlValue();

/// Maps the content of an XML element to a field.
class XmlValue {
  /// Optional custom converter for this field.
  final XmlConverter<dynamic>? converter;

  const XmlValue({this.converter});
}
