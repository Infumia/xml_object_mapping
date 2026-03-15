import "package:xml_object_mapping/xml_object_mapping.dart";

/// A converter for transforming XML string values to [DateTime] and vice versa.
///
/// By default, this converter uses [DateTime.parse] and [DateTime.toIso8601String]
/// for conversion and serialization.
class DateTimeConverter extends XmlConverter<DateTime> {
  const DateTimeConverter();

  @override
  DateTime convert(String value) => DateTime.parse(value);

  @override
  String serialize(DateTime value) => value.toIso8601String();
}
