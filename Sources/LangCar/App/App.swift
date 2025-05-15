import SwiftUI
import ComposableArchitecture

@main
struct LangCardsApp: App {
    let store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
