import SwiftUI

/// Mixed immersive space: the plate at life size, about table height,
/// 60 cm in front of you, so portions can be compared with real objects.
struct TableImmersiveView: View {
    var body: some View {
        PlateRealityView(origin: [0, 0.8, -0.6])
    }
}
