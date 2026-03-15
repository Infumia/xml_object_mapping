import "package:analyzer/dart/constant/value.dart";
import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/type.dart";
import "package:source_gen/source_gen.dart";
import "package:source_helper/source_helper.dart";
import "package:xml_object_mapping/xml_object_mapping.dart";
import "package:xml_object_mapping_generator/xml_object_mapping_generator.dart";

/// Reader for parsing XML mapping annotations from Dart elements.
class XmlAnnotationReader {
  /// The type checker for `@xml` annotation.
  static const _xmlTypeChecker = TypeChecker.typeNamed(
    Xml,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlElement` annotation.
  static const _xmlElementTypeChecker = TypeChecker.typeNamed(
    XmlElement,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlAttribute` annotation.
  static const _xmlAttributeTypeChecker = TypeChecker.typeNamed(
    XmlAttribute,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlValue` annotation.
  static const _xmlValueTypeChecker = TypeChecker.typeNamed(
    XmlValue,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlList` annotation.
  static const _xmlListTypeChecker = TypeChecker.typeNamed(
    XmlList,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlIgnore` annotation.
  static const _xmlIgnoreTypeChecker = TypeChecker.typeNamed(
    XmlIgnore,
    inPackage: "xml_object_mapping",
  );

  /// Checks if a class is annotated with `@xml`.
  static bool hasXmlAnnotation(ClassElement element) =>
      _xmlTypeChecker.hasAnnotationOf(element);

  /// Parses a class annotated with `@xml` into a [XmlClassModel].
  static XmlClassModel parseClass(ClassElement element) {
    final fields = <XmlFieldAnnotation>[];
    final allFields = <FieldElement>[];

    for (final field in element.fields) {
      // Skip static fields
      if (field.isStatic) {
        continue;
      }

      allFields.add(field);

      // Check for annotations
      final xmlElement = _xmlElementTypeChecker.firstAnnotationOf(field);
      if (xmlElement != null) {
        fields.add(_parseXmlElement(field, xmlElement));
        continue;
      }

      final xmlAttribute = _xmlAttributeTypeChecker.firstAnnotationOf(field);
      if (xmlAttribute != null) {
        fields.add(_parseXmlAttribute(field, xmlAttribute));
        continue;
      }

      final xmlValue = _xmlValueTypeChecker.firstAnnotationOf(field);
      if (xmlValue != null) {
        fields.add(_parseXmlValue(field, xmlValue));
        continue;
      }

      final xmlList = _xmlListTypeChecker.firstAnnotationOf(field);
      if (xmlList != null) {
        fields.add(_parseXmlList(field, xmlList));
        continue;
      }

      final xmlIgnore = _xmlIgnoreTypeChecker.firstAnnotationOf(field);
      if (xmlIgnore != null) {
        fields.add(XmlIgnoreAnnotation(field, null));
        continue;
      }

      // No annotation - field is not mapped
    }

    return XmlClassModel(element, fields, allFields);
  }

  static XmlElementAnnotation _parseXmlElement(
    FieldElement field,
    DartObject annotation,
  ) {
    final overrideName = _getStringAnnotationParam(annotation, "overrideName");
    final converter = _getConverterInstance(annotation);
    return XmlElementAnnotation(field, converter, overrideName);
  }

  static XmlAttributeAnnotation _parseXmlAttribute(
    FieldElement field,
    DartObject annotation,
  ) {
    final overrideName = _getStringAnnotationParam(annotation, "overrideName");
    final converter = _getConverterInstance(annotation);
    return XmlAttributeAnnotation(field, converter, overrideName);
  }

  static XmlValueAnnotation _parseXmlValue(
    FieldElement field,
    DartObject annotation,
  ) {
    final converter = _getConverterInstance(annotation);
    return XmlValueAnnotation(field, converter);
  }

  static XmlListAnnotation _parseXmlList(
    FieldElement field,
    DartObject annotation,
  ) {
    final childName = _getStringAnnotationParam(annotation, "childName")!;
    final overrideName = _getStringAnnotationParam(annotation, "overrideName");
    final converter = _getConverterInstance(annotation);
    return XmlListAnnotation(field, converter, childName, overrideName);
  }

  static String? _getStringAnnotationParam(
    DartObject annotation,
    String paramName,
  ) =>
      annotation.getField(paramName)?.toStringValue();

  static String? _getConverterInstance(DartObject annotation) {
    final converterField = annotation.getField("converter");
    if (converterField == null || converterField.isNull) {
      return null;
    }
    // Return the code representation of the converter instance
    return converterField.toStringValue();
  }

  /// Checks if a type is a built-in supported type.
  static bool isBuiltInType(DartType type) {
    final typeName = type.getDisplayString();
    return switch (typeName) {
      "String" || "int" || "double" || "num" || "bool" || "DateTime" => true,
      _ => false,
    };
  }

  /// Checks if a type is a List.
  static bool isListType(DartType type) {
    if (type is! InterfaceType) {
      return false;
    }
    return type.element.name == "List";
  }

  /// Gets the generic type argument from a List type.
  static DartType? getListGenericType(DartType type) {
    if (type is! InterfaceType) {
      return null;
    }
    if (type.typeArguments.isEmpty) {
      return null;
    }
    return type.typeArguments.first;
  }

  /// Checks if a type is nullable.
  static bool isNullable(DartType type) => type.isNullableType;

  /// Gets the non-nullable version of a type.
  static DartType getNonNullable(DartType type) => type;
}
