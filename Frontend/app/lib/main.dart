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
      title: 'Finora',
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
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0E0B2E), // Deep navy blue at top
              const Color(0xFF1A103C), // Dark purple in middle
              const Color(0xFF150C34), // Darkest purple at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative elements like those in the image
            // Glow effects
            Positioned(
              top: size.height * 0.1,
              right: size.width * 0.1,
              child: _buildGlowCircle(30, Colors.purple.shade300),
            ),
            Positioned(
              bottom: size.height * 0.2,
              left: size.width * 0.15,
              child: _buildGlowCircle(40, Colors.purple.shade200),
            ),
            
            // Small stars
            ..._buildStars(size, 20),
            
            // Rotating 3D cubes
            Positioned(
              bottom: size.height * 0.70,
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
                      size: size.width * 0.15, 
                      color: const Color(0xFF9575CD),
                    ),
                  );
                },
              ),
            ),

            Positioned(
            bottom: size.height * 0.15,
            right: size.width * 0.15,
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
                      size: size.width * 0.15, color: const Color(0xFF9575CD)),
                );
              },
           ),
),
            // Centered Logo
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStars(Size size, int count) {
    final random = Random();
    final stars = <Widget>[];
    
    for (var i = 0; i < count; i++) {
      stars.add(
        Positioned(
          left: random.nextDouble() * size.width,
          top: random.nextDouble() * size.height,
          child: _buildStar(random.nextInt(4) + 2),
        ),
      );
    }
    
    return stars;
  }

  Widget _buildStar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200.withOpacity(0.8),
            blurRadius: size * 2,
            spreadRadius: size / 2,
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: size,
            spreadRadius: size / 2,
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


// New Welcome Screen similar to the image you shared
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0E0B2E), // Deep navy blue at top
              const Color(0xFF1A103C), // Dark purple in middle
              const Color(0xFF150C34), // Darkest purple at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Title text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Start your journey to smarter spending',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Center phone image with financial elements
              SizedBox(
                height: size.height * 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // You'll need to create this image or use placeholder
                    Image.asset(
                      'assets/images/phone_screen.png',
                      width: size.width * 1.0,
                    height: size.width * 1.0,
                    ),
                    
                    // Decorative elements
                    /*
                    Positioned(
                      left: size.width * 0.1,
                      top: size.height * 0.05,
                      child: _buildDecorationItem('assets/images/piggy_bank.png', size.width * 0.15),
                    ),
                    Positioned(
                      right: size.width * 0.1,
                      top: size.height * 0.3,
                      child: _buildDecorationItem('assets/images/chart.png', size.width * 0.15),
                    ),
                    Positioned(
                      left: size.width * 0.15,
                      bottom: size.height * 0.05,
                      child: _buildCoinStack(size.width * 0.15),
                    ),
                    Positioned(
                      right: size.width * 0.15,
                      bottom: size.height * 0.05,
                      child: _buildCoinStack(size.width * 0.15),
                    ),*/
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Tagline
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Finora helps you track, save, and grow — effortlessly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBC4FF), // Light purple
                    foregroundColor: const Color(0xFF1A103C), // Dark purple
                    minimumSize: Size(size.width, 56),
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
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sign Up Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBC4FF), // Light purple
                    foregroundColor: const Color(0xFF1A103C), // Dark purple
                    minimumSize: Size(size.width, 56),
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
                    'Sign up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDecorationItem(String assetPath, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.purple.shade100.withOpacity(0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: size * 0.6,
          height: size * 0.6,
        ),
      ),
    );
  }
  
  Widget _buildCoinStack(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: List.generate(
          3,
          (index) => Positioned(
            bottom: index * 5.0,
            child: Container(
              width: size - (index * 5),
              height: 10,
              decoration: BoxDecoration(
                color: Colors.amber.shade300,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.shade100.withOpacity(0.8),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

