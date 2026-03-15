import "package:xml_object_mapping/xml_object_mapping.dart";

const xmlAttribute = XmlAttribute();

/// Maps an XML attribute to a field.
class XmlAttribute {
  /// Optional override name for the XML attribute.
  final String? overrideName;

  /// Optional custom converter for this field.
  final XmlConverter<dynamic>? converter;

  const XmlAttribute({this.overrideName, this.converter});
}
