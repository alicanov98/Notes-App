import Foundation

struct Note: Codable {
    let id: UUID
    let title: String
    let text: String
    let createdAt: Date
}
