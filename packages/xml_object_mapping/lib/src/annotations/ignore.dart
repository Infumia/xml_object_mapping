/// A constant annotation instance for excluding fields from XML mapping.
const xmlMapIgnore = XmlMapIgnore();

/// Excludes a field from XML mapping.
///
/// Fields annotated with this will be ignored during both
/// serialization (object to XML) and deserialization (XML to object).
class XmlMapIgnore {
  const XmlMapIgnore();
}
