import SwiftUI

/// İlk açılışta kullanıcıya gösterilen hoş geldin popup'ı
struct WelcomePopupView: View {
    let onCreateService: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dışarı tıklamada kapanmasın
                }
            
            // Popup content
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Content
                contentSection
                
                // Action button
                actionButton
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "scissors")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.accentColor)
            
            Text("Hoş Geldiniz!")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: 16) {
            Text("Berber uygulamasını kullanabilmek için öncelikle bir hizmet oluşturmanız gerekiyor.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Hizmetinizi oluşturduktan sonra müşterileriniz için randevu planlamaya başlayabilirsiniz.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
    
    private var actionButton: some View {
        Button(action: onCreateService) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Hizmet Oluştur")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct WelcomePopupView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePopupView(onCreateService: {})
    }
}
#endif 