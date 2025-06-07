import Foundation

/// İlk açılış durumunu yönetir. Kullanıcı uygulamayı ilk kez açtığında hoş geldin ekranı gösterilir.
final class FirstLaunchManager: ObservableObject {
    private let hasLaunchedBeforeKey = "has_launched_before_key"
    
    @Published var isFirstLaunch: Bool = false
    
    init() {
        checkFirstLaunch()
    }
    
    /// İlk açılış kontrolü yapar
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)
        isFirstLaunch = !hasLaunchedBefore
    }
    
    /// İlk açılış işlemini tamamlar, bir daha gösterilmez
    func completeFirstLaunch() {
        UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
        isFirstLaunch = false
    }
} 