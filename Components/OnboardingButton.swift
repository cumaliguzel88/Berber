import SwiftUI

/// Onboarding için özelleştirilebilir buton component'i.
struct OnboardingButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isEnabled ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.3))
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 8)
    }
}

#if DEBUG
struct OnboardingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            OnboardingButton(title: "İleri", action: {}, isEnabled: true)
            OnboardingButton(title: "Geri", action: {}, isEnabled: false)
        }
        .padding()
    }
}
#endif 