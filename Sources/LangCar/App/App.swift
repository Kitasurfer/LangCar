import SwiftUI
import ComposableArchitecture

struct LangCardsApp: App {
    let repository = WordRepository()
    let cloud: CloudSyncService? = nil
    
    var body: some Scene {
        WindowGroup {
            TabRootView(store: Store(initialState: AppState()) { 
                AppReducer(repository: repository)
            })
        }
    }
}
