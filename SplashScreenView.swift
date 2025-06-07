import SwiftUI

/// Uygulama açılışında görünen Splash Screen. Sade, animasyonlu ve sistem makas ikonu ile.
struct SplashScreenView: View {
    @State private var opacity: Double = 0
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack {
                Spacer()
                VStack(spacing: 18) {
                    Image(systemName: "scissors")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)
                        .shadow(radius: 8)
                    Text("Berber")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
                Spacer()
                // Alt bilgi en alta sabit
                Text("GuzelTech tarafından 2025 yılında geliştirildi")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) {
                    opacity = 1
                }
            }
        }
    }
}

#if DEBUG
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
#endif 
