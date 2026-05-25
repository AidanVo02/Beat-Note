import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.hasQuery, required this.onCreatePressed});

  final bool hasQuery;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off_rounded : Icons.library_music_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              hasQuery ? 'No results' : 'No ideas yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try different keywords.'
                  : 'Capture your next hook, chord, or lyric in seconds.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New idea'),
            ),
          ],
        ),
      ),
    );
  }
}

