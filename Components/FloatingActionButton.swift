import SwiftUI

/// Sağ alt köşede konumlanan Floating Action Button component'i.
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(22)
                .background(Circle().fill(Color.accentColor))
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel("Yeni Hizmet Ekle")
    }
}

#if DEBUG
struct FloatingActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground)
            FloatingActionButton(icon: "plus", action: {})
        }
    }
}
#endif 