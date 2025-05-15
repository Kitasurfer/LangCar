import ComposableArchitecture
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

public struct AddWordState: Equatable, Sendable {
    @BindingState public var original: String = ""
    @BindingState public var translation: String = ""
    @BindingState public var plural: String = ""
    @BindingState public var gender: GermanGender = .der
}

public enum AddWordAction: BindableAction, Equatable, Sendable {
    case saveTapped
    case cancelTapped
    case binding(BindingAction<AddWordState>)
    case delegate(Delegate)
    public enum Delegate: Equatable, Sendable { case saved(Word) }
}

public struct AddWordReducer: Reducer {
    public init() {}
    public var body: some Reducer<AddWordState, AddWordAction> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .saveTapped:
                guard !state.original.isEmpty, !state.translation.isEmpty else { return .none }
                let word = Word(original: state.original, gender: state.gender, translation: state.translation, plural: state.plural.isEmpty ? nil : state.plural)
                return .send(.delegate(.saved(word)))
            case .cancelTapped: return .none
            case .binding: return .none
            case .delegate: return .none
            }
        }
    }
}

#if canImport(SwiftUI)
public struct AddWordView: View {
    let store: StoreOf<AddWordReducer>
    public init(store: StoreOf<AddWordReducer>) { self.store = store }
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            NavigationStack {
                Form {
                    Section("Немецкое слово") {
                        TextField("Haus", text: vs.binding(\.$original))
                        Picker("Род", selection: vs.binding(\.$gender)) {
                            Text("der").tag(GermanGender.der)
                            Text("die").tag(GermanGender.die)
                            Text("das").tag(GermanGender.das)
                        }.pickerStyle(.segmented)
                        TextField("Мн. число (необязательно)", text: vs.binding(\.$plural))
                    }
                    Section("Перевод (русский)") {
                        TextField("Дом", text: vs.binding(\.$translation))
                    }
                }
                .navigationTitle("Добавить слово")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") { vs.send(.cancelTapped) }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Сохранить") { vs.send(.saveTapped) }
                            .disabled(vs.original.isEmpty || vs.translation.isEmpty)
                    }
                }
            }
        }
    }
}
#endif
