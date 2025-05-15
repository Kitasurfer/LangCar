import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI

@main
struct LangCarApp: App {
    let repository = WordRepository()
    var body: some Scene {
        WindowGroup {
            TabRootView(store: Store(initialState: AppState()) { AppReducer(repository: repository) })
        }
    }
}

public struct TabRootView: View {
    let store: StoreOf<AppReducer>
    public var body: some View {
        TabView {
            DictionaryView(store: store.scope(state: \.dictionary, action: AppAction.dictionary))
                .tabItem { Label("Словарь", systemImage: "list.bullet") }
            FlashcardsView(store: store.scope(state: \.flashcards, action: AppAction.flashcards))
                .tabItem { Label("Карточки", systemImage: "rectangle.stack") }
        }
    }
}
#endif

public struct AppState: Equatable, Sendable {
    public var dictionary = DictionaryState()
    public var flashcards = FlashSessionState()
    public init() {}
}

public enum AppAction: Equatable, Sendable {
    case dictionary(DictionaryAction)
    case flashcards(FlashSessionAction)
}

public struct AppReducer: Reducer {
    let repository: WordRepositoryProtocol
    public init(repository: WordRepositoryProtocol) { 
        self.repository = repository 
    }
    public var body: some Reducer<AppState, AppAction> {
        Scope(state: \.dictionary, action: /AppAction.dictionary) { DictionaryReducer(repo: repository) }
        Scope(state: \.flashcards, action: /AppAction.flashcards) { FlashSessionReducer(repo: repository) }
    }
}
