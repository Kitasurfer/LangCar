#if canImport(SwiftUI)
import SwiftUI
import ComposableArchitecture

@main
struct LangCarApp: App {
    var body: some Scene {
        WindowGroup {
            DictionaryView(store: Store(initialState: .init()) {
                AppReducer()
            }.scope(state: \.dictionary, action: AppAction.dictionary))
        }
    }
}
#endif
