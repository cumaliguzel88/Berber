import Foundation
import Combine

/// İstatistik ekranı için ViewModel. Sadece UI ile ilgili logic içerir.
final class StatisticsViewModel: ObservableObject {
    // Haftanın günleri (Pazartesi-Pazar)
    let weekDays: [String] = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    
    // Gün bazında tamamlanan randevu sayısı (haftalık)
    @Published private(set) var completedAppointmentsPerDay: [Int] = Array(repeating: 0, count: 7)
    // Hizmet bazında tamamlanan randevu sayısı (pie chart için)
    @Published private(set) var completedAppointmentsPerService: [String: Int] = [:]
    
    // Persistent tamamlanan randevular için repository
    private let completedRepository: CompletedAppointmentsRepositoryProtocol
    private var completedAppointments: [CompletedAppointment] = []
    private var cancellables = Set<AnyCancellable>()
    
    // Performance optimization: Cache last refresh date
    private var lastRefreshDate: Date?
    private let refreshThreshold: TimeInterval = 60 // 1 dakika
    
    init(completedRepository: CompletedAppointmentsRepositoryProtocol = CompletedAppointmentsRepository()) {
        self.completedRepository = completedRepository
        loadCompletedAppointments()
        calculateWeeklyStats()
        calculateServiceStats()
    }
    
    // MARK: - Data Loading & Optimization
    
    /// Persistent repository'den tamamlanan randevuları yükle
    private func loadCompletedAppointments() {
        // Throttling: Eğer son yenileme 1 dakikadan az ise skip et
        if let lastRefresh = lastRefreshDate, 
           Date().timeIntervalSince(lastRefresh) < refreshThreshold {
            return
        }
        
        let allCompleted = completedRepository.getAll()
        
        // Sadece bu haftaya ait tamamlanan randevular
        let calendar = Calendar.current
        let now = Date()
        let weekOfYear = calendar.component(.weekOfYear, from: now)
        let year = calendar.component(.yearForWeekOfYear, from: now)
        
        completedAppointments = allCompleted.filter { appt in
            calendar.component(.weekOfYear, from: appt.startDate) == weekOfYear &&
            calendar.component(.yearForWeekOfYear, from: appt.startDate) == year
        }
        
        lastRefreshDate = Date()
    }
    
    // MARK: - Statistics Calculations
    
    /// Haftanın günlerine göre tamamlanan randevu sayılarını hesapla (optimized)
    private func calculateWeeklyStats() {
        var counts = Array(repeating: 0, count: 7)
        let calendar = Calendar.current
        
        // Batch processing ile optimizasyon
        for appt in completedAppointments {
            let weekday = calendar.component(.weekday, from: appt.startDate)
            // Swift'te .weekday: 1=Pazar, 2=Pazartesi, ... 7=Cumartesi
            let index = (weekday + 5) % 7 // 0=Pazartesi, 6=Pazar
            if index >= 0 && index < 7 {
                counts[index] += 1
            }
        }
        
        // Ana thread'de güncelle
        DispatchQueue.main.async { [weak self] in
            self?.completedAppointmentsPerDay = counts
        }
    }
    
    /// Hizmet bazında tamamlanan randevu sayılarını hesapla (pie chart için)
    private func calculateServiceStats() {
        var dict: [String: Int] = [:]
        
        // Dictionary grouping ile optimize edilmiş hesaplama
        for appt in completedAppointments {
            dict[appt.serviceTitle, default: 0] += 1
        }
        
        // Ana thread'de güncelle
        DispatchQueue.main.async { [weak self] in
            self?.completedAppointmentsPerService = dict
        }
    }
    
    // MARK: - Public Interface
    
    /// Tüm istatistikleri güncelle (UI tetiklemek için)
    func refresh() {
        // Background queue'da hesaplama yap
        Task {
            await refreshAsync()
        }
    }
    
    @MainActor
    private func refreshAsync() async {
        // Background thread'de veri işleme
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                self?.loadCompletedAppointments()
            }
            
            group.addTask { [weak self] in
                self?.calculateWeeklyStats()
            }
            
            group.addTask { [weak self] in
                self?.calculateServiceStats()
            }
        }
    }
    
    // MARK: - Memory Management
    
    deinit {
        cancellables.removeAll()
    }
} 