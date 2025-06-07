import SwiftUI

struct TrophyCard: View {
    let count: Int
    let desc: String
    let reached: Bool
    var width: CGFloat = 180
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(count) tıraş")
                    .font(.headline)
                    .foregroundColor(reached ? .primary : .gray)
                Spacer()
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(reached ? .yellow : .gray.opacity(0.5))
            }
            Text(desc)
                .font(.caption)
                .foregroundColor(reached ? .secondary : .gray.opacity(0.7))
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(reached ? Color(.systemBackground) : Color(.secondarySystemBackground))
                .shadow(color: reached ? Color.black.opacity(0.08) : .clear, radius: 4, x: 0, y: 2)
        )
        .opacity(reached ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: reached)
    }
}

#if DEBUG
struct TrophyCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TrophyCard(count: 10,
                       desc: "Bugünkü kahve parası çıktı, devam!",
                       reached: true)
            TrophyCard(count: 25,
                       desc: "Jileti eline yeni aldın ama bilek hafiften kıpırdıyor.",
                       reached: false)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
 