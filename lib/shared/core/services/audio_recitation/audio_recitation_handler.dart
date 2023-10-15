import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecitationHandler extends BaseAudioHandler {
  AudioRecitationHandler() {
    _initHandler();
  }

  final AudioPlayer _player = AudioPlayer();
  VoidCallback? onSkipNext;
  VoidCallback? onSkipPrevious;
  VoidCallback? onPlaybackError;
  Uri? icon;

  void setOnSkipNext(VoidCallback callback) {
    onSkipNext = callback;
  }

  void setOnPlaybackError(VoidCallback callback) {
    onPlaybackError = callback;
  }

  void setOnSkipPrevious(VoidCallback callback) {
    onSkipPrevious = callback;
  }

  Future<Uri> _getIcon() async {
    final ByteData byteData = await rootBundle.load('images/logogram.png');
    final ByteBuffer buffer = byteData.buffer;
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    String filePath = '$tempPath/logo.png';

    return (await File(filePath).writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    ))
        .uri;
  }

  void _initHandler() {
    _player.playbackEventStream.listen(
      (PlaybackEvent event) {
        final bool isPlaying = _player.playing;
        playbackState.add(
          playbackState.value.copyWith(
            controls: [
              MediaControl.skipToPrevious,
              if (isPlaying) MediaControl.pause,
              if (!isPlaying) MediaControl.play,
              MediaControl.skipToNext,
            ],
            systemActions: {},
            processingState: {
              ProcessingState.idle: Platform.isIOS
                  ? AudioProcessingState.ready
                  : AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_player.processingState]!,
            playing: isPlaying,
            updatePosition: _player.position,
            bufferedPosition: _player.bufferedPosition,
            speed: _player.speed,
          ),
        );
      },
      onError: (_) {
        if (onPlaybackError != null) onPlaybackError!();
      },
    );
  }

  StreamSubscription<PlayerState> getStreamOnFinishedEvent(
    VoidCallback onFinished,
  ) {
    final StreamSubscription<PlayerState> res =
        _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        onFinished();
      }
    });

    return res;
  }

  Future<void> setUrl(String url) async {
    await _player.setUrl(url);
  }

  Future<void> setMediaItem(MediaItem item) async {
    icon ??= await _getIcon();

    final Duration duration =
        await _player.setUrl(item.extras?['url']) ?? const Duration();

    mediaItem.add(
      item.copyWith(
        duration: duration,
        artUri: icon,
      ),
    );
  }

  Stream<Duration> getPositionStream() {
    return _player.positionStream;
  }

  Stream<PlayerState> getPlayerStateStream() {
    return _player.playerStateStream;
  }

  Stream<Duration?> getDurationStream() {
    return _player.durationStream;
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  bool isPlaying() {
    return _player.playing;
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();

    return super.stop();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();

    return super.onNotificationDeleted();
  }

  @override
  Future<void> skipToNext() {
    if (onSkipNext != null) {
      onSkipNext!();
    }

    return super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() {
    if (onSkipPrevious != null) {
      onSkipPrevious!();
    }

    return super.skipToPrevious();
  }
}
