import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _calculateLevel(int count) {
    if (count >= 50) return 5;
    if (count >= 30) return 4;
    if (count >= 15) return 3;
    if (count >= 5) return 2;
    return 1;
  }

  double _calculateProgress(int count) {
    if (count >= 50) return 1.0;
    if (count >= 30) return count / 50;
    if (count >= 15) return count / 30;
    if (count >= 5) return count / 15;
    return count / 5;
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final historyVM = context.watch<HistoryViewModel>();

    final email = authVM.userEmail;
    final recognitionCount = historyVM.items.length;

    final level = _calculateLevel(recognitionCount);
    final progress = _calculateProgress(recognitionCount);

    return Scaffold(
      backgroundColor: AppTheme.darkGreen,

      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 2,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            const _ProfileBackground(),

            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      "Профиль",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  AnimatedBuilder(
                    animation: _leafAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _leafAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "PlantCare User",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Достижение",
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Уровень $level · $recognitionCount распознаваний",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 18),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 14,
                            backgroundColor: AppTheme.softGreen,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryGreen,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: const [
                            _AchievementStep(
                              label: "5",
                              icon: Icons.local_florist,
                            ),
                            _AchievementStep(
                              label: "15",
                              icon: Icons.eco,
                            ),
                            _AchievementStep(
                              label: "30",
                              icon: Icons.spa,
                            ),
                            _AchievementStep(
                              label: "50",
                              icon: Icons.emoji_events,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _ProfileActionCard(
                    icon: Icons.history,
                    title: "История распознаваний",
                    subtitle: "Просмотреть сохранённые результаты",
                    onTap: () => context.push('/history'),
                  ),

                  const SizedBox(height: 14),

                  _ProfileActionCard(
                    icon: Icons.logout,
                    title: "Выйти из аккаунта",
                    subtitle: "Вернуться на экран входа",
                    onTap: () => _logout(context),
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

class _AchievementStep extends StatelessWidget {
  final String label;
  final IconData icon;

  const _AchievementStep({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cream,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.softGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: AppTheme.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 42,
          left: 26,
          child: Icon(
            Icons.eco,
            size: 44,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          top: 118,
          right: 30,
          child: Icon(
            Icons.spa,
            size: 54,
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 28,
          child: Icon(
            Icons.grass,
            size: 58,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}