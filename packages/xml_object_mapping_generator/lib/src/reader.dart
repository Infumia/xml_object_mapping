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
    XmlMap,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlMapElement` annotation.
  static const _elementTypeChecker = TypeChecker.typeNamed(
    XmlMapElement,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlMapAttribute` annotation.
  static const _attributeTypeChecker = TypeChecker.typeNamed(
    XmlMapAttribute,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlMapValue` annotation.
  static const _valueTypeChecker = TypeChecker.typeNamed(
    XmlMapValue,
    inPackage: "xml_object_mapping",
  );

  /// The type checker for `@XmlMapList` annotation.
  static const _listTypeChecker = TypeChecker.typeNamed(
    XmlMapList,
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
      if (field.isStatic) {
        continue;
      }

      allFields.add(field);

      final elementAnnotation = _elementTypeChecker.firstAnnotationOf(field);
      if (elementAnnotation != null) {
        fields.add(_parseXmlElem(field, ConstantReader(elementAnnotation)));
        continue;
      }

      final attributeAnnotation = _attributeTypeChecker.firstAnnotationOf(
        field,
      );
      if (attributeAnnotation != null) {
        fields.add(_parseXmlAttr(field, ConstantReader(attributeAnnotation)));
        continue;
      }

      final valueAnnotation = _valueTypeChecker.firstAnnotationOf(field);
      if (valueAnnotation != null) {
        fields.add(_parseXmlValue(field, ConstantReader(valueAnnotation)));
        continue;
      }

      final listAnnotation = _listTypeChecker.firstAnnotationOf(field);
      if (listAnnotation != null) {
        fields.add(_parseXmlList(field, ConstantReader(listAnnotation)));
        continue;
      }

    }

    return XmlClassModel(element, fields, allFields);
  }

  static XmlMapElementAnnotation _parseXmlElem(
    FieldElement field,
    ConstantReader annotation,
  ) {
    final overrideName = _getStringAnnotationParam(annotation, "overrideName");
    final converter = _getConverterInstance(annotation);
    return XmlMapElementAnnotation(field, converter, overrideName);
  }

  static XmlMapAttributeAnnotation _parseXmlAttr(
    FieldElement field,
    ConstantReader annotation,
  ) {
    final overrideName = _getStringAnnotationParam(annotation, "overrideName");
    final converter = _getConverterInstance(annotation);
    return XmlMapAttributeAnnotation(field, converter, overrideName);
  }

  static XmlMapValueAnnotation _parseXmlValue(
    FieldElement field,
    ConstantReader annotation,
  ) {
    final converter = _getConverterInstance(annotation);
    return XmlMapValueAnnotation(field, converter);
  }

  static XmlMapListAnnotation _parseXmlList(
    FieldElement field,
    ConstantReader annotation,
  ) {
    final childName = _getStringAnnotationParam(annotation, "childName")!;
    final overrideName = _getStringAnnotationParam(annotation, "overrideName");
    final converter = _getConverterInstance(annotation);
    return XmlMapListAnnotation(field, converter, childName, overrideName);
  }

  static String? _getStringAnnotationParam(
    ConstantReader annotation,
    String paramName,
  ) => annotation.read(paramName).isNull
      ? null
      : annotation.read(paramName).stringValue;

  static String? _getConverterInstance(ConstantReader annotation) {
    final converterField = annotation.read("converter");
    if (converterField.isNull) {
      return null;
    }

    if (converterField.isString) {
      return converterField.stringValue;
    }

    final type = converterField.objectValue.type;
    if (type != null) {
      return "const ${type.getDisplayString()}()";
    }

    return null;
  }

  /// Checks if a type is an Enum.
  static bool isEnumType(DartType type) {
    final element = type.element;
    return element is EnumElement;
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
