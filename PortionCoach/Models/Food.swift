import SwiftUI

/// Food groups used by the coach to judge how balanced a plate is.
enum FoodCategory: String, CaseIterable, Identifiable, Sendable {
    case starch = "Starch"
    case protein = "Protein"
    case vegetable = "Vegetables"
    case extra = "Extras"

    var id: String { rawValue }
}

/// The 3D shape a dish is drawn with on the plate.
enum FoodShape: Sendable {
    case mound     // rice
    case puddle    // curries
    case heap      // sambols, fish
    case disc      // papadam
}

/// A Sri Lankan dish with its calories for one standard portion.
/// Calories are typical estimates, not exact nutrition data.
struct Food: Identifiable, Sendable {
    let id: String
    let name: String
    let portionName: String        // What "one portion" means, e.g. "1 cup"
    let calories: Int              // kcal per standard portion
    let category: FoodCategory
    let shape: FoodShape
    let rgb: SIMD3<Float>          // Colour on the plate (0–1)

    // MARK: - Geometry (metres, real size)

    /// Radius of the shape at one standard portion.
    var radius: Float {
        switch shape {
        case .mound: 0.05
        case .puddle: 0.045
        case .heap: 0.03
        case .disc: 0.055
        }
    }

    /// Squashes spheres into mounds and puddles.
    var baseScale: SIMD3<Float> {
        switch shape {
        case .mound: [1, 0.55, 1]
        case .puddle: [1, 0.28, 1]
        case .heap: [1, 0.6, 1]
        case .disc: [1, 1, 1]
        }
    }

    /// Half the height of the mesh before scaling.
    var localHalfHeight: Float { shape == .disc ? 0.002 : radius }

    /// Half the height of one standard portion as it sits on the plate.
    var halfHeight: Float { localHalfHeight * baseScale.y }

    // MARK: - Colours

    var color: Color { Color(red: Double(rgb.x), green: Double(rgb.y), blue: Double(rgb.z)) }
    var uiColor: UIColor { UIColor(red: CGFloat(rgb.x), green: CGFloat(rgb.y), blue: CGFloat(rgb.z), alpha: 1) }

    // MARK: - Menu

    static let menu: [Food] = [
        Food(id: "white-rice", name: "White rice", portionName: "1 cup", calories: 205,
             category: .starch, shape: .mound, rgb: [0.97, 0.96, 0.92]),
        Food(id: "red-rice", name: "Red rice", portionName: "1 cup", calories: 215,
             category: .starch, shape: .mound, rgb: [0.72, 0.45, 0.38]),
        Food(id: "dhal", name: "Dhal curry", portionName: "1/2 cup", calories: 150,
             category: .protein, shape: .puddle, rgb: [0.95, 0.75, 0.2]),
        Food(id: "chicken", name: "Chicken curry", portionName: "2 pieces", calories: 240,
             category: .protein, shape: .puddle, rgb: [0.55, 0.3, 0.15]),
        Food(id: "fish", name: "Fish ambul thiyal", portionName: "2 pieces", calories: 170,
             category: .protein, shape: .heap, rgb: [0.3, 0.2, 0.15]),
        Food(id: "beetroot", name: "Beetroot curry", portionName: "1/2 cup", calories: 80,
             category: .vegetable, shape: .puddle, rgb: [0.6, 0.1, 0.35]),
        Food(id: "gotukola", name: "Gotukola sambol", portionName: "1/2 cup", calories: 35,
             category: .vegetable, shape: .heap, rgb: [0.3, 0.6, 0.25]),
        Food(id: "pol-sambol", name: "Pol sambol", portionName: "2 tbsp", calories: 90,
             category: .extra, shape: .heap, rgb: [0.9, 0.35, 0.2]),
        Food(id: "papadam", name: "Papadam", portionName: "1 piece", calories: 45,
             category: .extra, shape: .disc, rgb: [0.95, 0.88, 0.65]),
    ]
}

/// Real-world size of the plate, in metres.
enum PlateGeometry {
    static let radius: Float = 0.13     // A 26 cm dinner plate
    static let top: Float = 0.012       // Height of the plate surface
}
