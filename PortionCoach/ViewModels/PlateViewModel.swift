import Foundation
import Observation

/// Shared state for the plate: which dishes are on it, their sizes, and coaching.
/// Every window and the immersive space read from this one model.
@Observable
@MainActor
final class PlateViewModel {
    private(set) var items: [PlateItem] = []
    var selectedID: UUID?

    /// A typical main meal, used to judge the total.
    static let mealTarget = 700

    /// Smallest and largest portion size allowed (0.125× to about 4× a standard portion).
    static let scaleRange: ClosedRange<Float> = 0.5...1.6

    // MARK: - Reading

    var selectedItem: PlateItem? { items.first { $0.id == selectedID } }

    var totalCalories: Int { items.reduce(0) { $0 + $1.calories } }

    func calories(in category: FoodCategory) -> Int {
        items.filter { $0.food.category == category }.reduce(0) { $0 + $1.calories }
    }

    /// A short tip about the balance of the plate.
    var coachTip: String {
        guard !items.isEmpty else {
            return "Add dishes from the list to build your plate."
        }
        if Double(calories(in: .starch)) / Double(max(totalCalories, 1)) > 0.5 {
            return "Rice is more than half of this plate's calories. Try a smaller rice portion."
        }
        if !items.contains(where: { $0.food.category == .vegetable }) {
            return "Add a vegetable such as gotukola sambol or beetroot curry."
        }
        if !items.contains(where: { $0.food.category == .protein }) {
            return "Add some protein: dhal, chicken or fish."
        }
        if totalCalories > Self.mealTarget {
            return "This plate is above a typical \(Self.mealTarget) kcal meal."
        }
        return "Nicely balanced plate!"
    }

    // MARK: - Changing

    /// Places a dish on the plate in a free spot and selects it.
    func add(_ food: Food) {
        let distance: Float = items.isEmpty ? 0 : 0.075
        let angle = Float(items.count) * 2.4          // Spreads dishes around the plate
        let item = PlateItem(food: food, position: [cos(angle) * distance, sin(angle) * distance])
        items.append(item)
        selectedID = item.id
    }

    func remove(_ id: UUID) {
        items.removeAll { $0.id == id }
        if selectedID == id { selectedID = nil }
    }

    func clear() {
        items.removeAll()
        selectedID = nil
    }

    func select(_ id: UUID?) {
        selectedID = id
    }

    /// Moves a dish, keeping it on the plate.
    func move(_ id: UUID, to point: SIMD2<Float>) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let limit = PlateGeometry.radius - 0.03
        let length = (point.x * point.x + point.y * point.y).squareRoot()
        items[index].position = length > limit ? point * (limit / length) : point
    }

    /// Resizes a dish within the allowed portion range.
    func setScale(_ id: UUID, _ scale: Float) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].scale = min(max(scale, Self.scaleRange.lowerBound), Self.scaleRange.upperBound)
    }
}
