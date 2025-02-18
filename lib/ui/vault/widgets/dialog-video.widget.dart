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
  late final player = Player(configuration: PlayerConfiguration());
  late final controller = VideoController(player);
  double playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.videoPath));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void increaseSpeed() {
    setState(() {
      playbackSpeed += 0.25;
      player.setRate(playbackSpeed);
    });
  }

  void decreaseSpeed() {
    setState(() {
      playbackSpeed -= 0.25;
      if (playbackSpeed < 0.25) {
        playbackSpeed = 0.25;
      }
      player.setRate(playbackSpeed);
    });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  IconButton(
                    icon: const Icon(Icons.fast_rewind),
                    onPressed: decreaseSpeed,
                    tooltip: 'Diminuir velocidade',
                  ),
                  Text(
                    '${playbackSpeed}x',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fast_forward),
                    onPressed: increaseSpeed,
                    tooltip: 'Aumentar velocidade',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
