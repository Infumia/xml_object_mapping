import "package:build/build.dart";
import "package:source_gen/source_gen.dart";
import "package:xml_object_mapping_generator/xml_object_mapping_generator.dart";

/// Builder for generating XML mapper classes.
Builder xmlMapperBuilder(BuilderOptions options) => LibraryBuilder(
  XmlMapperGenerator(),
  generatedExtension: ".xml_mapper.g.dart",
);
