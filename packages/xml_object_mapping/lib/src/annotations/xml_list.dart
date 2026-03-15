import "package:xml_object_mapping/xml_object_mapping.dart";

/// Maps repeated XML elements to a `List` field.
class XmlList {
  /// The name of the child elements to collect into a list.
  final String childName;

  /// Optional override name for the parent XML element.
  final String? overrideName;

  /// Optional custom converter for this field.
  final XmlConverter<dynamic>? converter;

  const XmlList({required this.childName, this.overrideName, this.converter});
}
