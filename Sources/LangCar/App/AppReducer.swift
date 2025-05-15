import ComposableArchitecture

public struct AppReducer: Reducer {
    public init(repository: WordRepositoryProtocol = WordRepository()) {
        self.repository = repository
    }
    let repository: WordRepositoryProtocol
    public var body: some Reducer<AppState, AppAction> {
        Scope(state: \AppState.dictionary, action: /AppAction.dictionary) {
            DictionaryReducer(repository: repository)
        }
    }
}
