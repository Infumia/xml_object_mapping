// ignore_for_file: avoid_print

import "package:xml_object_mapping/xml_object_mapping.dart";

part "advanced.g.dart";

enum ProjectStatus { planning, active, completed, onHold }

class ProjectStatusConverter extends XmlConverter<ProjectStatus> {
  const ProjectStatusConverter();

  @override
  ProjectStatus convert(String value) => ProjectStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => ProjectStatus.planning,
  );

  @override
  String serialize(ProjectStatus value) => value.name;
}

@xmlMap
class Project {
  @xmlMapAttribute
  final String id;

  @xmlMapElement
  final String title;

  @XmlMapElement(converter: ProjectStatusConverter())
  final ProjectStatus status;

  @XmlMapList(childName: "milestone", overrideName: "history")
  final List<String> milestones;

  @XmlMapList(childName: "task", overrideName: "tasks")
  final List<Task> tasks;

  final String internalId;

  Project({
    required this.id,
    required this.title,
    required this.status,
    required this.milestones,
    required this.tasks,
    this.internalId = "SECRET-123",
  });

  @override
  String toString() =>
      "Project(id: $id, title: $title, status: $status, milestones: $milestones, tasks: $tasks)";
}

@xmlMap
class Task {
  @xmlMapAttribute
  final int id;

  @xmlMapValue
  final String description;

  @XmlMapAttribute(overrideName: "completed")
  final bool isDone;

  Task({required this.id, required this.description, this.isDone = false});

  @override
  String toString() =>
      "Task(id: $id, description: $description, isDone: $isDone)";
}

void runAdvancedExample() {
  const xmlText = '''
<project id="PROJ-001">
  <title>AI XML Mapping Library</title>
  <status>active</status>
  <history>
    <milestone>Project started</milestone>
    <milestone>First MVP released</milestone>
  </history>
  <tasks>
    <task id="101" completed="true">Define core annotations</task>
    <task id="102" completed="false">Implement generator logic</task>
    <task id="103" completed="false">Add unit tests</task>
  </tasks>
</project>
''';

  print("--- Advanced Example ---");
  print("Parsing project XML...");

  final project = ProjectXmlMapper.parse(xmlText);

  print("Project ID: ${project.id}");
  print("Title: ${project.title}");
  print("Status: ${project.status}");
  print("Milestones: ${project.milestones.join(', ')}");
  print("Tasks:");
  for (final task in project.tasks) {
    print("  - [${task.isDone ? 'x' : ' '}] ${task.id}: ${task.description}");
  }

  print("\nFull Project Object:");
  print(project);
}
