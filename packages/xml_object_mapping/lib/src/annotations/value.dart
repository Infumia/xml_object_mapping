import "package:xml_object_mapping/xml_object_mapping.dart";

/// A constant annotation instance for mapping XML element content to fields.
const xmlMapValue = XmlMapValue();

/// Maps the content of an XML element to a field.
class XmlMapValue {
  /// Optional custom converter for this field.
  final XmlConverter<dynamic>? converter;

  const XmlMapValue({this.converter});
}
