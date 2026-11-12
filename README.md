# EVEE DRIVE

EVEE DRIVE is an Android-focused, open-world 3D driving game project built with Godot 4 and GDScript.

## Current prototype features

- Procedurally assembled test environment with a road and roadside markers
- Placeholder 3D vehicle with body, wheels, headlights and rear lights
- Basic acceleration, braking, reverse, steering and handbrake
- Third-person chase camera and first-person cockpit camera
- On-screen mobile steering, accelerator, brake and handbrake controls
- Speed display
- Graphics presets: Low, Medium, High and Ultra
- Frame-rate cap options: 30, 60, 90, 120 and 144 FPS
- Master audio volume control and saved settings
- Synthesized engine-tone audio prototype

## Planned features

- Larger explorable open-world map and road network
- Improved vehicle physics, suspension, tire grip and transmission
- Recorded and properly licensed engine, tire, road and environment sound libraries
- Traffic AI, pedestrians, missions and challenges
- Vehicle selection, garage and customization
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

This repository contains an early playable-prototype code foundation. It has not yet been imported, run, profiled or exported to an APK in this development session. Do not treat it as a finished game or release build.
