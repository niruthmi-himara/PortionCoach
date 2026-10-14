import SwiftUI

/// Main window: pick dishes, see calories, get coaching, and open the 3D plate.
struct ContentView: View {
    @Environment(PlateViewModel.self) private var plate
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var lifeSize = false

    var body: some View {
        NavigationSplitView {
            List(Food.menu) { food in
                Button {
                    plate.add(food)
                } label: {
                    FoodRow(food: food)
                }
            }
            .navigationTitle("Dishes")
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    totalSection
                    coachSection
                    selectedSection
                    controlsSection
                }
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Portion Coach")
        }
        .onAppear {
            openWindow(id: "plate", value: "plate")       // Show the 3D plate next to this window
        }
        .onChange(of: lifeSize) { _, isOn in
            Task {
                if isOn {
                    _ = await openImmersiveSpace(id: "table")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }

    // MARK: - Sections

    private var totalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This plate")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(plate.totalCalories) kcal")
                .font(.extraLargeTitle.bold())
                .contentTransition(.numericText())
                .animation(.snappy, value: plate.totalCalories)

            ProgressView(value: min(Double(plate.totalCalories) / Double(PlateViewModel.mealTarget), 1)) {
                Text("of a typical \(PlateViewModel.mealTarget) kcal meal")
            }
            .tint(plate.totalCalories > PlateViewModel.mealTarget ? .orange : .green)
            .frame(maxWidth: 480)

            HStack(spacing: 28) {
                ForEach(FoodCategory.allCases) { category in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(plate.calories(in: category)) kcal")
                            .font(.headline)
                    }
                }
            }
        }
    }

    private var coachSection: some View {
        Label(plate.coachTip, systemImage: "lightbulb.fill")
            .font(.title3)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 24))
    }

    @ViewBuilder
    private var selectedSection: some View {
        if let item = plate.selectedItem {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.food.name)
                    .font(.title2.bold())
                Slider(value: Binding(get: { item.scale },
                                      set: { plate.setScale(item.id, $0) }),
                       in: PlateViewModel.scaleRange) {
                    Text("Portion size")
                } minimumValueLabel: {
                    Image(systemName: "minus")
                } maximumValueLabel: {
                    Image(systemName: "plus")
                }
                Text("\(item.portions, specifier: "%.1f") × \(item.food.portionName) · \(item.calories) kcal")
                    .foregroundStyle(.secondary)
                Button("Remove from plate", systemImage: "trash", role: .destructive) {
                    plate.remove(item.id)
                }
            }
            .padding(20)
            .frame(maxWidth: 520, alignment: .leading)
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 24))
        } else {
            Text("Look at a dish on the 3D plate and pinch to select it. Pinch and drag to move it, or pinch with both hands to resize it.")
                .foregroundStyle(.secondary)
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button("Show 3D plate", systemImage: "fork.knife.circle") {
                openWindow(id: "plate", value: "plate")
            }
            Toggle("Life-size plate on the table", systemImage: "cube.transparent", isOn: $lifeSize)
            Button("Clear plate", systemImage: "trash", role: .destructive) {
                plate.clear()
            }
            .disabled(plate.items.isEmpty)
        }
        .frame(maxWidth: 420, alignment: .leading)
    }
}

/// One dish in the menu list.
struct FoodRow: View {
    let food: Food

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(food.color)
                .frame(width: 22, height: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                Text("\(food.calories) kcal · \(food.portionName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(.tint)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Adds it to the plate")
    }
}
