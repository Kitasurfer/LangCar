import Foundation
import ComposableArchitecture

struct AppReducer: Reducer {
    struct State: Equatable {
        var homeState = HomeState()
        var dictionaryState = DictionaryState()
        var flashcardsState = FlashcardState()
        var quizState = QuizState()
        var favoritesState = FavoritesState()
        var settingsState = SettingsState()
    }
    
    enum Action {
        case home(HomeAction)
        case dictionary(DictionaryAction)
        case flashcards(FlashcardAction)
        case quiz(QuizAction)
        case favorites(FavoritesAction)
        case settings(SettingsAction)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .home:
                return .none
            case .dictionary:
                return .none
            case .flashcards:
                return .none
            case .quiz:
                return .none
            case .favorites:
                return .none
            case .settings:
                return .none
            }
        }
    }
}
