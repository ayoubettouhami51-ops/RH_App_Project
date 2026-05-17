import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _passController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  void _login() {
    if (_passController.text.trim().toUpperCase() == "AYOUB ETTOUHAMI") {
      widget.onLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Code d'accès incorrect."),
          backgroundColor: OcpTheme.accentRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: OcpTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                
                // Pulsing Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(colors: [Color(0x3300D4FF), Color(0x337B61FF)]),
                      border: Border.all(color: const Color(0x4400D4FF), width: 1.5),
                      boxShadow: const [BoxShadow(color: Color(0x2600D4FF), blurRadius: 40)],
                    ),
                    child: const Center(
                      child: Text("📊", style: TextStyle(fontSize: 46)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text("PointageXpert", style: TextStyle(color: OcpTheme.accent, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 8),
                const Text("Analytics RH Professionnel", style: TextStyle(color: OcpTheme.textMuted, fontSize: 13)),
                
                const SizedBox(height: 60),
                
                // Password
                Container(
                  decoration: OcpTheme.cardDecoration(),
                  child: TextField(
                    controller: _passController,
                    obscureText: true,
                    style: const TextStyle(color: OcpTheme.text, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "Code d'accès sécurisé",
                      prefixIcon: const Icon(Icons.lock_outline, color: OcpTheme.accent),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Login Button
                GestureDetector(
                  onTap: _login,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: OcpTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x5900D4FF), blurRadius: 20, offset: Offset(0, 4))],
                    ),
                    child: const Text("Accéder au Portail →",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                
                const SizedBox(height: 100),
                OcpTheme.signature(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
