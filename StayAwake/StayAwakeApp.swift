import SwiftUI
import Combine
import IOKit.pwr_mgt

final class SleepPreventer: ObservableObject {
    @Published private(set) var isActive: Bool = false
    @Published private(set) var activeLabel: String = ""

    private var assertionID: IOPMAssertionID = 0
    private var timer: Timer?

    func start(duration: TimeInterval?, label: String, keepDisplayAwake: Bool = false) {
        stop()

        let assertionType = keepDisplayAwake
            ? kIOPMAssertionTypeNoDisplaySleep
            : kIOPMAssertionTypePreventUserIdleSystemSleep

        let reason = "StayAwakeApp: \(label)" as CFString
        let result = IOPMAssertionCreateWithName(
            assertionType as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        guard result == kIOReturnSuccess else {
            print("Couldn't create assertion: \(result)")
            return
        }

        isActive = true
        activeLabel = keepDisplayAwake ? "\(label) (monitor stays on)" : label

        if let duration {
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                self?.stop()
            }
        }
    }

    func stop() {
        if isActive {
            IOPMAssertionRelease(assertionID)
        }
        timer?.invalidate()
        timer = nil
        isActive = false
        activeLabel = ""
    }
}

struct StayAwakeMenuView: View {
    @ObservedObject var preventer: SleepPreventer

    private let options: [(label: String, duration: TimeInterval?)] = [
        ("20 min", 20 * 60),
        ("30 min", 30 * 60),
        ("1 hour", 60 * 60),
        ("2 hours", 2 * 60 * 60),
        ("4 hours", 4 * 60 * 60),
        ("Until turned off", nil)
    ]

    var body: some View {
        if preventer.isActive {
            Text("Active: \(preventer.activeLabel)")
            Button("Stop") {
                preventer.stop()
            }
        } else {
            ForEach(options, id: \.label) { option in
                Button(option.label) {
                    let optionHeld = NSEvent.modifierFlags.contains(.option)
                    preventer.start(
                        duration: option.duration,
                        label: option.label,
                        keepDisplayAwake: optionHeld
                    )
                }
            }
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}

@main
struct StayAwakeApp: App {
    @StateObject private var preventer = SleepPreventer()

    var body: some Scene {
        MenuBarExtra {
            StayAwakeMenuView(preventer: preventer)
        } label: {
            Image(systemName: preventer.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
        .menuBarExtraStyle(.menu)
    }
}
