import Foundation
import Combine

/// Hizmetler ekranı için ViewModel. Tüm veri işlemleri burada.
final class ServicesViewModel: ObservableObject {
    @Published private(set) var services: [Service] = []
    @Published var alertPresented: Bool = false
    @Published var editingService: Service? = nil
    @Published var showDeleteConfirmation: Bool = false
    
    private let storageKey = "services_storage_key"
    private var cancellables = Set<AnyCancellable>()
    private var serviceToDelete: Service? = nil
    
    init() {
        loadServices()
    }
    
    // Servisleri hafızadan yükle
    func loadServices() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Service].self, from: data) else {
            services = []
            return
        }
        services = decoded
    }
    // Servisleri hafızaya kaydet
    private func saveServices() {
        if let data = try? JSONEncoder().encode(services) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    // Yeni servis ekle
    func addService(title: String, price: Double) {
        let intPrice = Int(price)
        let newService = Service(title: title, price: Double(intPrice))
        services.append(newService)
        saveServices()
    }
    // Servis silme onayı iste
    func requestDeleteService(_ service: Service) {
        serviceToDelete = service
        showDeleteConfirmation = true
    }
    // Servisi sil (onaylandıktan sonra)
    func confirmDeleteService() {
        guard let service = serviceToDelete else { return }
        services.removeAll { $0.id == service.id }
        saveServices()
        serviceToDelete = nil
        showDeleteConfirmation = false
    }
    // Silme onayını iptal et
    func cancelDeleteService() {
        serviceToDelete = nil
        showDeleteConfirmation = false
    }
    // Servisi güncelle
    func updateService(_ service: Service, newTitle: String, newPrice: Double) {
        if let index = services.firstIndex(where: { $0.id == service.id }) {
            services[index].title = newTitle
            services[index].price = Double(Int(newPrice))
            saveServices()
        }
    }
    // Alert aç
    func presentAddAlert() {
        editingService = nil
        alertPresented = true
    }
    // Alert aç (güncelleme için)
    func presentEditAlert(for service: Service) {
        editingService = service
        alertPresented = true
    }
    // Alert kapat
    func dismissAlert() {
        alertPresented = false
        editingService = nil
    }
} 