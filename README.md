 
---
 
🍞 ToastSystem – SwiftUI Toast & Haptic Alerts
---

```markdown
# 🍞 ToastSystem – SwiftUI Toast & Haptic Alerts

ToastSystem is a lightweight, reusable SwiftUI package that provides elegant toast notifications with support for:

- Toast types: **success**, **error**, **warning**, **info**
- Positions: **top**, **center**, **bottom**
- Auto-dismiss duration
- Haptics & vibration
- Optional action buttons (Undo, Retry, etc.)
- Drag-to-dismiss
- Toast queueing (multiple toasts show one after another)

---

# 📦 1. Add Dependency (Swift Package Manager)

1. Open **Xcode → File → Add Packages…**
2. Paste the repository URL:

```

[https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Communit-IOS_ToastSystem](https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Communit-IOS_ToastSystem)

````

3. Add the package to your app target.

---

# 🔧 2. Import Module

```swift
import ToastSystem
````

---

# 🚀 3. Setup (Required)

ToastSystem needs one shared `ToastManager` and one global `ToastView` overlay.

### Add this to your `@main` App file:

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

> ⚠️ Important:
> Both `ContentView` **and** `ToastView` MUST receive `.environmentObject(toast)`
> otherwise SwiftUI will crash.

---

# 📲 4. Use Toasts in Any View

In any screen:

```swift
@EnvironmentObject var toast: ToastManager
```

---

# 🎉 5. Toast Types & Usage Examples

ToastSystem supports these toast types:

### **✔ Success Toast**

```swift
toast.show(.success, "Operation completed successfully!")
```

### **⚠️ Warning Toast**

```swift
toast.show(.warning, "Your session is about to expire.")
```

### **❌ Error Toast**

```swift
toast.show(.error, "Something went wrong. Please try again.")
```

### **ℹ️ Info Toast**

```swift
toast.show(.info, "New update available.")
```

---

# 🎚 6. Customizing Toast

### Position (top / center / bottom)

```swift
toast.show(.info, "Centered message", position: .center)
```

### Duration + Haptics Off

```swift
toast.show(.warning, "This will show for 5 seconds", duration: 5, haptic: false)
```

### Toast with Action Button (Undo / Retry)

```swift
toast.show(
    .success,
    "Item added to cart",
    action: { cartCount -= 1 },
    actionLabel: "Undo"
)
```

---

# 📡 7. Multiple Toasts (Automatic Queue)

```swift
toast.show(.success, "Saved successfully")
toast.show(.warning, "Check your network")
toast.show(.info, "Background sync complete")
```

Toasts will show **one at a time**, in order.

---

# 🛠 8. Troubleshooting

### ❌ Crash: “No ObservableObject of type ToastManager found”

You forgot to add:

```swift
.environmentObject(toast)
```

to BOTH:

* Your root view (`ContentView`)
* Your overlay (`ToastView()`)

### ❌ Toast not showing

Ensure:

```swift
.overlay(ToastView().environmentObject(toast))
```

is inside your App file.

### ❌ No vibration

Haptics only work on a **real device**, not simulator.

---
 
