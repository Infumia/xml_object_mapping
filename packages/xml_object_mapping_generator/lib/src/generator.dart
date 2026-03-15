import "package:analyzer/dart/element/element.dart";
import "package:analyzer/dart/element/type.dart";
import "package:build/build.dart";
import "package:code_builder/code_builder.dart";
import "package:source_gen/source_gen.dart" hide LibraryBuilder;
import "package:xml_object_mapping_generator/xml_object_mapping_generator.dart";

/// Generator for creating XML mapper classes from annotated Dart classes.
class XmlMapperGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final buffer = StringBuffer();

    for (final element in library.allElements) {
      if (element is! ClassElement) continue;
      if (!XmlAnnotationReader.hasXmlAnnotation(element)) continue;

      final model = XmlAnnotationReader.parseClass(element);
      buffer.writeln(_generateMapper(model));
    }

    return buffer.toString();
  }

  String _generateMapper(XmlClassModel model) {
    final mapperName = "Xml${model.className}Mapper";
    final className = model.className;

    final library = LibraryBuilder();
    library.ignoreForFile.add("unused_import");
    library.ignoreForFile.add("unnecessary_cast");

    // Add imports
    library.body.addAll([
      Directive.import("dart:io"),
      Directive.import("package:xml/xml.dart"),
      Directive.import("package:xml_object_mapping/xml_object_mapping.dart"),
    ]);

    // Add mapper class
    final mapperClass = ClassBuilder();
    mapperClass.name = mapperName;
    mapperClass.modifiers.add("final");

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

    library.body.add(mapperClass.build());

    final emitter = DartEmitter(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    return library.build().accept(emitter).toString();
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
          ..body = Code('''
final document = XmlDocument.parse(text);
final element = document.rootElement;
if (rootName != null && element.name.local != rootName) {
  throw XmlFormatException(
    'Expected root element "$rootName" but found "${element.name.local}"',
  );
}
return $mapperName._build(element);
'''),
      );

  Method _buildParseFromFileMethod(String mapperName, String className) =>
      Method(
        (b) => b
          ..name = "parse"
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
  return $mapperName.parse(text: text, rootName: rootName);
} on FileSystemException catch (e) {
  throw XmlParserException('Failed to read file: \${e.message}');
}
"""),
      );

  Method _buildParseFromPathMethod(String mapperName, String className) =>
      Method(
        (b) => b
          ..name = "parse"
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
return $mapperName.parse(file: File(path), rootName: rootName);
"""),
      );

  Method _buildParseFromXmlElementMethod(String mapperName, String className) =>
      Method(
        (b) => b
          ..name = "parse"
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
  throw XmlFormatException(
    'Expected root element "$rootName" but found "${xmlElement.name.local}"',
  );
}
return $mapperName._build(xmlElement);
'''),
      );

  Method _buildBuildMethod(XmlClassModel model, String className) {
    final assignments = <String>[];

    for (final field in model.fields) {
      if (field is XmlIgnoreAnnotation) continue;

      final fieldName = field.fieldName;
      final fieldType = field.fieldType.getDisplayString(
        withNullability: false,
      );
      final isNullable = field.isNullable;

      String extractionCode;

      if (field is XmlAttributeAnnotation) {
        final attrName = field.attributeName;
        extractionCode = _buildAttributeExtraction(
          fieldName,
          fieldType,
          attrName,
          className,
          isNullable,
          field.converterInstance,
        );
      } else if (field is XmlElementAnnotation) {
        final elemName = field.elementName;
        extractionCode = _buildElementExtraction(
          fieldName,
          fieldType,
          elemName,
          className,
          isNullable,
          field.converterInstance,
        );
      } else if (field is XmlValueAnnotation) {
        extractionCode = _buildValueExtraction(
          fieldName,
          fieldType,
          className,
          isNullable,
          field.converterInstance,
        );
      } else if (field is XmlListAnnotation) {
        final listElemName = field.elementName;
        final childName = field.childName;
        extractionCode = _buildListExtraction(
          field,
          fieldName,
          fieldType,
          listElemName,
          childName,
          className,
          isNullable,
          field.converterInstance,
        );
      } else {
        continue;
      }

      assignments.add(extractionCode);
    }

    final fieldNames = model.allFields.map((f) => f.name).join(", ");

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
  ) {
    final attrVar = "attr_$fieldName";
    final converter = converterInstance ?? _getDefaultConverter(fieldType);

    if (isNullable) {
      return '''
final $attrVar = element.getAttribute("$attrName");
final $fieldName = $attrVar != null ? ($converter.convert($attrVar) as $fieldType?) : null;
''';
    } else {
      return '''
final $attrVar = element.getAttribute("$attrName");
if ($attrVar == null) {
  throw XmlMissingElementException("$attrName", "$className");
}
$fieldType $fieldName;
try {
  $fieldName = $converter.convert($attrVar) as $fieldType;
} catch (e) {
  throw XmlTypeConversionException($attrVar, "$fieldType", reason: e.toString());
}
''';
    }
  }

  String _buildElementRetraction(
    String fieldName,
    String fieldType,
    String elemName,
    String className,
    bool isNullable,
    String? converterInstance,
  ) {
    final elemVar = "elem_$fieldName";
    final converter = converterInstance ?? _getDefaultConverter(fieldType);

    if (isNullable) {
      return '''
final $elemVar = element.getElement("$elemName");
final $fieldName = $elemVar != null ? ($converter.convert($elemVar.text) as $fieldType?) : null;
''';
    } else {
      return '''
final $elemVar = element.getElement("$elemName");
if ($elemVar == null) {
  throw XmlMissingElementException("$elemName", "$className");
}
$fieldType $fieldName;
try {
  $fieldName = $converter.convert($elemVar.text) as $fieldType;
} catch (e) {
  throw XmlTypeConversionException($elemVar.text, "$fieldType", reason: e.toString());
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
  ) {
    final converter = converterInstance ?? _getDefaultConverter(fieldType);

    if (isNullable) {
      return """
final $fieldName = element.text.isNotEmpty ? ($converter.convert(element.text) as $fieldType?) : null;
""";
    } else {
      return '''
$fieldType $fieldName;
try {
  $fieldName = $converter.convert(element.text) as $fieldType;
} catch (e) {
  throw XmlTypeConversionException(element.text, "$fieldType", reason: e.toString());
}
''';
    }
  }

  String _buildListExtraction(
    XmlListAnnotation field,
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
    final itemTypeName = itemType.getDisplayString(withNullability: false);
    final isNestedXmlClass = _isXmlAnnotatedClass(itemType);

    if (isNestedXmlClass) {
      final itemMapperName = "Xml${itemType.element.name}Mapper";
      return '''
final $fieldName = element.getElement("$listElemName")?.elements
    .where((e) => e.name.local == "$childName")
    .map((e) => $itemMapperName._build(e))
    .toList() ?? [];
''';
    } else {
      final converter = converterInstance ?? _getDefaultConverter(itemTypeName);
      return '''
final $fieldName = element.getElement("$listElemName")?.elements
    .where((e) => e.name.local == "$childName")
    .map((e) => $converter.convert(e.text) as $itemTypeName)
    .toList() ?? [];
''';
    }
  }

  bool _isXmlAnnotatedClass(DartType type) {
    if (type is! InterfaceType) return false;
    final element = type.element;
    if (element is! ClassElement) return false;
    return XmlAnnotationReader.hasXmlAnnotation(element);
  }

  String _getDefaultConverter(String typeName) => switch (typeName) {
    "int" => "const IntConverter()",
    "double" => "const DoubleConverter()",
    "num" => "const NumConverter()",
    "bool" => "const BoolConverter()",
    "DateTime" => "const DateTimeConverter()",
    _ => "const XmlValueConverter()",
  };

  Method _buildExtractMethod(XmlClassModel model) {
    // Placeholder for future extract functionality
    return Method(
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
        ..body = const Code("// Extraction logic"),
    );
  }

  Method _buildToXmlMethod(XmlClassModel model, String className) {
    // TODO: Implement serialization
    return Method(
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
        ..body = const Code("""
// TODO: Implement serialization
throw UnimplementedError('Serialization not yet implemented');
"""),
    );
  }
}

/// Default converter for String types.
class XmlValueConverter {
  const XmlValueConverter();

  String convert(String value) => value;
}
