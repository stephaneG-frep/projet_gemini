import 'package:flutter/material.dart';

import 'home_screen.dart';

class StartupIntroScreen extends StatefulWidget {
  const StartupIntroScreen({super.key});

  static const routeName = '/startup';

  @override
  State<StartupIntroScreen> createState() => _StartupIntroScreenState();
}

class _StartupIntroScreenState extends State<StartupIntroScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = [
      const _IntroPage(
        icon: Icons.psychology_alt_rounded,
        title: 'Une app pour retrouver l elan',
        body:
            'FocusBuddy est un jeu de motivation pour les moments ou les devoirs, le sport, les projets ou les habitudes semblent trop lourds. L objectif n est pas d etre parfait : c est de commencer, tenir une petite session, puis recommencer.',
      ),
      const _IntroPage(
        icon: Icons.verified_user_rounded,
        title: 'Joue honnetement',
        body:
            'Ne triche pas avec le timer, les recompenses ou les objectifs. Le royaume n a de valeur que s il represente tes vrais efforts. Si une session est difficile, ce n est pas grave : reviens, respire, et relance une quete.',
      ),
      const _IntroPage(
        icon: Icons.menu_book_rounded,
        title: "Mode d'emploi rapide",
        body:
            'Lance une session de concentration, reste dans l app, gagne de l XP et des pieces, puis construis ton royaume. Les quetes du jour et les objectifs donnent une direction. La boutique sert a personnaliser ton heros.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF101A2B), Color(0xFF16253C), Color(0xFF0F1624)]
                  : const [Color(0xFFF4F8FF), Color(0xFFFFF7EA), Color(0xFFF8F2E8)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.self_improvement_rounded),
                    const SizedBox(width: 8),
                    Text('FocusBuddy', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Passer'),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _page = value),
                    children: pages,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < pages.length; index++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: _page == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _page == index ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _page == pages.length - 1 ? _finish : _next,
                    icon: Icon(_page == pages.length - 1 ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded),
                    label: Text(_page == pages.length - 1 ? 'Commencer' : 'Suivant'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: isDark ? const Color(0xFF243552) : const Color(0xFFFFE8B8),
                child: Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
