import Foundation

struct QuizQuestion: Equatable {
    let id: String
    let word: Word
    let options: [String]
    let correctAnswer: String
    
    init(word: Word, options: [String]) {
        self.id = ULID().string
        self.word = word
        self.options = options
        self.correctAnswer = word.translation
    }
}
