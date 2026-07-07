import Foundation

struct CocktailEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var recipe: String
    var venue: String
    var rating: String
    var dateAdded: Date = Date()
}

struct AppSettings: Codable, Equatable {
    var categoryToggleOne: Bool = true
    var categoryToggleTwo: Bool = true
}
