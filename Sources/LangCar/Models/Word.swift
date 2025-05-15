import Foundation

public struct Word: Identifiable, Codable, Equatable {
    public let id: String            // ULID
    public let original: String      // Das Buch
    public let gender: GermanGender  // der/die/das
    public let translation: String   // Книга
    public let plural: String?       // Bücher
    public let difficulty: Difficulty
    public var lastSeen: Date?
    public var nextReviewDate: Date?
    
    public init(original: String, gender: GermanGender, translation: String, plural: String? = nil) {
        self.id = ULID().string
        self.original = original
        self.gender = gender
        self.translation = translation
        self.plural = plural
        self.difficulty = .medium
    }
}

public enum GermanGender: String, Codable {
    case masculine = "der"
    case feminine = "die"
    case neuter = "das"
}
