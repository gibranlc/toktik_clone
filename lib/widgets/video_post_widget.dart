import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- para detectar Web
import 'package:provider/provider.dart';
import 'package:toktik_clone/providers/user_action_provider.dart';
import 'package:video_player/video_player.dart';

import '../models/video_post.dart';
import '../providers/video_feed_provider.dart';
import '../utils/formatters.dart';
import 'video_controls_overlay.dart';

class VideoPostWidget extends StatefulWidget {
  final VideoPost post;
  final bool isActive;

  const VideoPostWidget({
    super.key,
    required this.post,
    required this.isActive,
  });

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _showHeart = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _createAndInitController();
  }

  Future<void> _createAndInitController() async {
    final path = widget.post.assetPath;
    final controller = VideoPlayerController.asset(path)..setLooping(true);
    _controller = controller;

    try {
      await controller.initialize();

      // Escucha errores del controlador (si ocurren, los mostramos).
      controller.addListener(() {
        final v = controller.value;
        if (v.hasError && mounted) {
          setState(() => _initError = v.errorDescription);
        }
      });

      if (!mounted) return;
      setState(() {
        _initialized = true;
        _initError = null;
      });

      // ====== Autoplay compatible con Web ======
      // En Web: inicia SIEMPRE muteado para permitir autoplay sin interacción.
      final actions = context.read<UserActionsProvider>();
      final startMuted = kIsWeb ? true : actions.isMuted(widget.post.id);
      await controller.setVolume(startMuted ? 0 : 1);

      // Sincronizado el icono/estado del provider en Web
      if (kIsWeb && !actions.isMuted(widget.post.id)) {
        actions.toggleMute(widget.post.id);
      }
      // ====== Fin Web fix ======

      // Autoplay en el siguiente frame para evitar problemas de timing.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _controller != controller) return;
        _syncPlayState(force: true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = e.toString();
        _initialized = false;
      });
    }
  }

  void _syncPlayState({bool force = false}) {
    final c = _controller;
    if (c == null || (!_initialized && !force)) return;
    if (widget.isActive) {
      c.play();
    } else {
      c.pause();
    }
  }

  @override
  void didUpdateWidget(covariant VideoPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cambió si la página está activa → play/pause
    if (oldWidget.isActive != widget.isActive) {
      _syncPlayState();
    }

    if (oldWidget.post.assetPath != widget.post.assetPath) {
      _disposeController();
      _initialized = false;
      _initError = null;
      _createAndInitController();
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _onDoubleTapLike() {
    context.read<VideoFeedProvider>().incrementLike(widget.post.id);
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final actions = context.watch<UserActionsProvider>();
    final isFav = actions.isFavorite(widget.post.id);
    final isMuted = actions.isMuted(widget.post.id);

    final controller = _controller;

    // Sincroniza volumen por cambios del provider.
    if (_initialized && controller != null) {
      controller.setVolume(isMuted ? 0 : 1);
    }

    return GestureDetector(
      onTap: () async {
        if (!_initialized || controller == null) return;

        // En Web: si está muteado (autoplay permitido), primer tap puede activar sonido.
        if (kIsWeb) {
          if (isMuted) {
            actions.toggleMute(widget.post.id);
            await controller.setVolume(1); // activa sonido
            if (!controller.value.isPlaying) {
              await controller.play();
            }
            return;
          }
        }

        // Comportamiento normal (nativo / web ya desmuteado)
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      onDoubleTap: _onDoubleTapLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // --- VIDEO ---
          if (_initError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error al cargar el video:\n$_initError\nRuta: ${widget.post.assetPath}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (!_initialized || controller == null)
            const Center(child: CircularProgressIndicator())
          else
            Center(
              child: AspectRatio(
                aspectRatio:
                    controller.value.isInitialized &&
                        controller.value.aspectRatio.isFinite
                    ? controller.value.aspectRatio
                    : (9 / 16),
                child: VideoPlayer(controller),
              ),
            ),
          const _BottomGradient(),

          // --- Texto (usuario, caption, fecha) ---
          Positioned(
            left: 16,
            bottom: 24,
            right: 96,
            child: FadeInUp(
              from: 40,
              duration: const Duration(milliseconds: 400),
              child: _CaptionArea(
                userName: widget.post.userName,
                caption: widget.post.caption,
                date: formatDateShort(widget.post.createdAt),
              ),
            ),
          ),

          // --- Controles laterales ---
          Positioned(
            right: 12,
            bottom: 24,
            child: VideoControlsOverlay(
              isFavorite: isFav,
              likesText: formatLikes(widget.post.likes),
              onToggleFavorite: () => actions.toggleFavorite(widget.post.id),
              onToggleMute: () => actions.toggleMute(widget.post.id),
              onShare: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Compartir')));
              },
              isMuted: isMuted,
            ),
          ),

          // --- Overlay guía (solo Web)
          if (kIsWeb && isMuted && _initialized)
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_off, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Pulsa para activar sonido',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // --- Corazón animado al dar doble tap ---
          if (_showHeart)
            Center(
              child: ZoomIn(
                duration: const Duration(milliseconds: 350),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 120,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CaptionArea extends StatelessWidget {
  final String userName;
  final String caption;
  final String date;
  const _CaptionArea({
    required this.userName,
    required this.caption,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(caption, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          const Text(''),
        ],
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, .6),
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54, Colors.black87],
          ),
        ),
      ),
    );
  }
}
