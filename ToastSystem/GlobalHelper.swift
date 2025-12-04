//
//  GlobalHelper.swift
//  ToastSystem
//

import Foundation
import SwiftUI
import Combine
import AudioToolbox

// MARK: - Toast Models

enum ToastType {
    case success, error, warning, info
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error:   return .red
        case .warning: return .orange
        case .info:    return .blue
        }
    }
}

enum ToastPosition {
    case top, center, bottom
}

struct ToastConfig {
    var type: ToastType
    var message: String
    var duration: Double
    var position: ToastPosition
    var haptic: Bool
    var action: (() -> Void)?
    var actionLabel: String?
    
    init(type: ToastType,
         message: String,
         duration: Double = 2.0,
         position: ToastPosition = .top,
         haptic: Bool = true,
         action: (() -> Void)? = nil,
         actionLabel: String? = nil) {
        self.type = type
        self.message = message
        self.duration = duration
        self.position = position
        self.haptic = haptic
        self.action = action
        self.actionLabel = actionLabel
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    @Published var currentToast: ToastConfig?
    @Published var show: Bool = false
    
    private var workItem: DispatchWorkItem?
    private var toastQueue: [ToastConfig] = []
    private var isProcessing = false
    
    func show(_ type: ToastType,
              _ message: String,
              duration: Double = 2.0,
              position: ToastPosition = .top,
              haptic: Bool = true,
              action: (() -> Void)? = nil,
              actionLabel: String? = nil) {
        
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
            show = true
        }
        
        workItem?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        workItem = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + config.duration, execute: task)
    }
    
    // MARK: - Public API
    func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            show = false
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
        // This id's are used ffo vibration
        let soundID: SystemSoundID
        
        switch type {
        case .success:
            // Light "success" click + subtle vibration
            soundID = 1519
        case .error:
            // Strong vibration for error
            soundID = kSystemSoundID_Vibrate
        case .warning:
            // Medium impact for warning
            soundID = 1520
        case .info:
            // Gentle informational "tink" sound
            soundID = 1104
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
}

// MARK: - Toast View
struct ToastView: View {
    @EnvironmentObject var toast: ToastManager
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if toast.show, let config = toast.currentToast {
                toastContent(config)
                    .position(x: UIScreen.main.bounds.width / 2,
                             y: yPosition(for: config.position))
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
                .fill(config.type.color.gradient)
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
