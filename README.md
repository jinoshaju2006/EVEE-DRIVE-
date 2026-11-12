# EVEE DRIVE

EVEE DRIVE is an Android-focused, open-world 3D driving game project built with Godot 4 and GDScript.

## Current prototype features

- Procedurally generated 1.2 km city-road test area with road markings, buildings, trees and street lights
- Lightweight ambient traffic cars moving through the test road
- Off-road dirt field with winding trail, rocky scenery and rolling terrain props
- Selectable off-road jeep visual with spare wheel and raised body styling
- In-game garage panel for switching between street car and trail jeep
- Four selectable shared paint colours (saved between sessions): purple, black, white and red
- Orbiting garage preview camera that pauses driving while inspecting a vehicle
- Animated wheel rotation tied to vehicle speed
- Visual body roll while steering, pitch under acceleration/braking and subtle speed-linked suspension movement
- Separate off-road driving profile with adjusted speed, acceleration and grip
- Six-checkpoint hill-climb challenge with progress tracking and completion time
- Placeholder 3D vehicle with body, wheels, headlights and rear lights
- Improved acceleration, braking, reverse, steering, lateral grip and handbrake handling
- Vehicle recovery/reset button and R-key recovery
- Third-person chase camera and first-person cockpit camera
- On-screen mobile steering, accelerator, brake and handbrake controls
- Speed display
- Graphics presets: Low, Medium, High and Ultra
- Frame-rate cap options: 30, 60, 90, 120 and 144 FPS
- Master audio volume control and saved settings
- Synthesized engine-tone audio prototype

## Planned features

- Expanded open-world map with more off-road trails, hill-climb routes and terrain collision detail
- Full rigid-body vehicle physics, physically simulated wheel suspension, tire grip and transmission
- Recorded and properly licensed engine, tire, road and environment sound libraries
- Advanced traffic AI, pedestrians, and additional mission types
- Additional unique vehicle models, deeper garage customization and saved paint choices
- Dynamic weather and day/night cycle
- Device-specific graphics optimization and Android release testing

## Technology

- Engine: Godot 4.x
- Language: GDScript
- Target platform: Android
- Renderer: Mobile-friendly GL Compatibility renderer

## Run in Godot

1. Install Godot 4.x.
2. Open this repository folder in the Godot Project Manager.
3. Import and open `project.godot`.
4. Run the main scene.

Keyboard controls: WASD or arrow keys to drive, Space for handbrake. Touch controls are shown in the game HUD.

## Android export

See [Android build notes](docs/ANDROID_BUILD.md) for SDK, export-template and device-testing requirements.

## Performance note

The 144 FPS option sets a frame-rate cap. It does not guarantee 144 FPS on every Android device. Actual performance depends on the device's display refresh rate, GPU/CPU, thermal limits and graphics settings.

## Development status

This repository contains an early driving-game prototype with a generated city-road scene and ambient traffic. It has not yet been imported, run, profiled or exported to an APK in this development session. Do not treat it as a finished game or release build.
