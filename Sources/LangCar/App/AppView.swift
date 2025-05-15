import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppReducer>
    
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Главная", systemImage: "house")
                }
            
            Text("Dictionary")
                .tabItem {
                    Label("Словарь", systemImage: "book")
                }
            
            Text("Flashcards")
                .tabItem {
                    Label("Карточки", systemImage: "square.stack")
                }
            
            Text("Quiz")
                .tabItem {
                    Label("Тесты", systemImage: "questionmark.circle")
                }
            
            Text("Settings")
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
}
