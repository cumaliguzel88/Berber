import SwiftUI

struct ServiceCard: View {
    let service: Service
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.title)
                    .font(.headline)
                Text("₺\(Int(service.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.accentColor)
            }
            .accessibilityLabel("Hizmeti Güncelle")
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .accessibilityLabel("Hizmeti Sil")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
        .shadow(color: Color.primary.opacity(0.08), radius: 2, y: 1)
        .padding(.horizontal, 8)
    }
}

#if DEBUG
struct ServiceCard_Previews: PreviewProvider {
    static var previews: some View {
        ServiceCard(service: Service(title: "Saç Kesimi", price: 150), onEdit: {}, onDelete: {})
            .padding()
    }
}
#endif 