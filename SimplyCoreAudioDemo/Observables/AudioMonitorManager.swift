import Foundation
import AudioKit
import SimplyCoreAudio
import AVFoundation


extension AudioEngine {

    /// Change only the *input* hardware on macOS ‑‑ leaves the output side untouched.
    /// - Important: Call while the engine is **stopped**.
    ///              Restart afterwards (AudioKit does that for you in the previous snippet).
    public func setInputDevice(_ device: Device) throws {
        
        // 1) Grab the Core Audio I/O unit that AVAudioEngine uses
        guard
            let ioNode = input?.avAudioNode as? AVAudioIONode,
            let ioUnit = ioNode.audioUnit
        else {
            throw NSError(domain: "AudioEngine+InputDevice",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey:
                                     "Could not obtain IOAudioUnit from engine.inputNode"])
        }

        // 2) Tell AUHAL to switch hardware
        var devID = device.deviceID
        let size  = UInt32(MemoryLayout.size(ofValue: devID))

        let status = AudioUnitSetProperty(ioUnit,
                                          kAudioOutputUnitProperty_CurrentDevice,
                                          kAudioUnitScope_Global,
                                          0,
                                          &devID,
                                          size)

        guard status == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain,
                          code: Int(status),
                          userInfo: [NSLocalizedDescriptionKey:
                                     "AudioUnitSetProperty returned \(status)"])
        }
    }
}


/// Manages audio input monitoring for the app without changing the system default device.
class AudioMonitorManager: ObservableObject {
    /// Currently monitored device if any.
    @Published private(set) var monitoredDevice: ObservableAudioDevice?

    private let engine = AudioEngine()

    /// A silent mixer that is always used as the engine’s output so the engine
    /// can start even when we are only monitoring.
    private let silentMixer: Mixer = {
        let m = Mixer()
        m.volume = 0   // ensure no audible output
        return m
    }()

    init() {
        // Give the engine a valid (silent) output so it can start without
        // needing a real audio destination.
        engine.output = silentMixer
    }

    /// Start monitoring the given device exclusively.
    func startMonitoring(device: ObservableAudioDevice) {
        // Only restart if switching devices.
        guard monitoredDevice?.id != device.id else { return }

        stopMonitoring()

        if let akDevice = AudioEngine.inputDevices.first(where: { $0.deviceID == device.id }) {
            do {
                try engine.setInputDevice(akDevice)
            } catch {
                print("Failed to set input device: \(error)")
            }
        }

        // Route the current input to the silent mixer so the node is attached to the engine graph.
        if let inputNode = engine.input {
            silentMixer.removeAllInputs()
            silentMixer.addInput(inputNode)
            // Refresh output connection so the mixer advertises the correct channel layout for the newly-selected device.
            engine.output = silentMixer
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
        print("Using input node for monitoring: \(String(describing: engine.input))")
        return engine.input ?? silentMixer
    }

    /// Indicates whether the provided device is being monitored.
    func isMonitoring(_ device: ObservableAudioDevice) -> Bool {
        monitoredDevice?.id == device.id
    }
}
