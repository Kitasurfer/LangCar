import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var homeState = HomeState()
    var dictionaryState = DictionaryState()
    var flashcardsState = FlashcardState()
    var quizState = QuizState()
    var favoritesState = FavoritesState()
    var settingsState = SettingsState()
}
