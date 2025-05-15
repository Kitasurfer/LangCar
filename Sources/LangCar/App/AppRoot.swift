import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI

@main
struct LangCarApp: App {
    let repository = WordRepository()
    let cloud: CloudSyncService? = nil
    var body: some Scene {
        WindowGroup {
            TabRootView(store: Store(initialState: AppState()) { AppReducer(repository: repository) })
        }
    }
}

public struct TabRootView: View {
    let store: StoreOf<AppReducer>
    public init(store: StoreOf<AppReducer>) { self.store = store }
    public var body: some View {
        TabView {

            IfLetStore(
                store.scope(state: { $0.dictionary }, action: { AppAction.dictionary($0) })
            ) { DictionaryView(store: $0) }
            .tabItem { Label("Словарь", systemImage: "list.bullet") }


            IfLetStore(
                store.scope(state: { $0.flashcards }, action: { AppAction.flashcards($0) })
            ) { FlashcardsView(store: $0) }
            .tabItem { Label("Карточки", systemImage: "rectangle.stack") }


            IfLetStore(
                store.scope(state: { $0.roadmap }, action: { AppAction.roadmap($0) })
            ) { RoadMapView(store: $0) }
            .tabItem { Label("Карта", systemImage: "map") }


            IfLetStore(
                store.scope(state: { $0.settings }, action: { AppAction.settings($0) })
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
                .ifLet(\.dictionary, action: /AppAction.dictionary) { 
                    DictionaryReducer(repo: repository)
                }
                .ifLet(\.flashcards, action: /AppAction.flashcards) { 
                    FlashSessionReducer(repo: repository)
                }
                .ifLet(\.roadmap, action: /AppAction.roadmap) { 
                    RoadMapReducer()
                }
                .ifLet(\.race, action: /AppAction.race) { 
                    RaceReducer()
                }
                .ifLet(\.settings, action: /AppAction.settings) { 
                    SettingsReducer(cloud: cloud, repo: repository)
                }
        }
    }
}
#endif
