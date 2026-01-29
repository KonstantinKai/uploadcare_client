import 'dart:async';

import 'package:flutter/material.dart' hide AspectRatio;
import 'package:uploadcare_flutter/uploadcare_flutter.dart';

class TransformationsScreen extends StatefulWidget {
  const TransformationsScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  final FileInfoEntity file;

  @override
  State<TransformationsScreen> createState() => _TransformationsScreenState();
}

class _TransformationsScreenState extends State<TransformationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ImageTransformation> _transformations = [];
  Timer? _debounceTimer;

  // Resize tab state
  int _resizeWidth = 800;
  int _resizeHeight = 600;
  bool _useSmartResize = false;
  int _previewSize = 1024;

  // Rotate tab state
  int _rotationAngle = 0;
  bool _flip = false;
  bool _mirror = false;

  // Color tab state
  int _brightness = 0;
  int _contrast = 0;
  int _saturation = 0;
  int _warmth = 0;
  bool _grayscale = false;
  bool _invert = false;
  int _enhance = 0;

  // Blur tab state
  int _blurStrength = 0;
  int _sharpStrength = 0;

  // Filter tab state
  FilterTValue? _selectedFilter;
  int _filterAmount = 100;

  // Format tab state
  ImageFormatTValue? _selectedFormat;
  QualityTValue _selectedQuality = QualityTValue.Normal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _updateTransformations();
    }
  }

  void _debouncedUpdateTransformations() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateTransformations();
    });
  }

  void _updateTransformations() {
    final List<ImageTransformation> newTransformations = [];

    // Check if we have a resize operation
    bool hasResizeOperation = _useSmartResize ||
        _resizeWidth != 800 ||
        _resizeHeight != 600 ||
        _previewSize != 1024;

    // Check if we need a resize operation (for color, filter, blur, rotate, overlay tabs)
    bool needsResizeOperation = _brightness != 0 ||
        _contrast != 0 ||
        _saturation != 0 ||
        _warmth != 0 ||
        _grayscale ||
        _invert ||
        _enhance > 0 ||
        _blurStrength > 0 ||
        _sharpStrength > 0 ||
        _selectedFilter != null ||
        _rotationAngle != 0 ||
        _flip ||
        _mirror;

    // Add default preview if needed but no resize operation is set
    if (needsResizeOperation && !hasResizeOperation) {
      newTransformations.add(PreviewTransformation());
    }

    // Add resize transformations
    if (_useSmartResize) {
      newTransformations.add(ImageResizeTransformation(
        Dimensions(_resizeWidth, _resizeHeight),
        true,
      ));
    } else if (_resizeWidth != 800 || _resizeHeight != 600) {
      newTransformations.add(ImageResizeTransformation(
        Dimensions(_resizeWidth, _resizeHeight),
      ));
    }

    if (_previewSize != 1024) {
      newTransformations.add(PreviewTransformation(
        Dimensions.square(_previewSize),
      ));
    }

    // Add rotation transformations
    if (_rotationAngle != 0) {
      newTransformations.add(RotateTransformation(_rotationAngle));
    }
    if (_flip) {
      newTransformations.add(FlipTransformation());
    }
    if (_mirror) {
      newTransformations.add(MirrorTransformation());
    }

    // Add color transformations
    if (_brightness != 0) {
      newTransformations.add(ColorBrightnessTransformation(_brightness));
    }
    if (_contrast != 0) {
      newTransformations.add(ColorContrastTransformation(_contrast));
    }
    if (_saturation != 0) {
      newTransformations.add(ColorSaturationTransformation(_saturation));
    }
    if (_warmth != 0) {
      newTransformations.add(ColorWarmthTransformation(_warmth));
    }
    if (_grayscale) {
      newTransformations.add(GrayscaleTransformation());
    }
    if (_invert) {
      newTransformations.add(InvertTransformation());
    }
    if (_enhance > 0) {
      newTransformations.add(EnhanceTransformation(_enhance));
    }

    // Add blur/sharp transformations
    if (_blurStrength > 0) {
      newTransformations.add(BlurTransformation(_blurStrength));
    }
    if (_sharpStrength > 0) {
      newTransformations.add(SharpTransformation(_sharpStrength));
    }

    // Add filter transformation
    if (_selectedFilter != null) {
      newTransformations.add(FilterTransformation(_selectedFilter!, _filterAmount));
    }

    // Add format transformation
    if (_selectedFormat != null) {
      newTransformations.add(ImageFormatTransformation(_selectedFormat!));
    }
    if (_selectedQuality != QualityTValue.Normal) {
      newTransformations.add(QualityTransformation(_selectedQuality));
    }

    setState(() {
      _transformations = newTransformations;
    });
  }

  void _resetAll() {
    setState(() {
      _resizeWidth = 800;
      _resizeHeight = 600;
      _useSmartResize = false;
      _previewSize = 1024;
      _rotationAngle = 0;
      _flip = false;
      _mirror = false;
      _brightness = 0;
      _contrast = 0;
      _saturation = 0;
      _warmth = 0;
      _grayscale = false;
      _invert = false;
      _enhance = 0;
      _blurStrength = 0;
      _sharpStrength = 0;
      _selectedFilter = null;
      _filterAmount = 100;
      _selectedFormat = null;
      _selectedQuality = QualityTValue.Normal;
      _transformations = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transformations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAll,
            tooltip: 'Reset all',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Resize'),
            Tab(text: 'Rotate'),
            Tab(text: 'Color'),
            Tab(text: 'Blur'),
            Tab(text: 'Filters'),
            Tab(text: 'Overlays'),
            Tab(text: 'Format'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black12,
              child: Center(
                child: Image(
                  image: UploadcareImageProvider(
                    widget.file.id,
                    transformations: _transformations,
                  ),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading image',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          if (_transformations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Active: ${_transformations.length} transformation(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            flex: 3,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResizeTab(),
                _buildRotateTab(),
                _buildColorTab(),
                _buildBlurTab(),
                _buildFiltersTab(),
                _buildOverlaysTab(),
                _buildFormatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResizeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Resize', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Width',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _resizeWidth.toString()),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0 && parsed <= 5000) {
                    _resizeWidth = parsed;
                    _updateTransformations();
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Height',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _resizeHeight.toString()),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0 && parsed <= 5000) {
                    _resizeHeight = parsed;
                    _updateTransformations();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Smart Resize'),
          subtitle: const Text('Uses AI to resize intelligently'),
          value: _useSmartResize,
          onChanged: (value) {
            setState(() {
              _useSmartResize = value;
            });
            _updateTransformations();
          },
        ),
        const Divider(),
        Text('Preview Size', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _previewSize.toDouble(),
          min: 256,
          max: 2048,
          divisions: 7,
          label: '${_previewSize}px',
          onChanged: (value) {
            setState(() {
              _previewSize = value.toInt();
            });
            _debouncedUpdateTransformations();
          },
        ),
        Text('Square preview: ${_previewSize}px'),
      ],
    );
  }

  Widget _buildRotateTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Rotation Angle', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [0, 90, 180, 270].map((angle) {
            return ChoiceChip(
              label: Text('$angle°'),
              selected: _rotationAngle == angle,
              onSelected: (selected) {
                setState(() {
                  _rotationAngle = selected ? angle : 0;
                });
                _updateTransformations();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text('Custom Angle: $_rotationAngle°'),
        Slider(
          value: _rotationAngle.toDouble(),
          min: -360,
          max: 360,
          divisions: 72,
          label: '$_rotationAngle°',
          onChanged: (value) {
            setState(() {
              _rotationAngle = value.toInt();
            });
            _debouncedUpdateTransformations();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Flip'),
          subtitle: const Text('Mirror across horizontal axis'),
          value: _flip,
          onChanged: (value) {
            setState(() {
              _flip = value;
            });
            _updateTransformations();
          },
        ),
        SwitchListTile(
          title: const Text('Mirror'),
          subtitle: const Text('Mirror across vertical axis'),
          value: _mirror,
          onChanged: (value) {
            setState(() {
              _mirror = value;
            });
            _updateTransformations();
          },
        ),
      ],
    );
  }

  Widget _buildColorTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSliderTile(
          'Brightness',
          _brightness.toDouble(),
          -100,
          100,
          (value) {
            setState(() => _brightness = value.toInt());
            _debouncedUpdateTransformations();
          },
        ),
        _buildSliderTile(
          'Contrast',
          _contrast.toDouble(),
          -100,
          500,
          (value) {
            setState(() => _contrast = value.toInt());
            _debouncedUpdateTransformations();
          },
        ),
        _buildSliderTile(
          'Saturation',
          _saturation.toDouble(),
          -100,
          500,
          (value) {
            setState(() => _saturation = value.toInt());
            _debouncedUpdateTransformations();
          },
        ),
        _buildSliderTile(
          'Warmth',
          _warmth.toDouble(),
          -100,
          100,
          (value) {
            setState(() => _warmth = value.toInt());
            _debouncedUpdateTransformations();
          },
        ),
        _buildSliderTile(
          'Enhance',
          _enhance.toDouble(),
          0,
          100,
          (value) {
            setState(() => _enhance = value.toInt());
            _debouncedUpdateTransformations();
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Grayscale'),
          value: _grayscale,
          onChanged: (value) {
            setState(() => _grayscale = value);
            _updateTransformations();
          },
        ),
        SwitchListTile(
          title: const Text('Invert'),
          value: _invert,
          onChanged: (value) {
            setState(() => _invert = value);
            _updateTransformations();
          },
        ),
      ],
    );
  }

  Widget _buildSliderTile(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}'),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _addOverlayTransformation(ImageTransformation transformation) {
    setState(() {
      // Check if we already have a resize operation
      final hasResizeOp = _transformations.any((t) =>
          t is ImageResizeTransformation ||
          t is PreviewTransformation ||
          t is ScaleCropTransformation);

      if (!hasResizeOp) {
        _transformations = [
          PreviewTransformation(),
          ..._transformations,
          transformation,
        ];
      } else {
        _transformations = [
          ..._transformations,
          transformation,
        ];
      }
    });
  }

  Widget _buildBlurTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Blur Strength', style: Theme.of(context).textTheme.titleMedium),
        Text('Current: $_blurStrength'),
        Slider(
          value: _blurStrength.toDouble(),
          min: 0,
          max: 500,
          divisions: 50,
          label: '$_blurStrength',
          onChanged: (value) {
            setState(() => _blurStrength = value.toInt());
            _debouncedUpdateTransformations();
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [0, 10, 50, 100, 200, 500].map((strength) {
            return ActionChip(
              label: Text('$strength'),
              onPressed: () {
                setState(() => _blurStrength = strength);
                _updateTransformations();
              },
            );
          }).toList(),
        ),
        const Divider(),
        Text('Sharpen Strength', style: Theme.of(context).textTheme.titleMedium),
        Text('Current: $_sharpStrength'),
        Slider(
          value: _sharpStrength.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: '$_sharpStrength',
          onChanged: (value) {
            setState(() => _sharpStrength = value.toInt());
            _debouncedUpdateTransformations();
          },
        ),
        Wrap(
          spacing: 8,
          children: [0, 5, 10, 15, 20].map((strength) {
            return ActionChip(
              label: Text('$strength'),
              onPressed: () {
                setState(() => _sharpStrength = strength);
                _updateTransformations();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFiltersTab() {
    final filters = [
      FilterTValue.Adaris,
      FilterTValue.Briaril,
      FilterTValue.Calarel,
      FilterTValue.Carris,
      FilterTValue.Cynarel,
      FilterTValue.Cyren,
      FilterTValue.Elmet,
      FilterTValue.Elonni,
      FilterTValue.Enzana,
      FilterTValue.Erydark,
      FilterTValue.Fenralan,
      FilterTValue.Ferand,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Select Filter', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('None'),
              selected: _selectedFilter == null,
              onSelected: (selected) {
                setState(() => _selectedFilter = null);
                _updateTransformations();
              },
            ),
            ...filters.map((filter) {
              final name = filter.toString().split('.').last;
              return ChoiceChip(
                label: Text(name),
                selected: _selectedFilter == filter,
                onSelected: (selected) {
                  setState(() => _selectedFilter = selected ? filter : null);
                  _updateTransformations();
                },
              );
            }),
          ],
        ),
        if (_selectedFilter != null) ...[
          const Divider(),
          Text('Filter Amount: $_filterAmount'),
          Slider(
            value: _filterAmount.toDouble(),
            min: -100,
            max: 200,
            divisions: 30,
            label: '$_filterAmount',
            onChanged: (value) {
              setState(() => _filterAmount = value.toInt());
              _debouncedUpdateTransformations();
            },
          ),
          const Text('0 = no effect, 100 = normal, 200 = emphasized'),
        ],
      ],
    );
  }

  Widget _buildOverlaysTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Overlays', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text Overlay',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Text overlays require special permissions. Contact Uploadcare sales to enable this feature.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rectangle Overlay',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Draw solid color rectangles on images. Configure color, dimensions, and position.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _addOverlayTransformation(
                      RectOverlayTransformation(
                        color: 'ff000080',
                        relativeDimensions: const Dimensions(
                          20,
                          20,
                          units: MeasureUnits.Percent,
                        ),
                        relativeCoordinates: const Offsets(
                          10,
                          10,
                          units: MeasureUnits.Percent,
                        ),
                      ),
                    );
                  },
                  child: const Text('Add Sample Rectangle'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Border Radius',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add rounded corners to images.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('10px'),
                      onPressed: () {
                        _addOverlayTransformation(
                          const BorderRadiusTransformation(
                            radii: Radii.all(10),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('25px'),
                      onPressed: () {
                        _addOverlayTransformation(
                          const BorderRadiusTransformation(
                            radii: Radii.all(25),
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      label: const Text('50px'),
                      onPressed: () {
                        _addOverlayTransformation(
                          const BorderRadiusTransformation(
                            radii: Radii.all(50),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Output Format', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Original'),
              selected: _selectedFormat == null,
              onSelected: (selected) {
                setState(() => _selectedFormat = null);
                _updateTransformations();
              },
            ),
            ChoiceChip(
              label: const Text('JPEG'),
              selected: _selectedFormat == ImageFormatTValue.Jpeg,
              onSelected: (selected) {
                setState(() =>
                    _selectedFormat = selected ? ImageFormatTValue.Jpeg : null);
                _updateTransformations();
              },
            ),
            ChoiceChip(
              label: const Text('PNG'),
              selected: _selectedFormat == ImageFormatTValue.Png,
              onSelected: (selected) {
                setState(() =>
                    _selectedFormat = selected ? ImageFormatTValue.Png : null);
                _updateTransformations();
              },
            ),
            ChoiceChip(
              label: const Text('WebP'),
              selected: _selectedFormat == ImageFormatTValue.Webp,
              onSelected: (selected) {
                setState(() =>
                    _selectedFormat = selected ? ImageFormatTValue.Webp : null);
                _updateTransformations();
              },
            ),
            ChoiceChip(
              label: const Text('Auto'),
              selected: _selectedFormat == ImageFormatTValue.Auto,
              onSelected: (selected) {
                setState(() =>
                    _selectedFormat = selected ? ImageFormatTValue.Auto : null);
                _updateTransformations();
              },
            ),
          ],
        ),
        const Divider(),
        Text('Quality', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QualityTValue.values.map((quality) {
            final name = quality.toString().split('.').last;
            return ChoiceChip(
              label: Text(name),
              selected: _selectedQuality == quality,
              onSelected: (selected) {
                setState(() => _selectedQuality =
                    selected ? quality : QualityTValue.Normal);
                _updateTransformations();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Quality levels:\n'
          '- Lightest: Minimal quality, fastest loading\n'
          '- Lighter: Good balance for web\n'
          '- Normal: Default quality\n'
          '- Better: Higher quality\n'
          '- Best: Maximum quality\n'
          '- Smart: AI-optimized\n'
          '- Smart Retina: Optimized for 2x displays',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
