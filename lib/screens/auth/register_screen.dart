import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _usernameController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    final error = await context.read<AuthProvider>().register(
      _usernameController.text.trim(),
      _fullnameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    if (mounted) {
      if (error == null) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF000000), Color(0xFF1A1A1A), Color(0xFF003333)],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "Join\nQicTok.",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.1, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Create an account to start sharing your talent.",
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 40),

                  _buildGlassInput(controller: _usernameController, hint: "Username", icon: Icons.person_outline),
                  const SizedBox(height: 15),
                  _buildGlassInput(controller: _fullnameController, hint: "Full Name", icon: Icons.badge_outlined),
                  const SizedBox(height: 15),
                  _buildGlassInput(controller: _emailController, hint: "Email address", icon: Icons.alternate_email),
                  const SizedBox(height: 15),
                  _buildGlassInput(controller: _passwordController, hint: "Password", icon: Icons.lock_outline, isPassword: true),
                  
                  const SizedBox(height: 35),

                  _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                    : GestureDetector(
                        onTap: _handleRegister,
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF00F2EA), Color(0xFFFF0050)]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              "CREATE ACCOUNT",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                            ),
                          ),
                        ),
                      ),
                  
                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.white.withOpacity(0.6)),
                          children: const [
                            TextSpan(text: "Log In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 55,
      borderRadius: 15,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.05)],
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }
}
