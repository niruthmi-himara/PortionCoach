import SwiftUI

/// Portion Coach: a visionOS app that shows Sri Lankan meal portions at real size in 3D.
@main
struct PortionCoachApp: App {
    @State private var plate = PlateViewModel()   // One shared model for every window and space

    var body: some Scene {
        // Main window: dish menu, calories and coaching
        WindowGroup(id: "main") {
            ContentView()
                .environment(plate)
        }
        .defaultSize(width: 980, height: 680)

        // 3D volume: the plate you can walk around and touch.
        // Opened with a value, so asking again brings the same window forward instead of a duplicate.
        WindowGroup(id: "plate", for: String.self) { _ in
            PlateVolumeView()
                .environment(plate)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.45, height: 0.3, depth: 0.45, in: .meters)

        // Mixed immersive space: the same plate at life size on a table in front of you
        ImmersiveSpace(id: "table") {
            TableImmersiveView()
                .environment(plate)
        }
    }
}
