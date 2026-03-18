// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// XmlMapperGenerator
// **************************************************************************

final class UserXmlMapper {
  static User parse(String text, {String? rootName}) {
    final document = XmlDocument.parse(text);
    final element = document.rootElement;
    if (rootName != null && element.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${element.name.local}"',
      );
    }

    return UserXmlMapper._build(element);
  }

  static User parseFile(File file, {String? rootName}) {
    try {
      final text = file.readAsStringSync();
      return UserXmlMapper.parse(text, rootName: rootName);
    } on FileSystemException catch (e) {
      throw XmlMappingParserException('Failed to read file: ${e.message}');
    }
  }

  static User parsePath(String path, {String? rootName}) {
    return UserXmlMapper.parseFile(File(path), rootName: rootName);
  }

  static User parseElement(XmlElement xmlElement, {String? rootName}) {
    if (rootName != null && xmlElement.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${xmlElement.name.local}"',
      );
    }
    return UserXmlMapper._build(xmlElement);
  }

  static XmlElement toXml(User instance) {
    // TODO: Implement serialization
    throw UnimplementedError('Serialization not yet implemented');
  }

  static User _build(XmlElement element) {
    final attr_id = element.getAttribute("id");
    if (attr_id == null) {
      throw XmlMappingMissingElementException("id", "User");
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

    final elem_name = element.getElement("name");
    if (elem_name == null) {
      throw XmlMappingMissingElementException("name", "User");
    }
    String name;
    try {
      name = const XmlValueConverter().convert(elem_name.text) as String;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        elem_name.text,
        "String",
        reason: e.toString(),
      );
    }

    final elem_email = element.getElement("email");
    if (elem_email == null) {
      throw XmlMappingMissingElementException("email", "User");
    }
    String email;
    try {
      email = const XmlValueConverter().convert(elem_email.text) as String;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        elem_email.text,
        "String",
        reason: e.toString(),
      );
    }

    final roles =
        element
            .getElement("roles")
            ?.childElements
            .where((e) => e.name.local == "role")
            .map((e) => const XmlValueConverter().convert(e.text) as String)
            .toList() ??
        [];

    final elem_profile = element.getElement("profile");
    final profile = elem_profile != null
        ? ProfileXmlMapper.parseElement(elem_profile)
        : null;

    return User(
      id: id,
      name: name,
      email: email,
      roles: roles,
      profile: profile,
    );
  }

  static void _extract(XmlElement element, dynamic instance) {
    // Extraction logic
  }
}

final class ProfileXmlMapper {
  static Profile parse(String text, {String? rootName}) {
    final document = XmlDocument.parse(text);
    final element = document.rootElement;
    if (rootName != null && element.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${element.name.local}"',
      );
    }

    return ProfileXmlMapper._build(element);
  }

  static Profile parseFile(File file, {String? rootName}) {
    try {
      final text = file.readAsStringSync();
      return ProfileXmlMapper.parse(text, rootName: rootName);
    } on FileSystemException catch (e) {
      throw XmlMappingParserException('Failed to read file: ${e.message}');
    }
  }

  static Profile parsePath(String path, {String? rootName}) {
    return ProfileXmlMapper.parseFile(File(path), rootName: rootName);
  }

  static Profile parseElement(XmlElement xmlElement, {String? rootName}) {
    if (rootName != null && xmlElement.name.local != rootName) {
      throw XmlMappingFormatException(
        'Expected root element "$rootName" but found "${xmlElement.name.local}"',
      );
    }
    return ProfileXmlMapper._build(xmlElement);
  }

  static XmlElement toXml(Profile instance) {
    // TODO: Implement serialization
    throw UnimplementedError('Serialization not yet implemented');
  }

  static Profile _build(XmlElement element) {
    final elem_bio = element.getElement("bio");
    if (elem_bio == null) {
      throw XmlMappingMissingElementException("bio", "Profile");
    }
    String bio;
    try {
      bio = const XmlValueConverter().convert(elem_bio.text) as String;
    } catch (e) {
      throw XmlMappingTypeConversionException(
        elem_bio.text,
        "String",
        reason: e.toString(),
      );
    }

    final elem_website = element.getElement("website");
    final website = elem_website != null
        ? (const XmlValueConverter().convert(elem_website.text) as String?)
        : null;

    return Profile(bio: bio, website: website);
  }

  static void _extract(XmlElement element, dynamic instance) {
    // Extraction logic
  }
}
