import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: MatrixRainBackground(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// สร้าง Widget ที่สามารถใช้เป็น background
class MatrixRainBackground extends StatelessWidget {
  final Widget child;

  const MatrixRainBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MultilingualMatrixRain(),
        child,
      ],
    );
  }
}

class MultilingualMatrixRain extends StatefulWidget {
  const MultilingualMatrixRain({Key? key}) : super(key: key);

  @override
  _MultilingualMatrixRainState createState() => _MultilingualMatrixRainState();
}

class _MultilingualMatrixRainState extends State<MultilingualMatrixRain> {
  final List<MatrixColumn> columns = [];
  Size? screenSize;
  Timer? animationTimer;
  final random = Random();

  static const Map<String, String> charSets = {
    'japanese':
        '゠ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロワヲンヴヵヶヷヸヹヺ',
    'korean': 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ',
    'english': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&*',
    'thai': 'กขฃคฅฆงจฉชซฌญฎฏฐฑฒณดตถทธนบปผฝพฟภมยรลวศษสหฬอฮ๐๑๒๓๔๕๖๗๘๙'
  };

  static const Map<String, Color> baseColors = {
    'japanese': Colors.green,
    'korean': Colors.cyan,
    'english': Colors.yellow,
    'thai': Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeColumns();
      startAnimation();
    });
  }

  void initializeColumns() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    screenSize = size;

    final columnWidth = 15.0;
    final numColumns = (size.width / columnWidth).floor();

    columns.clear();
    for (var i = 0; i < numColumns; i++) {
      columns.add(createNewColumn());
    }
  }

  MatrixColumn createNewColumn() {
    final language = charSets.keys.elementAt(random.nextInt(charSets.length));
    return MatrixColumn(
      y: -random.nextDouble() * (screenSize?.height ?? 600) * 2,
      speed: 2 + random.nextDouble() * 3,
      language: language,
      chars: List.generate(40, (_) => createRandomChar(language)),
      brightness: List.generate(40, (_) => random.nextDouble()),
    );
  }

  String createRandomChar(String language) {
    final chars = charSets[language]!;
    return chars[random.nextInt(chars.length)];
  }

  void startAnimation() {
    animationTimer?.cancel();
    animationTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;

      setState(() {
        for (var i = 0; i < columns.length; i++) {
          var column = columns[i];
          column.y += column.speed;

          if (column.y > (screenSize?.height ?? 600)) {
            columns[i] = createNewColumn();
          }

          // Randomly update some characters
          for (var j = 0; j < column.chars.length; j++) {
            if (random.nextDouble() < 0.2) {
              column.chars[j] = createRandomChar(column.language);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: MatrixRainPainter(columns: columns),
        size: Size.infinite,
      ),
    );
  }
}

class MatrixColumn {
  double y;
  final double speed;
  final String language;
  final List<String> chars;
  final List<double> brightness;

  MatrixColumn({
    required this.y,
    required this.speed,
    required this.language,
    required this.chars,
    required this.brightness,
  });
}

class MatrixRainPainter extends CustomPainter {
  final List<MatrixColumn> columns;
  static const double charSize = 20;

  MatrixRainPainter({required this.columns});

  @override
  void paint(Canvas canvas, Size size) {
    final columnWidth = size.width / columns.length;

    for (var i = 0; i < columns.length; i++) {
      final column = columns[i];
      final x = i * columnWidth;

      for (var j = 0; j < column.chars.length; j++) {
        final y = column.y + (j * charSize);
        if (y < 0 || y > size.height) continue;

        final char = column.chars[j];
        final brightness = column.brightness[j];
        final baseColor =
            _MultilingualMatrixRainState.baseColors[column.language]!;

        // Calculate fade effect
        final fade = max(0.0, min(1.0, 1.0 - (y - size.height / 2) * 0.002));
        final color = baseColor.withOpacity(fade * brightness);

        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: TextStyle(
              color: color,
              fontSize: charSize,
              fontFamily: 'monospace',
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
