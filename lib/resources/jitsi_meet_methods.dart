import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:omni_jitsi_meet/jitsi_meet.dart';
import 'package:zoom_clone/resources/auth_methods.dart';
import 'package:zoom_clone/resources/firestore_methods.dart';

class JitsiMeetMethods {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  void createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
  }) async {
    try {
      String? name;
      if (username.isEmpty) {
        name = _authMethods.user?.displayName!;
      } else {
        name = username;
      }
      final featureFlags = {
        FeatureFlagEnum.RESOLUTION: FeatureFlagVideoResolution.MD_RESOLUTION,
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };
      if (!kIsWeb && Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      }
      final options = JitsiMeetingOptions(
          room: roomName,
          // serverURL: serverUrl,
          // subject: subjectText.text,
          userDisplayName: name,
          userEmail: _authMethods.user?.email,
          // iosAppBarRGBAColor: iosAppBarRGBAColor.text,
          // audioOnly: isAudioOnly,
          audioMuted: isAudioMuted,
          videoMuted: isVideoMuted,
          featureFlags: featureFlags,
          webOptions: {
            "roomName": roomName,
            "width": "100%",
            "height": "100%",
            "enableWelcomePage": false,
            "enableNoAudioDetection": true,
            "enableNoisyMicDetection": true,
            "enableClosePage": false,
            "prejoinPageEnabled": false,
            "hideConferenceTimer": true,
            "disableInviteFunctions": true,
            "chromeExtensionBanner": null,
            "configOverwrite": {
              "prejoinPageEnabled": false,
              "disableDeepLinking": true,
              "enableLobbyChat": false,
              "enableClosePage": false,
              "chromeExtensionBanner": null,
              /*"toolbarButtons": [
              "microphone",
              "camera",
              "hangup",
            ]*/
            },
            "userInfo": {"email": _authMethods.user?.email, "displayName": name}
          });
      _firestoreMethods.addToMeetingHistory(roomName);
      await JitsiMeet.joinMeeting(options);
    } catch (error) {
      debugPrint("error: $error");
    }
  }
}
