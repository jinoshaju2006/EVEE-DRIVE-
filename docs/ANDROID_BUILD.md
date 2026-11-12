# Android build notes

EVEE DRIVE is configured as an Android-first Godot 4 project. An APK is not included yet.

## Required local setup

1. Install a current Godot 4.x stable release.
2. Install matching Godot export templates from the editor.
3. Install Android Studio and the Android SDK platform/build tools required by that Godot release.
4. Configure the Java SDK path and Android SDK path in Editor Settings > Export > Android.
5. Open Project > Export, add an Android preset, and configure the package name and app icon.
6. Export a debug APK first and test it on a physical Android device.

## Performance targets

The in-game frame-rate selector offers 30, 60, 90, 120 and 144 FPS caps. The cap is a target, not a guarantee. Actual frame rate is limited by the phone's display refresh rate, GPU/CPU performance, thermal state and the selected graphics preset.

## Graphics presets

- Low: reduced 3D render scale, MSAA disabled
- Medium: reduced render scale, 2x MSAA
- High: native render scale, 2x MSAA
- Ultra: native render scale, 4x MSAA

High and Ultra presets may be too demanding for entry-level Android devices.

## World and traffic prototype

The current city-road environment is generated from primitive meshes at startup. Buildings and roadside props are visual prototype geometry; traffic cars are lightweight moving visual actors and do not yet implement full traffic rules, collision response or pedestrian behavior. Replace the prototype geometry with optimized authored assets before a production release.

## Audio

The current prototype uses a synthesized engine-tone loop to validate runtime audio and volume controls. Replace or layer this with properly licensed recorded engine, tire, road, collision and environment audio before a public release.

## Validation checklist

- Import the project in the selected Godot 4.x version.
- Run the main scene and check the debugger for script/resource errors.
- Test touch buttons, camera switching and the on-screen vehicle reset button on an Android touchscreen.
- Check frame pacing and thermal behavior during longer drives with traffic enabled.
- Verify settings persist after restarting the app.
- Export and install a debug APK.
- Test all frame-rate caps and graphics presets on target hardware.
