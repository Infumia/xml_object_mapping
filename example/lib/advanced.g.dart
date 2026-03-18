// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced.dart';

// **************************************************************************
// XmlMapperGenerator
// **************************************************************************

final class ProjectXmlMapper {
  static Project parse(String text, {String? rootName}) {
    final document = XmlDocument.parse(text);
    final element = document.rootElement;
    if (rootName != null && element.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${element.name.local}"',
      );
    }

    return ProjectXmlMapper._build(element);
  }

  static Project parseFile(File file, {String? rootName}) {
    try {
      final text = file.readAsStringSync();
      return ProjectXmlMapper.parse(text, rootName: rootName);
    } on FileSystemException catch (e) {
      throw XmlMappingParserException('Failed to read file: ${e.message}');
    }
  }

  static Project parsePath(String path, {String? rootName}) {
    return ProjectXmlMapper.parseFile(File(path), rootName: rootName);
  }

  static Project parseElement(XmlElement xmlElement, {String? rootName}) {
    if (rootName != null && xmlElement.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${xmlElement.name.local}"',
      );
    }
    return ProjectXmlMapper._build(xmlElement);
  }

  static XmlElement toXml(Project instance) {
    // TODO: Implement serialization
    throw UnimplementedError('Serialization not yet implemented');
  }

  static Project _build(XmlElement element) {
    final attr_id = element.getAttribute("id");
    if (attr_id == null) {
      throw XmlMappingMissingElementException("id", "Project");
    }
    String id;
    try {
      id = const XmlValueConverter().convert(attr_id) as String;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        attr_id,
        "String",
        reason: e.toString(),
      );
    }

    final elem_title = element.getElement("title");
    if (elem_title == null) {
      throw XmlMappingMissingElementException("title", "Project");
    }
    String title;
    try {
      title = const XmlValueConverter().convert(elem_title.text) as String;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        elem_title.text,
        "String",
        reason: e.toString(),
      );
    }

    final elem_status = element.getElement("status");
    if (elem_status == null) {
      throw XmlMappingMissingElementException("status", "Project");
    }
    ProjectStatus status;
    try {
      status =
          const ProjectStatusConverter().convert(elem_status.text)
              as ProjectStatus;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        elem_status.text,
        "ProjectStatus",
        reason: e.toString(),
      );
    }

    final milestones =
        element
            .getElement("history")
            ?.childElements
            .where((e) => e.name.local == "milestone")
            .map((e) => const XmlValueConverter().convert(e.text) as String)
            .toList() ??
        [];

    final tasks =
        element
            .getElement("tasks")
            ?.childElements
            .where((e) => e.name.local == "task")
            .map((e) => TaskXmlMapper._build(e))
            .toList() ??
        [];

    return Project(
      id: id,
      title: title,
      status: status,
      milestones: milestones,
      tasks: tasks,
    );
  }

  static void _extract(XmlElement element, dynamic instance) {
    // Extraction logic
  }
}

final class TaskXmlMapper {
  static Task parse(String text, {String? rootName}) {
    final document = XmlDocument.parse(text);
    final element = document.rootElement;
    if (rootName != null && element.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${element.name.local}"',
      );
    }

    return TaskXmlMapper._build(element);
  }

  static Task parseFile(File file, {String? rootName}) {
    try {
      final text = file.readAsStringSync();
      return TaskXmlMapper.parse(text, rootName: rootName);
    } on FileSystemException catch (e) {
      throw XmlMappingParserException('Failed to read file: ${e.message}');
    }
  }

  static Task parsePath(String path, {String? rootName}) {
    return TaskXmlMapper.parseFile(File(path), rootName: rootName);
  }

  static Task parseElement(XmlElement xmlElement, {String? rootName}) {
    if (rootName != null && xmlElement.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${xmlElement.name.local}"',
      );
    }
    return TaskXmlMapper._build(xmlElement);
  }

  static XmlElement toXml(Task instance) {
    // TODO: Implement serialization
    throw UnimplementedError('Serialization not yet implemented');
  }

  static Task _build(XmlElement element) {
    final attr_id = element.getAttribute("id");
    if (attr_id == null) {
      throw XmlMappingMissingElementException("id", "Task");
    }
    int id;
    try {
      id = const IntConverter().convert(attr_id) as int;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        attr_id,
        "int",
        reason: e.toString(),
      );
    }

    String description;
    try {
      description = const XmlValueConverter().convert(element.text) as String;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        element.text,
        "String",
        reason: e.toString(),
      );
    }

    final attr_isDone = element.getAttribute("completed");
    if (attr_isDone == null) {
      throw XmlMappingMissingElementException("completed", "Task");
    }
    bool isDone;
    try {
      isDone = const BoolConverter().convert(attr_isDone) as bool;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        attr_isDone,
        "bool",
        reason: e.toString(),
      );
    }

    return Task(id: id, description: description, isDone: isDone);
  }

  static void _extract(XmlElement element, dynamic instance) {
    // Extraction logic
  }
}
