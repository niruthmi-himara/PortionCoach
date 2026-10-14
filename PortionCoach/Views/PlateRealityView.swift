import SwiftUI
import RealityKit

/// The 3D plate scene, used by both the volume and the immersive space.
/// It mirrors the shared PlateViewModel and turns hand gestures into changes to it.
struct PlateRealityView: View {
    @Environment(PlateViewModel.self) private var plate

    /// Where the plate sits in this scene, in metres.
    let origin: SIMD3<Float>

    @State private var root = Entity()
    @State private var scaleAtGestureStart: Float?

    var body: some View {
        // Read the model here so SwiftUI redraws the scene when it changes
        let items = plate.items
        let selected = plate.selectedID

        RealityView { content in
            root.position = origin
            root.addChild(FoodEntityFactory.makePlate())
            content.add(root)
        } update: { _ in
            sync(items, selected: selected)
        }
        .gesture(dragGesture)
        .simultaneousGesture(magnifyGesture)
        .gesture(tapGesture)
    }

    // MARK: - Gestures

    /// Look at a dish and pinch to select it.
    private var tapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                plate.select(Self.itemID(of: value.entity))
            }
    }

    /// Pinch and drag a dish to move it around the plate.
    private var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard let id = Self.itemID(of: value.entity) else { return }
                let point = value.convert(value.location3D, from: .local, to: root)
                plate.select(id)
                plate.move(id, to: [point.x, point.z])
            }
    }

    /// Pinch with both hands and pull apart or together to change the portion size.
    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard let id = Self.itemID(of: value.entity),
                      let item = plate.items.first(where: { $0.id == id }) else { return }
                if scaleAtGestureStart == nil { scaleAtGestureStart = item.scale }
                plate.select(id)
                plate.setScale(id, (scaleAtGestureStart ?? 1) * Float(value.magnification))
            }
            .onEnded { _ in
                scaleAtGestureStart = nil
            }
    }

    // MARK: - Keeping the 3D scene in step with the model

    private func sync(_ items: [PlateItem], selected: UUID?) {
        let wanted = Set(items.map { Self.entityName(for: $0.id) })

        // Remove dishes that are no longer on the plate
        for child in Array(root.children) where child.name.hasPrefix("food:") && !wanted.contains(child.name) {
            child.removeFromParent()
        }

        // Add new dishes and update size, position and selection
        for item in items {
            let name = Self.entityName(for: item.id)
            let entity: Entity
            if let existing = root.findEntity(named: name) {
                entity = existing
            } else {
                entity = FoodEntityFactory.makeFood(item.food)
                entity.name = name
                root.addChild(entity)
            }

            entity.scale = item.food.baseScale * item.scale
            entity.position = [item.position.x,
                               PlateGeometry.top + item.food.halfHeight * item.scale,
                               item.position.y]
            entity.findEntity(named: "ring")?.isEnabled = (item.id == selected)
        }
    }

    private static func entityName(for id: UUID) -> String {
        "food:\(id.uuidString)"
    }

    /// Finds which plate item a touched entity belongs to.
    private static func itemID(of entity: Entity) -> UUID? {
        guard entity.name.hasPrefix("food:") else { return nil }
        return UUID(uuidString: String(entity.name.dropFirst("food:".count)))
    }
}
