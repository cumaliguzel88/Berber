import SwiftUI

/// Onboarding ekranı için ViewModel. Sadece UI state ve logic içerir.
final class OnboardingViewModel: ObservableObject {
    // Onboarding ekranlarının verisi
    struct OnboardingPage: Identifiable, Equatable {
        let id = UUID()
        let icon: String
        let title: String
        let description: String
    }
    
    // Tüm onboarding sayfaları
    let pages: [OnboardingPage] = [
        OnboardingPage(icon: "calendar.badge.plus", title: "Randevularınızı kolayca yönetin", description: "Berber Randevularınızı bir dokunuşla oluşturun, düzenleyin ve takip edin."),
        OnboardingPage(icon: "bell.badge", title: "Zamanında bildirimler", description: "Randevularınızdan önce bildirimler alarak hiçbir randevuyu kaçırmayın."),
        OnboardingPage(icon: "chart.bar.xaxis", title: "Kazançlarınızı takip edin", description: "Günlük, haftalık ve aylık kazançlarınızı görüntüleyin ve gelirlerinizi analiz edin."),
        OnboardingPage(icon: "scissors", title: "Başlayalım", description: "Berber randevusu uygulaması ile işinizi daha verimli hale getirin.")
    ]
    
    // Şu anki sayfa index'i
    @Published var currentPage: Int = 0
    
    // Geri butonu aktif mi?
    var canGoBack: Bool {
        currentPage > 0
    }
    // İleri butonu aktif mi?
    var canGoForward: Bool {
        currentPage < pages.count - 1
    }
    // Son sayfa mı?
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    // İleri butonunun başlığı
    var nextButtonTitle: String {
        isLastPage ? "Başla" : "İleri"
    }
    // Geri butonunun başlığı
    var backButtonTitle: String {
        "Geri"
    }
    // İleri butonuna tıklandığında
    func goForward() {
        guard canGoForward else { return }
        currentPage += 1
    }
    // Geri butonuna tıklandığında
    func goBack() {
        guard canGoBack else { return }
        currentPage -= 1
    }
    // Swipe ile sayfa değiştirildiğinde
    func setPage(_ index: Int) {
        guard index >= 0 && index < pages.count else { return }
        currentPage = index
    }
    
    private let onboardingKey = "onboarding_completed_key"

    var isOnboardingCompleted: Bool {
        UserDefaults.standard.bool(forKey: onboardingKey)
    }

    func setOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
} 