import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI

@main
struct LangCarApp: App {
    let repository = WordRepository()
    let cloud: CloudSyncService? = nil
    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, macOS 13.0, *) {
                NavigationStack {
                    StartView(store: Store(initialState: StartState()) { StartReducer() })
                }
            } else {
                NavigationView {
                    StartView(store: Store(initialState: StartState()) { StartReducer() })
                }
            }
        }
    }
}

public struct TabRootView: View {
    let store: StoreOf<AppReducer>
    public init(store: StoreOf<AppReducer>) { self.store = store }
    public var body: some View {
        TabView {

            IfLetStore(
                store.scope(state: \.dictionary, action: \.dictionary)
            ) { DictionaryView(store: $0) }
            .tabItem { Label("Словарь", systemImage: "list.bullet") }


            IfLetStore(
                store.scope(state: \.flashcards, action: \.flashcards)
            ) { FlashcardsView(store: $0) }
            .tabItem { Label("Карточки", systemImage: "rectangle.stack") }


            IfLetStore(
                store.scope(state: \.roadmap, action: \.roadmap)
            ) { RoadMapView(store: $0) }
            .tabItem { Label("Карта", systemImage: "map") }


            IfLetStore(
                store.scope(state: \.settings, action: \.settings)
            ) { SettingsView(store: $0) }
            .tabItem { Label("Настройки", systemImage: "gear") }
        }
    }
}

import CasePaths

@CasePathable
public enum AppAction: Equatable, Sendable {
    case dictionary(DictionaryAction)
    case flashcards(FlashSessionAction)
    case roadmap(RoadMapAction)
    case race(RaceAction)
    case settings(SettingsAction)
}

public struct AppReducer: Reducer {
    let repository: WordRepositoryProtocol
    let cloud: CloudSyncService?

    public init(repository: WordRepositoryProtocol, cloud: CloudSyncService? = nil) { 
        self.repository = repository
        self.cloud = cloud
    }

    public var body: some Reducer<AppState, AppAction> {

        let baseReducer = Reduce<AppState, AppAction> { state, action in
            switch action {

            default:
                return .none
            }
        }
        
        return CombineReducers {
            baseReducer
            

            Reduce<AppState, AppAction> { _, _ in .none }
                .ifLet(\.dictionary, action: \.dictionary) { 
                    DictionaryReducer(repo: repository)
                }
                .ifLet(\.flashcards, action: \.flashcards) { 
                    FlashSessionReducer(repo: repository)
                }
                .ifLet(\.roadmap, action: \.roadmap) { 
                    RoadMapReducer()
                }
                .ifLet(\.race, action: \.race) { 
                    RaceReducer()
                }
                .ifLet(\.settings, action: \.settings) { 
                    SettingsReducer(cloud: cloud, repo: repository)
                }
        }
    }
}
#endif
