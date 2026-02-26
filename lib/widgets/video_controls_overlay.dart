import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class VideoControlsOverlay extends StatelessWidget {
  final bool isFavorite;
  final bool isMuted;
  final String likesText;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleMute;
  final VoidCallback onShare;

  const VideoControlsOverlay({
    super.key,
    required this.isFavorite,
    required this.isMuted,
    required this.likesText,
    required this.onToggleFavorite,
    required this.onToggleMute,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar de ejemplo
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(height: 16),

        // Like / favorito
        BounceIn(
          child: IconButton(
            iconSize: 34,
            color: isFavorite ? Colors.pinkAccent : color,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: onToggleFavorite,
          ),
        ),
        Text(likesText, style: TextStyle(color: color)),

        const SizedBox(height: 12),

        // Comentarios
        IconButton(
          iconSize: 32,
          color: color,
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Comentarios')));
          },
        ),
        const SizedBox(height: 12),

        // Compartir
        IconButton(
          iconSize: 30,
          color: color,
          icon: const Icon(Icons.share),
          onPressed: onShare,
        ),
        const SizedBox(height: 12),

        // Mute
        IconButton(
          iconSize: 28,
          color: color,
          icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
          onPressed: onToggleMute,
        ),
      ],
    );
  }
}
