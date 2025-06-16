# 🔊 SimplyCoreAudio Demo

[SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) demo project showcasing device enumeration and notifications using [SwiftUI](https://developer.apple.com/xcode/swiftui/).

## Requirements

- Xcode 12+
- macOS 11+
- When monitoring output devices, make sure the project has the `com.apple.security.device.audio-output` entitlement enabled.
- Use `activeOutputChannelCount` from `ObservableAudioDevice` when configuring
  output monitoring to match the device's current stream channels.

![Screenshot](images/Screenshot.png "a title")
