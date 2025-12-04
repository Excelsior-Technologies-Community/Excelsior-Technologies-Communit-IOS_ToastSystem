
//
//  ContentView.swift
//  ToastSystem
//
//  Created by Noman Belim on 04/12/25.
import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var toast: ToastManager
    @State private var counter = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Toast System")
                    .font(.title.bold())
                    .padding(.top, 40)
               
                // MARK: - Basic Toasts Section
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Button(" Success") {
                            toast.show(.success, "Operation completed successfully!")
                        }
                        .buttonStyle(ToastButtonStyle(color: .green))
                        Button(" Error") {
                            toast.show(.error, "Failed to connect to server")
                        }
                        .buttonStyle(ToastButtonStyle(color: .red))
                        
                        Button("  Warning") {
                            toast.show(.warning, "Your session is about to expire")
                        }
                        .buttonStyle(ToastButtonStyle(color: .orange))
                        
                        Button(" Info") {
                            toast.show(.info, "New features are available")
                        }
                        .buttonStyle(ToastButtonStyle(color: .blue))
                    }
                    
                    // MARK: - Position Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Spacer()
                            Text("Position")
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            Button("Top Position") {
                                toast.show(.info, "Toast at top", position: .top)
                            }
                            .buttonStyle(ToastButtonStyle(color: .blue))
                            
                            Button("Center Position") {
                                toast.show(.warning, "Toast at center", position: .center)
                            }
                            .buttonStyle(ToastButtonStyle(color: .orange))
                            
                            Button("Bottom Position") {
                                toast.show(.success, "Toast at bottom", position: .bottom)
                            }
                            .buttonStyle(ToastButtonStyle(color: .green))
                        }
                    }
                    
                    // MARK: - Duration & Advanced Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Spacer()
                            Text("Duration")
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        VStack(spacing: 12) {
                            Button("Long Duration") {
                                toast.show(.info, "This toast stays for 5 seconds", duration: 5.0)
                            }
                            .buttonStyle(ToastButtonStyle(color: .blue))
                            
                            Button(" Vibration Alert") {
                                // Strong error-style alert with haptic + vibration sound
                                toast.show(.error, "Vibration alert triggered!", duration: 3.0, position: .center)
                            }
                            .buttonStyle(ToastButtonStyle(color: .red))
                            
                            Button("With Action") {
                                toast.show(
                                    .success,
                                    "Item added to cart",
                                    duration: 4.0,
                                    action: {
                                        counter += 1
                                        print("Undo tapped! Counter: \(counter)")
                                    },
                                    actionLabel: "Undo"
                                )
                            }
                            .buttonStyle(ToastButtonStyle(color: .green))
                            
                            Button("Multiple Toasts") {
                                toast.show(.success, "First toast")
                                toast.show(.warning, "Second toast")
                                toast.show(.error, "Third toast")
                            }
                            .buttonStyle(ToastButtonStyle(color: .gray))
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - ToastButtonStyle
struct ToastButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(ToastManager())
}
