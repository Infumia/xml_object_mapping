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

/// Represents a field annotated with `@XmlMapElement`.
class XmlMapElementAnnotation extends XmlFieldAnnotation {
  /// The override name for the XML element.
  final String? overrideName;

  /// The decorator instance, if any.
  final String? decoratorInstance;

  XmlMapElementAnnotation(
    super.field,
    super.converterInstance,
    this.overrideName,
    this.decoratorInstance,
  );

  /// The name to use for the XML element.
  String get elementName => overrideName ?? fieldName;
}

/// Represents a field annotated with `@XmlMapAttribute`.
class XmlMapAttributeAnnotation extends XmlFieldAnnotation {
  /// The override name for the XML attribute.
  final String? overrideName;

  XmlMapAttributeAnnotation(
    super.field,
    super.converterInstance,
    this.overrideName,
  );

  /// The name to use for the XML attribute.
  String get attributeName => overrideName ?? fieldName;
}

/// Represents a field annotated with `@XmlMapValue`.
class XmlMapValueAnnotation extends XmlFieldAnnotation {
  XmlMapValueAnnotation(super.field, super.converterInstance);
}

/// Represents a field annotated with `@XmlMapList`.
class XmlMapListAnnotation extends XmlFieldAnnotation {
  /// The name of the child elements.
  final String childName;

  /// The override name for the parent XML element.
  final String? overrideName;

  XmlMapListAnnotation(
    super.field,
    super.converterInstance,
    this.childName,
    this.overrideName,
  );

  /// The name to use for the parent XML element.
  String get elementName => overrideName ?? fieldName;
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
