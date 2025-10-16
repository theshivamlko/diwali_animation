import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy Diwali Neon',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const DiwaliNeonScreen(),
    );
  }
}

class DiwaliNeonScreen extends StatefulWidget {
  const DiwaliNeonScreen({Key? key}) : super(key: key);

  @override
  State<DiwaliNeonScreen> createState() => _DiwaliNeonScreenState();
}

class _DiwaliNeonScreenState extends State<DiwaliNeonScreen>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _flickerController;
  late List<Sparkle> _sparkles;
  late List<Sparkle> _sparkles2;

  final List<Color> _neonColors = [
    const Color(0xFFFF6B35), // Orange
    const Color(0xFFF7931E), // Light Orange
    const Color(0xFFFFD700), // Gold
    const Color(0xFF39FF14), // Green
    const Color(0xFF00D4FF), // Cyan
    const Color(0xFFBC13FE), // Purple
    const Color(0xFFFF1493), // Pink
  ];

  @override
  void initState() {
    super.initState();

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _sparkles = List.generate(50, (index) => Sparkle());
    _sparkles2 = List.generate(50, (index) => Sparkle());
  }

  @override
  void dispose() {
    _colorController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_colorController, _flickerController]),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Sparkles
                Transform.rotate(
                  angle: _colorController.value  * pi * 0.05,
                  child: CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: SparklesPainter(_sparkles, _colorController.value),
                  ),
                ),
                Transform.rotate(
                  angle: -_colorController.value * pi * 0.2,
                  child: CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: SparklesPainter(_sparkles2, _colorController.value),
                  ),
                ),

                // Neon Text
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 200),
                  painter: NeonTextPainter(
                    text: 'Happy Diwali',
                    colors: _neonColors,
                    animationValue: _colorController.value,
                    flickerValue: _flickerController.value,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NeonTextPainter extends CustomPainter {
  final String text;
  final List<Color> colors;
  final double animationValue;
  final double flickerValue;

  NeonTextPainter({
    required this.text,
    required this.colors,
    required this.animationValue,
    required this.flickerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Split text into two lines
    final line1 = 'Happy';
    final line2 = 'Diwali';

    // Calculate appropriate font size based on screen width
    double fontSize = 120;
    late TextPainter line1Painter;
    late TextPainter line2Painter;

    // Measure and adjust font size to fit screen
    do {
      line1Painter = TextPainter(
        text: TextSpan(
          text: line1,
          style: TextStyle(
            fontFamily: 'GreatVibes',
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
            letterSpacing: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      line2Painter = TextPainter(
        text: TextSpan(
          text: line2,
          style: TextStyle(
            fontFamily: 'GreatVibes',
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
            letterSpacing: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final maxWidth = line1Painter.width > line2Painter.width
          ? line1Painter.width
          : line2Painter.width;

      if (maxWidth > size.width * 0.9) {
        fontSize -= 5;
      } else {
        break;
      }
    } while (fontSize > 40);

    final totalHeight =
        line1Painter.height +
        line2Painter.height +
        20; // 20px gap between lines
    final startY = (size.height - totalHeight) / 2;

    // Draw first line "Happy"
    _drawLine(canvas, line1, size, startY, fontSize, 0);

    // Draw second line "Diwali"
    _drawLine(
      canvas,
      line2,
      size,
      startY + line1Painter.height + 20,
      fontSize,
      line1.length,
    );
  }

  void _drawLine(
    Canvas canvas,
    String line,
    Size size,
    double yPosition,
    double fontSize,
    int startCharIndex,
  ) {
    final linePainter = TextPainter(
      text: TextSpan(
        text: line,
        style: TextStyle(
          fontFamily: 'GreatVibes',
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double currentX = (size.width - linePainter.width) / 2;

    // Draw each character individually with color animation
    for (int i = 0; i < line.length; i++) {
      int charIndex = startCharIndex + i;

      // Calculate color for each character with staggered offset
      final charAnimValue = (animationValue + (charIndex * 0.15)) % 1.0;
      final color = _getColorAtValue(charAnimValue);

      // Calculate opacity with flicker effect
      double opacity = 0.8 + (flickerValue * 0.2);
      if (animationValue > 0.18 && animationValue < 0.22) opacity *= 0.8;
      if (animationValue > 0.24 && animationValue < 0.26) opacity *= 0.8;
      if (animationValue > 0.53 && animationValue < 0.57) opacity *= 0.8;

      // Draw the character with glow effect
      _drawGlowingChar(
        canvas,
        line[i],
        Offset(currentX, yPosition),
        color.withOpacity(opacity),
        fontSize,
      );

      // Measure character width for next position
      final charPainter = TextPainter(
        text: TextSpan(
          text: line[i],
          style: TextStyle(
            fontFamily: 'GreatVibes',
            fontSize: fontSize,
            letterSpacing: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      currentX += charPainter.width;
    }
  }

  void _drawGlowingChar(
    Canvas canvas,
    String char,
    Offset position,
    Color color,
    double fontSize,
  ) {
    final textStyle = TextStyle(
      fontFamily: 'GreatVibes',
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      letterSpacing: 8,
      foreground: Paint()
        ..style = PaintingStyle.fill
        ..color = color,
      shadows: [
        Shadow(blurRadius: 3, color: color),
        Shadow(blurRadius: 8, color: color.withOpacity(0.8)),
        Shadow(blurRadius: 15, color: color.withOpacity(0.6)),
      ],
    );

    final textPainter = TextPainter(
      text: TextSpan(text: char, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, position);
  }

  Color _getColorAtValue(double value) {
    final colorIndex = (value * colors.length).floor() % colors.length;
    final nextColorIndex = (colorIndex + 1) % colors.length;
    final t = (value * colors.length) - colorIndex;

    return Color.lerp(colors[colorIndex], colors[nextColorIndex], t)!;
  }

  @override
  bool shouldRepaint(NeonTextPainter oldDelegate) => true;
}

class Sparkle {
  late double x;
  late double y;
  late double size;
  late double animationOffset;
  final Random _random = Random();

  Sparkle() {
    reset();
  }

  void reset() {
    x = _random.nextDouble();
    y = _random.nextDouble();
    size = (_random.nextInt(8)).toDouble(); // Random size between 3-10
    animationOffset = _random.nextDouble();
  }
}

class SparklesPainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final double animationValue;

  SparklesPainter(this.sparkles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var sparkle in sparkles) {
      final sparkleAnim = (animationValue + sparkle.animationOffset) % 1.0;
      double opacity;

      if (sparkleAnim < 0.5) {
        opacity = sparkleAnim * 2; // Fade in
      } else {
        opacity = (1.0 - sparkleAnim) * 2; // Fade out
      }

      final scale = sin(sparkleAnim * pi);

      final paint = Paint()..color = Colors.white.withOpacity(opacity);

      final position = Offset(sparkle.x * size.width, sparkle.y * size.height);

      canvas.drawCircle(position, sparkle.size * scale, paint);
    }
  }

  @override
  bool shouldRepaint(SparklesPainter oldDelegate) => true;
}
