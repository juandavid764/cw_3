import 'package:mr_croc/database/db_functions.dart';
import 'package:mr_croc/models/model_salsa.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UpdateSalsa extends StatefulWidget {
  final SalsaModel salsa;

  const UpdateSalsa({super.key, required this.salsa});

  @override
  State<UpdateSalsa> createState() => _UpdateSalsaState();
}

class _UpdateSalsaState extends State<UpdateSalsa> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  // HSV Color picker values
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.salsa.name);

    final color = widget.salsa.getColorObject();
    final hsvColor = HSVColor.fromColor(color);
    _hue = hsvColor.hue;
    _saturation = hsvColor.saturation * 100;
    _value = hsvColor.value * 100;
  }

  Color _getColorFromHSV() {
    return HSVColor.fromAHSV(1.0, _hue, _saturation / 100, _value / 100).toColor();
  }

  String _colorToHex(Color color) {
    return SalsaModel.colorToHex(color);
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _getColorFromHSV();
    final colorHex = _colorToHex(selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Salsa'),
        actions: [
          IconButton(
            onPressed: () => _buttonUpdate(context),
            icon: const Icon(Icons.save_rounded),
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Nombre Input
                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nombre de la Salsa",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: const Icon(Icons.local_fire_department),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    if (value.length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Color Picker Section
                Text(
                  'Selecciona un color:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // Main SV (Saturation-Value) Picker Square
                _ColorPickerSquare(
                  hue: _hue,
                  saturation: _saturation,
                  value: _value,
                  onColorChanged: (saturation, value) {
                    setState(() {
                      _saturation = saturation;
                      _value = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Hue Slider Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Matiz',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${_hue.toStringAsFixed(0)}°',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 40,
                        thumbShape: const RoundSliderThumbShape(
                          elevation: 4,
                          enabledThumbRadius: 16,
                        ),
                      ),
                      child: Slider(
                        value: _hue,
                        min: 0,
                        max: 360,
                        onChanged: (value) {
                          setState(() => _hue = value);
                        },
                        divisions: 360,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Color Preview Circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Hex Value
                Text(
                  colorHex,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _buttonUpdate(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final name = _nameController.text.trim();
        final color = _getColorFromHSV();
        final colorHex = _colorToHex(color);

        final updatedSalsa = widget.salsa.copyWith(
          name: name,
          color: colorHex,
        );

        await updateSalsa(updatedSalsa);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Salsa actualizada exitosamente"),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Error: $e")),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

/// Color picker square for selecting Saturation and Value
class _ColorPickerSquare extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final Function(double, double) onColorChanged;

  const _ColorPickerSquare({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final size = MediaQuery.of(context).size.width - 40;
        final x = details.localPosition.dx.clamp(0.0, size);
        final y = details.localPosition.dy.clamp(0.0, size);

        final newSaturation = (x / size) * 100;
        final newValue = 100 - ((y / size) * 100);

        onColorChanged(newSaturation, newValue);
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 2),
          image: DecorationImage(
            image: _ColorPickerImage(hue: hue),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // Saturation-Value gradient
            CustomPaint(
              painter: _SVGradientPainter(hue: hue),
              size: Size.infinite,
            ),
            // Selection crosshair
            Positioned(
              left: (saturation / 100) * (MediaQuery.of(context).size.width - 40) - 8,
              top: ((100 - value) / 100) * (MediaQuery.of(context).size.width - 40) - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for SV gradient background
class _SVGradientPainter extends CustomPainter {
  final double hue;

  _SVGradientPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    // White to color (left edge - saturation increases)
    for (double x = 0; x < size.width; x++) {
      final saturation = x / size.width;
      final paint = Paint()
        ..color = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Darken from top to bottom (value decreases)
    for (double y = 0; y < size.height; y++) {
      final value = 1.0 - (y / size.height);
      final paint = Paint()
        ..color = Colors.black.withOpacity(1.0 - value)
        ..blendMode = BlendMode.darken;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SVGradientPainter oldDelegate) {
    return oldDelegate.hue != hue;
  }
}

/// Image provider for color picker
class _ColorPickerImage extends ImageProvider<_ColorPickerImage> {
  final double hue;

  _ColorPickerImage({required this.hue});

  @override
  Future<_ColorPickerImage> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _ColorPickerImage key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      _loadAsync(key),
    );
  }

  Future<ImageInfo> _loadAsync(_ColorPickerImage key) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 300.0;

    final painter = _SVGradientPainter(hue: hue);
    painter.paint(canvas, Size(size, size));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    return ImageInfo(image: image);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ColorPickerImage &&
          runtimeType == other.runtimeType &&
          hue == other.hue;

  @override
  int get hashCode => hue.hashCode;
}
