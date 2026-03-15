import "package:xml_object_mapping/xml_object_mapping.dart";

/// A constant annotation instance for mapping XML elements to fields.
const xmlMapElement = XmlMapElement();

/// Maps an XML element to a field.
class XmlMapElement {
  /// Optional override name for the XML element.
  final String? overrideName;

  /// Optional custom converter for this field.
  final XmlConverter<dynamic>? converter;

  const XmlMapElement({this.overrideName, this.converter});
}
