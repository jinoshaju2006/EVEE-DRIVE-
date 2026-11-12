# Third-party asset credits

## Vehicle models

- **Asset pack:** Car Kit
- **Creator:** Kenney
- **Official source:** https://kenney.nl/assets/car-kit
- **License:** Creative Commons CC0 1.0 Universal (public-domain dedication)
- **License details:** https://creativecommons.org/publicdomain/zero/1.0/
- **Files included:** `sedanSports.glb`, `race.glb`, `suv.glb`, `truck.glb`, `van.glb`
- **Project use:** Player garage vehicle visuals and mixed-fleet selection.
- **Format:** glTF Binary (.glb), imported by Godot 4.3.

The Kenney Car Kit page identifies the pack as CC0. Attribution is not required; this credit is included as a courtesy. The models are low-poly prototype assets and do not represent licensed real-world vehicle brands.

## Android compatibility notes

The models are local project assets; the game does not download them at runtime. Keeping the models as GLB avoids runtime network dependencies. Their actual rendering performance still needs profiling on target Android devices. Use the Balanced graphics preset as the default and reduce resolution, shadows or visible traffic if a device struggles.

## Provenance

The selected GLB files were taken from the Kenney Car Kit model set as mirrored in the public Godot example repository:
https://github.com/kidscancode/3d_car_sphere/tree/cabc5c0019e68913012fc41d7b2ded6dcef3be31/assets/kenney_car_kit

The official Kenney asset page is the authoritative source for the pack licence.

## Forest and nature models

- **Asset pack:** Nature Kit 2.1
- **Creator:** Kenney
- **Official source:** https://kenney.nl/assets/nature-kit
- **License:** Creative Commons CC0 1.0 Universal
- **License details:** https://creativecommons.org/publicdomain/zero/1.0/
- **Files included:** `tree_pineTallA_detailed.glb`, `tree_oak.glb`, `stone_largeA.glb`, `plant_bushLarge.glb`
- **Project use:** Forest biome trees, rocks and low bushes.
- **Format:** glTF Binary (.glb).

The included copies are the PBR-material-adjusted versions documented by the upstream Udea asset notice; geometry and node transforms were retained by that source's preparation step. The official Kenney Nature Kit page identifies the source pack as CC0. These models are static scenery, not drivable or collidable vehicle assets.

Model-copy provenance and modification notes:
https://github.com/wildware-uk/Udea/tree/3fb827da42fedce4a73e34fc334c1fab61f94949/hollow/game/assets/models/nature

All environment models are bundled locally. No network downloads are required while the game is running.
