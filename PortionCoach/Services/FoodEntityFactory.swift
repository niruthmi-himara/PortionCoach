import RealityKit
import UIKit

/// Builds the 3D objects (RealityKit entities) for the plate and each dish.
/// All shapes are made in code, so no 3D model files are needed.
@MainActor
enum FoodEntityFactory {

    /// A white dinner plate on a banana leaf, at real size.
    static func makePlate() -> Entity {
        let plate = Entity()

        let leaf = ModelEntity(
            mesh: .generatePlane(width: 0.42, depth: 0.32, cornerRadius: 0.1),
            materials: [SimpleMaterial(color: UIColor(red: 0.18, green: 0.45, blue: 0.16, alpha: 1),
                                       roughness: 0.6, isMetallic: false)])
        leaf.position.y = 0.0005

        let rim = ModelEntity(
            mesh: .generateCylinder(height: 0.008, radius: PlateGeometry.radius + 0.015),
            materials: [SimpleMaterial(color: UIColor(white: 0.85, alpha: 1), roughness: 0.4, isMetallic: false)])
        rim.position.y = 0.004

        let surface = ModelEntity(
            mesh: .generateCylinder(height: PlateGeometry.top, radius: PlateGeometry.radius),
            materials: [SimpleMaterial(color: .white, roughness: 0.3, isMetallic: false)])
        surface.position.y = PlateGeometry.top / 2

        plate.addChild(leaf)
        plate.addChild(rim)
        plate.addChild(surface)
        return plate
    }

    /// One dish: a coloured shape you can look at, pinch, drag and resize.
    static func makeFood(_ food: Food) -> ModelEntity {
        let mesh: MeshResource = food.shape == .disc
            ? .generateCylinder(height: 0.004, radius: food.radius)
            : .generateSphere(radius: food.radius)

        let entity = ModelEntity(
            mesh: mesh,
            materials: [SimpleMaterial(color: food.uiColor, roughness: 0.8, isMetallic: false)])

        // Make it respond to gaze and hand gestures
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())
        entity.generateCollisionShapes(recursive: false)

        // Let VoiceOver read the dish's name
        var accessibility = AccessibilityComponent()
        accessibility.isAccessibilityElement = true
        accessibility.label = "\(food.name)"
        entity.components.set(accessibility)

        // Green ring shown under the dish when it is selected
        let ring = ModelEntity(
            mesh: .generateCylinder(height: 0.002, radius: food.radius * 1.15),
            materials: [SimpleMaterial(color: .systemGreen, roughness: 0.5, isMetallic: false)])
        ring.name = "ring"
        ring.position.y = -food.localHalfHeight
        ring.isEnabled = false
        entity.addChild(ring)

        return entity
    }
}
