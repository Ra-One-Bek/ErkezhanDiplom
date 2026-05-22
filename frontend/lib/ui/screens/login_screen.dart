import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _leafAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _leafAnimation = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final authVM = context.read<AuthViewModel>();

    final success = await authVM.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkGreen,
      body: SafeArea(
        child: Stack(
          children: [
            const _LeafPatternBackground(),

            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  AnimatedBuilder(
                    animation: _leafAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _leafAnimation.value),
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.eco,
                      size: 82,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "PlantCare AI",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Распознавание растений и болезней\nс помощью нейронной сети",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),

                  const SizedBox(height: 36),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Вход в аккаунт",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Введите email и пароль для продолжения",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Пароль",
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),

                        if (authVM.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            authVM.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: authVM.isLoading ? null : _login,
                          child: authVM.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Войти"),
                        ),

                        const SizedBox(height: 14),

                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text(
                            "Создать аккаунт",
                            style: TextStyle(
                              color: AppTheme.darkGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
}

class _LeafPatternBackground extends StatelessWidget {
  const _LeafPatternBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 36,
          left: 24,
          child: Icon(
            Icons.spa,
            size: 42,
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        Positioned(
          top: 120,
          right: 34,
          child: Icon(
            Icons.local_florist,
            size: 46,
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 32,
          child: Icon(
            Icons.eco,
            size: 54,
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        Positioned(
          bottom: 38,
          right: 26,
          child: Icon(
            Icons.grass,
            size: 58,
            color: Colors.white.withOpacity(0.12),
          ),
        ),
      ],
    );
  }
}