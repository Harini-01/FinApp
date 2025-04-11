import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Navigate to next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NextScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: Stack(
        children: [
          // Circular arcs positioned to match the image
          Positioned(
            top: -size.width * 0.001,
            right: -size.width * 0.2,
            child: _buildArc(size.width * 0.4),
          ),
          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.3,
            child: _buildArc(size.width * 0.6),
          ),
          Positioned(
            top: size.width * 0.35,
            left: -size.width * 0.2,
            child: _buildArc(size.width * 0.3),
          ),

          // Rotating 3D cubes
          Positioned(
            bottom: size.height * 0.50,
            left: size.width * 0.15,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_controller.value * 2 * pi)
                    ..rotateY(_controller.value * 2 * pi),
                  alignment: Alignment.center,
                  child: Cube(
                      size: size.width * 0.15, color: const Color(0xFF9575CD)),
                );
              },
            ),
          ),
          Positioned(
            bottom: size.height * 0.15,
            right: size.width * 0.10,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_controller.value * 2 * pi * -0.7)
                    ..rotateY(_controller.value * 2 * pi * -0.7),
                  alignment: Alignment.center,
                  child: Cube(
                      size: size.width * 0.25, color: const Color(0xFF9575CD)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArc(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF9575CD), // Light purple
          width: 6,
        ),
      ),
    );
  }
}

class Cube extends StatelessWidget {
  final double size;
  final Color color;

  const Cube({
    Key? key,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Front face
          Transform(
            transform: Matrix4.identity()..translate(0.0, 0.0, size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),

          // Back face
          Transform(
            transform: Matrix4.identity()..translate(0.0, 0.0, -size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),

          // Left face
          Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..rotateY(pi / 2)
              ..translate(-size / 2, 0.0, 0.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.7),
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),

          // Right face
          Transform(
            alignment: Alignment.centerRight,
            transform: Matrix4.identity()
              ..rotateY(-pi / 2)
              ..translate(size / 2, 0.0, 0.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.7),
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),

          // Top face
          Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()
              ..rotateX(-pi / 2)
              ..translate(0.0, -size / 2, 0.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),

          // Bottom face
          Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..rotateX(pi / 2)
              ..translate(0.0, size / 2, 0.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for the next screen
// Placeholder for the next screen with navigation to login and signup
// You can place this in your main.dart file or create a separate next_screen.dart file

class NextScreen extends StatelessWidget {
  const NextScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Finance App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Button to navigate to Login page
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade300,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Button to navigate to Sign Up page
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade300,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
