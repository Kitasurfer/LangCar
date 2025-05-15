import Foundation

enum HomeAction {
    case onAppear
    case wordOfTheDayLoaded(Word)
    case updateProgress(Int)
}
