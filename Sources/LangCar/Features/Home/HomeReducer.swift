import Foundation
import ComposableArchitecture

struct HomeReducer: Reducer {
    struct State: Equatable {
        var wordOfTheDay: Word?
        var dailyGoal: Int = 10
        var wordsLearned: Int = 0
    }
    
    enum Action {
        case onAppear
        case wordOfTheDayLoaded(Word)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .wordOfTheDayLoaded(word):
                state.wordOfTheDay = word
                return .none
            }
        }
    }
}
