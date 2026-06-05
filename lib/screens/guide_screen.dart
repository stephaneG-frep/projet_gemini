import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const routeName = '/guide';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Mode d'emploi")),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Comment jouer avec FocusBuddy',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Le principe est simple : chaque session de concentration devient une petite quete RPG.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              const _GuideStep(
                number: '1',
                icon: Icons.play_arrow_rounded,
                title: 'Lance une quete',
                body: 'Depuis l accueil, appuie sur Commencer une session. En mode normal, la quete dure 25 minutes.',
              ),
              const _GuideStep(
                number: '2',
                icon: Icons.self_improvement,
                title: 'Reste concentre',
                body: 'Tu peux mettre en pause ou reprendre. Si tu quittes l app pendant une session active, ton heros perd 10 PV.',
              ),
              const _GuideStep(
                number: '3',
                icon: Icons.emoji_events_rounded,
                title: 'Recolte tes recompenses',
                body: 'Une session terminee donne +25 XP et +10 pieces. Toutes les 4 sessions reussies ajoutent un bonus de 50 pieces.',
              ),
              const _GuideStep(
                number: '4',
                icon: Icons.favorite_rounded,
                title: 'Protege tes PV',
                body: 'Si les PV tombent a zero, la serie repart a zero et ton heros recupere 50% de ses PV max.',
              ),
              const _GuideStep(
                number: '5',
                icon: Icons.storefront_rounded,
                title: 'Achete et equipe',
                body: 'La boutique contient des cosmetiques. Achete un objet, puis equipe-le pour le voir sur ton personnage.',
              ),
              const _GuideStep(
                number: '6',
                icon: Icons.speed_rounded,
                title: 'Teste avec le mode dev',
                body: 'Active le mode dev sur l accueil pour raccourcir le timer entre 5 et 60 secondes et tester les recompenses rapidement.',
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Conseil : commence par une seule session. La serie et les niveaux sont la pour encourager la regularite, pas pour te mettre la pression.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String number;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
