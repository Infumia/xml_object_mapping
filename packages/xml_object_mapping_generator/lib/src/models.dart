import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/type.dart";
import "package:source_helper/source_helper.dart";

/// Represents a parsed field annotation for code generation.
sealed class XmlFieldAnnotation {
  /// The field element.
  final FieldElement field;

  /// The field name.
  String get fieldName => field.displayName;

  /// The field type.
  DartType get fieldType => field.type;

  /// Whether the field is nullable.
  bool get isNullable => fieldType.isNullableType;

  /// The custom converter instance, if any.
  final String? converterInstance;

  XmlFieldAnnotation(this.field, this.converterInstance);
}

/// Represents a field annotated with `@XmlElement`.
class XmlElementAnnotation extends XmlFieldAnnotation {
  /// The override name for the XML element.
  final String? overrideName;

  XmlElementAnnotation(super.field, super.converterInstance, this.overrideName);

  /// The name to use for the XML element.
  String get elementName => overrideName ?? fieldName;
}

/// Represents a field annotated with `@XmlAttribute`.
class XmlAttributeAnnotation extends XmlFieldAnnotation {
  /// The override name for the XML attribute.
  final String? overrideName;

  XmlAttributeAnnotation(
    super.field,
    super.converterInstance,
    this.overrideName,
  );

  /// The name to use for the XML attribute.
  String get attributeName => overrideName ?? fieldName;
}

/// Represents a field annotated with `@XmlValue`.
class XmlValueAnnotation extends XmlFieldAnnotation {
  XmlValueAnnotation(super.field, super.converterInstance);
}

/// Represents a field annotated with `@XmlList`.
class XmlListAnnotation extends XmlFieldAnnotation {
  /// The name of the child elements.
  final String childName;

  /// The override name for the parent XML element.
  final String? overrideName;

  XmlListAnnotation(
    super.field,
    super.converterInstance,
    this.childName,
    this.overrideName,
  );

  /// The name to use for the parent XML element.
  String get elementName => overrideName ?? fieldName;
}

/// Represents a field annotated with `@XmlIgnore`.
class XmlIgnoreAnnotation extends XmlFieldAnnotation {
  XmlIgnoreAnnotation(super.field, super.converterInstance);
}

/// Represents a parsed class for code generation.
class XmlClassModel {
  /// The class element.
  final ClassElement element;

  /// The class name.
  String get className => element.displayName;

  /// The fields with XML annotations.
  final List<XmlFieldAnnotation> fields;

  /// All fields (including ignored ones for constructor generation).
  final List<FieldElement> allFields;

  XmlClassModel(this.element, this.fields, this.allFields);
}
