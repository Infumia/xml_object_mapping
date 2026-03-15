/// A constant annotation instance for excluding fields from XML mapping.
const xmlIgnore = XmlIgnore();

/// Excludes a field from XML mapping.
///
/// Fields annotated with this will be ignored during both
/// serialization (object to XML) and deserialization (XML to object).
class XmlIgnore {
  const XmlIgnore();
}
