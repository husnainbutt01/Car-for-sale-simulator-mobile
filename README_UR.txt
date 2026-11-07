CAR FOR SALE SIMULATOR ADVANCED - MOBILE STARTER
Developed by Husnain Butt

Engine: Godot 4.2+
Renderer: GL Compatibility (mobile-friendly prototype)

CURRENTLY IMPLEMENTED IN THIS STARTER:
- 3D dealership environment and simple city blocks/road
- Walk/run character movement
- Basic display vehicles made from original primitive meshes
- Buy car / inventory counter / sell car prototype
- Enter and exit a demo vehicle
- Keyboard driving prototype: W accelerate, S brake, A/D steer
- Basic fuel meter and speed display
- Workshop service transaction (engine condition/fuel prototype)
- Paint shop transaction (paint selection placeholder)
- AI customer offer/reputation prototype
- Day progression and mission placeholder
- Local save/load using user://savegame.json
- On-screen touch buttons and HUD

IMPORTANT LIMITATIONS:
This is an advanced starter prototype, not a finished commercial game.
The cars are placeholder geometry, not licensed detailed 3D car assets.
Driving uses a simplified scripted controller, not full simulation-grade vehicle physics.
AI customers, traffic, police, auctions, deformation, multiplayer, detailed workshop animations,
large open world, licensed audio, and full language localization are future development tasks.
Some touch buttons are prototype controls; they are not yet a polished virtual joystick.

OPEN IN GODOT:
1. Extract this ZIP.
2. Open Godot Project Manager.
3. Import project.godot.
4. Open and run the project.

BUILD APK WITHOUT INSTALLING GODOT/ANDROID SDK LOCALLY:
This package includes a GitHub Actions workflow at .github/workflows/android-apk.yml.
You still need a GitHub account and a one-time upload of this project to a GitHub repository.
GitHub's cloud runner installs/uses Godot and Android build dependencies to export the APK.

CLOUD BUILD STEPS:
1. Create a new GitHub repository (public or private).
2. Upload all files and folders from this extracted project to the repository.
   Make sure project.godot and .github/workflows/android-apk.yml are at repository root paths.
3. Open the repository's Actions tab.
4. Select "Build Android APK" and click "Run workflow".
5. Wait for the workflow to finish successfully.
6. Open the completed workflow run, scroll to Artifacts, and download "Car-For-Sale-Simulator-APK".
7. Extract the downloaded artifact ZIP and install the APK on your Android phone.
   Android may ask you to allow installation from that browser/file manager.

If the cloud workflow fails, read the Actions log; the first export may need adjustments to match the selected Godot version/export template.
The workflow is a build configuration, not a guarantee that every future Godot/Android runner combination will work without maintenance.

For release signing / Play Store:
Create and securely store your own Android keystore and configure signing secrets.
Do not commit keystore files or passwords to GitHub.


ANDROID APK BUILD (MOBILE)
--------------------------
Yeh ZIP Godot project source hai; APK is ZIP ke andar pehle se bani hui nahi hai.

Android APK banane ke liye:
1. ZIP ko extract karein.
2. Project ke tamam files/folders ko GitHub repository ke ROOT mein upload karein.
3. Confirm karein ke root mein project.godot aur export_presets.cfg hain.
4. Confirm karein ke .github/workflows/android-apk.yml maujood hai.
5. GitHub repository mein Actions enabled hon.
6. Actions tab > Build Android APK > Run workflow.
7. Build complete hone par workflow run ke Artifacts section se
   Car-For-Sale-Simulator-Android-APK download karein.
8. ZIP extract karke APK phone par install karein. Phone par unknown-app
   installation ki permission deni par sakti hai.

Target export: Android ARM64 (64-bit).
Package ID: com.husnainbutt.car.forsale.simulator

Note: GitHub Actions build ko internet chahiye. Workflow ka actual successful
build GitHub par run karne ke baad hi confirm hoga. Yeh abhi prototype game hai,
fully finished commercial-grade simulator nahi.
