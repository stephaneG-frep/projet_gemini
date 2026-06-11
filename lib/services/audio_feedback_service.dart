import 'package:flutter/services.dart';

class AudioFeedbackService {
  AudioFeedbackService._();

  static final AudioFeedbackService instance = AudioFeedbackService._();
  static const MethodChannel _channel = MethodChannel('focus_buddy/audio');

  Future<void> playSessionComplete() async {
    try {
      await _channel.invokeMethod<void>('sessionComplete', {
        'message':
            'Bravo, session terminee. Tu avances ton royaume, continue comme ca.',
      });
    } on PlatformException {
      SystemSound.play(SystemSoundType.alert);
    } on MissingPluginException {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
