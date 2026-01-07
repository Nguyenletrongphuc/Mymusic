import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? currentTitle;
  String? currentPath;
  bool isPlaying = false;

  MusicPlayerProvider() {
    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing &&
          state.processingState != ProcessingState.completed;

      if (isPlaying != playing) {
        isPlaying = playing;
        notifyListeners();
      }
    });
  }

  Future<void> play(String path, String title) async {
    if (currentPath != path) {
      // Support both http(s) streams and local file paths
      final uri = path.startsWith('http') || path.startsWith('https')
          ? Uri.parse(path)
          : Uri.file(path);

      await _audioPlayer.setAudioSource(
        AudioSource.uri(uri),
      );

      currentPath = path;
      currentTitle = title;
    }

    await _audioPlayer.play();
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void disposePlayer() {
    _audioPlayer.dispose();
  }
}

