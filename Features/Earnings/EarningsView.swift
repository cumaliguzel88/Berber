import SwiftUI

struct EarningsView: View {
    @EnvironmentObject private var viewModel: EarningsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            EarningsCard(
                title: "Günlük Kazanç",
                amount: viewModel.dailySummary.totalAmount,
                count: viewModel.dailySummary.count,
                emoji: "☀️"
            )
            EarningsCard(
                title: "Haftalık Kazanç",
                amount: viewModel.weeklySummary.totalAmount,
                count: viewModel.weeklySummary.count,
                emoji: "📅"
            )
            EarningsCard(
                title: "Aylık Kazanç",
                amount: viewModel.monthlySummary.totalAmount,
                count: viewModel.monthlySummary.count,
                emoji: "📆"
            )
            Divider()
            TrophyScrollSection(
                totalShaveCount: viewModel.totalShaveCount,
                earnedTrophyIndexes: viewModel.earnedTrophyIndexes
            )
            Spacer()
        }
        .padding(.top, 32)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Kazançlar")
        .onAppear {
            // Performans: Sadece görünür olduğunda veri yükle
            viewModel.loadEarnings()
        }
    }
}

#if DEBUG
struct EarningsView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsView()
            .environmentObject(EarningsViewModel())
    }
}
#endif 