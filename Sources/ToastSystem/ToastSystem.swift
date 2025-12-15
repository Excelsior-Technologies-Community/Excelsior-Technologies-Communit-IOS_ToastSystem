//
//  ToastSystem.swift
//  ToastSystem (Swift Package)
//
//
//
import SwiftUI
import Foundation
import SwiftUI
import AudioToolbox
import UIKit

// MARK: - Public Toast Models

public enum ToastType {
    case success, error, warning, info
    
    public var color: Color {
        switch self {
        case .success: return .green
        case .error:   return .red
        case .warning: return .orange
        case .info:    return .blue
        }
    }
}

public enum ToastPosition {
    case top, center, bottom
}

public struct ToastConfig {
    public var type: ToastType
    public var message: String
    public var duration: Double
    public var position: ToastPosition
    public var haptic: Bool
    public var action: (() -> Void)?
    public var actionLabel: String?
    
    public init(
        type: ToastType,
        message: String,
        duration: Double = 2.0,
        position: ToastPosition = .top,
        haptic: Bool = true,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.type = type
        self.message = message
        self.duration = duration
        self.position = position
        self.haptic = haptic
        self.action = action
        self.actionLabel = actionLabel
    }
}

// MARK: - Public Toast Manager

public final class ToastManager: ObservableObject {
    @Published public var currentToast: ToastConfig?
    @Published public var isShowing: Bool = false
    
    private var workItem: DispatchWorkItem?
    private var toastQueue: [ToastConfig] = []
    private var isProcessing = false
    
    public init() {}
    
    /// Enqueue and display a new toast.
    public func show(
        _ type: ToastType,
        _ message: String,
        duration: Double = 2.0,
        position: ToastPosition = .top,
        haptic: Bool = true,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        let config = ToastConfig(
            type: type,
            message: message,
            duration: duration,
            position: position,
            haptic: haptic,
            action: action,
            actionLabel: actionLabel
        )
        
        toastQueue.append(config)
        processQueue()
    }
    
    private func processQueue() {
        // Must be run on main thread to check @Published properties
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.isProcessing, !self.toastQueue.isEmpty else { return }
            
            self.isProcessing = true
            let config = self.toastQueue.removeFirst()
            
            self.displayToast(config)
        }
    }
    
    private func displayToast(_ config: ToastConfig) {
        currentToast = config
        
        if config.haptic {
            triggerHaptic(for: config.type)
            playHapticSound(for: config.type)
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isShowing = true
        }
        
        workItem?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        workItem = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + config.duration, execute: task)
    }
    
    // MARK: - Public API
    
    /// Dismiss the current toast immediately.
    public func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isShowing = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.currentToast = nil
            self?.isProcessing = false
            self?.processQueue()
        }
    }
    
    // MARK: - Haptics & Sound
    
    private func triggerHaptic(for type: ToastType) {
        // UI Haptics need to be run on the main thread
        DispatchQueue.main.async {
            switch type {
            case .success:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            case .error:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            case .warning:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            case .info:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
    
    private func playHapticSound(for type: ToastType) {
        let soundID: SystemSoundID
        
        switch type {
        case .success:
            soundID = 1519   // light tap
        case .error:
            soundID = kSystemSoundID_Vibrate // full vibration
        case .warning:
            soundID = 1520   // medium impact
        case .info:
            soundID = 1104   // "tink" sound
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
}


// MARK: - Public Toast View

public struct ToastView: View {
    @EnvironmentObject public var toast: ToastManager
    @State private var dragOffset: CGFloat = 0
    
    // Approximate toast height for center/bottom calculation (adjust as needed)
    private let toastApproximateHeight: CGFloat = 60
    private let topSafeAreaOffset: CGFloat = 45 // For status bar / notch
    private let bottomSafeAreaOffset: CGFloat = 20 // For home indicator
    
    public init() {}
    
    public var body: some View {
        // Using ZStack with .top alignment for correct positioning with offset
        ZStack(alignment: .top) {
            if toast.isShowing, let config = toast.currentToast {
                toastContent(config)
                    // The .frame(maxWidth: .infinity) ensures the toast is centered
                    // horizontally within the ZStack's default center alignment.
                    .frame(maxWidth: .infinity)
                    // .offset handles the vertical positioning from the ZStack's top edge.
                    .offset(y: verticalOffset(for: config.position))
                    .transition(.move(edge: getEdge(for: config.position)))
            }
        }
    }
    
    @ViewBuilder
    private func toastContent(_ config: ToastConfig) -> some View {
        HStack(alignment: .center ,spacing: 12) {
            Text(config.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(3)
            
            Spacer()
            
            if let action = config.action, let label = config.actionLabel {
                Button(action: {
                    action()
                    toast.dismiss()
                }) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Button(action: {
                toast.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            config.type.color.opacity(0.9),
                            config.type.color
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: config.type.color.opacity(0.3), radius: 10, y: 5)
        )
        // Ensure horizontal padding is applied *outside* the toast background
        .padding(.horizontal, 16)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow drag in the direction that dismisses the toast
                    if (config.position == .top && value.translation.height < 0) ||
                       (config.position == .bottom && value.translation.height > 0) ||
                       (config.position == .center) { // Allow dragging center toasts both ways
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if abs(value.translation.height) > 50 {
                        toast.dismiss()
                    }
                    withAnimation(.spring()) {
                        dragOffset = 0
                    }
                }
        )
    }
    
    // MARK: - Positioning Logic (FIXED)
    
    private func getEdge(for position: ToastPosition) -> Edge {
        switch position {
        case .top: return .top
        case .center: return .leading // Arbitrary for center
        case .bottom: return .bottom
        }
    }

    private func verticalOffset(for position: ToastPosition) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch position {
        case .top:
            // 1. Initial offset from the top of the screen + drag
            return topSafeAreaOffset + dragOffset
            
        case .center:
            // 1. Calculate the center position
            // 2. Adjust up by half the toast's estimated height
            return (screenHeight / 2) - (toastApproximateHeight / 2) + dragOffset
            
        case .bottom:
            // 1. Full height of screen
            // 2. Subtract the toast's height
            // 3. Subtract safe area/padding (16 + 20)
            return screenHeight - (toastApproximateHeight + bottomSafeAreaOffset + 16) + dragOffset
        }
    }
}
