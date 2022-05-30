import 'package:flutter/material.dart';
import 'package:uploadcare_flutter/uploadcare_flutter.dart';

class ProjectInfoScreen extends StatelessWidget {
  const ProjectInfoScreen({
    Key? key,
    required this.project,
  }) : super(key: key);

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project info'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('name: ${project.name}'),
              const SizedBox(height: 10),
              Text('autoStoreEnabled: ${project.autoStoreEnabled}'),
              const SizedBox(height: 10),
              for (Collaborator value in project.collaborators) ...[
                Text('collaborator: ${value.email} - ${value.name}'),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
