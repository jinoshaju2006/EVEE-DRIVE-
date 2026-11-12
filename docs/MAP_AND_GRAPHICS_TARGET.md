# EVEE DRIVE map and graphics target

## Selected configuration

- Graphics style: **Balanced** (Medium preset by default).
- World size: **Medium**.
- Vehicle collection: **Mixed**.

## Current medium map footprint

The prototype currently uses a connected generated world rather than a downloaded real-world map:

- A 1.2 km main city-road test route.
- A neighbouring dirt-driving practice area with ramps and obstacles.
- A connected forest trail and pine-forest zone.

This is a medium-sized prototype layout, not a fully authored open-world map. The current geometry is generated in GDScript and uses lightweight primitives so it remains compatible with Godot 4.3's GL Compatibility renderer and Android export target.

## Balanced Android rendering

- Keep Godot 4.3 and the GL Compatibility renderer.
- Default to Medium quality; players can still choose Low/High/Ultra.
- Keep imported vehicles low-poly and use a small mixed traffic set.
- Avoid heavy desktop-only shaders, high-cost screen-space effects, and dense real-time shadowing.
- Profile on physical Android devices before increasing vegetation density, texture sizes, or shadow distance.

## Vehicle model integration

The player garage uses a Kenney sports sedan and SUV as visual models. Ambient traffic selects from five Kenney models: sports sedan, race car, SUV, truck, and van. Existing collision and movement scripts remain independent of the visual models.
