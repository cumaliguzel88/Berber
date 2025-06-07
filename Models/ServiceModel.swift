import Foundation

struct Service: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var price: Double
    
    init(id: UUID = UUID(), title: String, price: Double) {
        self.id = id
        self.title = title
        self.price = price
    }
} 