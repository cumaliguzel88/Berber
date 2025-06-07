//
//  ContentView.swift
//  berbers
//
//  Created by Cumali Güzel on 4.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: BottomTabBar.Tab = .appointments
    
    // Performance optimization: Lazy loading için ViewModels
    @StateObject private var appointmentsViewModel = AppointmentsViewModel()
    @StateObject private var earningsViewModel = EarningsViewModel()
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @StateObject private var servicesViewModel = ServicesViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    // İlk açılış yönetimi
    @StateObject private var firstLaunchManager = FirstLaunchManager()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .appointments:
                        AppointmentsView()
                            .environmentObject(appointmentsViewModel)
                            .environmentObject(servicesViewModel)
                    case .earnings:
                        EarningsView()
                            .environmentObject(earningsViewModel)
                    case .statistics:
                        StatisticsView()
                            .environmentObject(statisticsViewModel)
                    case .services:
                        ServicesView()
                            .environmentObject(servicesViewModel)
                    case .profile:
                        ProfileView()
                            .environmentObject(profileViewModel)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                
                BottomTabBar(selectedTab: $selectedTab)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            
            // İlk açılış hoş geldin popup'ı
            if firstLaunchManager.isFirstLaunch {
                WelcomePopupView {
                    handleWelcomeAction()
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(1000)
            }
        }
        .onAppear {
            // İlk yükleme optimizasyonu
            setupPerformanceOptimizations()
        }
    }
    
    // MARK: - Welcome Action Handler
    
    /// Hoş geldin popup'ındaki "Hizmet Oluştur" butonu tıklandığında çağrılır
    private func handleWelcomeAction() {
        withAnimation(.easeInOut(duration: 0.5)) {
            // Önce popup'ı kapat
            firstLaunchManager.completeFirstLaunch()
            
            // Services tab'ına geç
            selectedTab = .services
            
            // Kısa bir delay sonra add service alert'ini göster
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                servicesViewModel.presentAddAlert()
            }
        }
    }
    
    // MARK: - Performance Optimizations
    
    private func setupPerformanceOptimizations() {
        // Memory warning observer
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleMemoryWarning()
        }
    }
    
    private func handleMemoryWarning() {
        // Aktif olmayan tab'ların gereksiz verilerini temizle
        switch selectedTab {
        case .appointments:
            // Statistics ve Profile cache'lerini temizle
            statisticsViewModel.refresh()
        case .statistics:
            // Appointments completion status'u güncelle
            appointmentsViewModel.updateCompletionStatuses()
        default:
            break
        }
    }
}

#Preview {
    ContentView()
}
