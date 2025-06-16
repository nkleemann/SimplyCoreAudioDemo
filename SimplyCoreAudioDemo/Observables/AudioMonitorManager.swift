import Foundation
import AudioKit
import SimplyCoreAudio

/// Manages audio input monitoring for the app without changing the system default device.
class AudioMonitorManager: ObservableObject {
    /// Currently monitored device if any.
    @Published private(set) var monitoredDevice: ObservableAudioDevice?

    private let engine = AudioEngine()

    init() {
        // Attach the input directly to the output so the engine can run.
        engine.output = engine.input
    }

    /// Start monitoring the given device exclusively.
    func startMonitoring(device: ObservableAudioDevice) {
        // Only restart if switching devices.
        guard monitoredDevice?.id != device.id else { return }

        stopMonitoring()

        if let akDevice = engine.inputDevices.first(where: { $0.deviceID == device.id }) {
            do {
                try engine.setInputDevice(akDevice)
            } catch {
                print("Failed to set input device: \(error)")
            }
        }

        do {
            try engine.start()
            monitoredDevice = device
        } catch {
            print("Failed to start engine: \(error)")
        }
    }

    /// Stop monitoring any device.
    func stopMonitoring() {
        engine.stop()
        monitoredDevice = nil
    }

    /// Returns the node used for monitoring.
    var monitoredNode: Node {
        engine.input
    }

    /// Indicates whether the provided device is being monitored.
    func isMonitoring(_ device: ObservableAudioDevice) -> Bool {
        monitoredDevice?.id == device.id
    }
}
