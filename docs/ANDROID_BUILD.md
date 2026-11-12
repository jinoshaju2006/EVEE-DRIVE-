# Android build notes

EVEE DRIVE now has a GitHub Actions workflow configured to attempt a **debug APK** build. A successful workflow run will publish the APK as a downloadable Actions artifact; it is not a Play Store release.

## Downloading the APK artifact

1. Open the repository's **Actions** tab.
2. Select **Android debug APK**.
3. Open the latest successful run.
4. Find **Artifacts** at the bottom and download **EVEE-DRIVE-debug-apk**.
5. Extract the downloaded ZIP to obtain `EVEE-DRIVE-debug.apk`.

The workflow runs automatically on relevant game-source changes to `main), and can also be started manually with **Run workflow**. It uses Godot 4.3.0, Android SDK API 34, Java 17 and an ARM64 debug export. The first run may fail if an export-template or SDK setting needs adjustment; check the run log before treating an APK as available.

## Local Android export

1. Install Godot 4.3.0 and its matching export templates.
2. Install Android Studio and the Android SDK platform/build tools.
3. Configure the Java SDK path and Android SDK path in Editor Settings > Export > Android.
4. Open Project > Export and confirm the Android preset.
5. Export a debug APK and test it on a physical Android device.

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

- Import the project in the selected Godot version.
- Run the main scene and check the debugger for script/resource errors.
- Test touch buttons, camera switching and the on-screen vehicle reset button on an Android touchscreen.
- Check frame pacing and thermal behavior during longer drives with traffic enabled.
- Verify settings persist after restarting the app.
- Install and test the debug APK on target Android hardware.
- Test all frame-rate caps and graphics presets on target hardware.
