import '../entities/entities.dart';
import '../mixins/options_shortcuts_mixin.dart';
import '../mixins/transport_helper_mixin.dart';
import '../options.dart';

/// See https://uploadcare.com/api-refs/rest-api/v0.5.0/#tag/Project
class ApiProject with OptionsShortcutMixin, TransportHelperMixin {
  ApiProject({
    required this.options,
  });

  @override
  final ClientOptions options;

  /// Getting info about account project
  Future<ProjectEntity> info() async {
    return ProjectEntity.fromJson(
      await resolveStreamedResponse(
        createRequest(
          'GET',
          buildUri('$apiUrl/project/'),
        ).send(),
      ),
    );
  }
}
