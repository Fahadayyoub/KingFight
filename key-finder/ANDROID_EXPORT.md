# Android export

The project uses landscape rotation, a 960 × 540 reference viewport with expanding canvas scaling, nearest-neighbor textures, and the Compatibility renderer. Gameplay shows multitouch left/right/jump controls on mobile and touchscreen devices, positioned inside the reported screen safe area. Keyboard controls remain available on desktop. Music persists from the menu through gameplay.

## Build an APK for your phone

1. Use Godot 4.7.1 with its matching Android export templates. They are installed on this machine.
2. In Editor Settings → Export → Android, set Java SDK Path to `/Applications/Android Studio.app/Contents/jbr/Contents/Home` and Android SDK Path to `/Users/muhammad.fahad/Library/Android/sdk`. These paths are configured on this machine.
3. Open Project → Export → Android. The included preset builds an APK for ARM64 and ARMv7. Its initial application ID is `com.fahad.keyfinder`; set your own permanent ID before publishing.
4. Create a `build` folder in the project, select Export Project, leave Export With Debug enabled for device testing, and save `build/key-finder.apk`.
5. Install on a connected phone and verify Start, movement while jumping, audio, death/restart, landscape rotation, notches, and app background/resume. Actual Android-device testing is still required.

The debug APK was successfully exported to `build/key-finder.apk`, signed with Godot’s local debug key, and verified with Android `apksigner`. It is suitable for device testing. It is not a Play Store release build.

## Google Play release

Use an AAB export with Gradle enabled and a release signing key. Choose the permanent application ID, supply production launcher icons, and check current Play target API requirements before publishing. Keep signing credentials outside version control. SDK levels are left at the installed Godot version's defaults.

Official setup: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

## Verification performed

Godot headless checks cover configuration loading, layouts at 960 × 540, 1200 × 540 and 960 × 720, simultaneous movement/jump touch events, releasing jump independently, and clearing held touch input on focus loss. These checks do not verify physical-device rendering, sound output, or installation.
