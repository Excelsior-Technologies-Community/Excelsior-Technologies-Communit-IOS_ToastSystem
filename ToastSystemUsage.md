## ToastSystem – Usage Guide

This guide explains how to add and use the `ToastSystem` Swift Package in your own iOS app.

---

### 1. Add the Swift Package dependency

1. In Xcode, open **your app project**.
2. Go to **File → Add Package Dependency…**
3. Paste the repository URL:

   `https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Communit-IOS_ToastSystem`

4. On the “Dependency Rule” step, you can leave it as **Up to Next Major Version** (or your preferred option) using the default branch.
5. On the product screen, make sure the **`ToastSystem`** library is added to your app target.

After this, you can `import ToastSystem` in your code.

---

### 2. Wire the toast system in your `App`

In your main app file (the one with `@main`), create a `ToastManager` and overlay the `ToastView`:

```swift
import SwiftUI
import ToastSystem

@main
struct MyApp: App {
    @StateObject private var toast = ToastManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toast)
                .overlay(
                    ToastView()
                        .environmentObject(toast)
                        .ignoresSafeArea()
                )
        }
    }
}
```

---

### 3. Use the toast in a view

In any SwiftUI view where you want to trigger toasts:

```swift
import SwiftUI
import ToastSystem

struct ContentView: View {
    @EnvironmentObject var toast: ToastManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, world!")

            Button("Show Toast") {
                toast.show(.success, "Hello from ToastSystem!", position: .top)
            }
        }
        // IMPORTANT: make the view fill the screen so the toast is centered
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
```

**Note (left-side toast issue):**  
If the toast appears stuck on the left or not centered at the top, it usually means your root view does **not** fill the whole screen.  
Fix it by adding:

```swift
.frame(maxWidth: .infinity, maxHeight: .infinity)
```

to the outer container (e.g. `VStack`) as shown above.

---

### 4. Basic API reference

- **Show a toast**

```swift
toast.show(
    .success,              // type: .success / .error / .warning / .info
    "Your message here",   // message
    duration: 2.0,         // seconds (default 2.0)
    position: .top,        // .top / .center / .bottom (default .top)
    haptic: true           // true = haptic + sound, false = silent
)
```

- **Toast with action button**

```swift
toast.show(
    .success,
    "Item added",
    duration: 4.0,
    action: {
        // your undo / custom logic
    },
    actionLabel: "Undo"
)
```

That’s all you need to start using `ToastSystem` in other projects.


