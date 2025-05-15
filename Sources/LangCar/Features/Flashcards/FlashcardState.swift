import Foundation

struct FlashcardState: Equatable {
    var currentCard: Word?
    var remainingCards: [Word] = []
}
