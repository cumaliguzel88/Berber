import SwiftUI

struct AddAppointmentSheet: View {
    @Binding var isPresented: Bool
    let services: [Service]
    let onAdd: (String, Service, Int, Date) -> (Bool, String?)
    var initialName: String? = nil
    var initialService: Service? = nil
    var initialDuration: Int? = nil
    var initialStartDate: Date? = nil
    let selectedDate: Date
    
    @State private var customerName: String = ""
    @State private var selectedService: Service?
    @State private var selectedDuration: Int = 30
    @State private var startTime: Date = Date()
    @State private var showValidationError: Bool = false
    @State private var showConflictAlert: Bool = false
    @State private var conflictMessage: String = ""
    
    private let durations = [10, 30, 45, 60]
    
    var body: some View {
        NavigationView {
            Form {
                customerSection
                serviceSection
                durationSection
                timeSection
                if showValidationError {
                    Text("Lütfen tüm alanları doldurun.")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle(initialName == nil ? "Yeni Randevu" : "Randevuyu Güncelle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(initialName == nil ? "Kaydet" : "Güncelle") {
                        saveAppointment()
                    }
                }
            }
            .alert("Randevu Çakışması", isPresented: $showConflictAlert) {
                Button("Tamam") { 
                    // Alert kapandığında hiçbir şey yapma, sheet açık kalsın
                }
            } message: {
                Text(conflictMessage)
            }
            .onAppear {
                if let initialName = initialName {
                    customerName = initialName
                }
                if let initialService = initialService {
                    selectedService = initialService
                }
                if let initialDuration = initialDuration {
                    selectedDuration = initialDuration
                }
                if let initialStartDate = initialStartDate {
                    startTime = initialStartDate
                }
                if selectedService == nil, let first = services.first {
                    selectedService = first
                }
            }
        }
    }
    
    /// Randevu kaydetme işlemi - çakışma kontrolü ile
    private func saveAppointment() {
        guard let service = selectedService, !customerName.isEmpty else {
            showValidationError = true
            return
        }
        
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let combinedDate = calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: selectedDay) ?? selectedDay
        
        let result = onAdd(customerName, service, selectedDuration, combinedDate)
        
        if result.0 {
            // Başarılı, sheet'i kapat
            isPresented = false
        } else if let errorMessage = result.1 {
            // Çakışma var, alert göster
            conflictMessage = errorMessage
            showConflictAlert = true
        }
    }
    
    private var customerSection: some View {
        Section(header: Text("Müşteri Bilgisi")) {
            TextField("Ad Soyad", text: $customerName)
                .autocapitalization(.words)
        }
    }
    private var serviceSection: some View {
        Section(header: Text("Hizmet Seçimi")) {
            if services.isEmpty {
                Text("Henüz hizmet eklenmemiş")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                Picker("Hizmet", selection: $selectedService) {
                    ForEach(services) { service in
                        Text("\(service.title) (₺\(Int(service.price)))").tag(Optional(service))
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    private var durationSection: some View {
        Section(header: Text("Süre")) {
            Picker("Süre", selection: $selectedDuration) {
                ForEach(durations, id: \.self) { d in
                    Text("\(d) dk").tag(d)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    private var timeSection: some View {
        Section(header: Text("Başlangıç Saati")) {
            DatePicker("Saat", selection: $startTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
        }
    }
}

#if DEBUG
struct AddAppointmentSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddAppointmentSheet(
            isPresented: .constant(true),
            services: [Service(title: "Saç Sakal", price: 600)],
            onAdd: { _,_,_,_ in (true, nil) },
            selectedDate: Date()
        )
    }
}
#endif 