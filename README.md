Here’s a ready-to-paste **README-style step-by-step guide** for your Toast System dependency 👇

---

# 🍞 ToastSystem – Reusable Toast & Haptic Alerts for SwiftUI

A small SwiftUI package that shows beautiful toasts with **type (success/error/warning/info)**,
**position (top/center/bottom)**, **duration**, **haptics + vibration**, and **optional action buttons**.

---

## ✅ 1. Requirements

* iOS 15+ (recommended)
* Xcode 14+
* SwiftUI project

---

## 📦 2. Add Package Dependency (SPM)

1. Open your app in **Xcode**.

2. Go to **File → Add Packages…**

3. Paste your GitHub link:

   ```text
   https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Communit-IOS_ToastSystem
   ```

4. Choose the branch (`development`) or a version/tag (when available).

5. Select your **app target** and click **Add Package**.

Xcode will download the package and link it to your project.

---

## 📥 3. Import the Module

In any Swift file where you want to use the toast system:

```swift
import SwiftUI
import ToastSystem   // or the exact module name you defined in Package.swift
```

> 💡 If your `Package.swift` defines the library name differently (e.g. `ToastSystemKit`), use that name instead.

---

## 🚀 4. Quick Start (3 Steps)

### ✅ Step 1 – Create & Inject `ToastManager` at App Root

In your main `App` file, create a single shared `ToastManager` and inject it as an `environmentObject`, then overlay `ToastView` on top of your content.

```swift
import SwiftUI
import ToastSystem

@main
struct MyApp: App {
    @StateObject var toast = ToastManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(toast)
                .overlay(
                    ToastView()
                        .environmentObject(toast)
                        .ignoresSafeArea() // so it can show at top/bottom over everything
                )
        }
    }
}
```

> 🔑 Important: `ToastView` must be in an overlay at the **top level**, and both your screens and `ToastView` must share the same `ToastManager` via `.environmentObject`.

---

### ✅ Step 2 – Inject Toast Manager into Screens

In any SwiftUI view where you want to show a toast, add:

```swift
struct HomeView: View {
    @EnvironmentObject var toast: ToastManager   // 👈 get shared manager

    var body: some View {
        VStack {
            // your UI
        }
    }
}
```

---

### ✅ Step 3 – Show Toasts from Buttons / Events

You call a **single API** on `ToastManager`:

```swift
toast.show(
    _ type: ToastType,
    _ message: String,
    duration: Double = 2.0,
    position: ToastPosition = .top,
    haptic: Bool = true,
    action: (() -> Void)? = nil,
    actionLabel: String? = nil
)
```

---

## 🔔 5. Common Usage Examples

### 5.1 Basic Toasts (Success / Error / Warning / Info)

```swift
struct DemoView: View {
    @EnvironmentObject var toast: ToastManager

    var body: some View {
        VStack(spacing: 16) {
            Button("Show Success") {
                toast.show(.success, "Operation completed successfully!")
            }

            Button("Show Error") {
                toast.show(.error, "Failed to connect to server")
            }

            Button("Show Warning") {
                toast.show(.warning, "Your session is about to expire")
            }

            Button("Show Info") {
                toast.show(.info, "New features are available")
            }
        }
        .padding()
    }
}
```

Types are defined by `ToastType`: `.success`, `.error`, `.warning`, `.info`. Each one has its own color & haptics. 

---

### 5.2 Change Position (Top / Center / Bottom)

```swift
Button("Top Toast") {
    toast.show(.info, "Toast at top", position: .top)
}

Button("Center Toast") {
    toast.show(.warning, "Toast at center", position: .center)
}

Button("Bottom Toast") {
    toast.show(.success, "Toast at bottom", position: .bottom)
}
```

`ToastPosition` supports `.top`, `.center`, `.bottom`, and `ToastView` will place the toast accordingly. 

---

### 5.3 Control Duration & Haptic

```swift
// 5 sec info toast, no haptic
toast.show(
    .info,
    "This toast stays for 5 seconds, no haptic",
    duration: 5.0,
    position: .top,
    haptic: false
)
```

---

### 5.4 Toast with Action Button (Undo, Retry, etc.)

```swift
@State private var cartCount = 0

Button("Add to Cart") {
    toast.show(
        .success,
        "Item added to cart",
        duration: 4.0,
        action: {
            cartCount -= 1    // Undo logic
        },
        actionLabel: "Undo"
    )
}
```

The toast will show an **action button** (with label `"Undo"`) on the right.
When tapped, it runs your closure and then dismisses the toast.

---

### 5.5 Queue Multiple Toasts

You can trigger multiple toasts quickly — the manager will **queue** them and show one by one:

```swift
Button("Queue 3 Toasts") {
    toast.show(.success, "First toast")
    toast.show(.warning, "Second toast")
    toast.show(.error, "Third toast")
}
```

The queue logic is handled by `ToastManager` internally using `toastQueue` and `processQueue()`. 

---

## 🎚 6. How It Works (Short Explanation for New Devs)

* `ToastConfig` holds the toast data (type, message, duration, position, haptic, action). 
* `ToastManager`:

  * exposes `.show(...)` to create a new toast
  * manages a queue of toasts
  * triggers haptic + system sound depending on `ToastType`
  * hides the toast after `duration` and moves to the next. 
* `ToastView`:

  * reads `ToastManager` via `@EnvironmentObject`
  * shows the current toast with gradient background, shadow, close button, and optional action button
  * supports drag-to-dismiss from top/bottom. 

You don’t need to manage any of that, just:

1. Put `ToastView` in `.overlay(...)` at root.
2. Call `toast.show(...)` from your views.

---

## 🧪 7. Testing Checklist

* [ ] Does the toast appear above your UI at the chosen position?
* [ ] Do haptics & system vibration work on a real device?
* [ ] Does closing one toast show the next when you queue multiple?
* [ ] Does the action button execute your closure and dismiss the toast?
* [ ] Does dragging the toast off-screen dismiss it?

---

## 🛠 8. Troubleshooting

**❓ Toast doesn’t show at all**

* Ensure:

  * `@StateObject var toast = ToastManager()` is created once in your `App`.
  * `.environmentObject(toast)` is applied to your root view.
  * `ToastView().environmentObject(toast)` is added in `.overlay(...)`.

**❓ Crash: “No ObservableObject of type ToastManager found”**

* You forgot `.environmentObject(toast)` somewhere.
* Make sure every view that uses `@EnvironmentObject var toast` is inside the hierarchy where `ToastManager` is injected.

**❓ No haptic / vibration**

* Only works on **real device**, not simulator.
* Check Do Not Disturb / system haptic settings.

---

That’s it!
You now have a clean, dependency-ready **Toast System** that any new developer can add and use in a few steps. If you want, I can also:

* Add a **“Usage in UIKit via UIHostingController”** section
* Add **Theming / Custom Colors** section
* Or generate a **sample app snippet** you can put in the repo under `Examples/`
