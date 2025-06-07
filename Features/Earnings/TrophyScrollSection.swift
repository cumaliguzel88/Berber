import SwiftUI

struct TrophyScrollSection: View {
    let totalShaveCount: Int
    let earnedTrophyIndexes: [Int]
    
    private let trophies: [(count: Int, desc: String)] = [
        (10, "Bugünkü kahve parası çıktı, devam!"),
        (25, "Jileti eline yeni aldın ama bilek hafiften kıpırdıyor."),
        (50, "50 kafa gördün, aynaya bile başka bakıyorsun artık."),
        (80, "Müşteriler 'Bir daha geliriz' demeye başladı. Güzel sinyaller."),
        (100, "Kirası çıkar bu gidişle, boşuna mı uğraşıyoruz!"),
        (150, "Bilekten makas sesi geliyor. Duyuyoruz yani."),
        (200, "Çıraklara gözün kayıyor. 'Ben de bir zamanlar...' moduna girdin."),
        (300, "Günde 10 kafa kesiyorsan, bir gün Range Rover da kesersin."),
        (400, "Her saçtan hikâye, her jiletten iz var artık sende."),
        (500, "Bir E300 hayalin vardı sanki... Yavaştan gerçekleşiyor gibi."),
        (600, "Şu makasın kulpu var ya... Altın gibi değerli artık."),
        (700, "Artık insanlar seni öneriyor. 'Ben ona gidiyorum' diyorlar."),
        (800, "Bir günde 15 kafa. Yoruldun ama o para tatlı."),
        (900, "Fön makinesi yansa da durmazsın. Az kaldı, sabret."),
        (1000, "Bin dediğin ne ki? Sen zaten günlük tura çıkıyorsun."),
        (1100, "Mahallede senin adını bilmeyen yok. Bir de çaycı tanıyor."),
        (1200, "Tıraş yaparken fonda rap açma, sen zaten beat gibisin."),
        (1300, "Cuma sabahı gibi bereketli gidiyorsun. Nazar değmesin."),
        (1400, "Çıraklar artık sana bakarak jilet tutuyor."),
        (1500, "Bu makas seni değil, sen onu taşıyorsun. Yolun açık, başı dik!")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 18) {
                ForEach(0..<trophies.count, id: \.self) { idx in
                    let reached = earnedTrophyIndexes.contains(idx)
                    TrophyCard(
                        count: trophies[idx].count,
                        desc: trophies[idx].desc,
                        reached: reached,
                        width: 260
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }
} 