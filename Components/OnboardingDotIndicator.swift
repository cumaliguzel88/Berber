import SwiftUI

/// Onboarding için dot indicator component'i.
struct OnboardingDotIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \ .self) { index in
                Circle()
                    .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct OnboardingDotIndicator_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingDotIndicator(numberOfPages: 4, currentPage: 1)
    }
}
#endif 