import "package:xml_object_mapping/xml_object_mapping.dart";

/// Default converter for String types.
class XmlValueConverter extends XmlConverter<String> {
  const XmlValueConverter();

  @override
  String convert(String value) => value;
}
