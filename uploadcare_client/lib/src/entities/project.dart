import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  /// Project login name
  final String name;

  final bool autoStoreEnabled;

  final List<Collaborator> collaborators;

  const ProjectEntity({
    required this.name,
    required this.autoStoreEnabled,
    required this.collaborators,
  });

  factory ProjectEntity.fromJson(Map<String, dynamic> json) => ProjectEntity(
        name: json['name'],
        autoStoreEnabled: json['autostore_enabled'],
        collaborators: json['collaborators'] != null
            ? (json['collaborators'] as List)
                .map((item) =>
                    Collaborator(email: item['email'], name: item['name']))
                .toList()
            : [],
      );

  @override
  List<Object?> get props => [
        name,
        autoStoreEnabled,
        collaborators,
      ];
}

class Collaborator extends Equatable {
  /// Collaborator email
  final String email;

  /// Collaborator name
  final String name;

  const Collaborator({
    required this.email,
    required this.name,
  });

  @override
  List<Object?> get props => [
        email,
        name,
      ];
}
