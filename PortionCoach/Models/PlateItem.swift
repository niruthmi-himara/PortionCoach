import Foundation

/// One dish placed on the plate, with its position and portion size.
struct PlateItem: Identifiable, Sendable {
    let id = UUID()
    let food: Food
    var position: SIMD2<Float>      // x and z on the plate, in metres from the centre
    var scale: Float = 1            // Size compared with one standard portion

    /// Portions grow with volume, so doubling the size gives 8 portions.
    var portions: Float { scale * scale * scale }

    var calories: Int { Int((Float(food.calories) * portions).rounded()) }
}
