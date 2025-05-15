import Foundation

struct QuizState: Equatable {
    var currentQuestion: QuizQuestion?
    var score: Int = 0
    var totalQuestions: Int = 10
}
