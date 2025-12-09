 
# Quick summary (one line)

1. Add the package via **Xcode → Add Package Dependency**.
2. `import ScreenshotDetectorKit` in your file.
3. Wrap sensitive UI with `ProtectedScreenView` or `ScreenshotProtectedView`, or use `.detectScreenshots(...)` modifier.
4. Test on real devices.

---

# Step 1 — Add the package dependency (Xcode)

1. Open your app project in **Xcode**.
2. From the menu choose **File → Add Packages…**.
3. Paste your package GitHub URL, for example:
   `https://github.com/Excelsior-Technologies-Community/excelsior-Technologies-Community-IOS_ScreenShotDetector.git`
4. Choose the version rule (recommended: **Up to Next Major** or a specific tag like `v1.0.0`).
5. Select the app target(s) to which the package should be added. Click **Add Package** / **Add**.

> ✅ After this Xcode will download the package and add it to your project.

---

# Step 2 — Import the module

At the top of any Swift file where you want to use the package:

```swift
import ScreenshotDetectorKit
```

(If your Package.product has a different module name, import that name.)

---

# Step 3 — Basic usage examples

Below are the three typical ways developers will use the package.

### A — Protect an entire screen (recommended)

Wrap the whole view in `ProtectedScreenView`. When screen recording is active the user will see a black secure screen; when a screenshot is taken the package will show a toast message (and try to use platform APIs to produce a black screenshot where supported).

```swift
import SwiftUI
import ScreenshotDetectorKit

struct SensitiveAccountView: View {
    var body: some View {
        ProtectedScreenView {
            VStack(spacing: 20) {
                Text("Welcome, Noman")
                    .font(.title)
                Text("Account: 1234 5678 9012")
                    .font(.headline)
            }
            .padding()
        }
    }
}
```

### B — Protect only a subview

If you only need to protect a card or specific portion, use `ScreenshotProtectedView`:

```swift
ScreenshotProtectedView {
    VStack {
        Text("Secret ID")
        Text("XXXX-XXXX")
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
}
```

This embeds your SwiftUI view inside a `UIView` that applies capture-protection when possible.

### C — Detect screenshots & show toast (modifier)

If you only want to *detect* screenshots/recordings and show a small toast:

```swift
struct DemoView: View {
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isScreenCaptured = UIScreen.main.isCaptured

    var body: some View {
        VStack { /* your content */ }
            .detectScreenshots(
                showToast: $showToast,
                toastMessage: $toastMessage,
                isScreenCaptured: $isScreenCaptured
            )
            .overlay(
                Group {
                    if showToast {
                        ToastView(message: toastMessage)
                            .padding(.top, 40)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }, alignment: .top
            )
    }
}
```

---

# Step 4 — Where to put in App lifecycle (optional)

No special wiring is required. Just use the wrapper in your view hierarchy. Example `App` entry:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            SensitiveAccountView()
        }
    }
}
```

If you use environment objects from the package, ensure you inject them at the root (but this package example does not require that).

---

# Step 5 — Test on real devices (VERY IMPORTANT)

* Run on a **real iPhone** (simulator may not reflect capture behavior).
* Test **screenshot**: press device buttons — verify saved screenshot (in Photos) is black/blank where API support exists.
* Test **screen recording**: start recording from Control Center — confirm the app view becomes black while recording.
* Test different iOS versions if your app supports multiple.

---

# Step 6 — What to explain to teammates / users

* `userDidTakeScreenshotNotification` arrives **after** the screenshot is saved. You cannot retroactively change that screenshot; rely on platform capture prevention APIs to have the OS save a blank screenshot instead.
* Not all iOS versions support official capture prevention APIs. The package uses the best-available approach and includes fallback behavior. Always test on the OS versions you support.
* This is a UI-level protection. Extremely sensitive workflows should combine UI protections with server-side protections and reduced on-screen exposure.

---

# Step 7 — Troubleshooting

* **Package not found** in Xcode Add Package: confirm `Package.swift` is at the repo root and you pushed to the branch you selected.
* **Capture prevention not working**: confirm iOS version, test on a real device, and ensure you wrapped the correct view.
* **Toast not showing**: verify you used `.detectScreenshots(...)` or that `ProtectedScreenView` is in the view hierarchy and that `ToastView` overlay is present.
* **No black screenshot**: older iOS might not support black screenshot via API. The screenshot notification occurs after capture — that’s why prevention API is required for black capture.

---

# Step 8 — Recommended integrations & options

* Add logs in debug builds to confirm notifications being received.
* Provide optional callbacks (e.g., `.onScreenshotDetected { }`) if you want consumers to clear sensitive fields programmatically.
* Offer a style config for the toast (color, duration) so teams can match app UI.

---
 
