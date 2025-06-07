import SwiftUI

struct AppointmentCard: View {
    let appointment: Appointment
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text(appointment.isCompleted ? "✅" : "💈")
                        .font(.title)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(appointment.customerName)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(appointment.service.title)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.accentColor)
                            Text("Süre: \(appointment.duration) dk")
                                .font(.subheadline)
                            Image(systemName: "calendar")
                                .foregroundColor(.accentColor)
                            Text("\(formattedTime(appointment.startDate)) - \(formattedTime(appointment.endDate))")
                                .font(.subheadline)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "creditcard")
                                .foregroundColor(.accentColor)
                            Text("₺\(Int(appointment.service.price))")
                                .font(.subheadline)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.accentColor)
                            Text(formattedDate(appointment.startDate))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button(action: onEdit) {
                        Text("Düzenle")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 14)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    .accessibilityLabel("Randevuyu Güncelle")
                }
                if appointment.isCompleted {
                    Text("Tamamlandı")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .cornerRadius(8)
                        .padding(.top, 4)
                }
                Button(action: onDelete) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Sil")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .accessibilityLabel("Randevuyu Sil")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 8)
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

#if DEBUG
struct AppointmentCard_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentCard(
            appointment: Appointment(
                customerName: "Ali Veli",
                service: Service(title: "Saç & Sakal", price: 500),
                duration: 45,
                startDate: Date()
            ),
            onDelete: {},
            onEdit: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif 