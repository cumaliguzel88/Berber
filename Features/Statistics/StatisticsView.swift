import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var viewModel: StatisticsViewModel
    // Haftanın gün kısaltmaları
    private let shortDays = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Pie Chart Kartı
            CardBackground {
                VStack(spacing: 12) {
                    Text("Haftalık Yoğunluk (Pie Chart)")
                        .font(.headline)
                        .padding(.top, 8)
                    PieChartView(values: viewModel.completedAppointmentsPerDay, days: shortDays)
                        .frame(height: 200)
                }
            }
            // Bar Chart Kartı
            CardBackground {
                VStack(spacing: 12) {
                    Text("Haftalık Yoğunluk (Bar Chart)")
                        .font(.headline)
                        .padding(.top, 8)
                    BarChartView(days: shortDays, values: viewModel.completedAppointmentsPerDay)
                        .frame(height: 200)
                }
            }
            Spacer()
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear { 
            // Performans: Sadece görünür olduğunda refresh et
            viewModel.refresh() 
        }
        .navigationTitle("E-Statistik")
    }
}

// Kart arka planı için reusable component
struct CardBackground<Content: View>: View {
    let content: () -> Content
    var body: some View {
        VStack {
            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: Color.primary.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

// PieChartView: Her gün için farklı canlı renk, sadece dilim ortasında gün kısaltması
struct PieChartView: View {
    let values: [Int]
    let days: [String]
    // Her gün için canlı ve farklı renkler (beyaz yok)
    private let colors: [Color] = [
        Color(red: 0.22, green: 0.49, blue: 0.99), // Pzt - mavi
        Color(red: 0.13, green: 0.75, blue: 0.47), // Sal - yeşil
        Color(red: 1.00, green: 0.68, blue: 0.26), // Çar - turuncu
        Color(red: 0.60, green: 0.36, blue: 0.71), // Per - mor
        Color(red: 0.98, green: 0.36, blue: 0.35), // Cum - kırmızı
        Color(red: 0.99, green: 0.80, blue: 0.20), // Cmt - sarı
        Color(red: 0.26, green: 0.74, blue: 0.98)  // Paz - turkuaz
    ]
    var total: Int { values.reduce(0, +) }
    var angles: [Angle] {
        var result: [Angle] = []
        var start: Double = 0
        for v in values {
            let angle = total > 0 ? Double(v) / Double(total) * 360 : 0
            result.append(.degrees(start))
            start += angle
        }
        return result
    }
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Pasta dilimleri
                ForEach(Array(values.indices), id: \ .self) { i in
                    if values[i] > 0 {
                        let endAngle = i == values.count-1 ? .degrees(360) : angles[safe: i+1] ?? .degrees(360)
                        PieSlice(startAngle: angles[i], endAngle: endAngle)
                            .fill(colors[i % colors.count])
                            .overlay(
                                PieSlice(startAngle: angles[i], endAngle: endAngle)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .scaleEffect(1.02)
                            .animation(.easeOut(duration: 0.8), value: values)
                    }
                }
                // Her dilimin ortasında sadece gün kısaltması
                ForEach(Array(values.indices), id: \ .self) { i in
                    if values[i] > 0 {
                        let nextAngle = i == values.count-1 ? 360.0 : angles[safe: i+1]?.degrees ?? 360.0
                        let midAngle = (angles[i].degrees + (nextAngle - angles[i].degrees)/2)
                        let radius = geo.size.width * 0.32
                        let radian = (midAngle-90) * Double.pi / 180
                        let x = geo.size.width/2 + cos(radian) * radius
                        let y = geo.size.height/2 + sin(radian) * radius
                        Text(days[i])
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .position(x: x, y: y)
                            .animation(.easeOut(duration: 0.8), value: values)
                    }
                }
            }
        }
    }
}

/// Pie dilimi çizen Shape
struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle-Angle.degrees(90), endAngle: endAngle-Angle.degrees(90), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// Array safe index
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// BarChartView: Gün kısaltmaları güncellendi
struct BarChartView: View {
    let days: [String]
    let values: [Int]
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(days.indices), id: \ .self) { i in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentColor)
                            .frame(height: CGFloat(values[i]) * 6)
                        Text(days[i])
                            .font(.caption2)
                            .frame(maxWidth: 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#if DEBUG
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
#endif 