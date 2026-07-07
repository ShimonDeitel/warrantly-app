import Foundation

struct Warranty: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var customer: String = ""
    var expiration: Date = Date()
    var notes: String = ""
    var dateAdded: Date = Date()
}
