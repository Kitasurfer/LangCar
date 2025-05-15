import Foundation
import ComposableArchitecture

struct HomeState: Equatable {
    var wordOfTheDay: Word?
    var dailyGoal: Int = 10
    var wordsLearned: Int = 0
}
