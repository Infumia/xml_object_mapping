import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/type.dart";
import "package:build/build.dart";
import "package:code_builder/code_builder.dart";
import "package:source_gen/source_gen.dart";
import "package:xml_object_mapping/xml_object_mapping.dart";
import "package:xml_object_mapping_generator/xml_object_mapping_generator.dart";

/// Generator for creating XML mapper classes from annotated Dart classes.
class XmlMapperGenerator extends GeneratorForAnnotation<XmlMap> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        "The @xml annotation can only be applied to classes.",
        element: element,
      );
    }

    final model = XmlAnnotationReader.parseClass(element);
    final mapperClass = _buildMapperClass(model);

    final emitter = DartEmitter(useNullSafetySyntax: true);

    return mapperClass.accept(emitter).toString();
  }

  Class _buildMapperClass(XmlClassModel model) {
    final mapperName = "Xml${model.className}Mapper";
    final className = model.className;

    final mapperClass = ClassBuilder()
      ..name = mapperName
      ..modifier = ClassModifier.final$;

    // Add parse methods
    mapperClass.methods.addAll([
      _buildParseFromTextMethod(mapperName, className),
      _buildParseFromFileMethod(mapperName, className),
      _buildParseFromPathMethod(mapperName, className),
      _buildParseFromXmlElementMethod(mapperName, className),
      _buildToXmlMethod(model, className),
    ]);

    // Add helper methods
    mapperClass.methods.addAll([
      _buildBuildMethod(model, className),
      _buildExtractMethod(model),
    ]);

    return mapperClass.build();
  }

  Method _buildParseFromTextMethod(String mapperName, String className) =>
      Method(
        (b) => b
          ..name = "parse"
          ..static = true
          ..returns = refer(className)
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = "text"
                ..type = refer("String"),
            ),
          )
          ..optionalParameters.add(
            Parameter(
              (b) => b
                ..name = "rootName"
                ..type = refer("String?")
                ..named = true,
            ),
          )
          ..body = Block.of([
            const Code("final document = XmlDocument.parse(text);"),
            const Code("final element = document.rootElement;"),
            const Code(r'''
if (rootName != null && element.name.local != rootName) {
  throw XmlMappingFormatException(
    'Expected root element "$rootName" but found "${element.name.local}"',
  );
}
'''),
            Code("return $mapperName._build(element);"),
          ]),
      );

  Method _buildParseFromFileMethod(String mapperName, String className) =>
      Method(
        (b) => b
          ..name = "parseFile"
          ..static = true
          ..returns = refer(className)
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = "file"
                ..type = refer("File"),
            ),
          )
          ..optionalParameters.add(
            Parameter(
              (b) => b
                ..name = "rootName"
                ..type = refer("String?")
                ..named = true,
            ),
          )
          ..body = Code("""
try {
  final text = file.readAsStringSync();
  return $mapperName.parse(text, rootName: rootName);
} on FileSystemException catch (e) {
  throw XmlMappingParserException('Failed to read file: \${e.message}');
}
"""),
      );

  Method _buildParseFromPathMethod(String mapperName, String className) =>
      Method(
        (b) => b
          ..name = "parsePath"
          ..static = true
          ..returns = refer(className)
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = "path"
                ..type = refer("String"),
            ),
          )
          ..optionalParameters.add(
            Parameter(
              (b) => b
                ..name = "rootName"
                ..type = refer("String?")
                ..named = true,
            ),
          )
          ..body = Code("""
return $mapperName.parseFile(File(path), rootName: rootName);
"""),
      );

  Method _buildParseFromXmlElementMethod(String mapperName, String className) =>
      Method(
        (b) => b
          ..name = "parseElement"
          ..static = true
          ..returns = refer(className)
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = "xmlElement"
                ..type = refer("XmlElement"),
            ),
          )
          ..optionalParameters.add(
            Parameter(
              (b) => b
                ..name = "rootName"
                ..type = refer("String?")
                ..named = true,
            ),
          )
          ..body = Code('''
if (rootName != null && xmlElement.name.local != rootName) {
  throw XmlMappingFormatException(
    'Expected root element "\$rootName" but found "\${xmlElement.name.local}"',
  );
}
return $mapperName._build(xmlElement);
'''),
      );

  Method _buildBuildMethod(XmlClassModel model, String className) {
    final assignments = <String>[];

    for (final field in model.fields) {
      if (field is XmlMapIgnoreAnnotation) {
        continue;
      }

      final fieldName = field.fieldName;
      final fieldType = field.fieldType.getDisplayString();
      final isNullable = field.isNullable;
      final isNested = _isXmlAnnotatedClass(field.fieldType);

      String extractionCode;

      if (field is XmlMapAttributeAnnotation) {
        extractionCode = _buildAttributeExtraction(
          fieldName,
          fieldType,
          field.attributeName,
          className,
          isNullable,
          field.converterInstance,
          isNested,
        );
      } else if (field is XmlMapElementAnnotation) {
        extractionCode = _buildElementExtraction(
          fieldName,
          fieldType,
          field.elementName,
          className,
          isNullable,
          field.converterInstance,
          isNested,
        );
      } else if (field is XmlMapValueAnnotation) {
        extractionCode = _buildValueExtraction(
          fieldName,
          fieldType,
          className,
          isNullable,
          field.converterInstance,
          isNested,
        );
      } else if (field is XmlMapListAnnotation) {
        extractionCode = _buildListExtraction(
          field,
          fieldName,
          fieldType,
          field.elementName,
          field.childName,
          className,
          isNullable,
          field.converterInstance,
        );
      } else {
        continue;
      }

      assignments.add(extractionCode);
    }

    final mappedFieldNames = model.fields
        .where((f) => f is! XmlMapIgnoreAnnotation)
        .map((f) => f.fieldName)
        .toSet();

    final fieldNames = model.allFields
        .where((f) => mappedFieldNames.contains(f.name))
        .map((f) => "${f.name}: ${f.name}")
        .join(", ");

    return Method(
      (b) => b
        ..name = "_build"
        ..returns = refer(className)
        ..static = true
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = "element"
              ..type = refer("XmlElement"),
          ),
        )
        ..body = Code('''
${assignments.join('\n')}
return $className($fieldNames);
'''),
    );
  }

  String _buildAttributeExtraction(
    String fieldName,
    String fieldType,
    String attrName,
    String className,
    bool isNullable,
    String? converterInstance,
    bool isNested,
  ) {
    final attrVar = "attr_$fieldName";
    final converter = converterInstance ?? _getDefaultConverter(fieldType);

    if (isNested) {
      final nestedMapper = "Xml${fieldType.replaceAll('?', '')}Mapper";
      if (isNullable) {
        return '''
final $attrVar = element.getAttribute("$attrName");
final $fieldName = $attrVar != null ? $nestedMapper.parse($attrVar) : null;
''';
      } else {
        return '''
final $attrVar = element.getAttribute("$attrName");
if ($attrVar == null) throw XmlMappingMissingElementException("$attrName", "$className");
final $fieldName = $nestedMapper.parse($attrVar);
''';
      }
    }

    final castType = isNullable
        ? (fieldType.endsWith("?") ? fieldType : "$fieldType?")
        : fieldType;

    if (isNullable) {
      return '''
final $attrVar = element.getAttribute("$attrName");
final $fieldName = $attrVar != null ? ($converter.convert($attrVar) as $castType) : null;
''';
    } else {
      return '''
final $attrVar = element.getAttribute("$attrName");
if ($attrVar == null) {
  throw XmlMappingMissingElementException("$attrName", "$className");
}
$fieldType $fieldName;
try {
  $fieldName = $converter.convert($attrVar) as $fieldType;
} catch (e) {
  throw XmlMappingTypeConversionException($attrVar, "$fieldType", reason: e.toString());
}
''';
    }
  }

  String _buildElementExtraction(
    String fieldName,
    String fieldType,
    String elemName,
    String className,
    bool isNullable,
    String? converterInstance,
    bool isNested,
  ) {
    final elemVar = "elem_$fieldName";

    if (isNested) {
      final nestedMapper = "Xml${fieldType.replaceAll('?', '')}Mapper";
      if (isNullable) {
        return '''
final $elemVar = element.getElement("$elemName");
final $fieldName = $elemVar != null ? $nestedMapper.parseElement($elemVar) : null;
''';
      } else {
        return '''
final $elemVar = element.getElement("$elemName");
if ($elemVar == null) throw XmlMappingMissingElementException("$elemName", "$className");
final $fieldName = $nestedMapper.parseElement($elemVar);
''';
      }
    }

    final converter = converterInstance ?? _getDefaultConverter(fieldType);
    final castType = isNullable
        ? (fieldType.endsWith("?") ? fieldType : "$fieldType?")
        : fieldType;

    if (isNullable) {
      return '''
final $elemVar = element.getElement("$elemName");
final $fieldName = $elemVar != null ? ($converter.convert($elemVar.text) as $castType) : null;
''';
    } else {
      return '''
final $elemVar = element.getElement("$elemName");
if ($elemVar == null) {
  throw XmlMappingMissingElementException("$elemName", "$className");
}
$fieldType $fieldName;
try {
  $fieldName = $converter.convert($elemVar.text) as $fieldType;
} catch (e) {
  throw XmlMappingTypeConversionException($elemVar.text, "$fieldType", reason: e.toString());
}
''';
    }
  }

  String _buildValueExtraction(
    String fieldName,
    String fieldType,
    String className,
    bool isNullable,
    String? converterInstance,
    bool isNested,
  ) {
    if (isNested) {
      final nestedMapper = "Xml${fieldType.replaceAll('?', '')}Mapper";
      return "final $fieldName = $nestedMapper.parseElement(element);";
    }

    final converter = converterInstance ?? _getDefaultConverter(fieldType);
    final castType = isNullable
        ? (fieldType.endsWith("?") ? fieldType : "$fieldType?")
        : fieldType;

    if (isNullable) {
      return "final $fieldName = element.text.isNotEmpty ? ($converter.convert(element.text) as $castType) : null;";
    } else {
      return '''
$fieldType $fieldName;
try {
  $fieldName = $converter.convert(element.text) as $fieldType;
} catch (e) {
  throw XmlMappingTypeConversionException(element.text, "$fieldType", reason: e.toString());
}
''';
    }
  }

  String _buildListExtraction(
    XmlMapListAnnotation field,
    String fieldName,
    String fieldType,
    String listElemName,
    String childName,
    String className,
    bool isNullable,
    String? converterInstance,
  ) {
    final listType = field.fieldType;
    if (listType is! InterfaceType || listType.typeArguments.isEmpty) {
      return "final $fieldName = <dynamic>[];\n";
    }

    final itemType = listType.typeArguments.first;
    final itemTypeName = itemType.getDisplayString();
    final isNestedXmlClass = _isXmlAnnotatedClass(itemType);

    if (isNestedXmlClass) {
      final itemMapperName = "Xml${itemType.element!.name}Mapper";
      return '''
final $fieldName = element.getElement("$listElemName")?.childElements
    .where((e) => e.name.local == "$childName")
    .map((e) => $itemMapperName._build(e))
    .toList() ?? [];
''';
    } else {
      final converter = converterInstance ?? _getDefaultConverter(itemTypeName);
      return '''
final $fieldName = element.getElement("$listElemName")?.childElements
    .where((e) => e.name.local == "$childName")
    .map((e) => $converter.convert(e.text) as $itemTypeName)
    .toList() ?? [];
''';
    }
  }

  bool _isXmlAnnotatedClass(DartType type) {
    final element = type is InterfaceType ? type.element : null;
    if (element is! ClassElement) {
      return false;
    }
    return XmlAnnotationReader.hasXmlAnnotation(element);
  }

  String _getDefaultConverter(String typeName) {
    final cleanType = typeName.replaceAll("?", "");
    return switch (cleanType) {
      "int" => "const IntConverter()",
      "double" => "const DoubleConverter()",
      "num" => "const NumConverter()",
      "bool" => "const BoolConverter()",
      "DateTime" => "const DateTimeConverter()",
      _ => "const XmlValueConverter()",
    };
  }

  Method _buildExtractMethod(XmlClassModel model) => Method(
    (b) => b
      ..name = "_extract"
      ..returns = refer("void")
      ..static = true
      ..requiredParameters.add(
        Parameter(
          (b) => b
            ..name = "element"
            ..type = refer("XmlElement"),
        ),
      )
      ..requiredParameters.add(
        Parameter(
          (b) => b
            ..name = "instance"
            ..type = refer("dynamic"),
        ),
      )
      ..body = const Code("// Extraction logic\n"),
  );

  Method _buildToXmlMethod(XmlClassModel model, String className) => Method(
    (b) => b
      ..name = "toXml"
      ..static = true
      ..returns = refer("XmlElement")
      ..requiredParameters.add(
        Parameter(
          (b) => b
            ..name = "instance"
            ..type = refer(className),
        ),
      )
      ..body = const Code(
        "// TODO: Implement serialization\nthrow UnimplementedError('Serialization not yet implemented');\n",
      ),
  );
}
