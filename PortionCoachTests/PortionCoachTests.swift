import Testing
@testable import PortionCoach

/// Unit tests for the plate model: portions, calories, limits and coaching.
@MainActor
struct PortionCoachTests {

    private let rice = Food.menu[0]          // White rice, 205 kcal per cup

    @Test func addingFoodPutsItOnThePlateAndSelectsIt() {
        let plate = PlateViewModel()
        plate.add(rice)
        #expect(plate.items.count == 1)
        #expect(plate.selectedID == plate.items.first?.id)
    }

    @Test func doublingTheSizeGivesEightPortions() {
        var item = PlateItem(food: rice, position: .zero)
        item.scale = 2
        #expect(item.portions == 8)
    }

    @Test func caloriesFollowThePortionVolume() throws {
        let plate = PlateViewModel()
        plate.add(rice)
        let id = try #require(plate.items.first?.id)
        plate.setScale(id, 0.5)                                    // Half the size = 1/8 of the volume
        #expect(plate.totalCalories == Int((205.0 * 0.125).rounded()))
    }

    @Test func portionSizeIsKeptWithinLimits() throws {
        let plate = PlateViewModel()
        plate.add(rice)
        let id = try #require(plate.items.first?.id)
        plate.setScale(id, 10)
        #expect(plate.items.first?.scale == PlateViewModel.scaleRange.upperBound)
        plate.setScale(id, 0)
        #expect(plate.items.first?.scale == PlateViewModel.scaleRange.lowerBound)
    }

    @Test func movedDishesStayOnThePlate() throws {
        let plate = PlateViewModel()
        plate.add(rice)
        let id = try #require(plate.items.first?.id)
        plate.move(id, to: [1, 0])                                 // 1 m away: far off the plate
        let position = try #require(plate.items.first?.position)
        let distance = (position.x * position.x + position.y * position.y).squareRoot()
        #expect(distance <= PlateGeometry.radius)
    }

    @Test func coachWarnsWhenRiceDominates() {
        let plate = PlateViewModel()
        plate.add(rice)
        #expect(plate.coachTip.contains("Rice"))
    }

    @Test func coachAsksForVegetables() {
        let plate = PlateViewModel()
        plate.add(rice)
        plate.add(Food.menu[3])                                    // Chicken curry
        plate.add(Food.menu[2])                                    // Dhal curry
        #expect(plate.coachTip.contains("vegetable"))
    }

    @Test func removingAndClearingEmptyThePlate() throws {
        let plate = PlateViewModel()
        plate.add(rice)
        plate.add(Food.menu[2])
        let id = try #require(plate.items.first?.id)
        plate.remove(id)
        #expect(plate.items.count == 1)
        plate.clear()
        #expect(plate.items.isEmpty)
        #expect(plate.selectedID == nil)
    }
}
