import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(FortuneWheelApp());

class FortuneWheelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FortuneWheelScreen(),
    );
  }
}

class FortuneWheelScreen extends StatefulWidget {
  @override
  _FortuneWheelScreenState createState() => _FortuneWheelScreenState();
}

class _FortuneWheelScreenState extends State<FortuneWheelScreen>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  bool _isSpinning = false;
  bool _canSpin = true;
  DateTime? _nextSpinTime;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> _sections = [
    "Better Luck Next Time",
    "iphone 16",
    "Washing Machine",
    "TV",
    "Bike",
  ];

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ))..addListener(() {
        setState(() {
          _angle = _animation.value;
        });
      });
  }

  void _startSpin() {
    if (!_canSpin) return;

    setState(() {
      _isSpinning = true;
      _canSpin = false;
      _nextSpinTime = DateTime.now().add(Duration(hours: 1));
      _startTimer();
    });

    // Calculate the angle for "Better Luck Next Time" (red section)
    int selectedIndex = 0; // Index of "Better Luck Next Time"
    double sectionAngle = 2 * pi / _sections.length;
    double targetAngle = 2 * pi * 5 + (sectionAngle * selectedIndex) +
        sectionAngle / 2; // Offset to align with the pointer

    // Animate the wheel to the target angle
    _animation = Tween<double>(begin: _angle, end: targetAngle).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward(from: 0).then((_) {
      setState(() {
        _isSpinning = false;
      });

      Future.delayed(Duration(milliseconds: 500), () {
        _showMessage();
      });
    });
  }

  void _showMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Better Luck Next Time",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "😔",
              style: TextStyle(fontSize: 48),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _nextSpinTime!.difference(DateTime.now());
        if (_remainingTime.isNegative) {
          _timer?.cancel();
          _remainingTime = Duration.zero;
          _canSpin = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fortune Wheel"),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _angle,
                    child: Container(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: WheelPainter(
                          _sections,
                          _colors,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/pointer.png",
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
              SizedBox(height: 50),
              _isSpinning
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _canSpin ? _startSpin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Spin the Wheel",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              if (!_canSpin)
                Text(
                  "Next spin available in: ${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> sections;
  final List<Color> colors;

  WheelPainter(this.sections, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final radius = size.width / 2;
    final angle = 2 * pi / sections.length;

    for (int i = 0; i < sections.length; i++) {
      paint.color = colors[i % colors.length];
      final startAngle = i * angle;

      // Draw the background color for the section
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        angle,
        true,
        paint,
      );

      // Draw the text
      final textPainter = TextPainter(
        text: TextSpan(
          text: sections[i],
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: radius,
      );

      final offset = Offset(
        radius +
            cos(startAngle + angle / 2) * radius * 0.6 -
            textPainter.width / 2,
        radius +
            sin(startAngle + angle / 2) * radius * 0.6 -
            textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
