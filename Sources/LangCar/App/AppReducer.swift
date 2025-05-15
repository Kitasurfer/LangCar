import Foundation
import ComposableArchitecture

public struct AppReducer: Reducer {
    public init() {}
    public var body: some Reducer<AppState, AppAction> {
        Reduce { state, action in
            switch action {
            case .loadSampleData:
                state.words = [
                    Word(original: "Haus", gender: .das, translation: "Дом", plural: "Häuser"),
                    Word(original: "Baum", gender: .der, translation: "Дерево", plural: "Bäume")
                ].identified
                return .none
            case let .addWord(word):
                state.words.append(word)
                return .none
            case let .removeWord(id):
                state.words.remove(id: id)
                return .none
            }
        }
    }
}
