import Foundation
import Combine

/// AppointmentsViewModel: Tüm randevu işlemlerinin mantığını yönetir. MVVM, SOLID ve Clean Code prensiplerine uygundur.
final class AppointmentsViewModel: ObservableObject {
    @Published private(set) var appointments: [Appointment] = []
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var showBottomSheet: Bool = false
    @Published private(set) var appointmentsForSelectedDate: [Appointment] = []
    @Published var showDeleteConfirmation: Bool = false
    
    private let storageKey = "appointments_storage_key"
    private var cancellables = Set<AnyCancellable>()
    private var appointmentToDelete: Appointment? = nil
    
    // Dependency injection ile singleton yerine protokol kullanımı
    private let earningsViewModel: EarningsViewModel
    private let notificationService: NotificationServiceProtocol
    private let completedRepository: CompletedAppointmentsRepositoryProtocol
    private lazy var scheduleAppointmentUseCase = ScheduleAppointmentUseCase(notificationService: notificationService)
    
    init(earningsViewModel: EarningsViewModel = EarningsViewModel(), 
         notificationService: NotificationServiceProtocol = NotificationService(),
         completedRepository: CompletedAppointmentsRepositoryProtocol = CompletedAppointmentsRepository()) {
        self.earningsViewModel = earningsViewModel
        self.notificationService = notificationService
        self.completedRepository = completedRepository
        
        loadAppointments()
        updateCompletionStatuses()
        setupSelectedDateObserver()
    }
    
    // MARK: - Data Loading
    
    // Randevuları hafızadan yükle
    private func loadAppointments() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Appointment].self, from: data) else {
            appointments = []
            updateAppointmentsForSelectedDate()
            return
        }
        appointments = decoded
        updateAppointmentsForSelectedDate()
    }
    
    // Randevuları hafızaya kaydet
    private func saveAppointments() {
        if let data = try? JSONEncoder().encode(appointments) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // MARK: - Performance Optimizations
    
    // Seçili tarihin değiştiğinde otomatik güncelleme
    private func setupSelectedDateObserver() {
        $selectedDate
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main) // UI debounce
            .removeDuplicates { date1, date2 in 
                Calendar.current.isDate(date1, inSameDayAs: date2) // Aynı gün kontrolü
            }
            .sink { [weak self] newDate in
                print("📅 Tarih değişti: \(newDate)")
                self?.updateAppointmentsForSelectedDate()
            }
            .store(in: &cancellables)
        
        // İlk yükleme
        updateAppointmentsForSelectedDate()
    }
    
    // Seçili güne ait randevuları güncelle (performans için cached)
    private func updateAppointmentsForSelectedDate() {
        let calendar = Calendar.current
        appointmentsForSelectedDate = appointments
            .filter { calendar.isDate($0.startDate, inSameDayAs: selectedDate) }
            .sorted { $0.startDate < $1.startDate }
    }
    
    // MARK: - Business Logic
    
    // Randevu ekle (çakışma kontrolü ile)
    /// Çakışma: Yeni randevu mevcut bir randevunun bitiş saatine tam eşitse çakışma sayılmaz.
    /// Returns: (success: Bool, errorMessage: String?) - Başarı durumu ve hata mesajı
    func addAppointment(customerName: String, service: Service, duration: Int, startDate: Date) -> (Bool, String?) {
        let newEndDate = Calendar.current.date(byAdding: .minute, value: duration, to: startDate) ?? startDate
        
        // Çakışma kontrolü: [startDate, newEndDate) aralığı, mevcut randevularla kesişiyor mu?
        if let conflict = appointmentsForSelectedDate.first(where: { appt in
            let apptStart = appt.startDate
            let apptEnd = appt.endDate
            // Sadece tam bitiş anında başlama serbest, diğer tüm çakışmalar engellenir
            return (startDate < apptEnd && newEndDate > apptStart)
        }) {
            // Çakışan randevunun saat bilgilerini formatla
            let conflictStartTime = formatTime(conflict.startDate)
            let conflictEndTime = formatTime(conflict.endDate)
            
            let errorMessage = "Bu saatte randevu oluşturamazsınız!\n\n\(conflict.customerName) isimli müşterinin \(conflictStartTime) - \(conflictEndTime) arasında randevusu bulunmaktadır.\n\nLütfen randevu listesini kontrol edip başka uygun bir zamana randevu oluşturunuz."
            return (false, errorMessage)
        }
        
        let appointment = Appointment(customerName: customerName, service: service, duration: duration, startDate: startDate)
        appointments.append(appointment)
        saveAppointments()
        updateAppointmentsForSelectedDate()
        
        // Bildirim planla
        scheduleAppointmentUseCase.execute(appointment: appointment)
        return (true, nil)
    }
    
    // Randevu silme onayı iste
    func requestDeleteAppointment(_ appointment: Appointment) {
        appointmentToDelete = appointment
        showDeleteConfirmation = true
    }
    
    // Randevu sil (onaylandıktan sonra)
    func confirmDeleteAppointment() {
        guard let appointment = appointmentToDelete else { return }
        appointments.removeAll { $0.id == appointment.id }
        saveAppointments()
        updateAppointmentsForSelectedDate()
        appointmentToDelete = nil
        showDeleteConfirmation = false
    }
    
    // Silme onayını iptal et
    func cancelDeleteAppointment() {
        appointmentToDelete = nil
        showDeleteConfirmation = false
    }
    
    // Randevu tamamlanma durumlarını güncelle
    func updateCompletionStatuses() {
        let now = Date()
        var hasChanges = false
        
        for i in appointments.indices {
            let wasCompleted = appointments[i].isCompleted
            appointments[i].isCompleted = now > appointments[i].endDate
            
            if !wasCompleted && appointments[i].isCompleted {
                // Kazanç kaydı ekle
                earningsViewModel.addEarningIfNeeded(for: appointments[i])
                // İstatistik için persistent kayıt ekle
                completedRepository.add(appointments[i])
                hasChanges = true
            }
        }
        
        if hasChanges {
            saveAppointments()
            updateAppointmentsForSelectedDate()
        }
    }
    
    // Randevu güncelle
    func updateAppointment(_ appointment: Appointment, newName: String, newService: Service, newDuration: Int, newStartDate: Date) {
        guard let index = appointments.firstIndex(where: { $0.id == appointment.id }) else { return }
        
        let newEndDate = Calendar.current.date(byAdding: .minute, value: newDuration, to: newStartDate) ?? newStartDate
        appointments[index].customerName = newName
        appointments[index].service = newService
        appointments[index].duration = newDuration
        appointments[index].startDate = newStartDate
        appointments[index].endDate = newEndDate
        appointments[index].isCompleted = Date() > newEndDate
        
        saveAppointments()
        updateAppointmentsForSelectedDate()
    }
    
    // MARK: - Helper Functions
    
    // Saat formatı için yardımcı fonksiyon
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
} 