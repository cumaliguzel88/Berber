import SwiftUI

@main
struct berbersApp: App {
    @StateObject private var notificationVM = AppNotificationViewModel()
    @State private var isOnboardingCompleted = OnboardingViewModel().isOnboardingCompleted
    @State private var showSplash = true // Splash ekranı kontrolü
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(2)
                } else {
                    if isOnboardingCompleted {
                        ContentView()
                            .onAppear {
                                notificationVM.requestNotificationPermission()
                            }
                    } else {
                        OnboardingView(isCompleted: $isOnboardingCompleted)
                    }
                }
            }
            .onAppear {
                // Splash ekranı 1.2 saniye göster
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { showSplash = false }
                }
            }
        }
    }
} 