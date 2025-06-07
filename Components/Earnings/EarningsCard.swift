import SwiftUI

struct EarningsCard: View {
    let title: String
    let amount: Double
    let count: Int
    let emoji: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(emoji)
                    .font(.largeTitle)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "creditcard")
                        .foregroundColor(.accentColor)
                    Text("₺\(Int(amount))")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                    Text("\(count) kişi")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Spacer()
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.primary.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

#if DEBUG
struct EarningsCard_Previews: PreviewProvider {
    static var previews: some View {
        EarningsCard(title: "Günlük Kazanç", amount: 1200, count: 8, emoji: "☀️")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif 