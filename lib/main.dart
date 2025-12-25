import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CosmicGarden(),
  ));
}

class CosmicGarden extends StatefulWidget {
  const CosmicGarden({super.key});

  @override
  State<CosmicGarden> createState() => _CosmicGardenState();
}

class _CosmicGardenState extends State<CosmicGarden>
    with SingleTickerProviderStateMixin {
  final List<Flower> flowers = [];
  final Random random = Random();
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addFlower(Offset pos) {
    setState(() {
      flowers.add(
        Flower(
          position: pos,
          size: random.nextDouble() * 18 + 18,
          rotation: random.nextDouble() * pi,
          swaySpeed: random.nextDouble() * 1.5 + 0.5,
          colors: palettes[random.nextInt(palettes.length)],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 10, 33),
      body: GestureDetector(
        onTapDown: (d) => addFlower(d.localPosition),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return CustomPaint(
              painter: GardenPainter(flowers, controller.value),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/* ---------------- DATA MODEL ---------------- */

class Flower {
  final Offset position;
  final double size;
  final double rotation;
  final double swaySpeed;
  final List<Color> colors;

  Flower({
    required this.position,
    required this.size,
    required this.rotation,
    required this.swaySpeed,
    required this.colors,
  });
}

/* ---------------- COLOR PALETTES ---------------- */

final List<List<Color>> palettes = [
  [Colors.pinkAccent, Colors.deepPurpleAccent],
  [Colors.orangeAccent, Colors.redAccent],
  [Colors.lightBlueAccent, const Color.fromARGB(255, 86, 72, 11)],
  [Colors.yellowAccent, Colors.orange],
  [Colors.greenAccent, const Color.fromARGB(255, 43, 85, 24)],
];

/* ---------------- PAINTER ---------------- */

class GardenPainter extends CustomPainter {
  final List<Flower> flowers;
  final double t;

  GardenPainter(this.flowers, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas, size);

    for (final flower in flowers) {
      final sway = sin(t * pi * 2 * flower.swaySpeed) * 14;
      final top = Offset(
        flower.position.dx + sway,
        flower.position.dy,
      );

      _drawStem(canvas, size, flower.position, top, sway);
      _drawPetals(canvas, top, flower);
      _drawCenter(canvas, top);
    }
  }

  void _drawStem(Canvas c, Size s, Offset base, Offset top, double sway) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..moveTo(base.dx, s.height)
      ..quadraticBezierTo(
        base.dx - sway,
        s.height - (s.height - top.dy) * 0.5,
        top.dx,
        top.dy,
      );

    c.drawPath(path, paint);
  }

  void _drawPetals(Canvas c, Offset center, Flower flower) {
    for (int i = 0; i < 6; i++) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: flower.colors,
        ).createShader(
          Rect.fromCircle(center: Offset.zero, radius: flower.size),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(flower.rotation + i * pi / 3 + t * 0.5);
      c.drawOval(
        Rect.fromCenter(
          center: Offset(flower.size * 0.6, 0),
          width: flower.size,
          height: flower.size * 0.6,
        ),
        paint,
      );
      c.restore();
    }
  }

  void _drawCenter(Canvas c, Offset center) {
    final glow = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    c.drawCircle(center, 4, glow);
    c.drawCircle(center, 2.5, Paint()..color = Colors.orange);
  }

  void _drawStars(Canvas c, Size s) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15);
    for (int i = 0; i < 40; i++) {
      c.drawCircle(
        Offset((i * 97) % s.width, (i * 53) % s.height),
        1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
