//
//  ToastSystem.swift
//  ToastSystem (Swift Package)
//
//  Public API so other projects can use the toast system via SPM.
//

import Foundation
import SwiftUI
import Combine
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
        guard !isProcessing, !toastQueue.isEmpty else { return }
        
        isProcessing = true
        let config = toastQueue.removeFirst()
        
        displayToast(config)
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
    
    private func playHapticSound(for type: ToastType) {
        // These IDs are used for short vibration / sound patterns.
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
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if toast.isShowing, let config = toast.currentToast {
                toastContent(config)
                    .position(
                        x: UIScreen.main.bounds.width / 2,
                        y: yPosition(for: config.position)
                    )
            }
        }
    }
    
    @ViewBuilder
    private func toastContent(_ config: ToastConfig) -> some View {
        HStack(spacing: 12) {
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
        .padding(.horizontal, 16)
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if (config.position == .top && value.translation.height < 0) ||
                       (config.position == .bottom && value.translation.height > 0) {
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
    
    private func yPosition(for position: ToastPosition) -> CGFloat {
        switch position {
        case .top:
            return 80 + dragOffset
        case .center:
            return UIScreen.main.bounds.height / 2
        case .bottom:
            return UIScreen.main.bounds.height - 100 + dragOffset
        }
    }
}


