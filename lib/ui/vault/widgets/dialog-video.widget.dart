import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class DialogVideoWidget extends StatefulWidget {
  const DialogVideoWidget({
    super.key,
    required this.title,
    required this.videoPath,
  });

  final String title;
  final String videoPath;

  @override
  State<DialogVideoWidget> createState() => _DialogVideoWidgetState();
}

class _DialogVideoWidgetState extends State<DialogVideoWidget> {
  // Create a [Player] to control playback.
  late final player = Player(configuration: PlayerConfiguration(muted: true));
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(Media(widget.videoPath));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (4 / 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Expanded(child: Video(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}
