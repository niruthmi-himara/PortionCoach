# Portion Coach 🍛

**See your portion before you eat it.** A visionOS app for Apple Vision Pro that shows Sri Lankan meal portions at real size, in 3D.

> SE4041 Mobile Application Design and Development, Assignment 2, Part B
> K N H Rathnayake (IT23274570), SLIIT, BSc (Hons) in Information Technology, specialising in Interactive Media

---

## The idea

Sri Lanka has one of the highest diabetes rates in Asia, and rice-heavy meals with large portions are a daily habit. Calorie apps only estimate a meal after it is served; none show what a healthy portion looks like. Portion Coach lets you build a rice and curry plate at true size in 3D, resize each portion with your hands, and watch the calories and coaching tips change.

## Features

| Feature | visionOS capability |
|---|---|
| A 26 cm plate on a banana leaf that you can walk around | **Volumetric window** (RealityKit) |
| Look and pinch to select a dish, pinch and drag to move it, two-hand pinch to resize it | **Spatial gestures** on entities |
| Floating calorie total and Clear button under the plate | **Ornament** |
| The same plate at life size in your room | **Mixed immersive space** |
| Calories by food group and coach tips (rice share, vegetables, protein, meal size) | SwiftUI main window |
| VoiceOver names for every dish; a slider as an alternative to two-hand gestures | **Accessibility** |

Portions scale with volume: doubling the size of a dish gives 8 portions, which the app makes visible.

## Requirements

- macOS with **Xcode 26** or later
- **visionOS 26 simulator** (Xcode → Settings → Components), or an Apple Vision Pro
- No third-party packages or internet connection needed

## How to build and run

1. Clone the repository (it is private; ask the author for access):
   ```bash
   git clone https://github.com/niruthmi-himara/PortionCoach.git
   ```
2. Open **`PortionCoach.xcodeproj`** in Xcode.
3. Choose **Apple Vision Pro** as the run destination and press **⌘R**.
4. The main window and the 3D plate open side by side. Add dishes from the list.

**Simulator controls:** the pointer is where you look and a click is a pinch. Click and drag a dish to move it. Hold **Option** and drag for a two-hand pinch to resize, or use the **Portion size** slider. Use the buttons at the bottom right of the simulator, or **W A S D**, to move around the room.

### Running the tests

Press **⌘U**. **8 unit tests** (Swift Testing) cover adding and removing dishes, portion volume and calories, size limits, keeping dishes on the plate, and coach tips.

## Project structure

```
PortionCoach/
├── Models/        Food (dish menu, calories, 3D sizes), PlateItem
├── ViewModels/    PlateViewModel (shared state, gestures' effects, coaching)
├── Services/      FoodEntityFactory (builds the plate and dishes in RealityKit)
├── Views/         ContentView, PlateRealityView, PlateVolumeView, TableImmersiveView
└── PortionCoachApp.swift   Window, volume and immersive space scenes
PortionCoachTests/ Unit tests
```

## Architecture

**MVVM.** One `@Observable` `PlateViewModel` is shared by the main window, the volume and the immersive space through the SwiftUI environment, so all three always show the same plate. `PlateRealityView` mirrors the model into RealityKit entities and turns gestures into model changes, keeping the model the single source of truth. All 3D shapes are generated in code, so the app ships no 3D model files.

## Known limitations and future work

- Calorie values are typical per-portion estimates.
- The life-size plate is placed at a fixed height; future versions will anchor it to a real table with plane detection.
- Planned: Create ML recognition of Sri Lankan dishes (shared with the PlateWise iOS app), SharePlay sessions for a dietitian and patient, and HealthKit export.

## Related

- **PlateWise** (Part A): the iPhone food logger with Core ML food recognition.

## AI-assisted development

AI assistance (Claude, by Anthropic) was used for guidance, explanations, debugging and code suggestions. All prompts and responses are documented in the AI usage log submitted with this assignment.
