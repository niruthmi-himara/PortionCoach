import SwiftUI

/// The 3D volume window: the plate plus a floating toolbar (ornament) below it.
struct PlateVolumeView: View {
    @Environment(PlateViewModel.self) private var plate

    var body: some View {
        PlateRealityView(origin: [0, -0.12, 0])
            .ornament(attachmentAnchor: .scene(.bottomFront)) {
                HStack(spacing: 20) {
                    Label("\(plate.totalCalories) kcal", systemImage: "flame.fill")
                        .font(.headline)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: plate.totalCalories)
                    Button("Clear", systemImage: "trash") {
                        plate.clear()
                    }
                    .disabled(plate.items.isEmpty)
                }
                .fixedSize()
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassBackgroundEffect()
            }
    }
}
