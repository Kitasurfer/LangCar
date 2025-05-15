import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI

@main
struct LangCarApp: App {
    let store = Store(initialState: AppState()) { AppReducer() }
    var body: some Scene { WindowGroup { RootView(store: store) } }
}

public struct RootView: View {
    let store: StoreOf<AppReducer>
    public var body: some View {
        DictionaryView(store: store.scope(state: \.dictionary, action: AppAction.dictionary))
    }
}
#endif

public struct AppState: Equatable, Sendable { 
    public var dictionary = DictionaryState() 
    public init() {}
}

public enum AppAction: Equatable, Sendable { 
    case dictionary(DictionaryAction) 
}

public struct AppReducer: Reducer {
    let repository: WordRepositoryProtocol
    public init(repository: WordRepositoryProtocol = WordRepository()) { 
        self.repository = repository 
    }
    public var body: some Reducer<AppState, AppAction> {
        Scope(state: \.dictionary, action: /AppAction.dictionary) {
            DictionaryReducer(repo: repository)
        }
    }
}
