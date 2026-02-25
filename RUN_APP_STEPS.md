# Run KevLines on iPhone or Simulator

Quick steps to run the updated KevLines app in the iOS Simulator or on a physical iPhone.

---

## Option 1: Run in iOS Simulator (easiest)

**Prerequisites:** Xcode installed on your Mac.

### Steps

1. **Open the project in Xcode**
   ```bash
   cd /Users/kevinjones/Documents/KevLines
   open KevLines/KevLines.xcodeproj
   ```
   Or in Finder: double-click `KevLines/KevLines.xcodeproj`.

2. **Pick the Simulator**
   - At the top of Xcode, click the device dropdown (next to “KevLines”).
   - Choose an **iPhone** simulator, e.g. **iPhone 16** or **iPhone 15**.

3. **Build and run**
   - Press **⌘R** (or Product → Run).
   - Xcode builds the app and launches it in the simulator.

4. **Use the app**
   - The simulator may be slow to boot the first time.
   - For video/backend features, the simulator and your Mac must use the same network; for UI-only testing, you can use the app without the backend.

**Note:** Simulator can’t use the real camera. Use “Choose Video” (Photos picker) to test with a video from your Mac’s photo library if available in the simulator.

---

## Option 2: Run on a Physical iPhone

**Prerequisites:** Xcode installed, iPhone with a cable (or same Apple ID for wireless later), Apple ID (free or paid developer account).

### Steps

1. **Open the project**
   ```bash
   cd /Users/kevinjones/Documents/KevLines
   open KevLines/KevLines.xcodeproj
   ```

2. **Connect your iPhone**
   - Plug in the iPhone with a USB cable.
   - On the iPhone, tap **Trust** if it asks to trust this computer.
   - Unlock the phone and leave it unlocked if Xcode asks for permission.

3. **Set up signing (required for device)**
   - In the left sidebar, click the **KevLines** project (blue icon).
   - Under **TARGETS**, select **KevLines**.
   - Open the **Signing & Capabilities** tab.
   - Check **Automatically manage signing**.
   - **Team:** Choose your Apple ID (or “Add an Account…” and sign in with your Apple ID).
   - If you see a bundle ID error, change **Bundle Identifier** to something unique (e.g. `com.yourname.KevLines`).

4. **Trust the developer (first time only)**
   - On the iPhone: **Settings → General → VPN & Device Management**.
   - Under **Developer App**, tap your Apple ID and tap **Trust**.

5. **Select your iPhone and run**
   - In the device dropdown at the top, select your **iPhone** (not a simulator).
   - Press **⌘R** (or Product → Run).
   - Xcode builds and installs the app on the device.

6. **If the app doesn’t open**
   - On the iPhone, open the Home Screen and tap the KevLines icon.
   - If it says “Untrusted Developer”: go to Settings → General → VPN & Device Management → your developer account → **Trust**.

**Free Apple ID:** The app will run on the device but may need to be reinstalled after about 7 days (re-run from Xcode with the phone connected).

---

## Using the app with the Python backend (video analysis)

For **Analyze Form** (upload → analyze → download) to work:

1. **Start the backend on your Mac**
   ```bash
   cd /Users/kevinjones/Documents/KevLines
   python3 app.py
   ```
   You should see something like: `Running on http://0.0.0.0:3000`.

2. **Put iPhone and Mac on the same Wi‑Fi network.**

3. **Point the app at your Mac**
   - In the project, open **KevLines/KevLines/APIService.swift**.
   - Find:
     ```swift
     private let baseURL = "http://10.0.10.231:3000"
     ```
   - Replace `10.0.10.231` with your **Mac’s IP address** (System Settings → Network → Wi‑Fi → Details, or run `ipconfig getifaddr en0` in Terminal).
   - Save, then in Xcode run the app again (⌘R) so it uses the new URL.

4. **Test**
   - In the app: choose an exercise, pick a video, tap **Analyze Form**. The video is sent to the Mac, processed, and the result is downloaded back.

---

## Quick reference

| Goal              | Action |
|-------------------|--------|
| Simulator         | Open project → device dropdown → choose iPhone simulator → ⌘R |
| Physical iPhone   | Connect iPhone → Signing & Capabilities → set Team → device dropdown → choose iPhone → ⌘R |
| Backend for app   | Run `python3 app.py` in KevLines folder; set `baseURL` in APIService.swift to your Mac’s IP |

For more detail: see **IPHONE_TESTING_GUIDE.md** and **IOS_DEPLOYMENT_GUIDE.md** in this repo.
