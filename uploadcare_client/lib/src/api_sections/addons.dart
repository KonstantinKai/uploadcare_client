import 'dart:async';
import 'dart:convert';

import '../entities/addons.dart';
import '../mixins/mixins.dart';
import '../options.dart';

/// **Since v0.7**
///
/// An Add-On is an application implemented by Uploadcare that accepts uploaded
/// files as an input and can produce other files and/or `appdata` as an output.
///
/// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#tag/Add-Ons
class ApiAddons with OptionsShortcutMixin, TransportHelperMixin {
  @override
  final ClientOptions options;

  ApiAddons({
    required this.options,
  });

  /// Execute AWS Rekognition Add-On for a given target to detect labels in an image.
  /// Note: Detected labels are stored in the file's appdata.
  ///
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/awsRekognitionExecute
  Future<String> executeAWSRekognition(String fileId) async {
    return await _execute(
      pathname: '/addons/aws_rekognition_detect_labels/execute/',
      params: {
        'target': fileId,
      },
    );
  }

  /// Check the status of an Add-On execution request that had been started using the Execute Add-On operation.
  ///
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/awsRekognitionExecutionStatus
  Future<AddonExecutionStatus<void>> checkAWSRekognitionExecutionStatus(
      String requestId) async {
    final response = await _checkStatus(
      requestId: requestId,
      pathname: '/addons/aws_rekognition_detect_labels/execute/status/',
    );

    return AddonExecutionStatus(
      status: AddonExecutionStatusValue.parse(
        response['status'],
      ),
    );
  }

  /// Execute ClamAV virus checking Add-On for a given target.
  ///
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/ucClamavVirusScanExecute
  Future<String> executeClamAV(
    String fileId, {
    bool? purgeInfected,
  }) async {
    return await _execute(
      pathname: '/addons/uc_clamav_virus_scan/execute/',
      params: {
        'target': fileId,
        if (purgeInfected != null)
          'params': {'purge_infected': purgeInfected.toString()},
      },
    );
  }

  /// Check the status of an Add-On execution request that had been started using the Execute Add-On operation.
  ///
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/ucClamavVirusScanExecutionStatus
  Future<AddonExecutionStatus<void>> checkClamAVExecutionStatus(
      String requestId) async {
    final response = await _checkStatus(
      requestId: requestId,
      pathname: '/addons/uc_clamav_virus_scan/execute/status/',
    );

    return AddonExecutionStatus(
      status: AddonExecutionStatusValue.parse(
        response['status'],
      ),
    );
  }

  /// Execute remove.bg background image removal Add-On for a given target.
  ///
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/removeBgExecute
  Future<String> executeRemoveBg(
    String fileId, {

    /// Whether to crop off all empty regions
    /// Default: false
    bool? crop,

    /// Adds a margin around the cropped subject, e.g 30px or 30%
    /// Default: '0'
    String? cropMargin,

    /// Scales the subject relative to the total image size, e.g 80%
    String? scale,

    /// Whether to add an artificial shadow to the result
    /// Default: false
    bool? addShadow,

    /// Default: 'none'
    RemoveBgTypeLevelValue? typeLevel,

    /// Foreground type.
    RemoveBgTypeValue? type,

    /// Whether to have semi-transparent regions in the result
    /// Default: true
    bool? semitransparency,

    /// Request either the finalized image ('rgba', default) or an alpha mask ('alpha').
    /// Default: 'rgba'
    RemoveBgChannelsValue? channels,

    /// Region of interest: Only contents of this rectangular region can be detected as foreground.
    /// Everything outside is considered background and will be removed.
    /// The rectangle is defined as two x/y coordinates in the format "x1 y1 x2 y2".
    /// The coordinates can be in absolute pixels (suffix 'px') or relative to the width/height of the image (suffix '%').
    /// By default, the whole image is the region of interest ("0% 0% 100% 100%").
    String? roi,

    /// Positions the subject within the image canvas.
    /// Can be "original" (default unless "scale" is given), "center" (default when "scale" is given) or a value from "0%" to "100%" (both horizontal and vertical) or two values (horizontal, vertical).
    String? position,
  }) async {
    final params = <String, String>{
      if (crop != null) 'crop': crop.toString(),
      if (cropMargin != null) 'crop_margin': cropMargin,
      if (scale != null) 'scale': scale,
      if (addShadow != null) 'add_shadow': addShadow.toString(),
      if (typeLevel != null) 'type_level': typeLevel.toString(),
      if (type != null) 'type': type.toString(),
      if (semitransparency != null)
        'semitransparency': semitransparency.toString(),
      if (channels != null) 'channels': channels.toString(),
      if (roi != null) 'roi': roi,
      if (position != null) 'position': position,
    };

    return await _execute(
      pathname: '/addons/remove_bg/execute/',
      params: {
        'target': fileId,
        if (params.isNotEmpty) 'params': params,
      },
    );
  }

  /// Check the status of an Add-On execution request that had been started using the Execute Add-On operation.
  ///
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/removeBgExecutionStatus
  Future<AddonExecutionStatus<String>> checkRemoveBgExecutionStatus(
      String requestId) async {
    final response = await _checkStatus(
      requestId: requestId,
      pathname: '/addons/remove_bg/execute/status/',
    );

    final status = AddonExecutionStatusValue.parse(response['status']);

    return AddonExecutionStatus(
      status: status,
      result: status == AddonExecutionStatusValue.Done
          ? response['result']['file_id'] as String
          : null,
    );
  }

  Stream<AddonExecutionStatus<T>> checkTaskExecutionStatusAsStream<T>({
    required String requestId,
    required Future<AddonExecutionStatus<T>> Function(String requestId) task,
    Duration checkInterval = const Duration(seconds: 5),
  }) {
    Future<void> checker(
        StreamController<AddonExecutionStatus<T>> controller) async {
      late AddonExecutionStatus<T> status;

      try {
        status = await task(requestId);
      } catch (e) {
        controller.addError(e);
        controller.close();
      }

      controller.add(status);

      if (status.status == AddonExecutionStatusValue.InProgress) {
        Timer(checkInterval, () => checker(controller));

        return;
      }

      controller.close();
    }

    final StreamController<AddonExecutionStatus<T>> controller =
        StreamController.broadcast();

    checker(controller);

    return controller.stream;
  }

  void _ensureRightVersionForAddons() {
    ensureRightVersion(0.7, 'Add-Ons API');
  }

  Future<String> _execute({
    required String pathname,
    required Map<String, dynamic> params,
  }) async {
    _ensureRightVersionForAddons();

    final request = createRequest('POST', buildUri('$apiUrl$pathname'))
      ..body = jsonEncode(params);

    final response = await resolveStreamedResponse(request.send());

    return (response as Map<String, dynamic>)['request_id'] as String;
  }

  Future<Map<String, dynamic>> _checkStatus<T>({
    required String requestId,
    required String pathname,
  }) async {
    _ensureRightVersionForAddons();

    final response = await resolveStreamedResponse(
      createRequest(
        'GET',
        buildUri('$apiUrl$pathname', {
          'request_id': requestId,
        }),
      ).send(),
    );

    return response as Map<String, dynamic>;
  }
}
