import "package:xml_object_mapping/xml_object_mapping.dart";

/// A constant annotation instance for mapping XML attributes to fields.
const xmlMapAttribute = XmlMapAttribute();

/// Maps an XML attribute to a field.
class XmlMapAttribute {
  /// Optional override name for the XML attribute.
  final String? overrideName;

  /// Optional decorator for this field.
  final XmlConverter<String>? decorator;

  /// Optional custom converter for this field.
  final XmlConverter<dynamic>? converter;

  const XmlMapAttribute({this.overrideName, this.decorator, this.converter});
}
