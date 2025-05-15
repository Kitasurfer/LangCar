import Foundation

public struct Word: Identifiable, Codable, Equatable, Sendable {
    public var id: String              // ULID
    public let original: String        // Немецкое
    public let gender: GermanGender
    public let translation: String     // Русский
    public let plural: String?
    public var difficulty: Difficulty
    public var lastSeen: Date?
    public var nextReviewDate: Date?
    public var easeFactor: Double?  // for SRS

    public init(original: String,
                gender: GermanGender,
                translation: String,
                plural: String? = nil,
                difficulty: Difficulty = .medium) {
        self.id = ULID().string
        self.original = original
        self.gender = gender
        self.translation = translation
        self.plural = plural
        self.difficulty = difficulty
    }
}
