import "package:xml_object_mapping/xml_object_mapping.dart";

part "models.g.dart";

@xmlMap
class User {
  @xmlMapAttribute
  final int id;

  @xmlMapElement
  final String name;

  @xmlMapElement
  final String email;

  @XmlMapList(childName: "role", overrideName: "roles")
  final List<String> roles;

  @xmlMapElement
  final Profile? profile;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.profile,
  });

  @override
  String toString() =>
      "User(id: $id, name: $name, email: $email, roles: $roles, profile: $profile)";
}

@xmlMap
class Profile {
  @XmlMapElement(overrideName: "bio")
  final String bio;

  @XmlMapElement(overrideName: "website")
  final String? website;

  Profile({required this.bio, this.website});

  @override
  String toString() => "Profile(bio: $bio, website: $website)";
}
