import SwiftUI

/// Onboarding ana ekranı. MVVM, SOLID ve Clean Code prensiplerine uygun.
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @GestureState private var dragOffset: CGFloat = 0
    @Binding var isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 32)
            // İkon
            Image(systemName: viewModel.pages[viewModel.currentPage].icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
                .padding(.bottom, 8)
                .accessibilityHidden(true)
            // Başlık
            Text(viewModel.pages[viewModel.currentPage].title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            // Açıklama
            Text(viewModel.pages[viewModel.currentPage].description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
            // Dot Indicator
            OnboardingDotIndicator(numberOfPages: viewModel.pages.count, currentPage: viewModel.currentPage)
            // Butonlar
            HStack(spacing: 12) {
                if viewModel.canGoBack {
                    OnboardingButton(title: viewModel.backButtonTitle, action: {
                        withAnimation { viewModel.goBack() }
                    }, isEnabled: viewModel.canGoBack)
                }
                OnboardingButton(title: viewModel.nextButtonTitle, action: {
                    withAnimation {
                        if viewModel.isLastPage {
                            viewModel.setOnboardingCompleted()
                            isCompleted = true
                        } else {
                            viewModel.goForward()
                        }
                    }
                }, isEnabled: true)
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width < -50 {
                        // Sağa kaydır: ileri
                        withAnimation { viewModel.goForward() }
                    } else if value.translation.width > 50 {
                        // Sola kaydır: geri
                        withAnimation { viewModel.goBack() }
                    }
                }
        )
        .animation(.easeInOut, value: viewModel.currentPage)
        .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isCompleted: .constant(false))
    }
}
#endif 