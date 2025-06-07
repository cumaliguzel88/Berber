import SwiftUI

/// Alt navigasyon barı (BottomTabBar) component'i.
struct BottomTabBar: View {
    @Binding var selectedTab: Tab
    
    enum Tab: Int, CaseIterable {
        case appointments, earnings, statistics, services, profile
        
        var title: String {
            switch self {
            case .appointments: return "Randevu"
            case .earnings: return "Kazanç"
            case .statistics: return "İstatistik"
            case .services: return "Hizmetler"
            case .profile: return "Profil"
            }
        }
        var icon: String {
            switch self {
            case .appointments: return "calendar"
            case .earnings: return "creditcard"
            case .statistics: return "chart.bar"
            case .services: return "scissors"
            case .profile: return "person.crop.circle"
            }
        }
    }
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .accentColor : .gray)
                        Text(tab.title)
                            .font(.caption)
                            .foregroundColor(selectedTab == tab ? .accentColor : .gray)
                    }
                    .padding(.vertical, 6)
                }
                Spacer()
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
        .shadow(color: Color.black.opacity(0.04), radius: 2, y: -2)
    }
}

#if DEBUG
struct BottomTabBar_Previews: PreviewProvider {
    @State static var selectedTab: BottomTabBar.Tab = .appointments
    static var previews: some View {
        BottomTabBar(selectedTab: $selectedTab)
    }
}
#endif 
